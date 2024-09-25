classdef Main < handle
%#ok<*NASGU>
%#ok<*NOPRT>
%#ok<*TRYNC>
    properties
        player % DoBot Robot Object
        dealer % HitMeBot Object
        HitMeHome % HitMeBot home q posiiton
        DoBotHome % DoBotMagician home q position
        
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
            qTest = [0,deg2rad(30),deg2rad(30),deg2rad(80),0];
            self.player.model.animate(qTest);
            drawnow();
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
        function TestFunction(self)
            q = [0,0,0,0,0,0];
            self.dealer.model.teach(q)
            %self.dealer.TestMoveHitMeBot()
        end
    end
end
