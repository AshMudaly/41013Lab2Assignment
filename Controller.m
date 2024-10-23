classdef Controller < handle
%#ok<*NASGU>
%#ok<*NOPRT>
%#ok<*TRYNC>
    properties
        player % DoBot Robot Object
        dealer % HitMeBot Object
        hitMeHome % HitMeBot home q posiiton
        doBotHome % DoBotMagician home q position
        chip % Test property for chip
        chipPosition % Test property for chip position, initially only 1 pos
        
    end

    methods
        %% Contructor
        function self = Controller()
            hold on
            self.player = DobotMagician(transl(0,-0.2,0.45)*trotz(-pi/2));
            self.dealer = HitMeBot(transl(0,-1.4,0.45)*trotz(pi/2));
            self.player.homeQ = [0,deg2rad(0),deg2rad(0),deg2rad(80),0];
            self.player.model.animate(self.player.homeQ);
            self.dealer.model.animate(self.dealer.homeQ);
            self.chipPosition = [0,-0.6,0.64];
            self.chip = PlaceObject('chip.ply', self.chipPosition);
            drawnow();
        end

%% Get Joint Values - Return the join value as q values, 1 x 7 matrix or 1 x 5 matrix depending on the robot specified
% Called inside Controller using "self.GetJointState(self.player/dealer)"
% Called inside Main using "self.robots.GetJointState(self.robots.player/dealer)"
        function jointValue = GetJointState(self, robot)
            if robot == self.dealer
                jointValue = self.dealer.model.getpos();
            elseif robot == self.player
                jointValue = self.player.model.getpos();
            else
                error('Invalid robot specified. Choose either player or dealer.');
            end
        end

%% Get Pose - Return the position of the end effector as a 4x4 matrix
% Called inside Controller using "self.GetPos(self.player/dealer)"
% Called inside Main using "self.robots.GetPos(self.robots.player/dealer)"
        function pos = GetPos(self, robot)
            if robot == self.dealer
                jointValues = self.GetJointState(self.dealer);
                pos = self.dealer.model.fkine(jointValues).T;
            elseif robot == self.player
                jointValues = self.GetJointState(self.player);
                pos = self.player.model.fkine(jointValues).T;
            else
                error('Invalid robot specified. Choose either player or dealer.');
            end
        end

%% Basic Robot Movement
% Called inside Controller using "self.RobotMove(self.player/dealer, X, Y,
% Z, steps, Rotation)" input which robot you want to move, the x y and z coordinate
% and the number of steps it will take. currenty using jtraj
function RobotMove(self, robot, translation, steps)
            if robot == self.dealer
                currentQ = self.GetJointState(self.dealer);
                newQ = self.dealer.model.ikcon(translation, currentQ);
                self.dealer.model.fkine(newQ);
                % Create Matrix of movement between start position and end
                % position with 25 iterations
                moveQ = jtraj(currentQ,newQ,steps);
                for i =1:steps
                    % Animate the LinearUR3e robot through each q value
                    self.dealer.model.animate(moveQ(i,:));
                    drawnow();
                    pause(0.1)
                end
            elseif robot == self.player
                currentQ = self.GetJointState(self.player);
                newQ = self.player.model.ikcon(translation, currentQ);
                self.player.model.fkine(newQ)
                % Create Matrix of movement between start position and end
                % position with 25 iterations
                moveQ = jtraj(currentQ,newQ,steps)
                for i =1:steps
                    % Animate the LinearUR3e robot through each q value
                    self.player.model.animate(moveQ(i,:));
                    drawnow();
                    pause(0.1)
                end
            end
        end

