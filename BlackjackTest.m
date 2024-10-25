classdef BlackjackTest
    properties
        balance;   % Player's starting balance
        deck;      % Deck of cards
        cardNames; % Card names
        GuiTesting; % Reference to the GUI app instance
    end

    methods
        % Constructor to initialize properties
        function obj = BlackjackTest(GuiTestingInstance)
            obj.GuiTesting = GuiTestingInstance; % Store reference to app for GUI output
            obj.balance = 100;
            obj.cardNames = {'Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King'};
            obj = obj.shuffleDeck();
            obj.GuiTesting.updateOutput('Welcome to Blackjack!');
        end
        
        % Function to shuffle the deck
        function obj = shuffleDeck(obj)
            deckValues = [1:10, 10, 10, 10];
            obj.deck = repmat(deckValues, 1, 4);
            obj.deck = obj.deck(randperm(length(obj.deck)));
            obj.GuiTesting.updateOutput('Deck shuffled!');
        end
        
        % Function to start the game
        function play(obj)
            while obj.balance > 0
                obj.GuiTesting.updateOutput(['Current balance: $', num2str(obj.balance)]);
                % Wait for bet to be entered in the GUI
                obj.GuiTesting.waitForBet();
                bet = obj.GuiTesting.betAmount;  % Get bet amount from the GUI
                obj.GuiTesting.updateOutput(['You bet $', num2str(bet)]);
                
                % Shuffle deck if fewer than 15 cards are left
                if length(obj.deck) < 15
                    obj = obj.shuffleDeck();
                end
                
                % Player's and Dealer's hands
                [playerHand, obj] = obj.dealCard([], 2);
                [dealerHand, obj] = obj.dealCard([], 2);
                obj.showHands(playerHand, dealerHand, true);  % Show initial hands

                % Player's turn
                [playerBust, obj] = obj.playerTurn(playerHand, dealerHand, bet);
                
                % Dealer's turn if player hasn't busted
                if ~playerBust
                    obj = obj.dealerTurn(playerHand, dealerHand, bet);
                end

                % Ask if the player wants to continue via the GUI
                if obj.balance > 0
                    obj.GuiTesting.updateOutput('Do you want to play again?');
                    obj.GuiTesting.waitForPlayAgainDecision();  % Wait for player decision (y/n)
                    if ~obj.GuiTesting.playAgain
                        break;  % Exit the game
                    end
                else
                    obj.GuiTesting.updateOutput('You have run out of money! Game over.');
                end
            end
        end

        % Function to handle player's turn
        function [playerBust, obj] = playerTurn(obj, playerHand, dealerHand, bet)
            playerBust = false;
            obj.GuiTesting.updateOutput('Player''s turn.');

            while true
                obj.showHands(playerHand, dealerHand, true);

                % Wait for the player's decision (hit or stand) via the GUI
                obj.GuiTesting.waitForPlayerDecision();
                if obj.GuiTesting.PlayerChoseHit
                    [playerHand, obj] = obj.dealCard(playerHand);
                    if obj.calculateTotal(playerHand) > 21
                        obj.GuiTesting.updateOutput('Bust! You lose.');
                        obj.balance = obj.balance - bet;
                        obj.GuiTesting.updateOutput(['New balance: $', num2str(obj.balance)]);
                        playerBust = true;  % Player busted
                        return;  % Exit the player turn
                    end
                elseif obj.GuiTesting.PlayerChoseStand
                    break;  % Exit the player turn
                end
            end
        end

        % Function to handle dealer's turn
        function [obj] = dealerTurn(obj, playerHand, dealerHand, bet)
            dealerTotal = obj.calculateTotal(dealerHand);
            obj.GuiTesting.updateOutput(['Dealer''s cards: ', obj.handToString(dealerHand), ' | Total: ', num2str(dealerTotal)]);

            % Dealer draws cards until total is at least 17
            while dealerTotal < 17
                [dealerHand, obj] = obj.dealCard(dealerHand);
                dealerTotal = obj.calculateTotal(dealerHand);
                obj.GuiTesting.updateOutput(['Dealer draws a card. Dealer''s cards: ', obj.handToString(dealerHand), ' | Total: ', num2str(dealerTotal)]);
            end

            % Determine if the dealer busts
            if dealerTotal > 21
                obj.GuiTesting.updateOutput('Dealer busts! You win.');
                obj.balance = obj.balance + bet;  % Player wins
            else
                % Determine the winner
                balanceChange = obj.determineWinner(playerHand, dealerHand, bet);
                obj.balance = obj.balance + balanceChange;
            end
            obj.GuiTesting.updateOutput(['New balance: $', num2str(obj.balance)]);
        end  % Corrected the placement of this end

        % Helper function to calculate hand total
        function total = calculateTotal(~, hand)
            total = sum(hand);
            aceCount = sum(hand == 1);
            while total <= 11 && aceCount > 0
                total = total + 10;  % Count Ace as 11 if it doesn't bust the hand
                aceCount = aceCount - 1;
            end
        end

        % Helper function to convert a hand to a readable string
        function handString = handToString(obj, hand)
            handString = strjoin(obj.cardNames(hand), ', ');
        end

        % Helper function to show hands
        function showHands(obj, playerHand, dealerHand, hideDealer)
            obj.GuiTesting.updateOutput(['Your cards: ', obj.handToString(playerHand), ' | Total: ', num2str(obj.calculateTotal(playerHand))]);
            if hideDealer
                obj.GuiTesting.updateOutput(['Dealer''s first card: ', obj.cardNames{dealerHand(1)}]);
            else
                obj.GuiTesting.updateOutput(['Dealer''s cards: ', obj.handToString(dealerHand), ' | Total: ', num2str(obj.calculateTotal(dealerHand))]);
            end
        end

        % Helper function to determine the winner and update balance
        function balanceChange = determineWinner(obj, playerHand, dealerHand, bet)
            playerTotal = obj.calculateTotal(playerHand);  % Calculate player total
            dealerTotal = obj.calculateTotal(dealerHand);  % Calculate dealer total

            if playerTotal > dealerTotal
                obj.GuiTesting.updateOutput('You win!');
                balanceChange = bet;  % Win the bet
            elseif playerTotal < dealerTotal
                obj.GuiTesting.updateOutput('Dealer wins.');
                balanceChange = -bet;  % Lose the bet
            else
                obj.GuiTesting.updateOutput('It''s a tie!');
                balanceChange = 0;  % No change in balance
            end
        end
    end
end
