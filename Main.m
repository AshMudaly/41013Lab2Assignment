classdef Main < handle
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
        function self = Main()
            clf
            clc
            hold on
            self.Environment();
            self.player = DobotMagician(transl(0,-0.2,0.45)*trotz(-pi/2));
            self.dealer = HitMeBot(transl(0,-1.4,0.45)*trotz(pi/2));
            self.player.model.animate([0,deg2rad(30),deg2rad(30),deg2rad(80),0]);
            self.dealer.model.animate(self.dealer.homeQ);
            self.chipPosition = [0,-0.6,0.64];
            self.chip = PlaceObject('chip.ply', self.chipPosition);
            drawnow();
        end

    %% Get Joint Values
        function jointValue = GetJointState(self)
            % Return the join value as q values, 1 x 7 matrix
            jointValue = self.dealer.model.getpos();
        end

%% Get Pose
        function pos = GetPos(self)
            % Return the position of the end effector as a 4x4 matrix
            pos = self.dealer.model.fkine(GetJointState(self));
        end
    end

    methods(Static)
        %% Generate Environment
        function Environment()
            xLimits = [-2, 2];
            yLimits = [-2, 2];
            zLimits = [0, 2];
            axis([xLimits, yLimits, zLimits]);

            azimuth = 225;
            elevation = 30;
            view(azimuth, elevation)

            blackjackTable = PlaceObject('blackjackTable.ply', [0, -0.6, -1.2]);
            blackjackVerts = [get(blackjackTable,'Vertices'), ones(size(get(blackjackTable,'Vertices'),1),1)]*trotx(pi/2);
            set(blackjackTable,'Vertices',blackjackVerts(:,1:3))

            
            dealerChip = PlaceObject('dealerChip.ply', [0,-1.15,0.64]);

            stoolPositions = [0,0,-0.2;
                0.423,0,-0.294;
                -0.423,0,-0.294;
                0.766,0,-0.557;
                -0.766,0,-0.557;
                0.966,0,-0.941;
                -0.966,0,-0.941;
                0,0,-1.4];

            stools = cell(size(stoolPositions,1), 1);

            for i = 1:size(stoolPositions,1)
                stools{i} = PlaceObject('stool.ply', stoolPositions(i, :));
                stoolVerts = [get(stools{i},'Vertices'), ones(size(get(stools{i},'Vertices'),1),1)]*trotx(pi/2);
                set(stools{i},'Vertices',stoolVerts(:,1:3))
            end

            surf([-2,-2;2,2] ...
                ,[2,-2;2,-2] ...
                ,[0,0;0,0] ...
                ,'CData',imread('floor.jpg') ...
                ,'FaceColor','texturemap');
            surf([2,-2;2,-2] ...
                ,[-2,-2;-2,-2] ...
                ,[2,2;0,0] ...
                ,'CData',imread('casinoWall.jpg') ...
                ,'FaceColor','texturemap');
            surf([2,2;2,2] ...
                ,[2,-2;2,-2] ...
                ,[2,2;0,0] ...
                ,'CData',imread('darkRedBrickWall.jpg') ...
                ,'FaceColor','texturemap');
        end
%%
        function TestFunction(self)
            q = [0,0,0,0,0,0];
            self.dealer.model.teach(q)
            %self.dealer.TestMoveHitMeBot()
        end
%% Pick up chip basic funciton
        function PickUpChip(self)
            currentQ = GetJointState(self);
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
            % Find the current position of the robot in q values
            currentQ = GetJointState(self);
            % Create a Jtraj matrix with 25 iterations from the current
            % position to the safe/home position
            moveQ = jtraj(currentQ,self.dealer.homeQ,25);
            % Animate to the safe/home position
            for i = 1:25
                self.dealer.model.animate(moveQ(i,:));
                drawnow();
                pause(0.1)
            end
        end
    end
end
