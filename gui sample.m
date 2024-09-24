To create an interactive GUI for this Blackjack game in MATLAB App Designer, you can follow these steps. I'll guide you through the basic implementation of the main elements (Hit, Stand, Displaying Cards, and Dealer Turn) in the GUI. 

Here's a brief outline of the steps and code that you'll need to implement in MATLAB App Designer.

### 1. **Design the Interface:**
   - Open **App Designer** in MATLAB (`MATLAB > Home > New > App > Blank App`).
   - In the **Component Browser**, drag and drop the following components:
     - A **TextArea** for the player's and dealer's hands (e.g., `TextAreaPlayerHand`, `TextAreaDealerHand`).
     - **Buttons** for `Hit` and `Stand` (`ButtonHit`, `ButtonStand`).
     - A **Label** to show the current status (e.g., `LabelMessage`).
     - **Labels** to show totals for both the player and dealer (`LabelPlayerTotal`, `LabelDealerTotal`).

### 2. **Add Properties to Store the Game State:**
   In the **Code View** of the App Designer, define the game state properties under the `properties` block. These will include the deck, player and dealer hands, and other variables needed to track the game progress.

   ```matlab
   properties (Access = private)
       deck % The shuffled deck
       playerHand % Player's hand
       dealerHand % Dealer's hand
       cardNames = {'Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King'}; % Card names
   end
   ```

### 3. **Initialize the Game (Startup Function):**
   In the **StartupFcn**, initialize the deck, shuffle it, and deal two cards to both the player and dealer. This will be the initial setup for the game.

   ```matlab
   function startupFcn(app)
       % Initialize deck (1-10, J, Q, K represented by 10, Ace as 1)
       app.deck = [1:10, 10, 10, 10];
       app.deck = repmat(app.deck, 1, 4); % 4 suits
       app.deck = app.deck(randperm(length(app.deck))); % Shuffle deck

       % Deal initial hands
       [app.playerHand, app.deck] = dealCard(app, [], app.deck, 2);
       [app.dealerHand, app.deck] = dealCard(app, [], app.deck, 2);
       
       % Display the hands
       updateDisplay(app);
   end
   ```

### 4. **Create Button Callbacks:**
   Now, implement the logic for when the user clicks on the "Hit" or "Stand" buttons.

   #### "Hit" Button Callback:
   When the player clicks on the `Hit` button, a new card is dealt, and the player's hand is updated. If the player busts (goes over 21), display the "Bust" message and disable further actions.

   ```matlab
   function ButtonHitPushed(app, event)
       % Deal a card to the player
       [app.playerHand, app.deck] = dealCard(app, app.playerHand, app.deck);
       updateDisplay(app);
       
       % Check for bust or limit
       if calculateTotal(app, app.playerHand) > 21
           app.LabelMessage.Text = 'Bust! You lose.';
           disableButtons(app); % Disable both buttons
       elseif length(app.playerHand) >= 5
           app.LabelMessage.Text = 'You have 5 cards, you must stand!';
           app.ButtonHit.Enable = 'off'; % Disable the hit button
       end
   end
   ```

   #### "Stand" Button Callback:
   The player stands, and the game moves to the dealer's turn. The dealer will automatically draw cards until their total is 17 or greater, and the winner is determined.

   ```matlab
   function ButtonStandPushed(app, event)
       % Dealer's turn
       while calculateTotal(app, app.dealerHand) < 17
           [app.dealerHand, app.deck] = dealCard(app, app.dealerHand, app.deck);
       end
       
       updateDisplay(app); % Show the dealer's full hand

       % Determine the winner
       if calculateTotal(app, app.dealerHand) > 21
           app.LabelMessage.Text = 'Dealer busts! You win.';
       else
           determineWinner(app);
       end
       
       disableButtons(app); % End the game
   end
   ```

### 5. **Helper Functions for Game Logic:**

   - **dealCard:** This function deals cards from the deck and updates the hand.

   ```matlab
   function [hand, deck] = dealCard(app, hand, deck, numCards)
       if nargin < 4
           numCards = 1;
       end
       hand = [hand, deck(1:numCards)];
       deck(1:numCards) = [];
   end
   ```

   - **calculateTotal:** This function calculates the total value of a hand, considering the ace as 1 or 11.

   ```matlab
   function total = calculateTotal(app, hand)
       total = sum(hand);
       aceCount = sum(hand == 1);
       while total <= 11 && aceCount > 0
           total = total + 10; % Count Ace as 11 if it doesn't bust the hand
           aceCount = aceCount - 1;
       end
   end
   ```

   - **updateDisplay:** This function updates the GUI with the current player's and dealer's hands and totals.

   ```matlab
   function updateDisplay(app)
       % Player's hand and total
       app.TextAreaPlayerHand.Value = strjoin(app.cardNames(app.playerHand), ', ');
       app.LabelPlayerTotal.Text = ['Total: ', num2str(calculateTotal(app, app.playerHand))];
       
       % Dealer's hand (only show one card until player stands)
       app.TextAreaDealerHand.Value = [app.cardNames{app.dealerHand(1)}, ', Hidden'];
       app.LabelDealerTotal.Text = 'Total: Hidden';
   end
   ```

   - **determineWinner:** This function compares the player's and dealer's totals and displays the winner.

   ```matlab
   function determineWinner(app)
       playerTotal = calculateTotal(app, app.playerHand);
       dealerTotal = calculateTotal(app, app.dealerHand);
       
       if playerTotal > dealerTotal
           app.LabelMessage.Text = 'You win!';
       elseif playerTotal < dealerTotal
           app.LabelMessage.Text = 'Dealer wins.';
       else
           app.LabelMessage.Text = 'It''s a tie!';
       end
   end
   ```

### 6. **Disabling Buttons After the Game Ends:**
   This function disables the `Hit` and `Stand` buttons once the game ends.

   ```matlab
   function disableButtons(app)
       app.ButtonHit.Enable = 'off';
       app.ButtonStand.Enable = 'off';
   end
   ```

### 7. **Testing the App:**
   After setting up the app and coding all the components, run the app and play through the game. You should be able to interact with the GUI, hit cards, stand, and see the dealer's turn automatically.

---

This is a basic template to get started with developing a Blackjack game GUI in MATLAB App Designer. You can enhance it further by adding more features like displaying card images, allowing the player to restart the game, etc.