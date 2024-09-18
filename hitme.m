clc;
clear all;
clf;

% Initialize Robot
r = DobotMagician;
r.model.base = troty(pi/2) * trotz(pi/2)  * transl(0.5, 0.75, 0.8);


qNow = r.model.getpos();

% Set workspace limits
xLimits = [-8, 8]; % X-axis limits
yLimits = [-8, 8]; % Y-axis limits
zLimits = [0, 3.5];  % Z-axis limits

axis([xLimits, yLimits, zLimits]);
% Example angles
azimuth = 45;  % View from 45 degrees around the z-axis
elevation = 30; % View from 30 degrees up from the x-y plane

% Set the view
view(azimuth, elevation);


%Spawning Object:
%Floor
hold on;
surf([-7, -7; 7, 7], [-7, 7; -7, 7], [0, 0; 0, 0], 'CData', imread('concrete.jpg'), 'FaceColor', 'texturemap');

%Walls
surf([-7, 7; -7, 7], [7, 7; 7, 7], [0, 0; 7, 7], 'CData', imread('water.jpg'), 'FaceColor', 'texturemap');

% Wall 2 (Left wall)
surf([-7, -7; -7, -7], [-7, 7; -7, 7], [0, 0; 7, 7], 'CData', imread('matt.jpg'), 'FaceColor', 'texturemap');

% Wall 3 (Right wall)
surf([7, 7; 7, 7], [-7, 7; -7, 7], [0, 0; 7, 7], 'CData', imread('city.jpg'), 'FaceColor', 'texturemap');


% Position of Fire Extinguisher
PlaceObject('fireExtinguisher.ply',[2, -4 ,0]);

% Position of Fence
PlaceObject('fenceAssemblyGreenRectangle4x8x2.5m.ply',[2.5, 1.5, -0.5]);

% Position of Emergency Stop Button
objeStop = PlaceObject('emergencyStopWallMounted.ply', [2, 6.9, 2.5]);
vertices = get(objeStop, 'Vertices');
position = [2, 6.9, 2.5]; % Update with actual position if necessary
centered = vertices - position;
rotationMatrix = trotz(pi);
transformed = (rotationMatrix(1:3, 1:3) * centered')';
set(objeStop, 'Vertices', transformed + position);

% Position of Suprvisor

%%PlaceObject('HumanDummy.ply', [1,6.5,0]);
objSupie = PlaceObject('HumanDummy.ply', [1, 6.5, 0]);
vertices = get(objSupie, 'Vertices');
position = [2, 6.5, 0]; % Update with actual position if necessary
centered = vertices - position;
rotationMatrix = trotz(pi);
transformed = (rotationMatrix(1:3, 1:3) * centered')';
set(objSupie, 'Vertices', transformed + position);


% Position of Worker
% Maximum 1 operator inside the area of operation, just in case
% the button needs to be pressed
PlaceObject('HumanDummy.ply', [4, 1, 0]);

PlaceObject('Table.ply', [0, 0, 0.35]);
PlaceObject('Table.ply', [0, 0.75, 0.35]);

% Define Initial and Final Brick Positions
initialBricks = [
    0.75, 1, 0.75;
    0.65, 1, 0.75;
    0.55, 1, 0.75;
    0.45, 1, 0.75;
    0.35, 1, 0.75;
    0.25, 1, 0.75;
    0.15, 1, 0.75;
    0.05, 1, 0.75;
    -0.05, 1, 0.75
    ];

finalBricks = [
    0, 0, 0.75;%
    -0.15, 0, 0.75;
    0, 0, 0.8;%
    -0.15, 0, 0.775;
    0, 0, 0.775;%
    0.15, 0, 0.8;
    -0.15, 0, 0.8;
    0.15, 0, 0.75;
    0.15, 0, 0.775;
    ];

% Place initial bricks
brickObjs = arrayfun(@(i) PlaceObject('HalfSizedRedGreenBrick.ply', initialBricks(i, :)), 1:9, 'UniformOutput', false);

% Initialize trajectory parameters
steps = 50;
pauseTime = 0.01;

% Directly move the end-effector to the brick and final positions
for i = 1:9
    % Step 1: Move to the position above the initial brick
    targetPos = initialBricks(i, :);
    qStart = r.model.getpos;

    %%qWay = [0, pi/2, 0, 0, 0, 0, 0];
    %%jtraj

    % Move above the brick by raising the Z position
    targetPosRaised = targetPos + [0, 0, 0.5];
    T_targetRaised = transl(targetPosRaised) * troty(pi);

    % Calculate the joint positions for the raised position
    qTargetRaised = r.model.ikcon(T_targetRaised, qStart);
    qMatrixRaised = jtraj(qStart, qTargetRaised, steps);
    MoveToBrick(r, qMatrixRaised, pauseTime);  % Animate movement

    % Step 2: Lower to the brick position
    T_target = transl(targetPos) * troty(pi);
    qTarget = r.model.ikcon(T_target, qTargetRaised);
    qMatrix = jtraj(qMatrixRaised(end, :), qTarget, steps);
    MoveToBrick(r, qMatrix, pauseTime);  % Animate movement

    % Simulate "picking up" the brick
    delete(brickObjs{i});

    % Step 3: Move to the raised final brick position
    finalPos = finalBricks(i, :);
    finalPosRaised = finalPos + [0, 0, 0.05];  % Final raised position
    T_finalRaised = transl(finalPosRaised) * troty(pi);

    qTargetFinalRaised = r.model.ikcon(T_finalRaised, qTarget);
    qMatrixFinalRaised = jtraj(qTarget, qTargetFinalRaised, steps);
    MoveToBrick(r, qMatrixFinalRaised, pauseTime);  % Animate movement

    % Place the brick at the final position
    brickObjs{i} = PlaceObject('HalfSizedRedGreenBrick.ply', finalPos);
end

    

% Optimized MoveToBrick Function
function MoveToBrick(r, qTraj, pauseTime)
for i = 1:size(qTraj, 1)
    q = qTraj(i, :);
    r.model.animate(q);
    pause(pauseTime);
end
end

% Plot the Robot in the final position
r.PlotAndColourRobot();
pause;

% Test Script
% Define workspace limits
xLimits = [-8, 8];
yLimits = [-8, 8];
zLimits = [0, 3.5];

% Initialize the robot (assuming `r` is an instance of LinearUR3e)
% Create the VolClass instance
vol = VolClass(r, xLimits, yLimits, zLimits);

% Generate and plot the point cloud
numSamples = 1000; % Number of samples for the point cloud
vol.createPointCloud(numSamples);
