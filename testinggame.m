% In a new script or command window
clc;
clear all;
close; 
% 
 g = BlackjackTest();  % Create an instance of the BlackjackTest class
 g.play();             % Start the game
 app.BlackjackGame = BlackjackTest(app1);

% gui = guifunctionsample();
% gui.play();
% Initialization and deal initial hands
% function startupFcn(app)
%     app.BlackjackGame = BlackjackTest();  % Initialize Blackjack game
%     app.BlackjackGame.balance = 100;  % Set starting balance
%     app.bet = 10;  % Set default bet
%     app.playerBust = false;
% 
%     % Deal initial hands
%     [app.playerHand, app.BlackjackGame] = app.BlackjackGame.dealCard([], 2);
%     [app.dealerHand, app.BlackjackGame] = app.BlackjackGame.dealCard([], 2);
% 
%     % Update balance and game info display
%     app.updateBalance();
%     app.updateGameInfo();
% end

