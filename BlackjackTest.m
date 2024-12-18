classdef BlackjackTest
    properties
        playerHand % Cell array to store player's hand
        dealerHand % Cell array to store dealer's hand
        deck       % Cell array representing the deck of cards
        balance    % Player's balance
        betAmount  % Current bet amount
        updateGameWindow % Messages to display in the game window
        gameStarted % Flag to indicate if the game has started
        GameWindowTextbox % Update the UI component
        gameWindow
    end

    methods
        % Constructor
        function obj = BlackjackTest()
            obj.balance = 500; % Starting balance
            obj.deck = obj.createDeck(); % Create a new deck
            obj.gameWindow = '';
            obj.playerHand = {};
            obj.dealerHand = {};
            obj.gameStarted = false; % Initialize gameStarted flag
            obj.GameWindowTextbox = app.GameWindowTextbox;

            % obj.showWelcomeMessage(); % Show welcome message upon initialization
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

        function showWelcomeMessage(obj)
    obj.gameWindow = 'Welcome to Blackjack!';
    obj.updateGameWindow();
end
        % % Method to show a welcome message
        % function showWelcomeMessage(obj)
        %     obj.gameWindow = 'Welcome to Blackjack!';
        %     obj.updateGameWindow();
        % end

        function play(obj, app)
            % This method will control the main game loop
            while true
                % Display the current balance
                obj.gameWindow = sprintf('Current Balance: $%d', obj.balance);
                obj.updateGameWindow();

                % Get player bet amount from the app UI
                obj.betAmount = app.BetAmountField.Value; % Adjust according to your UI field name

                % Check if the bet amount is valid
                if obj.betAmount > obj.balance || obj.betAmount <= 0
                    obj.gameWindow = 'Invalid bet amount. Please enter a valid bet.';
                    obj.updateGameWindow();
                    continue; % Skip to the next iteration
                end

                % Deal initial cards
                obj = obj.dealCards();

                % Game loop for player's turn
                while obj.gameStarted
                    % Here you would check for hits or stands based on the UI buttons
                    % Assuming you have buttons in your app for "Hit" and "Stand"
                    if myApp.HitButton.Value % Assuming HitButton is a button in your app
                        obj = obj.hitCard('player', 1);
                        obj.displayCurrentHands();

                        % Check if player has busted
                        if obj.calculateTotal(obj.playerHand) > 21
                            break; % Exit loop if player busts
                        end
                    elseif myApp.StandButton.Value % Assuming StandButton is a button in your app
                        obj = obj.onStandButtonPress();
                        break; % Exit loop to proceed to dealer's turn
                    end
                end

                % Check if player busted
                if obj.calculateTotal(obj.playerHand) > 21
                    obj.gameWindow = 'You busted! Dealer Wins!';
                    obj.updateGameWindow();
                else
                    % Proceed to dealer's turn
                    obj = obj.onDealerTurn();
                end

                % Ask if the player wants to play again
                playAgain = questdlg('Do you want to play again?', ...
                    'Play Again', ...
                    'Yes', 'No', 'Yes');
                if strcmp(playAgain, 'No')
                    break; % Exit the game loop
                end

                % Reset game state for a new round
                obj.playerHand = {};
                obj.dealerHand = {};
                obj.deck = obj.createDeck();
                obj.gameStarted = false;
            end

            % Display final balance
            obj.gameWindow = sprintf('Thank you for playing! Your final balance is $%d', obj.balance);
            obj.updateGameWindow();
        end


        % Method to deal inital cards
        function obj = dealCards(obj)
            if ~obj.gameStarted % Only deal if the game has not started
                % Deal two cards each to player and dealer
                obj = obj.hitCard('player', 2);
                obj = obj.hitCard('dealer', 2);
                obj.gameStarted = true; % Set gameStarted to true after dealing
                obj.displayCurrentHands(); % Show the current hands after dealing
            else
                obj.gameWindow = 'The game has already started. Please choose to hit or stand.';
                obj.updateGameWindow();
            end
        end

        % Method to deal a card
        function [hand, obj] = hitCard(obj, who, numCards)
            if strcmp(who, 'player')
                hand = obj.playerHand;
                % Check if the player's hand total is already 21
                if obj.calculateTotal(hand) == 21
                    obj.gameWindow = 'You have 21! No more hits allowed.';
                    obj.updateGameWindow;
                    return;
                end
            else
                hand = obj.dealerHand;
            end

            % Check if the hand already has 5 cards
            if length(hand) + numCards > 5
                obj.gameWindow = sprintf('Cannot deal more than 5 cards to the %s!', who);
                obj.updateGameWindow();

                return;
            end

            for i = 1:numCards
                if isempty(obj.deck)
                    obj.gameWindow = 'No more cards in the deck!';
                    obj.updateGameWindow();

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

            playerHandStr = ['Your cards: ', obj.handToString(obj.playerHand), ' | Total: ', num2str(playerTotal)];
            dealerHandStr = ['Dealer''s cards: ', obj.handToString(obj.dealerHand), ' | Total: ', num2str(dealerTotal)];

            % Update displayMessageGame for hands display
            obj.gameWindow = [playerHandStr, '\n', dealerHandStr];
            obj.updateGameWindow();
        end

        % Method to calculate the total value of a hand
        function total = calculateTotal(~, hand)
            total = 0;
            aces = 0;  % Count aces separately

            for i = 1:length(hand)
                card = hand{i};
                rank = card(1); % Get the rank (the first character)

                % Check the value of the rank
                if any(strcmp(rank, {'J', 'Q', 'K'}))
                    total = total + 10; % Face cards are worth 10
                elseif strcmp(rank, 'A')
                    aces = aces + 1; % Count Aces
                    total = total + 11; % Assume Ace is 11 for now
                else
                    total = total + str2double(rank); % Numeric cards are their face value
                end
            end

            % Adjust for Aces if total exceeds 21
            while total > 21 && aces > 0
                total = total - 10; % Count Ace as 1 instead of 11
                aces = aces - 1;  % Reduce the count of Aces
            end
        end

        % Method to convert hand to a string for display
        function str = handToString(~, hand)
            str = strjoin(hand, ', ');
        end

        % Method to handle the Stand button press
        function obj = onStandButtonPress(obj)
            if obj.gameStarted
                obj.gameWindow = 'Player stands. Dealer\''s turn...';
                pause(1); % Small pause for effect
                obj = obj.onDealerTurn(); % Trigger dealer’s turn when player stands
            else
                obj.gameWindow = 'Please start the game before standing.';
                obj.updateGameWindow();
            end
        end

        % Method to handle the Dealer's Turn
        function obj = onDealerTurn(obj)
            if obj.gameStarted
                dealerTotal = obj.calculateTotal(obj.dealerHand);

                % Dealer continues to hit until they reach at least 18 or bust
                while dealerTotal < 18
                    obj = obj.hitCard('dealer', 1);
                    dealerTotal = obj.calculateTotal(obj.dealerHand);
                    pause(1); % Pause between each card for better user experience
                    obj.displayCurrentHands();
                end

                % Additional draw for a 70% win rate, as discussed
                playerTotal = obj.calculateTotal(obj.playerHand);
                if dealerTotal <= 21 && dealerTotal < playerTotal && dealerTotal < 19
                    obj = obj.hitCard('dealer', 1);
                    dealerTotal = obj.calculateTotal(obj.dealerHand);
                    pause(1); % Additional pause for dramatic effect
                    obj.displayCurrentHands();
                end

                % After the dealer’s turn, determine the winner and display the outcome
                obj = obj.determineWinner();
            end
        end
    end
end

