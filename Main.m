classdef Main < handle
    %#ok<*NASGU>
    %#ok<*NOPRT>
    %#ok<*TRYNC>
    
    properties
        gui % Gui Object
        robots % controller object
    end

    methods
        %% Constructor
        function self = Main()
            clf
            clc
            hold on
            self.Environment();
            self.robots = Controller();
            %self.gui = app1();
        end
    end
    
    methods(Static)
        %% Generate Environment
        function Environment()
            hold on
            xLimits = [-2, 2];
            yLimits = [-2, 2];
            zLimits = [0, 2];
            axis([xLimits, yLimits, zLimits]);

            azimuth = 225;
            elevation = 30;
            view(azimuth, elevation);

            blackjackTable = PlaceObject('blackjackTable.ply', [0, -0.6, -1.2]);
            blackjackVerts = [get(blackjackTable,'Vertices'), ones(size(get(blackjackTable,'Vertices'),1),1)]*trotx(pi/2);
            set(blackjackTable,'Vertices',blackjackVerts(:,1:3));

            fireExtinguisher = PlaceObject('fireExtinguisher.ply', [1.85, -1.8, 0]);
            fireExtinguisherVerts = [get(fireExtinguisher,'Vertices'), ones(size(get(fireExtinguisher,'Vertices'),1),1)];
            set(fireExtinguisher,'Vertices',fireExtinguisherVerts(:,1:3));

            barrier1 = PlaceObject('ropeBarrier.ply', [1.5, -1.3, 0]);
            barrier1Verts = [get(barrier1,'Vertices'), ones(size(get(barrier1,'Vertices'),1),1)]*trotz(pi/2);
            set(barrier1,'Vertices',barrier1Verts(:,1:3));

            barrier2 = PlaceObject('ropeBarrier.ply', [1.5, 1.3, 0]);
            barrier2Verts = [get(barrier2,'Vertices'), ones(size(get(barrier2,'Vertices'),1),1)]*trotz(pi/2);
            set(barrier2,'Vertices',barrier2Verts(:,1:3));

            camera = PlaceObject('camera.ply', [1.5, -0.9, -2]);
            cameraVerts = [get(camera,'Vertices'), ones(size(get(camera,'Vertices'),1),1)]*troty(pi/2);
            set(camera,'Vertices',cameraVerts(:,1:3));

            eStop = PlaceObject('emergencyStopWallMounted.ply', [0,-1.95,1]);
            eStopVerts = [get(eStop,'Vertices'), ones(size(get(eStop,'Vertices'),1),1)] * trotz(-pi/2);
            set(eStop,'Vertices',eStopVerts(:,1:3))
            

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

            surf([1.6,1.2;1.6,1.2] ...
                ,[-2,-2;-2,-2] ...
                ,[1.5,1.5;1.1,1.1] ...
                ,'CData',imread('under18sign.jpg') ...
                ,'FaceColor','texturemap');

            surf([-1.2,-1.6;-1.2,-1.6] ...
                ,[-2,-2;-2,-2] ...
                ,[1.5,1.5;1.1,1.1] ...
                ,'CData',imread('noFoodOrDrink.jpg') ...
                ,'FaceColor','texturemap');
        end
    end
end
