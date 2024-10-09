function guifunctionsample(action)
   basebet = 10;
   if nargin == 0
      P1 = [];
      P2 = [];
      D = [];
      bet1 = 0;
      bet2 = 0;
      count = 0;
      total = 0;
      who = 1;
      buttons = initbuttons;
      setbuttons({'Double','Stand','Hit'})
      set(gcf,'userdata',{P1,P2,D,bet1,bet2,count,total,who,buttons})
      action = 'Deal';
   end
   
   userdata = get(gcf,'userdata');
   [P1,P2,D,bet1,bet2,count,total,who,buttons] = deal(userdata{:});
   
   % Modify game flow to include BlackjackTest decisions
   switch action
      case 'Deal'
         setup;
      case 'Hit'
         hit;
      case 'Stand'
         stand;
      case 'Keep'
         keep;
      case 'Double'
         double;
      case 'Split'
         split;
      case 'Close'
         close(gcf)
         return 
   end
   
   % Store updated values
   set(gcf,'userdata',{P1,P2,D,bet1,bet2,count,total,who,buttons})
   
   % Decision-making using BlackjackTest
   function decision = autoDecision(P1, D)
      decision = BlackjackTest(P1, D);  % Call your test function here
      % 'decision' could be 'Hit', 'Stand', 'Double', etc.
   end
  
   % ------------------------
   function setup
      delete(get(gca,'children'))
      bet1 = basebet;
      bet2 = 0;
      who = 1;
      P1 = card;  % Player's hand
      D = card;   % Dealer's hand
      P1 = [P1 card];
      D = [D -card];  % Hide dealer's hole card
      P2 = [];
      show(1, P1, false)
      show(3, D, false)
      
      % Automatically make a decision using BlackjackTest
      action = autoDecision(P1, D);
      blackjack(action);  % Call blackjack with the decision from BlackjackTest
      
      if value(P1) == 21
         twentyone;
      elseif mod(P1(1), 13) == mod(P1(2), 13)
         setbuttons({'', 'Keep', 'Split'});
         strategy(P1, D, false);
      else
         setbuttons({'Double', 'Stand', 'Hit'});
         strategy(P1, D, false);
      end
      updateTotal();
   end
end
