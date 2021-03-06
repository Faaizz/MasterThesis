## Master Thesis - Alberto Franco

My name is Alberto Franco and I'm going to take my Master's degree in Automation Engineering at the Università degli Studi di Padova. I’m beginning my Master Thesis in the Laboratório de Automação e Robótica (LAR) at the Mechanical Department of the Universidade de Aveiro. My supervisor is Professor Vitor Santos.

The purpose of this blog is to, not only, document the progress of my master thesis, but also help me organize my work and my tasks for this project.

---------------------------------------------------------------------------------------------------
### Week 0 - (2nd October 2018 / 8th October 2018)
This week marks the beginning of my master thesis.

I started with the installation of the ROS environment (ROS Kinetic Kame) in my personal computer and I did all of the beginner and intermediate ROS tutorials at <http://wiki.ros.org/ROS/Tutorials> and C++/OpenCV tutorials.

I thought about the thesis proposals and I started to do research about it.

---------------------------------------------------------------------------------------------------
### Weeks 1&2 - (9th October 2018 / 22nd October 2018)
During these weeks I continued to practice with ROS and C++ doing simple exercises. Moreover these weeks were also dedicated to do some initial research and to write the preliminary report. This was important for me, not only, to introduce myself to the process of autonomous navigation and the projects that have already been developed in this field, but also, to organize my thoughts in tasks to come in this project.

