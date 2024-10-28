function BlackjackGUI
% Initialize game
game = BlackjackTest();
close all;

% Set up the main figure
hFig = figure('Name', 'Blackjack Game', 'NumberTitle', 'off', ...
    'Position', [300, 200, 600, 400], 'MenuBar', 'none', 'Resize', 'off');

% Text displays
uicontrol('Style', 'text', 'Position', [50, 350, 500, 30], ...
    'String', 'Welcome to Blackjack!', 'FontSize', 12, 'Tag', 'Message');

% Balance display
uicontrol('Style', 'text', 'Position', [50, 300, 200, 30], ...
    'String', sprintf('Balance: $%d', game.balance), 'FontSize', 12, 'Tag', 'BalanceText');

% Bet Input Field
uicontrol('Style', 'text', 'Position', [50, 250, 200, 30], ...
    'String', 'Enter Bet Amount:', 'FontSize', 10);
hBetInput = uicontrol('Style', 'edit', 'Position', [200, 250, 50, 30], ...
    'String', '10', 'FontSize', 10);

% Player and dealer hands
uicontrol('Style', 'text', 'Position', [50, 200, 500, 30], ...
    'String', 'Your Hand: ', 'FontSize', 10, 'Tag', 'PlayerHand');
uicontrol('Style', 'text', 'Position', [50, 150, 500, 30], ...
    'String', 'Dealer Hand: ', 'FontSize', 10, 'Tag', 'DealerHand');

% Buttons for game control
uicontrol('Style', 'pushbutton', 'Position', [300, 250, 100, 30], ...
    'String', 'Place Bet', 'Callback', @placeBet);
uicontrol('Style', 'pushbutton', 'Position', [150, 100, 100, 30], ...
    'String', 'Hit', 'Callback', @hit, 'Tag', 'HitButton', 'Enable', 'off');
uicontrol('Style', 'pushbutton', 'Position', [300, 100, 100, 30], ...
    'String', 'Stand', 'Callback', @stand, 'Tag', 'StandButton', 'Enable', 'off');
uicontrol('Style', 'pushbutton', 'Position', [450, 100, 100, 30], ...
    'String', 'Restart', 'Callback', @restartGame);

% Place bet callback
    function placeBet(~, ~)
        betAmount = str2double(get(hBetInput, 'String'));
        if isnan(betAmount) || betAmount < 1 || betAmount > game.balance
            updateMessage('Invalid bet. Enter a valid amount.');
            return;
        end

        % Set the bet amount in the game object
        game.betAmount = betAmount;
        % Ensure the deck is shuffled if needed
        game = game.shuffleDeck();

        % Deal initial cards to both player and dealer
        [game.playerHand, game] = game.dealCard([], 2);
        [game.dealerHand, game] = game.dealCard([], 2);

        % Check if hands are successfully dealt
        if isempty(game.playerHand) || isempty(game.dealerHand)
            updateMessage('Error: Could not deal cards. Please try again.');
            return;
        end

        updateGameState();

        % Enable hit and stand buttons, disable betting
        set(findobj(hFig, 'Tag', 'HitButton'), 'Enable', 'on');
        set(findobj(hFig, 'Tag', 'StandButton'), 'Enable', 'on');
    end

% Helper function to show hands
    function showHands(obj, playerHand, dealerHand, hideDealer)
        if isempty(playerHand)
            disp('Your cards: No cards dealt yet.');
        else
            disp(['Your cards: ', obj.handToString(playerHand), ' | Total: ', num2str(obj.calculateTotal(playerHand))]);
        end

        if hideDealer
            if isempty(dealerHand)
                disp('Dealer''s first card: No cards dealt yet.');
            else
                disp(['Dealer''s first card: ', obj.cardNames{dealerHand(1)}]);
            end
        else
            if isempty(dealerHand)
                disp('Dealer''s cards: No cards dealt yet.');
            else
                disp(['Dealer''s cards: ', obj.handToString(dealerHand), ' | Total: ', num2str(obj.calculateTotal(dealerHand))]);
            end
        end
    end
% Hit callback
    function hit(~, ~)
        [playerBust, game] = game.playerTurn(game.playerHand, game.dealerHand, game.betAmount);
        if playerBust
            updateMessage('You bust! Dealer wins.');
            disableGameControls();
        end
        updateGameState();
    end

% Stand callback
    function stand(~, ~)
        game = game.dealerTurn(game.playerHand, game.dealerHand, game.betAmount);
        updateGameState();
    end

% Restart game
    function restartGame(~, ~)
        game = BlackjackTest();
        updateGameState();
        updateMessage('Game restarted! Place your bet.');
    end

