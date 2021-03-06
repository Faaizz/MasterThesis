clear all
close all
clc

%% ATLASCAR2 - Moving Obstacle Avoidance based on MPC

car = struct;
road = struct;
obstacle = struct;

%% Vehicle model

% Parameters definition
car.length = 5;                 % Length of the ATLASCAR2
car.width = 2;                  % Witdh of the ATLASCAR2
car.V = 20;                     % Constant speed of the ATLASCAR2
car.x0 = [0; 0; 0; car.V];      % Initial conditions
car.u0 = [0; 0];
Ts = 0.02;                      % Sampling time

% Obtain a linear plant model at the nominal operating point and convert it
% into a discrete-time model to be used by the model predictive controller.
[Ad,Bd,Cd,Dd,U,Y,X,DX] = ATLASCAR2ModelDT(Ts,car.x0,car.u0);

dsys = ss(Ad,Bd,Cd,Dd,'Ts',Ts);          % State space
dsys.InputName = {'Throttle','Delta'};   % Input u
dsys.StateName = {'X','Y','Theta','V'};  % State x
dsys.OutputName = dsys.StateName;        % Output y   

%% Road and Obstacle Information

road.lanes = 3;         % The road is straight and has 3 lanes.
road.laneWidth = 4;     % Each lane is |4| meters wide.

obstacle.length = 5;    % The obstacle in this example is a moving car 
obstacle.width = 2;     % with the same size and shape of the ATLASCAR2

obstacle.X = 50;        % Initial position of the obstacle (in this example  
obstacle.Y = 0;         % the obstacle is DYNAMIC)    

% Virtual safe zone around the obstacle
obstacle.safeDistanceX = obstacle.length; % Length equal to two car lengths
obstacle.safeDistanceY = road.laneWidth;  % Width equal to two lane widths.
obstacle = obstacleGenerateObstacleGeometryInfo(obstacle);

% Assume that the lidar device can detect an obstacle 30
% meters in front of the ATLASCAR2.
obstacle.DetectionDistance = 30;

%% Plot initial condition

% ATLASCAR2 - Green with black boundary
% Horizontal lanes - Dashed black lines
% Obstacle/Car - Red with with black boundary
% Safe zone - Dashed red boundary.

f = obstaclePlotInitialCondition(car, obstacle, road);

%% MPC design

% MPC object: sampling time Ts, Prediction Horizon 10, Control Horizon 2
status = mpcverbosity('off');
mpcobj = mpc(dsys);

% Set the values of the prediction horizon and the control horizon
mpcobj.PredictionHorizon = 25;   % number of steps = 0.5 seconds
mpcobj.ControlHorizon = 5;

%% Constraints and Weights

% To prevent the ATLASCAR2 from accelerating or decelerating too quickly, 
% add a hard constraint of 0.2 (m^2/sec) on the throttle rate of change.
mpcobj.ManipulatedVariables(1).RateMin = -0.2; 
mpcobj.ManipulatedVariables(1).RateMax = 0.2;

% add a hard constraint of 6 degrees per sec on the steering angle rate of change.
mpcobj.ManipulatedVariables(2).RateMin = -pi/30;
mpcobj.ManipulatedVariables(2).RateMax = pi/30;

% Scale the throttle and steering angle by their respective operating ranges.
mpcobj.ManipulatedVariables(1).ScaleFactor = 2;
mpcobj.ManipulatedVariables(2).ScaleFactor = 0.2;

% Choose the Y position and velocity by setting the weights of the other 
% two outputs (X and theta) to zero
mpcobj.Weights.OutputVariables = [0 1 0 1];

% Update the controller with the nominal operating condition
mpcobj.Model.Nominal = struct('U',U,'Y',Y,'X',X,'DX',DX);

%% Specify Mixed I/O Constraints for Obstacle Avoidance Maneuver

% E*u + F*y <= G where u is the manipulated variable vector and y is the output
% variable vector. You can update the constraint matrices E, F, and G when 
% the controller is running.

% The first constraint is an upper bound on y
E1 = [0 0];
F1 = [0 1 0 0]; 
G1 = road.laneWidth*road.lanes/2;

% The second constraint is a lower bound on y
E2 = [0 0];
F2 = [0 -1 0 0]; 
G2 = road.laneWidth*road.lanes/2;

% The third constraint is for obstacle avoidance. Even though no obstacle
% is detected at the nominal operating condition, you must add a "fake"
% constraint here because you cannot change the dimensions of the
% constraint matrices at run time. For the fake constraint, use a
% constraint with the same form as the second constraint.
E3 = [0 0];
F3 = [0 -1 0 0]; 
G3 = road.laneWidth*road.lanes/2;

% Specify the mixed input/output constraints in the controller using the
% |setconstraint| function.
setconstraint(mpcobj,[E1;E2;E3],[F1;F2;F3],[G1;G2;G3]);

%% Simulation

ref = [0 0 0 car.V];               % Constant reference signal 

x = car.x0;                        % State initialization
u = car.u0;                        % Input initialization             
egoStates = mpcstate(mpcobj);      % Controller states inizialization

