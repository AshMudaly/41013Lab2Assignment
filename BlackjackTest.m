classdef BlackjackTest
    properties
        playerHand % Cell array to store player's hand
        dealerHand % Cell array to store dealer's hand
        deck       % Cell array representing the deck of cards
        balance    % Player's balance
        betAmount  % Current bet amount
        displayMessageGame % Messages to display in the game window
        gameStarted % Flag to indicate if the game has started
    end
    
    methods
        % Constructor
        function obj = BlackjackTest()
            obj.balance = 500; % Starting balance
            obj.deck = obj.createDeck(); % Create a new deck
            obj.displayMessageGame = '';
            obj.playerHand = {};
            obj.dealerHand = {};
            obj.gameStarted = false; % Initialize gameStarted flag
            obj.showWelcomeMessage(); % Show welcome message upon initialization
        end
        
        % Method to create a standard deck of cards
        function deck = createDeck(~)
            suits = {'Hearts', 'Diamonds', 'Clubs', 'Spades'};
            ranks = {'2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'};
            deck = {};
            for suit = suits
                for rank = ranks
                    deck{end+1} = [rank{1}, ' of ', suit{1}]; % Create card
                end
            end
            deck = deck(randperm(length(deck))); % Shuffle deck
        end
        
        % Method to show a welcome message
        function showWelcomeMessage(obj)
            obj.displayMessageGame = 'Welcome to Blackjack!'; % Set welcome message
            disp(obj.displayMessageGame); % Display the welcome message in the console
        end
        
        % Method to deal cards
        function obj = dealCards(obj)
            if ~obj.gameStarted % Only deal if the game has not started
                % Deal two cards each to player and dealer
                obj = obj.dealCard('player', 2);
                obj = obj.dealCard('dealer', 2);
                obj.gameStarted = true; % Set gameStarted to true after dealing
                obj.displayCurrentHands(); % Show the current hands after dealing
            else
                disp('The game has already started. Please choose to hit or stand.'); % Inform player if they try to start again
            end
        end

        % Method to deal a card
        function [hand, obj] = dealCard(obj, who, numCards)
            if strcmp(who, 'player')
                hand = obj.playerHand;
            else
                hand = obj.dealerHand;
            end
            
            for i = 1:numCards
                if isempty(obj.deck)
                    obj.displayMessageGame = 'No more cards in the deck!';
                    return;
                end
                card = obj.deck{end}; % Get the last card from the deck
                obj.deck(end) = [];    % Remove the card from the deck
                hand{end+1} = card;    % Add card to the hand
            end
            
            if strcmp(who, 'player')
                obj.playerHand = hand;
            else
                obj.dealerHand = hand;
            end
        end
        
        % Method to display current hands along with their totals
        function displayCurrentHands(obj)
           playerTotal = obj.calculateTotal(obj.playerHand);
    dealerTotal = obj.calculateTotal(obj.dealerHand);
    
    % Format the output strings
    playerHandStr = ['Your cards: ', obj.handToString(obj.playerHand), ' | Total: ', num2str(playerTotal)];
    dealerHandStr = ['Dealer\''s cards: ', obj.handToString(obj.dealerHand), ' | Total: ', num2str(dealerTotal)];
    
    % Display in console (you can replace this with your UI display logic)
    disp(playerHandStr);
    disp(dealerHandStr);
    
    % You might want to set these strings to your UI properties here
    obj.displayMessageGame = playerHandStr; % Update the display message for player
        end

        % Method to calculate the total value of a hand
        function total = calculateTotal(~, hand)
            total = 0;
            aces = 0;
            for i = 1:length(hand)
                card = hand{i};
                rank = card(1); % Get the rank of the card
                if any(strcmp(rank, {'J', 'Q', 'K'}))
                    total = total + 10; % Face cards are worth 10
                elseif strcmp(rank, 'A')
                    total = total + 11; % Aces initially worth 11
                    aces = aces + 1;    % Count aces
                else
                    total = total + str2double(rank); % Add numeric value
                end
            end
            
            % Adjust for aces if total exceeds 21
            while total > 21 && aces > 0
                total = total - 10; % Count ace as 1 instead of 11
                aces = aces - 1;
            end
        end
        
        % Method to convert hand to a string for display
        function str = handToString(~, hand)
            str = strjoin(hand, ', '); % Join card strings
        end
        
        % Method to determine the winner and update the balance
        function obj = determineWinner(obj)
            playerTotal = obj.calculateTotal(obj.playerHand);
            dealerTotal = obj.calculateTotal(obj.dealerHand);
            
            obj.displayCurrentHands(); % Display hands before announcing the result
            
            if playerTotal > 21 % Player busts
                obj.displayMessageGame = 'You busted! Dealer Wins!';
                disp(obj.displayMessageGame);
                % Dealer wins; no change in balance
            elseif dealerTotal > 21 % Dealer busts
                obj.displayMessageGame = 'Dealer Busts! Player Wins!';
                disp(obj.displayMessageGame);
                obj.balance = obj.balance + obj.betAmount; % Return bet to player
            elseif playerTotal > dealerTotal % Player wins
                obj.displayMessageGame = 'Player Wins!';
                disp(obj.displayMessageGame);
                obj.balance = obj.balance + obj.betAmount; % Return bet to player
            elseif playerTotal < dealerTotal % Dealer wins
                obj.displayMessageGame = 'Dealer Wins!';
                disp(obj.displayMessageGame);
                % No change in balance
            else % It's a tie
                obj.displayMessageGame = 'It''s a Tie! Nothing happens.';
                disp(obj.displayMessageGame);
                % No change in balance
            end
            
            obj.gameStarted = false; % Reset game state for the next round
        end
        
        % Method to handle the Start button press
        function obj = onStartButtonPress(obj)
            obj = obj.dealCards(); % Deal the cards when the start button is pressed
        end
        
        % Method to handle the Hit button press
        function obj = onHitButtonPress(obj)
            if obj.gameStarted
                obj = obj.dealCard('player', 1); % Deal one card to the player
                obj.displayCurrentHands(); % Show the current hands after hitting
                playerTotal = obj.calculateTotal(obj.playerHand);
                if playerTotal > 21
                    obj.displayMessageGame = 'You busted! Dealer Wins!';
                    disp(obj.displayMessageGame);
                    obj.gameStarted = false; % Reset game state
                end
            else
                disp('Please start the game before hitting.'); % Inform player if they try to hit without starting
            end
        end
        
        % Method to handle the Dealer's Turn
        function obj = onDealerTurn(obj)
            if obj.gameStarted
                while obj.calculateTotal(obj.dealerHand) < 17 % Dealer hits until total is 17 or higher
                    obj = obj.dealCard('dealer', 1);
                end
                obj = obj.determineWinner(); % Determine winner and update balance
            else
                disp('Please start the game before dealer turns.'); % Inform player if they try to invoke dealer turn without starting
            end
        end
    end
end
