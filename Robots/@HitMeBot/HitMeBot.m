classdef HitMeBot < RobotBaseClass
    %% HitMeBot
    %This is a copy of the DoBotMagician robot and modifying it for our
    %6DOF robot

    properties(Access =public)   
        plyFileNameStem = 'HitMeBot';
        
    end

    methods (Access = public) 
%% Constructor 
        function self = HitMeBot(baseTr)
			self.CreateModel();
            if nargin == 1			
				self.model.base = self.model.base.T * baseTr;
            end
            self.name = 'HitMeBot'
            self.homeQ  = [0,pi/4,0,-pi/4,0,0,0];
            self.PlotAndColourRobot();
            %self.animate(homeQ);
        end

%% CreateModel
        function CreateModel(self)       
            link(1) = Link('d',0.2,'a',0.1,'alpha',pi/2,'offset',0,'qlim',[deg2rad(-180),deg2rad(180)]);
            link(2) = Link('d',0,'a',0.1,'alpha',0,'offset',0,'qlim',[deg2rad(-180),deg2rad(180)]);
            link(3) = Link('d',0,'a',0.1,'alpha',0,'offset',0,'qlim',[deg2rad(-180),deg2rad(180)]);
            link(4) = Link('d',0,'a',0.1,'alpha',pi/2,'offset',0,'qlim',[deg2rad(-180),deg2rad(180)]);
            link(5) = Link('d',0.1,'a',0,'alpha',-pi/2,'offset',0,'qlim',[deg2rad(-180),deg2rad(180)]);
            link(6) = Link('d',0,'a',0,'alpha',pi/2,'offset',pi/2,'qlim',[deg2rad(-180),deg2rad(180)]);
            link(7) = Link('d',0.1,'a',0,'alpha',0,'offset',0,'qlim',[deg2rad(-180),deg2rad(180)]);

            self.model = SerialLink(link,'name',self.name);
        end   
    end
    
    methods

%% Test Move HitMeBot
    function TestMoveHitMeBot(self)
            qPath = jtraj(self.model.qlim(:,1)',self.model.qlim(:,2)',50);                       
            for i = 1:50                
                self.model.animate(qPath(i,:));
                hold on;
                pause(0.2);
            end
        end
    end
end