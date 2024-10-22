clear all;
clc;
close all;
rosshutdown;
%% Start Dobot Magician Node
rosinit('192.168.27.1');

%% Start Dobot ROS
dobot = DobotMagicianRealMove();

%% Test Motion
%% Publish custom joint target
%Chip Pickup Code
chip_pickup = [0.7,0.83,1.4,0.0]
chip_waypoint = [0.0,0.0,0.5,0.0];
chip_placement = [0.0,1.2,0.7,0.0];

dobot.PublishTargetJoint(chip_waypoint);
pause(0.3)

%joint_target2 = [0.0,0.0,1.39,0.0];
%joint_target3 = [-0.32,0.0,0.89,2.2];
dobot.PublishTargetJoint(chip_pickup);

onOff = 1;
openClose = 1;
dobot.PublishToolState(onOff,openClose);
pause(0.3)
% chip placement

dobot.PublishTargetJoint(chip_waypoint);
pause(0.3)
dobot.PublishTargetJoint(chip_placement);
pause(4.5)
onOff = 0;
openClose = 0;
dobot.PublishToolState(onOff,openClose);

dobot.PublishTargetJoint(chip_waypoint);
%% 
%Card Pickup

card_pickup = [0.0,1.25,0.7,0.0]
card_pickup2 = [0.2,1.25,0.7,0.0]
card_waypoint = [0.0,0.0,0.5,0.0];

dobot.PublishTargetJoint(card_waypoint);
pause(0.5)

%pickup
dobot.PublishTargetJoint(card_pickup);
pause(2.0)
%suction on
onOff = 1;
openClose = 1;
dobot.PublishToolState(onOff,openClose);

pause(0.5)

card_check = [0.0,0.2,0.6,1.5];
dobot.PublishTargetJoint(card_check);
pause(0.5)
dobot.PublishTargetJoint(card_pickup);
pause(4.0)

onOff = 0;
openClose = 0;
dobot.PublishToolState(onOff,openClose);

dobot.PublishTargetJoint(card_waypoint);
pause(0.5)

dobot.PublishTargetJoint(card_waypoint);
pause(0.5)

%pickup
dobot.PublishTargetJoint(card_pickup2);
pause(2.0)
%suction on
onOff = 1;
openClose = 1;
dobot.PublishToolState(onOff,openClose);

pause(0.5)

card_check = [0.0,0.2,0.6,1.5];
dobot.PublishTargetJoint(card_check);
pause(0.5)
dobot.PublishTargetJoint(card_pickup2);
pause(4.0)

onOff = 0;
openClose = 0;
dobot.PublishToolState(onOff,openClose);

dobot.PublishTargetJoint(card_waypoint);
pause(0.5)

%% 
%Hit me

hitMe_waypoint = [0.0,0.0,0.5,0.0];
hitMe_high = [0.0,1.2,0.7,0.0];
hitMe_low = [0.0,1.25,0.72,0.0];

dobot.PublishTargetJoint(hitMe_waypoint);
pause(0.3);

dobot.PublishTargetJoint(hitMe_high);
pause(0.3);

dobot.PublishTargetJoint(hitMe_low);
pause(0.3);

dobot.PublishTargetJoint(hitMe_high);
pause(0.3);

dobot.PublishTargetJoint(hitMe_low);
pause(0.3);

dobot.PublishTargetJoint(hitMe_waypoint);
pause(0.3)

%% 
%stay

stay_waypoint = [0.0,0.0,0.5,0.0];
stay_left = [-0.05,1.1,0.7,0.0];
stay_right = [0.05,1.1,0.7,0.0];

dobot.PublishTargetJoint(stay_waypoint);
pause(0.3);

dobot.PublishTargetJoint(stay_left);
pause(0.3);

dobot.PublishTargetJoint(stay_right);
pause(0.3);

dobot.PublishTargetJoint(stay_left);
pause(0.3);

dobot.PublishTargetJoint(stay_right);
pause(0.3);

dobot.PublishTargetJoint(stay_left);
pause(0.3);

dobot.PublishTargetJoint(stay_waypoint);
pause(0.3);


%% chip stacking
chip_placement1 = [0.7,0.83,1.4,0.0];
chip_waypoint = [0.0,0.0,0.5,0.0];
chip_pickup1 = [0.0,1.2,0.7,0.0];

chip_placement2 = [0.7,0.80,1.4,0.0]
chip_pickup2 = [0.1,1.2,0.7,0.0];

dobot.PublishTargetJoint(chip_waypoint);
pause(0.3)

%%
test_Joint = [0,0.5,0.6,0.0];
dobot.PublishTargetJoint(test_Joint);

%% Publish custom end effector pose
end_effector_position = [0.2,0,0.05];
end_effector_rotation = [0,0,0];
dobot.PublishEndEffectorPose(end_effector_position,end_effector_rotation);

%% Turn on tool
% Open tool
onOff = 1;
openClose = 1;
dobot.PublishToolState(onOff,openClose);
%%
% Close tool
onOff = 1;
openClose = 0;
dobot.PublishToolState(onOff,openClose);

%% Turn off tool
onOff = 0;
openClose = 0;
dobot.PublishToolState(onOff,openClose);

%% Test ESTOP 
%% Send this first
for i = 0.1:0.05:1.0
    joint_target = [0.0,i,0.3,0.0];
    dobot.PublishTargetJoint(joint_target);
    pause(0.1);
end

%% When the robot is in motion, send this
dobot.EStopRobot();

%% Reinitilise Robot
dobot.InitaliseRobot();

%% Set Rail status to true
dobot.SetRobotOnRail(true);

%% Reinitialise robot. It should perform homing with the linear rail
dobot.InitaliseRobot();

%% Move the rail to the position of 0.1
dobot.MoveRailToPosition(0.1);

%% Set Rail status to false
dobot.SetRobotOnRail(false);

%% Reinitialise robot. It should not perform homing with the linear rail
dobot.InitaliseRobot();

%% Test IO
%% Get current IO status of all io pins on the robot
[ioMux, ioData] = dobot.GetCurrentIOStatus();

%% Set a particular pin a particular IO output
address = 1;
ioMux = 1;
data = 1;
dobot.SetIOData(address,ioMux, data);

%% Set particular pin a particular IO input
address = 1;
ioMux = 3;
data = 0;
dobot.SetIOData(address,ioMux,data);

%% Set a velocity to the conveyor belt
enableConveyor = true;
conveyorVelocity = 15000; % Note: this is ticks per second
dobot.SetConveyorBeltVelocity(enableConveyor,conveyorVelocity);

%% Turn off conveyor belt
enableConveyor = false;
conveyorVelocity = 0; % Note: this is ticks per second
dobot.SetConveyorBeltVelocity(enableConveyor,conveyorVelocity);