[Preliminary Report](https://github.com/AlbertoFranco/MasterThesis/blob/master/Thesis_Latex/Preliminary%20Report/Preliminary_Report.pdf "Click here to open Preliminary Report.pdf")

---------------------------------------------------------------------------------------------------
### Week 3&4 - (23rd October 2018 / 5th November 2018)
During these weeks I started to implement the basic idea of ​​my project in MATLAB. I started by creating a simple nonlinear bicycle model to describe the dynamics of the ATLASCAR2. In these first examples I assumed that all the states are measurable. At the nominal operating point, the ATLASCAR2 drives east at a constant speed. I obtained a linear plant model at the nominal operating point and I have converted it into a discrete-time model to be used by the model predictive controller. The obstacles in this example are moving cars with the same size and shape of the ATLASCAR2. In the Model Predictive Control design I added different constraints on the throttle rate and on the steering angle rate and also I have specified mixed I/O constraints for obstacle avoidance maneuver. Here, I used an adaptive MPC controller because it handles the nonlinear vehicle dynamics more effectively than a traditional MPC controller. A traditional MPC controller uses a constant plant model. However, adaptive MPC allows me to provide a new plant model at each control interval. Then finally I have simulated the two different situations with only 1 moving obstacle and also with N moving obstacles (for simplicity the obstacles are in the middle of the center lane). For the collision avoidance with only 1 moving obstacle, I developed also the model in Simulink.

---------------------------------------------------------------------------------------------------
### Week 5 - (6th November 2018 / 12th November 2018)
In this week I continued to work in MATLAB adding some fundamental constraints in the MPC: in the Mixed I/O Constraints I specified an upper and a lower bound for the street limits, and also I have added a "fake" constraint if though no obstacle is detected at the nominal operating condition because it's not possible to change the dimensions of the constraint matrices at run time. In order to complicate the simulation with N obstacles I have made changes to the CustomConstraints so that the ATLASCAR2 can avoid the obstacle by overtaking it to the right: first with only one moving car and later I generalized the algorithm for N random (with respect to the number and the position) obstacles. In the animation, ATLASCAR2 can avoid obstacles by overcoming them on the right and on the left, deciding which is the best way to go.

---------------------------------------------------------------------------------------------------
### Weeks 6&7 - (13th November 2018 / 26th November 2018)
In these two weeks I tried to add curves by building a circular path. I found problems in tracking the reference. Probably the model I am using is not suitable for this purpose. So I started making a Simulink scheme to follow a curved line. Also in this case I have adopted an Adaptive MPC but the model considered is different (taking into account both the longitudinal and the lateral velocity).

---------------------------------------------------------------------------------------------------
### Week 8 - (27th November 2018 / 3rd December 2018)
This week I designed a lane-following controller based on the Lane Keeping Assist system developed by MATLAB, in which  the vehicle measures the lateral deviation and the relative yaw angle between the center line of a lane and the car. Instead of directly using Lane Keeping Assist system provided by MATLAB, I implemented an algorithm based on the Adaptive Model Predictive Control. In the previous week we had noticed that in the case of curves it was necessary to take into account both the longitudinal and the lateral velocity. A lane-following system manipulates both the longitudinal acceleration and front steering angle of the vehicle to  keep the lateral deviation and relative yaw angle small but also keep the longitudinal velocity close to a driver set velocity. The idea now is to take the two controllers designed to create a system that allows path tracking with moving obstacle avoidance based on the Adaptive Model Predictive Control. Moreover in this week I started to write a paper in which I formalized the problem and the solutions adopted. 

---------------------------------------------------------------------------------------------------
### Week 9 - (4th December 2018 / 10th December 2018)
In this week I started writing a paper where I reported theoretically the models used for both methods. In the problem of the lane following I put a disturbance on the dynamics of the sensors in order to verify the correct functioning of the adaptive MPC. I have also modified the constraints for the upper and lower bound of the street: I have simulated that at each step the constraints change slightly (error of the lateral measurement). The results found are consistent therefore the error in the case of the circular path is probably due to the initialization of the constraints.

[Paper](https://github.com/AlbertoFranco/MasterThesis/blob/master/Thesis_Latex/Paper/Paper.pdf "Click here to open Paper.pdf")

---------------------------------------------------------------------------------------------------
### Week 10 - (11th December 2018 / 17th December 2018)
During this week I have finished writing the first version of the paper. The following paragraphs have been added: theoretical background about the adaptive Model Predictive Control, Simulation Results for the Obstacle Avoidance and Simulation Results for the Lane Following. In addition, I adapted the Lane Following parameters to make them equal to those used in the Obstacle Avoidance algorithm. I have also tried to make simulations by considering different types of errors within the dynamics of the sensors, in particular on the longitudinal velocity, on the steering angle and finally on the yaw angle. Only one part of the results obtained have been reported in the paper. Finally I started to formalize the constraints related to obstacle avoidance in order to make them generic also for a circular path. During the Christmas holidays I will try to find a solution to this last problem.

[Paper](https://github.com/AlbertoFranco/MasterThesis/blob/master/Thesis_Latex/Paper/Paper.pdf "Click here to open Paper.pdf")

---------------------------------------------------------------------------------------------------
### Weeks 11&12&13 - (18th December 2018 / 7th January 2019)
In these weeks, during the Christmas holidays, I fixed the wrong parts of the paper and I added the correct references for the models that I used. Moreover, I started doing further simulations for the Lane Following using various types of paths and assuming that the sensors are affected by different errors: the simulated curves are those for car overtaking and a circular path. The results obtained validate the relative Simulink model.

---------------------------------------------------------------------------------------------------
### Week 14 - (8th January 2019 / 14th January 2019)
During this week I modified the constraints so that when the car meets 3 obstacles and can not overcome them because the road is busy. The constraints were imposed both on the maximum and minimum speed that the ATLASCAR2 can have and on the deceleration to be imposed that depends on the distance and velocity of the obstacles. In the MATLAB files is it possible to find a first simulation about this scenario.

[Simulation](https://github.com/AlbertoFranco/MasterThesis/blob/master/MATLAB/three_obstacles_no_overtaking/animation.avi "Click here to open animation.avi")

---------------------------------------------------------------------------------------------------
### Week 15 - (15th January 2019 / 21st January 2019)
This week I have modified the code related to the constraints in order to choose correctly the matrices E, F and G according to the scenario. In the case  there are three vehicles that prevent overtaking, the car with velocity equal to 20 m/s, slows down and adapts its speed to the one of the obstacles (supposed to be 8 m/s) remaining always behind. If, on the other hand, one of the obstacles increases its speed, the ATLASCAR2 that had previously slowed down, waits for the necessary space between the obstacles to perform the overtaking maneuver. During the overrun, the vehicle resumes the reference speed of 20 m/s and returns in the middle of the road. To allow both of these maneuvers it was necessary to insert new constraints relative to the position with respect to the x-axis. We have inserted an upper and lower bound which depend on the position of the ATLASCAR2 and the position of the slower obstacle. By inserting this constraint the vehicle modifies its velocity respecting the restrictions on its coordinates in x and y. Finally I made the graphs for the most important components of the simulation (speed, throttle, heading and steering angles, and the lateral position).

[Simulation_1](https://github.com/AlbertoFranco/MasterThesis/blob/master/MATLAB/three_obstacles_no_overtaking/animation1.avi "Click here to open animation1.avi")

[Simulation_2](https://github.com/AlbertoFranco/MasterThesis/blob/master/MATLAB/three_obstacles_no_overtaking/animation3.avi "Click here to open animation3.avi")

---------------------------------------------------------------------------------------------------
### Weeks 16/17/18 – (22nd January 2019 / 14th February)
In these weeks I finished and submitted a Paper concerning short-term path planning with multiple moving obstacle avoidance based on adaptive MPC. I implemented also model predictive control with softening constraints for trajectory tracking. In order to improve real-time robustness of the ATLASCAR2, a linearized tracking error model is used to predict system behaviours. The code is based on the following paper adapted to our scenario (adaptive MPC, real car model): 

[Trajectory tracking for wheeled mobile robots via model predictive control with softening constraints](https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=8259415 "Click here to open").

Moreover I wrote a short Report on the work done here in Aveiro during this 5 months.

[Final Report](https://github.com/AlbertoFranco/MasterThesis/blob/master/Thesis_Latex/FinalReport/FinalReport.pdf "Click here to open the final report")

---------------------------------------------------------------------------------------------------

