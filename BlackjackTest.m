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
            obj.displayMessageGame = 'Welcome to Blackjack!';
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
                obj.displayMessageGame = 'The game has already started. Please choose to hit or stand.';
            end
        end

        % Method to deal a card
        function [hand, obj] = hitCard(obj, who, numCards)
            if strcmp(who, 'player')
                hand = obj.playerHand;
                % Check if the player's hand total is already 21
                if obj.calculateTotal(hand) == 21
                    obj.displayMessageGame = 'You have 21! No more hits allowed.';
                    return;
                end
            else
                hand = obj.dealerHand;
            end

            % Check if the hand already has 5 cards
            if length(hand) + numCards > 5
                obj.displayMessageGame = sprintf('Cannot deal more than 5 cards to the %s!', who);
                return;
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

            playerHandStr = ['Your cards: ', obj.handToString(obj.playerHand), ' | Total: ', num2str(playerTotal)];
            dealerHandStr = ['Dealer''s cards: ', obj.handToString(obj.dealerHand), ' | Total: ', num2str(dealerTotal)];

            % Update displayMessageGame for hands display
            obj.displayMessageGame = [playerHandStr, '\n', dealerHandStr];
        end

        % Method to calculate the total value of a hand
        function total = calculateTotal(~, hand)
            total = 0;
            aces = 0;
            for i = 1:length(hand)
                card = hand{i};
                rank = card(1);
                if any(strcmp(rank, {'J', 'Q', 'K'}))
                    total = total + 10;
                elseif strcmp(rank, 'A')
                    total = total + 11;
                    aces = aces + 1;
                else
                    total = total + str2double(rank);
                end
            end
            while total > 21 && aces > 0
                total = total - 10;
                aces = aces - 1;
            end
        end

        % Method to convert hand to a string for display
        function str = handToString(~, hand)
            str = strjoin(hand, ', ');
        end

        % Method to determine the winner and update the balance
        function obj = determineWinner(obj)
            playerTotal = obj.calculateTotal(obj.playerHand);
            dealerTotal = obj.calculateTotal(obj.dealerHand);

            obj.displayCurrentHands();

            if playerTotal > 21
                obj.displayMessageGame = 'You busted! Dealer Wins!';
            elseif dealerTotal > 21
                obj.displayMessageGame = 'Dealer Busts! Player Wins!';
                obj.balance = obj.balance + obj.betAmount;
            elseif playerTotal > dealerTotal
                obj.displayMessageGame = 'Player Wins!';
                obj.balance = obj.balance + obj.betAmount;
            elseif playerTotal < dealerTotal
                obj.displayMessageGame = 'Dealer Wins!';
            else
                obj.displayMessageGame = 'It''s a Tie! Nothing happens.';
            end

            obj.gameStarted = false;
        end

        % Method to handle the Stand button press
        function obj = onStandButtonPress(obj)
            if obj.gameStarted
                obj.displayMessageGame = 'Player stands. Dealer\''s turn...';
                pause(1); % Small pause for effect
                obj = obj.onDealerTurn(); % Trigger dealer’s turn when player stands
            else
                obj.displayMessageGame = 'Please start the game before standing.';
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

