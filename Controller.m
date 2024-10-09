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
            self.player.model.animate([0,deg2rad(30),deg2rad(30),deg2rad(80),0]);
            self.dealer.model.animate(self.dealer.homeQ);
            self.chipPosition = [0,-0.6,0.64];
            self.chip = PlaceObject('chip.ply', self.chipPosition);
            drawnow();
        end

    %% Get Joint Values - currently under development
        function jointValue = GetJointState(self, robot)
            % Return the join value as q values, 1 x 7 matrix
            if robot == self.dealer
                jointValue = self.dealer.model.getpos();
            elseif robot == self.player
                    jointValue = self.player.model.getpos();
            else
                error('Invalid robot specified. Choose either player or dealer.');
            end
        end

%% Get Pose
        function pos = GetPos(self)
            % Return the position of the end effector as a 4x4 matrix
            pos = self.dealer.model.fkine(GetJointState(self));
        end
    end

    methods(Static)
%% Test Function
        function TestFunction(self)
            q = [0,0,0,0,0,0];
            self.dealer.model.teach(q)
            %self.dealer.TestMoveHitMeBot()
        end
%% Pick up chip basic funciton
        function PickUpChip(self)
            currentQ = GetJointState();
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

            currentQ = GetJointState(self);
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

            currentQ = GetJointState(self);
            newQ = self.dealer.model.ikcon(transl(self.chipPosition)*trotx(-pi/2)*transl(0,-0.085,0), currentQ);
            self.dealer.model.fkine(newQ)
            % Create Matrix of movement between start position and end
            % position with 25 iterations
            moveQ = jtraj(currentQ,newQ,25);
            for i =1:25
                % Animate the LinearUR3e robot through each q value
                self.dealer.model.animate(moveQ(i,:));
                delete(self.chip);
                self.chip = PlaceObject('chip.ply', transl((GetPos(self).T) * (transl(0,0.065,0)))');
                drawnow();
                pause(0.1)
            end


        end
%% Return To Home Function
        function ReturnToHome(self)

            % Currently working return to home

            % % Find the current position of the robot in q values
            % currentQ = GetJointState(self);
            % % Create a Jtraj matrix with 25 iterations from the current
            % % position to the safe/home position
            % moveQ = jtraj(currentQ,self.dealer.homeQ,25);
            % % Animate to the safe/home position
            % for i = 1:25
            %     self.dealer.model.animate(moveQ(i,:));
            %     drawnow();
            %     pause(0.1)
            % end

            % Atempting RMRC
            deltaT = 0.1; % Time Step
            epsilon = 1e-3 % Threshold for stopping condition
            maxSteps = 100000; % Maximum number of itterations

            % Find the current position of the robot and desired position
            currentQ = GetJointState(self)
            currentPos = GetPos(self);
            desiredQ = self.dealer.homeQ;
            desiredPos = self.dealer.model.fkine(desiredQ)
            for i = 1:maxSteps
                % Calculate the error in position and orientation
                errorPos = tr2delta(currentPos, desiredPos);
                % Check if the error is big enough to break out of the loop
                if norm(errorPos) < epsilon
                    break;
                end
                % Get the Jacobian at the current joint configuration
                j = self.dealer.model.jacob0(currentQ);
                % Compute the joint velocities using pseudoinverse of the
                % Jacobian
                lambda = 0.1; % Damping factor to avoid singularities
                qdot = pinv(j + lambda * eye(size(j))) * errorPos(:); % Joint Velocities
                % Update the currect join posiiotns using the caculated
                % join velocities
                currentQ = currentQ + qdot' * deltaT;
                % Animate the robot at the new joint configuration
                self.dealer.model.animate(currentQ);
                drawnow();
                pause(deltaT);
                % Update the current end effector pos
                currentPos = GetPos(self);
                i
            end          
        end
    end
end