%% Return To Home Function For Both Robots
% Called inside Controller using "self.ReturnToHome(self.player/dealer)"
% Called inside Main using "self.robots.ReturnToHome(self.robots.player/dealer)"
        function ReturnToHome(self, robot)
            
            % Currently working return to home without RMRC
            
            if robot == self.dealer
                % Find the current position of the robot in q values
                currentQ = self.GetJointState(self.dealer);
                % Create a Jtraj matrix with 25 iterations from the current
                % position to the safe/home position
                moveQ = jtraj(currentQ,self.dealer.homeQ,25);
                % Animate to the safe/home position
                for i = 1:25
                    self.dealer.model.animate(moveQ(i,:));
                    drawnow();
                    pause(0.1)
                end
            elseif robot == self.player
                % Find the current position of the robot in q values
                currentQ = self.GetJointState(self.player);
                % Create a Jtraj matrix with 25 iterations from the current
                % position to the safe/home position
                moveQ = jtraj(currentQ,self.player.homeQ,25);
                % Animate to the safe/home position
                for i = 1:25
                    self.player.model.animate(moveQ(i,:));
                    drawnow();
                    pause(0.1)
                end
            else
                error('Invalid robot specified. Choose either player or dealer.');
            end 
        end
%% Testing RMRC for Robot
%
%
        function RMRC(self)
            t = 5;             % Total time (s)
            deltaT = 0.1;      % Control frequency
            steps = t/deltaT;   % No. of steps for simulation
            delta = 2*pi/steps; % Small angle change
            epsilon = 0.1;      % Threshold value for manipulability/Damped Least Squares
            W = diag([1 1 1 0.1 0.1 0.1]);    % Weighting matrix for the velocity vector

            % 1.2) Allocate array data
            m = zeros(steps,1);             % Array for Measure of Manipulability
            qMatrix = zeros(steps,7);       % Array for joint anglesR
            qdot = zeros(steps,7);          % Array for joint velocities
            theta = zeros(3,steps);         % Array for roll-pitch-yaw angles
            xyz = zeros(3,steps);           % Array for x-y-z trajectory
            positionError = zeros(3,steps); % For plotting trajectory error
            angleError = zeros(3,steps);    % For plotting trajectory error

            currentT = self.GetPos(self.dealer)
            x = currentT(1,4)
            y = currentT(2,4)
            z = currentT(3,4)
            xyz(1,:) = lspb(x,x,steps);
            xyz(2,:) = lspb(y,y,steps);
            xyz(3,:) = lspb(z,1.0,steps);
            R = currentT(1:3, 1:3)
            eul = rotm2eul(R)
            yaw = eul(1)   % Rotation about the z-axis
            pitch = eul(2) % Rotation about the y-axis
            roll = eul(3)  % Rotation about the x-axis
            
            % suction cup down at home positons is roll = -pi/2, 0 for
            % pithc and yaw

            theta(1,:) = lspb(roll,-pi/2,steps);
            theta(2,:) = lspb(pitch,0,steps);
            theta(3,:) = lspb(yaw,0,steps);


            T = [rpy2r(theta(1,1),theta(2,1),theta(3,1)) xyz(:,1);zeros(1,3) 1]        % Create transformation of first point and angle
            q0 = zeros(1,7);                                                            % Initial guess for joint angles
            qMatrix(1,:) = self.dealer.model.ikcon(T,q0);                               % Solve joint angles to achieve first waypoint

            % 1.4) Track the trajectory with RMRC
            for i = 1:steps-1
                % UPDATE: fkine function now returns an SE3 object. To obtain the
                % Transform Matrix, access the variable in the object 'T' with '.T'.
                T = self.dealer.model.fkine(qMatrix(i,:)).T;                                         % Get forward transformation at current joint state
                deltaX = xyz(:,i+1) - T(1:3,4);                                         	% Get position error from next waypoint
                Rd = rpy2r(theta(1,i+1),theta(2,i+1),theta(3,i+1));                     % Get next RPY angles, convert to rotation matrix
                Ra = T(1:3,1:3);                                                        % Current end-effector rotation matrix
                Rdot = (1/deltaT)*(Rd - Ra);                                            % Calculate rotation matrix error
                S = Rdot*Ra';                                                           % Skew symmetric!
                linear_velocity = (1/deltaT)*deltaX;
                angular_velocity = [S(3,2);S(1,3);S(2,1)];                              % Check the structure of Skew Symmetric matrix!!
                deltaTheta = tr2rpy(Rd*Ra');                                            % Convert rotation matrix to RPY angles
                xdot = W*[linear_velocity;angular_velocity];                          	% Calculate end-effector velocity to reach next waypoint.
                J = self.dealer.model.jacob0(qMatrix(i,:));                             % Get Jacobian at current joint state
                m(i) = sqrt(det(J*J'));
                if m(i) < epsilon  % If manipulability is less than given threshold
                    lambda = (1 - m(i)/epsilon)*5E-2;
                else
                    lambda = 0;
                end
                invJ = inv(J'*J + lambda *eye(7))*J';                                   % DLS Inverse
                qdot(i,:) = (invJ*xdot)';                                               % Solve the RMRC equation (you may need to transpose the         vector)
                for j = 1:7                                                             % Loop through joints 1 to 6
                    if qMatrix(i,j) + deltaT*qdot(i,j) < self.dealer.model.qlim(j,1)                 % If next joint angle is lower than joint limit...
                        qdot(i,j) = 0; % Stop the motor
                    elseif qMatrix(i,j) + deltaT*qdot(i,j) > self.dealer.model.qlim(j,2)             % If next joint angle is greater than joint limit ...
                        qdot(i,j) = 0; % Stop the motor
                    end
                end
                qMatrix(i+1,:) = qMatrix(i,:) + deltaT*qdot(i,:);                       % Update next joint state based on joint velocities
                positionError(:,i) = xyz(:,i+1) - T(1:3,4);                               % For plotting
                angleError(:,i) = deltaTheta;                                           % For plotting
            end
            qMatrix
            for i =1:steps
                self.dealer.model.animate(qMatrix(i,:));
                drawnow();
                pause(0.1)
            end
            % all the plots for acuracy and singularity analysis
            % for i = 1:6
            %     figure(2)
            %     subplot(3,2,i)
            %     plot(qMatrix(:,i),'k','LineWidth',1)
            %     title(['Joint ', num2str(i)])
            %     ylabel('Angle (rad)')
            %     refline(0,self.dealer.model.qlim(i,1));
            %     refline(0,self.dealer.model.qlim(i,2));
            % 
            %     figure(3)
            %     subplot(3,2,i)
            %     plot(qdot(:,i),'k','LineWidth',1)
            %     title(['Joint ',num2str(i)]);
            %     ylabel('Velocity (rad/s)')
            %     refline(0,0)
            % end
            % 
            % figure(4)
            % subplot(2,1,1)
            % plot(positionError'*1000,'LineWidth',1)
            % refline(0,0)
            % xlabel('Step')
            % ylabel('Position Error (mm)')
            % legend('X-Axis','Y-Axis','Z-Axis')
            % 
            % subplot(2,1,2)
            % plot(angleError','LineWidth',1)
            % refline(0,0)
            % xlabel('Step')
            % ylabel('Angle Error (rad)')
            % legend('Roll','Pitch','Yaw')
            % figure(5)
            % plot(m,'k','LineWidth',1)
            % refline(0,epsilon)
            % title('Manipulability')

        end
    end

    methods(Static)
%% Pick up chip basic funciton - moves HitMeBot towards the chip and picks it up
% Called inside Controller using "self.PickUpChipDealer(self)"
% Called inside Main using "self.robots.PickUpChipDealer(self.robots)"
        function PickUpChipDealer(self)
            currentQ = self.GetJointState(self.dealer);
            newQ = self.dealer.model.ikcon(transl(self.chipPosition)*trotx(-pi/2)*transl(0,-0.085,0), currentQ);
            self.dealer.model.fkine(newQ)
            % Create Matrix of movement between start position and end
            % position with 25 iterations
            moveQ = jtraj(currentQ,newQ,25);
            for i =1:25
                % Animate the LinearUR3e robot through each q value
                self.dealer.model.animate(moveQ(i,:));
                drawnow();
                pause(0.1)
            end

            currentQ = self.GetJointState(self.dealer);
            newQ = self.dealer.model.ikcon(transl(self.chipPosition)*trotx(-pi/2)*transl(0,-0.065,0), currentQ);
            self.dealer.model.fkine(newQ)
            % Create Matrix of movement between start position and end
            % position with 25 iterations
            moveQ = jtraj(currentQ,newQ,25);
            for i =1:25
                % Animate the LinearUR3e robot through each q value
                self.dealer.model.animate(moveQ(i,:));
                drawnow();
                pause(0.1)
            end

            currentQ = self.GetJointState(self.dealer);
            newQ = self.dealer.model.ikcon(transl(self.chipPosition)*trotx(-pi/2)*transl(0,-0.085,0), currentQ);
            self.dealer.model.fkine(newQ)
            % Create Matrix of movement between start position and end
            % position with 25 iterations
            moveQ = jtraj(currentQ,newQ,25);
            for i =1:25
                % Animate the LinearUR3e robot through each q value
                self.dealer.model.animate(moveQ(i,:));
                delete(self.chip);
                self.chip = PlaceObject('chip.ply', transl((self.GetPos(self.dealer)) * (transl(0,0.065,0)))');
                drawnow();
                pause(0.1)
            end
        end

%% Hit Me Function - Moves DoBotMagician so it taps the table 
% Called inside Controller using "self.HitMe(self)"
% Called inside Main using "self.robots.HitMe(self.robots)"
        function HitMe(self)
            
            RobotMove(self, self.player, transl(-0.05,-0.35,0.73), 25);
            RobotMove(self, self.player, transl(-0.05,-0.35,0.72), 3);
            RobotMove(self, self.player, transl(-0.05, -0.35,0.73), 3);
            RobotMove(self, self.player, transl(-0.05,-0.35,0.72), 3);
            RobotMove(self, self.player, transl(-0.05, -0.35,0.73), 3);
            self.ReturnToHome(self.player);
        end 

%% Stand Function - Moves DoBotMagician so it waves the end effector over the cards 
% Called inside Controller using "self.Stand(self)"
% Called inside Main using "self.robots.Stand(self.robots)"
        function Stand(self)
            RobotMove(self, self.player, transl(0,-0.4,0.73), 25);
            RobotMove(self, self.player, transl(0.03,-0.4,0.73), 3);
            RobotMove(self, self.player, transl(-0.03,-0.4,0.73), 3);
            RobotMove(self, self.player, transl(0.03,-0.4,0.73), 3);
            RobotMove(self, self.player, transl(-0.03,-0.4,0.73), 3);
            RobotMove(self, self.player, transl(0.03,-0.4,0.73), 3);
            self.ReturnToHome(self.player);
        end

%% Pick up chip basic funciton - moves DoBotMagician towards the chip and picks it up
% Called inside Controller using "self.PickUpChipPlayer(self)"
% Called inside Main using "self.robots.PickUpChipPlayer(self.robots)"
        function PickUpChipPlayer(self)
            currentQ = self.GetJointState(self.player);
            newQ = self.player.model.ikcon(transl(self.chipPosition)*trotx(-pi/2)*transl(0,-0.085,0), currentQ);
            self.player.model.fkine(newQ)
            % Create Matrix of movement between start position and end
            % position with 25 iterations
            moveQ = jtraj(currentQ,newQ,25);
            for i =1:25
                % Animate the LinearUR3e robot through each q value
                self.player.model.animate(moveQ(i,:));
                drawnow();
                pause(0.1)
            end

            currentQ = self.GetJointState(self.player);
            newQ = self.player.model.ikcon(transl(self.chipPosition)*trotx(-pi/2)*transl(0,-0.065,0), currentQ);
            self.player.model.fkine(newQ)
            % Create Matrix of movement between start position and end
            % position with 25 iterations
            moveQ = jtraj(currentQ,newQ,25);
            for i =1:25
                % Animate the LinearUR3e robot through each q value
                self.player.model.animate(moveQ(i,:));
                drawnow();
                pause(0.1)
            end

            currentQ = self.GetJointState(self.player);
            newQ = self.player.model.ikcon(transl(self.chipPosition)*trotx(-pi/2)*transl(0,-0.085,0), currentQ);
            self.player.model.fkine(newQ)
            % Create Matrix of movement between start position and end
            % position with 25 iterations
            moveQ = jtraj(currentQ,newQ,25);
            for i =1:25
                % Animate the LinearUR3e robot through each q value
                self.player.model.animate(moveQ(i,:));
                delete(self.chip);
                self.chip = PlaceObject('chip.ply', transl((self.GetPos(self.player)) * (transl(0,0.065,0)))');
                drawnow();
                pause(0.1)
            end
        end     
    end
end
