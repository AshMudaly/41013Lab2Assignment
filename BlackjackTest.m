classdef BlackjackTest
    properties
        balance;   % Player's starting balance
        deck;      % Deck of cards
        cardNames; % Card names
        app;       % App instance for updating UI
    end

    methods
        % Constructor to initialize properties
        function obj = BlackjackTest(app)
            obj.balance = 100;  % Player's starting balance
            obj.cardNames = {'Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King'};
            obj.app = app;  % Reference to the app instance
            obj = obj.shuffleDeck();  % Shuffle the deck at the start

            % Update balance display in the app
            obj.updateAppDisplay(['Welcome to Blackjack! Your starting balance is $', num2str(obj.balance)], 'play');
        end

        % Function to start the game
        function play(obj)
            obj.updateAppDisplay('Starting a new game...', 'play');
            obj.app.HitMeButton.Enable = 'on';
            obj.app.StandButton.Enable = 'on';

            % Shuffle the deck if needed
            if length(obj.deck) < 15
                obj = obj.shuffleDeck();
            end

            % Deal initial cards
            [playerHand, obj] = obj.dealCard([], 2);
            [dealerHand, obj] = obj.dealCard([], 2);
            obj.app.playerHand = playerHand;
            obj.app.dealerHand = dealerHand;

            % Show initial hands in the UI
            obj.showHands(playerHand, dealerHand, true);
        end

        % Shuffle the deck
        function obj = shuffleDeck(obj)
            deckValues = [1:10, 10, 10, 10];  % J, Q, K represented by 10, Ace as 1
            obj.deck = repmat(deckValues, 1, 4);  % 4 suits (total 52 cards)
            obj.deck = obj.deck(randperm(length(obj.deck)));  % Shuffle the deck
        end

        % Deal a card and update the deck
        function [hand, obj] = dealCard(obj, hand, numCards)
            if nargin < 3
                numCards = 1;  % Default to dealing 1 card
            end
            hand = [hand, obj.deck(1:numCards)];  % Add cards to hand
            obj.deck(1:numCards) = [];  % Remove dealt cards from deck
        end

        % Helper to handle the player's turn (hit/stand)
        function [playerBust, obj] = playerTurn(obj, playerHand, dealerHand)
            playerBust = false;
            % Player hits or stands - update the text areas accordingly
            obj.showHands(playerHand, dealerHand, true);
        end

        % Show hands in the app UI
        function showHands(obj, playerHand, dealerHand, hideDealer)
            playerHandStr = ['Player Hand: ', obj.handToString(playerHand), ...
                ' | Total: ', num2str(obj.calculateTotal(playerHand))];
            obj.updateAppDisplay(playerHandStr, 'hit');

            if hideDealer
                dealerHandStr = ['Dealer''s first card: ', obj.cardNames{dealerHand(1)}, ' and [Hidden]'];
            else
                dealerHandStr = ['Dealer Hand: ', obj.handToString(dealerHand), ...
                    ' | Total: ', num2str(obj.calculateTotal(dealerHand))];
            end
            obj.updateAppDisplay(dealerHandStr, 'stand');
        end

        % Helper to convert a hand to a readable string
        function handString = handToString(obj, hand)
            handString = strjoin(obj.cardNames(hand), ', ');
        end

        % Calculate hand total
        function total = calculateTotal(~, hand)
            total = sum(hand);
            aceCount = sum(hand == 1);
            while total <= 11 && aceCount > 0
                total = total + 10;  % Count Ace as 11 if it doesn't bust the hand
                aceCount = aceCount - 1;
            end
        end

        % Update display in the app
        function updateAppDisplay(obj, message, area)
            switch area
                case 'play'
                    obj.app.playTextArea.Value = message;
                case 'hit'
                    obj.app.hitTextArea.Value = message;
                case 'stand'
                    obj.app.standTextArea.Value = message;
            end
        end
    end
end