T = 0:Ts:5;                        % Simulation time

% Log simulation data for plotting
saveSlope = zeros(length(T),1);         
saveIntercept = zeros(length(T),1);
ympc = zeros(length(T),size(Cd,1));
umpc = zeros(length(T),size(Bd,2));

% Run the simulation
for k = 1:length(T)
    % Obtain new plant model and output measurements for interval |k|.
    [Ad,Bd,Cd,Dd,U,Y,X,DX] = ATLASCAR2ModelDT(Ts,x,u);
    measurements = Cd * x + Dd * u;
    ympc(k,:) = measurements';
    
    % Create Obstacle Dynamics
    obstacle.X(k+1) = obstacle.X(k)+0.1;
    % Safe zone for the plot
    flSafeX(k) = obstacle.X(k)+obstacle.safeDistanceX;
    frSafeX(k) = obstacle.X(k)+obstacle.safeDistanceX;
    rlSafeX(k) = obstacle.X(k)-obstacle.safeDistanceX; 
    rrSafeX(k) = obstacle.X(k)-obstacle.safeDistanceX; 
    
    % Virtual safe zone around the obstacle
    obstacle = obstacleGenerateObstacleGeometryInfo(obstacle);  
    
    % Determine whether the vehicle sees the obstacle, and update the mixed
    % I/O constraints when obstacle is detected.
    detection = obstacleDetect(x,obstacle,road.laneWidth);
    [E,F,G,saveSlope(k),saveIntercept(k)] = ...
        obstacleComputeCustomConstraint(x,detection,obstacle,road.laneWidth,road.lanes); 
   
    % Prepare new plant model and nominal conditions for adaptive MPC.
    newPlant = ss(Ad,Bd,Cd,Dd,'Ts',Ts);
    newNominal = struct('U',U,'Y',Y,'X',X,'DX',DX);
    
    % Prepare new mixed I/O constraints.
    options = mpcmoveopt;
    options.CustomConstraint = struct('E',E,'F',F,'G',G);
    
    % Compute optimal moves using the updated plant, nominal conditions,
    % and constraints.
    [u,Info] = mpcmoveAdaptive(mpcobj,egoStates,newPlant,newNominal,...
        measurements,ref,[],options);
    umpc(k,:) = u';
    
    % Update the plant state for the next iteration |k+1|.
    x = Ad * x + Bd * u;
end

mpcverbosity(status);

%% Results
% Plot the trajectory of the ATLASCAR2 (blue line) and the third mixed
% I/O constraints (dashed green lines) during the obstacle avoidance
% maneuver.
% figure(f)
% for k = 1:length(saveSlope)
%     X = [0;50;100];
%     Y = saveSlope(k)*X + saveIntercept(k);
%     line(X,Y,'LineStyle','--','Color','g' )
% end    
plot(ympc(:,1),ympc(:,2),'-b');
% axis([0 ympc(end,1) -road.laneWidth*road.lanes/2 road.laneWidth*road.lanes/2]) % reset axis

%% Animation
% writerObj = VideoWriter('animation.avi');
% writerObj.FrameRate = 1/Ts; 
% open(writerObj);
for k = 1:length(saveSlope)  
    hold on 
    grid on
    grid minor
    % ATLASCAR2 green rectangle
    p = patch([ympc(k,1)-car.length/2 ympc(k,1)-car.length/2 ympc(k,1)+car.length/2 ympc(k,1)+car.length/2], [ympc(k,2)-car.width/2, ympc(k,2)+car.width/2, ympc(k,2)+car.width/2, ympc(k,2)-car.width/2], [0 1 0]);
    rotate(p, [0 0 1], rad2deg(asin(ympc(k,3))), [ympc(k,1)-car.length/2 ympc(k,2)-car.width/2 0]);
    
    % Obstacle with their safe zone
    o = patch([obstacle.X(k)-obstacle.length/2 obstacle.X(k)-obstacle.length/2 obstacle.X(k)+obstacle.length/2 obstacle.X(k)+obstacle.length/2], [obstacle.Y-obstacle.width/2 obstacle.Y+obstacle.width/2 obstacle.Y+obstacle.width/2 obstacle.Y-obstacle.width/2], [1 0 0]);
    safe = patch([flSafeX(k) frSafeX(k) rlSafeX(k) rrSafeX(k)],[obstacle.flSafeY obstacle.frSafeY obstacle.rrSafeY obstacle.rlSafeY],'--');
    safe.FaceColor='none';
    safe.EdgeColor='[1 0 0]';
    safe.LineStyle='--';

     %frame = getframe(gcf); 
     %writeVideo(writerObj, frame);
     %%print('figure\overtaking_end','-dpdf','-r0'); 
    pause(80/car.V/length(T))
    delete(p)
    delete(o)
    delete(safe)
end
% hold off
% close(writerObj);
close(f);
% print -sMovingObstacleAvoidanceMPC -dpdf MovingObstacleAvoidance.pdf
% movefile('MovingObstacleAvoidance.pdf','figure')
