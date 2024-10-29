classdef BlackjackTest
    properties
        deck;
        cardNames;
        playerHandString;
        dealerHandString;
        playerHand;
        dealerHand;
        balance;
        betAmount;
        gameStarted;
        updateAppUI;
    end

    methods
        function obj = BlackjackTest()
            obj.cardNames = {'Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King'};
            obj = obj.shuffleDeck();
            obj.gameStarted = false;
            obj.balance = 500;  % Initialize starting balance
        end

        function play(obj, app)
            % Main game loop
            obj.gameStarted = true;
            app.GameWindowTextbox.Value = {'Welcome to Blackjack! Good luck!'};

            % Run the game loop while the balance is greater than 0
            while obj.balance > 0
                obj.playerHand = [];
                obj.dealerHand = [];

                % Place the bet (no output assignment)
                obj.placeBet(app);

                % Wait for player to play (hit or stand)
                uiwait(app.UIFigure);  % This waits for the user to hit "Hit" or "Stand" button
            end

            % End of game message
            if obj.balance <= 0
                app.GameWindowTextbox.Value = {'Game over! You have run out of money.'};
            end
        end

        function obj = shuffleDeck(obj)
            deckValues = [1:10, 10, 10, 10];
            obj.deck = repmat(deckValues, 1, 4);
            obj.deck = obj.deck(randperm(length(obj.deck)));
        end

        function placeBet(obj, app)
            % Ensure a valid bet
            bet = app.BetAmountTextbox.Value;
            if bet < 1 || bet > obj.balance
                uialert(app.UIFigure, 'Invalid bet! Please enter a valid bet.', 'Error');
            else 
                obj.betAmount = bet;
                obj.balance = obj.balance - bet;
                app.BalanceTextBox.Value = obj.balance;  % Update balance in UI
                obj.dealInitialCards(app);  % Deal initial cards
                app.GameWindowTextbox.Value = {'Bet placed. Dealing cards...'};
            end
        end


        function obj = dealInitialCards(obj, app)
            obj.playerHand = [];
            obj.dealerHand = [];

            obj = obj.dealCard(app, 'player', 2);
            obj = obj.dealCard(app, 'dealer', 2);

            app.HitButton.Enable = 'on';
            app.StandButton.Enable = 'on';
        end

        function obj = dealCard(obj, app, target, numCards)
            numCards = min(numCards, length(obj.deck));
            dealtCards = obj.deck(1:numCards);
            obj.deck(1:numCards) = [];  % Remove cards from deck

            if strcmp(target, 'player')
                obj.playerHand = [obj.playerHand, dealtCards];
                obj.playerHandString = obj.handToString(obj.playerHand);
                app.PlayerHandTextbox.Value = {obj.playerHandString};
                app.GameWindowTextbox.Value = ['Player was dealt: ', obj.cardNames{dealtCards}];
            elseif strcmp(target, 'dealer')
                obj.dealerHand = [obj.dealerHand, dealtCards];
                obj.dealerHandString = obj.handToString(obj.dealerHand);
                app.DealerHandTextbox.Value = {obj.dealerHandString};
                app.GameWindowTextbox.Value = ['Dealer was dealt: ', obj.cardNames{dealtCards}];
            end
        end

        function hit(obj, app)
            obj = obj.dealCard(app, 'player', 1);

            if obj.calculateTotal(obj.playerHand) > 21
                app.GameWindowTextbox.Value = {'Bust! You lose.'};
                obj.balance = obj.balance - obj.betAmount;
                app.BalanceTextBox.Value = obj.balance;  % Update balance in UI
                app.HitButton.Enable = 'off';
                app.StandButton.Enable = 'off';
            end
        end

        function stand(obj, app)
            app.HitButton.Enable = 'off';
            app.StandButton.Enable = 'off';
            obj.dealerTurn(app);
        end

        function dealerTurn(obj, app)
            dealerTotal = obj.calculateTotal(obj.dealerHand);

            while dealerTotal < 17
                obj = obj.dealCard(app, 'dealer', 1);
                dealerTotal = obj.calculateTotal(obj.dealerHand);
            end

            obj.checkOutcome(app);
        end

        function total = calculateTotal(~, hand)
            total = sum(hand);
            aceCount = sum(hand == 1);
            while total <= 11 && aceCount > 0
                total = total + 10;
                aceCount = aceCount - 1;
            end
        end

        function checkOutcome(obj, app)
            playerTotal = obj.calculateTotal(obj.playerHand);
            dealerTotal = obj.calculateTotal(obj.dealerHand);

            if dealerTotal > 21 || playerTotal > dealerTotal
                app.GameWindowTextbox.Value = {'You win!'};
                obj.balance = obj.balance + 2 * obj.betAmount;
            elseif playerTotal == dealerTotal
                app.GameWindowTextbox.Value = {'It''s a tie!'};
                obj.balance = obj.balance + obj.betAmount;
            else
                app.GameWindowTextbox.Value = {'Dealer wins.'};
            end
            app.BalanceTextBox.Value = obj.balance;
        end

        function handString = handToString(obj, hand)
            handString = strjoin(obj.cardNames(hand), ', ');
        end

        function displayMessageGame(obj, app, message)
            if obj.gameStarted
                currentMessages = app.GameWindowTextbox.Value;  % Get current messages
                app.GameWindowTextbox.Value = [currentMessages; {message}];  % Append message to game window
            end
        end

        function displayMessagePlayer(obj, app, message)
            % if obj.gameStarted
            currentMessages = app.PlayerHandTextbox.Value;  % Get current messages
            app.PlayerHandTextbox.Value = [currentMessages; {message}];  % Append message to game window
            % end
        end

        function displayMessageDealer(obj, app, message)
            % if obj.gameStarted
            currentMessages = app.DealerHandTextbox.Value;  % Get current messages
            app.DealerHandTextbox.Value = [currentMessages; {message}];  % Append message to game window
            % end
        end
    end
end

