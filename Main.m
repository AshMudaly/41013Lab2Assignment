classdef Main < handle
    %#ok<*NASGU>
    %#ok<*NOPRT>
    %#ok<*TRYNC>
    
    properties
        gui % Gui Object
        game % Blakcjack game engine object
    end

    methods
        %% Constructor
        function self = Main()
            clf
            clc
            hold on
            self.Environment();
<<<<<<< HEAD
            %self.game = BlackjackTest();
            self.gui = app1();
=======
            self.robots = Controller();
            self.startBlackjackGame();
        end
        
        %% Method to start the Blackjack game and GUI
        function startBlackjackGame(~)
            % Create an instance of your BlackjackTest class
            game = BlackjackTest();

            % Create an instance of the app1 GUI
            myApp = app1(); 

            % Start the game loop
            game.play(myApp);  % Pass the app instance to the play method
>>>>>>> 19110b3b6ea5bb5816aff4de77d1f2f717b9fffe
        end
    end
    
    methods(Static)
        %% basic game
        %simple game to demonstrate betting and the robots moving from the
        %GUI
        function BasicGame(self)
            
        end
        %% Generate Environment
        function Environment()
            hold on
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
        
        function BetAndReturn(self)
            self.robots.PlayerBet(self.robots)
            self.robots.PickUpChipDealer(self.robots)
            self.robots.HitMe(self.robots)
            self.robots.DealCard(self.robots)
            self.robots.PickUpCardPlayer(self.robots)
            self.robots.Stand(self.robots)
            self.robots.DealChip(self.robots)
            self.robots.PickUpChipPlayer(self.robots)
        end
    end
end
