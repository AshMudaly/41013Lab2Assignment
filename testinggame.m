% Main file to run the Blackjack game
function testinggame()
    % Create an instance of your BlackjackTest class
    game = BlackjackTest();

    % Create an instance of the app1 GUI
    myApp = app1(); 

    % Start the game loop
     game.play(myApp);  % Pass the app instance to the play method
end
