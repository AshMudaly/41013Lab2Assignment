SafeCo proposes to sell to the casino industry a robot called HitMe that can deal Blackjack, receive, and dish out chips accordingly. In addition, a DoBot with a suction cup will also be able to play the game for a customer virtually, with a GUI to control what bets are placed, to hit or check advise how much money is won/lost.


Coding Standards:
------------------------------------
* Class def: ClassName
* Function def: Function_Name
* Properties: propertyName
* PLY Files: objectName1


Code Structure:
------------------------------------
* Class 1: DoBotSuction
* Class 2: HitMe (preliminary name)
* Class 3: BlackjackGame


REMINDER
------------------------------------
REMEMBER TO FETCH AND PULL BEFORE CODING SESSIONS 

REMEMBER TO COMMIT AND PUSH AFTER ALL CODING SESSIONS

To Do List
------------------------------------
* Create 6 DOF robot (HitMeBot - Dealer)
* Use a real robot that interacts with 6 DOF robot (DoBot with suction cup - Player)
* Create a GUI with options for the player to play the game, below are the functions we want
* * What to Bet (numeric input)
* * Hit me (Button)
* * Check (Button) 
* * E-Stop (Big Button)
* * Current Cards (Read Out)
* * Current Money (Read Out)
* * Restart button (Button)
* All robot movement using RMRC and colision avoidance
* E-Stop stops movement immediatly, to restart machine, "unclick" digital E-Stop and press restart button
* Movement of the robots slow when human is "detected" within a range and stops when too close


Scope of Project
------------------------------------
* Use RMRC (robot movement end effector movement is linear and not an arc)
* Collision avoidance
* A GUI Where appropriate
* Creatively use a real robot that mimics or enhances the simulation and application

Safety Considerations
------------------------------------
* System reacts to user emergency stop action (1) GUI e-stop; (1) Hardware e-stop. (Minus marks if no e-stop).
* Trajectory reacts to simulated sensor input (e.g. light curtain) (1)
* Trajectory reacts to a forced simulated upcoming collision (1)
* Design a simulated environment with strategically placed models of appropriate safety equipment (1)

Scaling Options
------------------------------------
* Image of Card shown on GUI from the DoBot
* More blackjack options (Split, specific chip amounts, more players)
* Real deck simulation with image recognition
* Player movement of hit and check by tapping on the table

 
De-Scoping Options
------------------------------------
* Simplify betting options to 1 chip size
* Remove all image acquisition
* Deck of cards only gets a random number, no suit or recognition of previous card being drawn


