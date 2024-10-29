classdef BlackjackTest
    %#ok<*NASGU>
    %#ok<*NOPRT>
    %#ok<*TRYNC>
    properties
        balance;   % Player's starting balance
        deck;      % Deck of cards
        cardNames; % Card names
        playerHandString;  % Readable player hand string
        dealerHandString;  % Readable dealer hand string
        playerHand; % Player's current hand
        dealerHand; % Dealer's current hand
    end

    methods
        % Constructor to initialize properties
        function obj = BlackjackTest()
            obj.balance = 100;  % Player's starting balance
            obj.cardNames = {'Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King'};
            obj = obj.shuffleDeck();  % Shuffle the deck at the start
        end

        % Function to start the game
        function obj = play(obj, app)
            app.updateAppUI(obj);  % Update UI with initial balance

            while obj.balance > 0
                obj.playerHand = [];
                obj.dealerHand = [];
                app.BetAmount.Value = 0;  % Reset the bet input

                % Get the bet amount from the GUI
                bet = app.BetAmount.Value;  % Retrieve the bet from the numeric edit field

                % Validate the bet amount
                if bet < 1 || bet > obj.balance
                    uialert(app.UIFigure, 'Invalid bet amount! Please enter a value between 1 and your current balance.', 'Bet Error');
                    continue;  % Skip this iteration if the bet is invalid
                end

                % Shuffle deck if fewer than 15 cards are left
                if length(obj.deck) < 15
                    obj = obj.shuffleDeck();
                end

                % Deal initial cards
                obj.dealCard('player', 2);
                obj.dealCard('dealer', 2);
                app.updateAppUI(obj);  % Update UI to show hands

                % Player's turn
                playerBust = obj.playerTurn(bet, app);  % Pass app to update UI during player's turn

                % Dealer's turn if player hasn't busted
                if ~playerBust
                    obj = obj.dealerTurn(bet, app);
                end

                % Ask if the player wants to continue (you can implement this in the GUI as a button)
                if obj.balance <= 0
                    uialert(app.UIFigure, 'You have run out of money! Game over.', 'Game Over');
                end
            end
        end

        % Shuffle the deck
        function obj = shuffleDeck(obj)
            deckValues = [1:10, 10, 10, 10];  % J, Q, K represented by 10, Ace as 1
            obj.deck = repmat(deckValues, 1, 4);  % 4 suits (total 52 cards)
            obj.deck = obj.deck(randperm(length(obj.deck)));  % Shuffle the deck
        end

        % Helper function to deal a card
        function obj = dealCard(obj, target, numCards)
            if nargin < 3
                numCards = 1;
            end
            numCards = min(numCards, length(obj.deck));

            switch target
                case 'player'
                    obj.playerHand = [obj.playerHand, obj.deck(1:numCards)];
                    obj.playerHandString = obj.handToString(obj.playerHand);
                case 'dealer'
                    obj.dealerHand = [obj.dealerHand, obj.deck(1:numCards)];
                    obj.dealerHandString = obj.handToString(obj.dealerHand);
            end

            obj.deck(1:numCards) = [];  % Remove dealt cards from the deck
        end

        % Handle player's turn
        function playerBust = playerTurn(obj, bet, app)
            playerBust = false;

            while true
                app.updateAppUI(obj);  % Update UI to show current hands

                if length(obj.playerHand) >= 5
                    uialert(app.UIFigure, 'You have 5 cards. You must stand.', 'Stand Alert');
                    break;
                end

                % Here you could add a UI option for hit or stand instead of using input
                choice = app.PlayerActionDropDown.Value;  % Assume you have a dropdown for actions

                switch choice
                    case 'Hit'
                        obj.dealCard('player', 1);
                        if obj.calculateTotal(obj.playerHand) > 21
                            uialert(app.UIFigure, 'Bust! You lose.', 'Bust Alert');
                            obj.balance = obj.balance - bet;
                            playerBust = true;
                            app.updateAppUI(obj);  % Update UI after bust
                            return;  % Exit the player turn
                        end
                    case 'Stand'
                        break;  % Exit the player turn
                    otherwise
                        uialert(app.UIFigure, 'Invalid choice. Please select Hit or Stand.', 'Invalid Choice');
                end
            end
        end

        % Handle dealer's turn
        function obj = dealerTurn(obj, bet, app)
            dealerTotal = obj.calculateTotal(obj.dealerHand);
            app.updateAppUI(obj);  % Update UI for dealer's turn

            while dealerTotal < 17
                obj.dealCard('dealer', 1);
                dealerTotal = obj.calculateTotal(obj.dealerHand);
                app.updateAppUI(obj);  % Update UI after each dealer draw
            end

            if dealerTotal > 21
                uialert(app.UIFigure, 'Dealer busts! You win.', 'Dealer Bust');
                obj.balance = obj.balance + bet;
            else
                % Determine the winner
                balanceChange = obj.determineWinner(obj.playerHand, obj.dealerHand, bet);
                obj.balance = obj.balance + balanceChange;
            end

            app.updateAppUI(obj);  % Update UI to show final hands
        end

        % Helper function to calculate hand total
        function total = calculateTotal(~, hand)
            total = sum(hand);
            aceCount = sum(hand == 1);
            while total <= 11 && aceCount > 0
                total = total + 10;  % Count Ace as 11 if it doesn't bust
                aceCount = aceCount - 1;
            end
        end

        % Helper function to convert a hand to a readable string
        function handString = handToString(obj, hand)
            handString = strjoin(obj.cardNames(hand), ', ');
        end

        % Helper function to determine the winner and update balance
        function balanceChange = determineWinner(obj, playerHand, dealerHand, bet)
            playerTotal = obj.calculateTotal(playerHand);
            dealerTotal = obj.calculateTotal(dealerHand);

            if playerTotal > dealerTotal
                balanceChange = bet;  % Win the bet
            elseif playerTotal < dealerTotal
                balanceChange = -bet;  % Lose the bet
            else
                balanceChange = 0;  % No change in balance
            end
        end

        % Function to update the app UI with current game state
        function updateAppUI(obj, app)
            app.BalanceLabel.Text = ['Balance: $', num2str(obj.balance)];
            app.PlayerHandTextArea.Value = obj.playerHandString;  % Update player's hand
            app.DealerHandTextArea.Value = obj.dealerHandString;  % Update dealer's hand
        end
    end
end