% Update displayed game state
    function updateGameState
        % Update balance
        balanceText = findobj(hFig, 'Tag', 'BalanceText');
        set(balanceText, 'String', sprintf('Balance: $%d', game.balance));

        % Update player and dealer hands
        playerHandText = findobj(hFig, 'Tag', 'PlayerHand');
        dealerHandText = findobj(hFig, 'Tag', 'DealerHand');
        set(playerHandText, 'String', sprintf('Your Hand: %s', game.handToString(game.playerHand)));
        set(dealerHandText, 'String', sprintf('Dealer Hand: %s', game.handToString(game.dealerHand)));

        % Check if game is over
        if game.balance <= 0
            updateMessage('Game over! You ran out of money.');
            disableGameControls();
        end
    end

% Disable game control buttons
    function disableGameControls
        set(findobj(hFig, 'Tag', 'HitButton'), 'Enable', 'off');
        set(findobj(hFig, 'Tag', 'StandButton'), 'Enable', 'off');
    end

% Display a message to the player
    function updateMessage(msg)
        messageText = findobj(hFig, 'Tag', 'Message');
        set(messageText, 'String', msg);
    end
end


%%
% classdef BlackjackTest
%     properties
%         balance;   % Player's starting balance
%         deck;      % Deck of cards
%         cardNames; % Card names
%         playerHand; % Player's hand
%         dealerHand; % Dealer's hand
%         betAmount;    % Bet amount for current round
%     end
% 
%     methods
%         % Constructor to initialize properties
%         function obj = BlackjackTest()
%             disp('Welcome to Blackjack!');
%             pause(2);
%             obj.balance = 100;  % Player's starting balance
%             obj.cardNames = {'Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King'};
%             obj = obj.shuffleDeck();  % Shuffle the deck at the start
%             obj.playerHand = []; % Initialize player's hand
%             obj.dealerHand = []; % Initialize dealer's hand
%             obj.betAmount = 0;        % Initialize bet amount
%         end
% 
%         % Function to start the game
%         function play(obj)
%             while obj.balance > 0
%                 clc;
%                 disp(['Current balance: $', num2str(obj.balance)]);
% 
%                 bet = obj.getBet();  % Betting amount
%                 disp(['You bet $', num2str(bet)]);
% 
%                 % Shuffle deck if fewer than 15 cards are left
%                 if length(obj.deck) < 15
%                     obj = obj.shuffleDeck();
%                 end
% 
%                 % Player's and Dealer's hands
%                 [playerHand, obj] = obj.dealCard([], 2);
%                 [dealerHand, obj] = obj.dealCard([], 2);
%                 obj.showHands(playerHand, dealerHand, true);  % Show initial hands
% 
%                 % Player's turn
%                 [playerBust, obj] = obj.playerTurn(playerHand, dealerHand, bet);
% 
%                 % Dealer's turn if player hasn't busted
%                 if ~playerBust
%                     obj = obj.dealerTurn(playerHand, dealerHand, bet);
%                 end
% 
%                 % Ask if the player wants to continue
%                 if obj.balance > 0
%                     cont = input('Do you want to play again? (y/n): ', 's');
%                     switch cont
%                         case 'y'
%                             continue;  % Continue playing
%                         case 'n'
%                             break;  % Exit the game
%                         otherwise
%                             disp('Invalid input. Exiting game.');
%                             break;  % Exit the game
%                     end
%                 else
%                     disp('You have run out of money! Game over.');
%                 end
%             end
%         end
% 
%         % Shuffle the deck and ensure it resets to 52 cards
%         function obj = shuffleDeck(obj)
%             deckValues = [1:10, 10, 10, 10];  % J, Q, K represented by 10, Ace as 1
%             obj.deck = repmat(deckValues, 1, 4);  % 4 suits (total 52 cards)
%             obj.deck = obj.deck(randperm(length(obj.deck)));  % Shuffle the deck
% 
%             % Debugging: Check the length of the deck after shuffling
%             disp(['Deck size after shuffling: ', num2str(length(obj.deck))]);
%         end
% 
%         % Helper function to get player's bet
%         function bet = getBet(obj)
%             while true
%                 betInput = input(['Enter your bet (1 to ', num2str(obj.balance), '): '], 's'); % Take input as a string
%                 bet = str2double(betInput);  % Convert input to a number
% 
%                 switch true
%                     case isnan(bet) || bet < 1 || bet > obj.balance
%                         disp(['Invalid input. Please enter a value between 1 and ', num2str(obj.balance), '.']);
%                         disp(['Current balance: $', num2str(obj.balance)]); % Display current balance
%                         pause(2);
%                         clc;
%                     otherwise
%                         return;  % Valid input, exit the loop
%                 end
%             end
%         end
% 
%         % Helper function to deal a card and update the deck
%         function [hand, obj] = dealCard(obj, hand, numCards)
%             if nargin < 3
%                 numCards = 1; % Default to dealing 1 card
%             end
%             numCards = min(numCards, length(obj.deck));  % Ensure we don't deal more cards than available
%             hand = [hand, obj.deck(1:numCards)];  % Add card(s) to hand
%             obj.deck(1:numCards) = [];  % Remove card(s) from deck
% 
%             % Debugging: Check deck size after dealing cards
%             disp(['Deck size after dealing: ', num2str(length(obj.deck))]);
% 
%             if isempty(obj.deck)  % Reshuffle if deck is empty
%                 disp('Reshuffling deck...');
%                 obj = obj.shuffleDeck();
%             end
%         end
% 
%         % Helper function to handle player's turn
%         function [playerBust, obj] = playerTurn(obj, playerHand, dealerHand, bet)
%             playerBust = false;
% 
%             while true
%                 clc;
%                 obj.showHands(playerHand, dealerHand, true);
% 
%                 if length(playerHand) >= 5
%                     disp('You have 5 cards. You must stand.');
%                     break;
%                 end
% 
%                 choice = input('Do you want to (h)it or (s)tand? ', 's');
%                 switch choice
%                     case 'h'
%                         [playerHand, obj] = obj.dealCard(playerHand);
%                         if obj.calculateTotal(playerHand) > 21
%                             clc;
%                             obj.showHands(playerHand, dealerHand, true);
%                             disp('Bust! You lose.');
%                             obj.balance = obj.balance - bet;
%                             disp(['New balance: $', num2str(obj.balance)]);
%                             playerBust = true;  % Player busted
%                             return;  % Exit the player turn
%                         end
%                     case 's'
%                         break;  % Exit the player turn
%                     otherwise
%                         disp('Invalid choice. Please type h to hit or s to stand.');
%                 end
%             end
%         end
% 
% 
%         function [obj] = dealerTurn(obj, playerHand, dealerHand, bet)
%             clc;
%             dealerTotal = obj.calculateTotal(dealerHand);  % Calculate the initial dealer total
%             disp(['Dealer''s cards: ', obj.handToString(dealerHand), ' | Total: ', num2str(dealerTotal)]);
% 
%             % Dealer draws cards until total is at least 17
%             while dealerTotal < 17
%                 [dealerHand, obj] = obj.dealCard(dealerHand);  % Dealer draws a card
%                 dealerTotal = obj.calculateTotal(dealerHand);  % Recalculate total after drawing
%                 clc;
%                 disp(['Dealer draws a card. Dealer''s cards: ', obj.handToString(dealerHand), ' | Total: ', num2str(dealerTotal)]);
%             end
% 
%             % Check if dealer busts
%             if dealerTotal > 21
%                 disp('Dealer busts! You win.');
%                 obj.balance = obj.balance + bet;  % Player wins, increase balance
%             else
%                 % Determine the winner if dealer doesn't bust
%                 balanceChange = obj.determineWinner(playerHand, dealerHand, bet);
%                 obj.balance = obj.balance + balanceChange;
%             end
% 
%             % Display updated balance
%             disp(['New balance: $', num2str(obj.balance)]);
%         end
% 
% 
%         % Helper function to calculate hand total
%         function total = calculateTotal(~, hand)
%             total = sum(hand);
%             aceCount = sum(hand == 1);
%             while total <= 11 && aceCount > 0
%                 total = total + 10;  % Count Ace as 11 if it doesn't bust the hand
%                 aceCount = aceCount - 1;
%             end
%         end
% 
%         % Helper function to convert a hand to a readable string
%         function handString = handToString(obj, hand)
%             handString = strjoin(obj.cardNames(hand), ', ');
%         end
% 
%         % Helper function to show hands
%         function showHands(obj, playerHand, dealerHand, hideDealer)
%             disp(['Your cards: ', obj.handToString(playerHand), ' | Total: ', num2str(obj.calculateTotal(playerHand))]);
%             if hideDealer
%                 disp(['Dealer''s first card: ', obj.cardNames{dealerHand(1)}]);
%             else
%                 disp(['Dealer''s cards: ', obj.handToString(dealerHand), ' | Total: ', num2str(obj.calculateTotal(dealerHand))]);
%             end
%         end
% 
%         % Helper function to determine the winner and update balance
%         function balanceChange = determineWinner(obj, playerHand, dealerHand, bet)
%             playerTotal = obj.calculateTotal(playerHand);  % Calculate player total
%             dealerTotal = obj.calculateTotal(dealerHand);  % Calculate dealer total
% 
%             if playerTotal > dealerTotal
%                 disp('You win!');
%                 balanceChange = bet;  % Win the bet
%             elseif playerTotal < dealerTotal
%                 disp('Dealer wins.');
%                 balanceChange = -bet;  % Lose the bet
%             else
%                 disp('It''s a tie!');
%                 balanceChange = 0;  % No change in balance
%             end
%         end
% 
%     end
% end