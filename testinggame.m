% Main.m
% Launch the Blackjack GUI and start the game

% Create an instance of the GUI
app = GuiTesting();

% Pause briefly to allow the GUI to initialize fully
pause(0.5);

% Create an instance of the BlackjackTest game, passing in the GUI instance
game = BlackjackTest();

% Start the game loop
game.play();