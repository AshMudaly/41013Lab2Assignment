classdef BlackjackTest < handle
    properties
        app1            % Reference to the App Designer instance
        deck            % Deck of cards
        playerHand      % Player's hand
        dealerHand      % Dealer's hand
        balance         % Player's balance
        currentBet      % Current bet
        cardNames       % Names of cards for display
    end
    
    methods
        % Constructor: Initialize game with reference to the app
        function obj = BlackjackTest(app1)
            obj.app1 = app;                % Store reference to the app
            obj.deck = obj.initializeDeck(); % Initialize deck of cards
            obj.balance = 1000;             % Starting balance
            obj.playerHand = [];            % Initialize empty player hand
            obj.dealerHand = [];            % Initialize empty dealer hand
            obj.cardNames = {'2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'};
        end
        
        % Initialize the deck with 52 cards
        function deck = initializeDeck(obj)
            suits = {'Hearts', 'Diamonds', 'Clubs', 'Spades'};
            values = 2:14; % 11=J, 12=Q, 13=K, 14=A
            deck = [];
            for s = 1:numel(suits)
                for v = values
                    deck = [deck; struct('value', v, 'suit', suits{s})];
                end
            end
            deck = deck(randperm(length(deck))); % Shuffle the deck
        end

        % Start the game and deal initial cards
        function play(obj)
            obj.playerHand = obj.dealCard([], 2);  % Deal 2 cards to player
            obj.dealerHand = obj.dealCard([], 2);  % Deal 2 cards to dealer
            obj.app1.updateDisplay();  % Update the app display with initial hands
        end

        % Deal card(s) to the specified hand
        function hand = dealCard(obj, hand, numCards)
            for i = 1:numCards
                hand = [hand, obj.deck(1)];  % Add top card to hand
                obj.deck(1) = [];            % Remove the dealt card from deck
            end
        end

        % Calculate the total value of a hand
        function total = calculateTotal(obj, hand)
            total = 0;
            numAces = 0;
            for i = 1:length(hand)
                value = hand(i).value;
                if value > 10  % Face cards (J, Q, K)
                    value = 10;
                elseif value == 14  % Ace
                    value = 11;
                    numAces = numAces + 1;
                end
                total = total + value;
            end
            % Adjust for Aces if total exceeds 21
            while total > 21 && numAces > 0
                total = total - 10;
                numAces = numAces - 1;
            end
        end

        % Convert a hand into a string for display
        function handStr = handToString(obj, hand)
            handStr = '';
            for i = 1:length(hand)
                card = hand(i);
                handStr = [handStr, obj.cardNames{card.value - 1}, ' of ', card.suit]; %#ok<AGROW>
                if i < length(hand)
                    handStr = [handStr, ', ']; %#ok<AGROW>
                end
            end
        end

        % Logic for player's hit action
        function hit(obj)
            obj.playerHand = obj.dealCard(obj.playerHand, 1);  % Deal a card to player
            obj.app1.updateDisplay();  % Update display
            if obj.calculateTotal(obj.playerHand) > 21
                obj.app1.endGame('Player Busts! You lose.');
            end
        end

        % Logic for player's stand action
        function [dealerBust, resultMessage] = stand(obj)
            % Dealer's turn: must hit until total is 17 or more
            while obj.calculateTotal(obj.dealerHand) < 17
                obj.dealerHand = obj.dealCard(obj.dealerHand, 1);
            end

            dealerTotal = obj.calculateTotal(obj.dealerHand);
            playerTotal = obj.calculateTotal(obj.playerHand);

            if dealerTotal > 21
                dealerBust = true;
                resultMessage = 'Dealer Busts! You win!';
                obj.balance = obj.balance + obj.currentBet;
            elseif playerTotal > dealerTotal
                resultMessage = 'You win!';
                obj.balance = obj.balance + obj.currentBet;
            elseif playerTotal == dealerTotal
                resultMessage = 'Push (Tie)!';
            else
                resultMessage = 'You lose!';
                obj.balance = obj.balance - obj.currentBet;
            end
        end
    end
end
