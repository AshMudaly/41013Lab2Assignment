function BlackjackTest()
    clc;
    disp('Welcome to Blackjack!')

    % Initialize deck (1-10, J, Q, K represented by 10, Ace as 1)
    cardNames = {'Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King'};
    deck = [1:10, 10, 10, 10]; % J, Q, K are 10 points
    deck = repmat(deck, 1, 4); % 4 suits

    % Shuffle deck
    deck = deck(randperm(length(deck)));

    % Player's and Dealer's hands
    [playerHand, deck] = dealCard([], deck, 2);
    [dealerHand, deck] = dealCard([], deck, 2);

    % Show initial hands
    showHands(playerHand, dealerHand, cardNames, true);

    % Player's turn
    while true
        % Clear screen and show current hand again before each action
        clc;
        showHands(playerHand, dealerHand, cardNames, true);

        % Check if player already has 5 cards
        if length(playerHand) >= 5
            disp('You have 5 cards. You must stand.');
            break;
        end

        choice = input('Do you want to (h)it or (s)tand? ', 's');
        if choice == 'h'
            [playerHand, deck] = dealCard(playerHand, deck);
            if calculateTotal(playerHand) > 21
                clc;
                showHands(playerHand, dealerHand, cardNames, true);
                disp('Bust! You lose.');
                return;
            end
        elseif choice == 's'
            break;
        else
            disp('Invalid choice. Please type h to hit or s to stand.');
        end
    end

    % Dealer's turn (dealer hits on 16 or less)
    clc;
    disp(['Dealer''s cards: ', handToString(dealerHand, cardNames), ' | Total: ', num2str(calculateTotal(dealerHand))]);
    while calculateTotal(dealerHand) < 17
        [dealerHand, deck] = dealCard(dealerHand, deck);
        clc;
        disp(['Dealer draws a card. Dealer''s cards: ', handToString(dealerHand, cardNames), ' | Total: ', num2str(calculateTotal(dealerHand))]);
    end

    % Check dealer bust
    if calculateTotal(dealerHand) > 21
        disp('Dealer busts! You win.');
        return;
    end

    % Determine the winner
    determineWinner(playerHand, dealerHand);
end

% Helper function to deal a card and update the deck
function [hand, deck] = dealCard(hand, deck, numCards)
    if nargin < 3
        numCards = 1; % Default to dealing 1 card
    end
    hand = [hand, deck(1:numCards)]; % Add card(s) to hand
    deck(1:numCards) = []; % Remove card(s) from deck
end

% Helper function to calculate hand total
function total = calculateTotal(hand)
    total = sum(hand);
    aceCount = sum(hand == 1);
    while total <= 11 && aceCount > 0
        total = total + 10; % Count Ace as 11 if it doesn't bust the hand
        aceCount = aceCount - 1;
    end
end

% Helper function to convert a hand to a readable string
function handString = handToString(hand, cardNames)
    handString = strjoin(cardNames(hand), ', ');
end

% Helper function to show hands
function showHands(playerHand, dealerHand, cardNames, hideDealer)
    disp(['Your cards: ', handToString(playerHand, cardNames), ' | Total: ', num2str(calculateTotal(playerHand))]);
    if hideDealer
        disp(['Dealer''s first card: ', cardNames{dealerHand(1)}]);
    else
        disp(['Dealer''s cards: ', handToString(dealerHand, cardNames), ' | Total: ', num2str(calculateTotal(dealerHand))]);
    end
end

% Helper function to determine the winner
function determineWinner(playerHand, dealerHand)
    playerTotal = calculateTotal(playerHand);
    dealerTotal = calculateTotal(dealerHand);
    if playerTotal > dealerTotal
        disp('You win!');
    elseif playerTotal < dealerTotal
        disp('Dealer wins.');
    else
        disp('It''s a tie!');
    end
end
