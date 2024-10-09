classdef BlackjackTest
    properties
        balance;   % Player's starting balance
        deck;      % Deck of cards
        cardNames; % Card names
    end

    methods
        % Constructor to initialize properties
        function obj = BlackjackTest()
            disp('Welcome to Blackjack!');
            pause(2);

            % Initialize properties inside constructor
            obj.balance = 100;  % Player's starting balance
            obj.cardNames = {'Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King'};
            obj = obj.shuffleDeck();  % Shuffle the deck at the start
        end

        % Function to start the game
        function play(obj)
            while obj.balance > 0
                clc;
                disp(['Current balance: $', num2str(obj.balance)]);

                % Betting amount
                bet = obj.getBet();
                disp(['You bet $', num2str(bet)]);

                % Shuffle deck if fewer than 15 cards are left
                if length(obj.deck) < 15
                    obj = obj.shuffleDeck();
                end

                % Player's and Dealer's hands
                [playerHand, obj] = obj.dealCard([], 2);
                [dealerHand, obj] = obj.dealCard([], 2);

                % Show initial hands
                obj.showHands(playerHand, dealerHand, true);

                % Player's turn
                while true
                    clc;
                    obj.showHands(playerHand, dealerHand, true);

                    % Check if player already has 5 cards
                    if length(playerHand) >= 5
                        disp('You have 5 cards. You must stand.');
                        break;
                    end

                    choice = input('Do you want to (h)it or (s)tand? ', 's');

                    switch choice
                        case 'h'
                            [playerHand, obj] = obj.dealCard(playerHand);
                            if obj.calculateTotal(playerHand) > 21
                                clc;
                                obj.showHands(playerHand, dealerHand, true);
                                disp('Bust! You lose.');
                                obj.balance = obj.balance - bet;
                                disp(['New balance: $', num2str(obj.balance)]);
                                break;
                            end
                        case 's'
                            break;
                        otherwise
                            disp('Invalid choice. Please type h to hit or s to stand.');
                    end
                end

                % Dealer's turn if player hasn't busted
                if obj.calculateTotal(playerHand) <= 21
                    clc;
                    disp(['Dealer''s cards: ', obj.handToString(dealerHand), ' | Total: ', num2str(obj.calculateTotal(dealerHand))]);
                    while obj.calculateTotal(dealerHand) < 17
                        [dealerHand, obj] = obj.dealCard(dealerHand);
                        clc;
                        disp(['Dealer draws a card. Dealer''s cards: ', obj.handToString(dealerHand), ' | Total: ', num2str(obj.calculateTotal(dealerHand))]);
                    end

                    % Check dealer bust
                    if obj.calculateTotal(dealerHand) > 21
                        disp('Dealer busts! You win.');
                        obj.balance = obj.balance + bet;
                        disp(['New balance: $', num2str(obj.balance)]);
                    else
                        % Determine the winner
                        obj.balance = obj.balance + obj.determineWinner(playerHand, dealerHand, bet);
                        disp(['New balance: $', num2str(obj.balance)]);
                    end
                end

                % Ask if the player wants to continue
                if obj.balance > 0
                    cont = input('Do you want to play again? (y/n): ', 's');
                    if cont == 'n'
                        break;
                    end
                else
                    disp('You have run out of money! Game over.');
                end
            end
        end

        % Shuffle the deck
        function obj = shuffleDeck(obj)
            % Initialize deck (1-10, J, Q, K represented by 10, Ace as 1)
            deckValues = [1:10, 10, 10, 10];  % J, Q, K are 10 points
            obj.deck = repmat(deckValues, 1, 4);  % 4 suits (total 52 cards)
            obj.deck = obj.deck(randperm(length(obj.deck)));  % Shuffle the deck
        end

        % Helper function to get player's bet
        function bet = getBet(obj)
            while true
                betInput = input(['Enter your bet (1 to ', num2str(obj.balance), '): '], 's'); % Take input as a string
                bet = str2double(betInput);  % Convert input to a number
                % Check if the conversion was successful and if the value is within the valid range
                if isnan(bet) || ~isscalar(bet) || bet < 1 || bet > obj.balance
                    disp(['Invalid input. Please enter a value between 1 and ', num2str(obj.balance), '.']);
                    pause(2);
                    clc;
                else
                    break;  % Valid input, exit the loop
                end
            end
        end

        % Helper function to deal a card and update the deck
        function [hand, obj] = dealCard(obj, hand, numCards)
            if nargin < 3
                numCards = 1; % Default to dealing 1 card
            end

            % Ensure we don't attempt to deal more cards than available
            if numCards > length(obj.deck)
                numCards = length(obj.deck);
            end

            hand = [hand, obj.deck(1:numCards)];  % Add card(s) to hand
            obj.deck(1:numCards) = [];  % Remove card(s) from deck

            % Reshuffle if deck is empty
            if isempty(obj.deck)
                disp('Reshuffling deck...');
                obj = obj.shuffleDeck();
            end
        end

        % Helper function to calculate hand total
        function total = calculateTotal(~, hand)
            total = sum(hand);
            aceCount = sum(hand == 1);
            while total <= 11 && aceCount > 0
                total = total + 10; % Count Ace as 11 if it doesn't bust the hand
                aceCount = aceCount - 1;
            end
        end

        % Helper function to convert a hand to a readable string
        function handString = handToString(obj, hand)
            handString = strjoin(obj.cardNames(hand), ', ');
        end

        % Helper function to show hands
        function showHands(obj, playerHand, dealerHand, hideDealer)
            disp(['Your cards: ', obj.handToString(playerHand), ' | Total: ', num2str(obj.calculateTotal(playerHand))]);
            if hideDealer
                disp(['Dealer''s first card: ', obj.cardNames{dealerHand(1)}]);
            else
                disp(['Dealer''s cards: ', obj.handToString(dealerHand), ' | Total: ', num2str(obj.calculateTotal(dealerHand))]);
            end
        end

        % Helper function to determine the winner and update balance
        function balanceChange = determineWinner(obj, playerHand, dealerHand, bet)
            playerTotal = obj.calculateTotal(playerHand);
            dealerTotal = obj.calculateTotal(dealerHand);

            if playerTotal > dealerTotal
                disp('You win!');
                balanceChange = bet;  % Win the bet
            elseif playerTotal < dealerTotal
                disp('Dealer wins.');
                balanceChange = -bet;  % Lose the bet
            else
                disp('It''s a tie!');
                balanceChange = 0;  % No change in balance
            end
        end
    end
end
