classdef BlackjackTest
    properties
        balance = 100; % Player's starting balance
        deck; % The deck of cards
        cardNames = {'Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King'}; % Card names
        playerHand; % Player's hand
        dealerHand; % Dealer's hand
    end
    
    methods
        % Constructor to initialize deck and start the game
        function obj = BlackjackTest()
            obj.deck = obj.initializeDeck(); % Initialize deck
            obj.startGame(); % Start the game
        end

        % Method to initialize a shuffled deck
        function deck = initializeDeck(obj)
            deck = [1:10, 10, 10, 10]; % J, Q, K are 10 points
            deck = repmat(deck, 1, 4); % 4 suits
            deck = deck(randperm(length(deck))); % Shuffle deck
        end

        % Method to start the game loop
        function startGame(obj)
            while obj.balance > 0
                clc;
                disp(['Current balance: $', num2str(obj.balance)]);

                % Get flexible bet from the player
                bet = obj.getFlexibleBet();
                disp(['You bet $', num2str(bet)]);

                % Deal initial hands
                obj.playerHand = obj.dealCard([], 2);
                obj.dealerHand = obj.dealCard([], 2);

                % Show initial hands
                obj.showHands(true);

                % Player's turn
                while true
                    clc;
                    obj.showHands(true);

                    % Check if player already has 5 cards
                    if length(obj.playerHand) >= 5
                        disp('You have 5 cards. You must stand.');
                        break;
                    end

                    choice = input('Do you want to (h)it or (s)tand? ', 's');
                    if choice == 'h'
                        obj.playerHand = obj.dealCard(obj.playerHand, 1);
                        if obj.calculateTotal(obj.playerHand) > 21
                            clc;
                            obj.showHands(true);
                            disp('Bust! You lose.');
                            obj.balance = obj.balance - bet;
                            disp(['New balance: $', num2str(obj.balance)]);
                            break;
                        end
                    elseif choice == 's'
                        break;
                    else
                        disp('Invalid choice. Please type h to hit or s to stand.');
                    end
                end

                % Dealer's turn if player hasn't busted
                if obj.calculateTotal(obj.playerHand) <= 21
                    clc;
                    disp(['Dealer''s cards: ', obj.handToString(obj.dealerHand), ' | Total: ', num2str(obj.calculateTotal(obj.dealerHand))]);
                    while obj.calculateTotal(obj.dealerHand) < 17
                        obj.dealerHand = obj.dealCard(obj.dealerHand, 1);
                        clc;
                        disp(['Dealer draws a card. Dealer''s cards: ', obj.handToString(obj.dealerHand), ' | Total: ', num2str(obj.calculateTotal(obj.dealerHand))]);
                    end

                    % Check dealer bust
                    if obj.calculateTotal(obj.dealerHand) > 21
                        disp('Dealer busts! You win.');
                        obj.balance = obj.balance + bet;
                    else
                        % Determine the winner
                        obj.balance = obj.balance + obj.determineWinner(bet);
                    end

                    disp(['New balance: $', num2str(obj.balance)]);
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

        % Method to get the player's flexible bet
        function bet = getFlexibleBet(obj)
            while true
                bet = input(['Enter your bet (1 to ', num2str(obj.balance), '): ']);
                if bet >= 1 && bet <= obj.balance
                    break;
                else
                    disp(['Invalid bet. Please enter a value between 1 and ', num2str(obj.balance)]);
                end
            end
        end

        % Method to deal cards to a hand and update the deck
        function hand = dealCard(obj, hand, numCards)
            if nargin < 3
                numCards = 1; % Default to dealing 1 card
            end
            hand = [hand, obj.deck(1:numCards)]; % Add card(s) to hand
            obj.deck(1:numCards) = []; % Remove card(s) from deck
        end

        % Method to calculate the total value of a hand
        function total = calculateTotal(~, hand)
            total = sum(hand);
            aceCount = sum(hand == 1);
            while total <= 11 && aceCount > 0
                total = total + 10; % Count Ace as 11 if it doesn't bust the hand
                aceCount = aceCount - 1;
            end
        end

        % Method to convert a hand into a readable string
        function handString = handToString(obj, hand)
            handString = strjoin(obj.cardNames(hand), ', ');
        end

        % Method to show both hands (hiding dealer's second card optionally)
        function showHands(obj, hideDealer)
            disp(['Your cards: ', obj.handToString(obj.playerHand), ' | Total: ', num2str(obj.calculateTotal(obj.playerHand))]);
            if hideDealer
                disp(['Dealer''s first card: ', obj.cardNames{obj.dealerHand(1)}]);
            else
                disp(['Dealer''s cards: ', obj.handToString(obj.dealerHand), ' | Total: ', num2str(obj.calculateTotal(obj.dealerHand))]);
            end
        end

        % Method to determine the winner and update balance
        function balanceChange = determineWinner(obj, bet)
            playerTotal = obj.calculateTotal(obj.playerHand);
            dealerTotal = obj.calculateTotal(obj.dealerHand);
            
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
