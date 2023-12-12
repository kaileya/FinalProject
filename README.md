# FinalProject

video overview: https://clipchamp.com/watch/PoC5z7zUmfs

OVERALL: I am proud of the game I created! This was a tough assignment as I am not a computer science major of any sort, am not involved in the gaming world, and had never coded in another language than python. I am really happy with myself for creating a tangible game in a new language, despite (what felt like) endless blue error screens.

Notes: I recreated the game Breakout by Atari using code from the CS50 Pong assignment. Basing the assignment off of the Pong assignment code made my journey a lot smoother as it gave me a basic structure to understand the setup of a game written in lua. My alterations to the code included changing the direction of the ball movement (vertical rather than horizontal) and its change in direction when colliding with objects (slight changes in the horizontal direction); changing the direction of the paddle movement (horizontal rather than vertical); having the ball move with the paddle only for the start state of the game; adding a grid of blocks in the same table; making the blocks dissappear after being hit; adding to the score when a block is hit; making the ball reverse direction when hitting the top wall, side walls, or bricks; keeping track of rounds; increasing the speed of ball every round; creating a win screen and loss screen

Had my friends sample the game and came across some random things to add to easy user play like writing Rounds: _ "of 5" to ensure they knew how many rounds they had to destroy the bricks, making the ball move with the paddle, and altering the color/transperency of the bricks so it was easier to see and understand.

UNRESOLVED ISSUES: The ball does not properly interact with the paddle and will sometimes hit it and fall through after glitching. Additionally, the ball will sometimes lag while it is traveling between the paddle and bricks.

EXAMPLES OF CHALLENGES FACED:
- using LOVE and lua coding in general was a big challenge. Even after following the entire Pong assignment videos it was a struggle to grasp the differences between lua and python. I had to look through the manual for basic syntax and online for functions like making my bricks dissappear. Additionally at the very beginning I remember trying to figure out how to run the lua code in love.
  
- adding the bricks into the same table and getting them to dissappear
    * had a lot of trouble figuring out how to add the bricks in as one group. I started with the bricks as individual             objects labeled brick1, brick2, etc. but this was very inefficient and only allowed me to have 4 bricks on the screen        (which would not be a very fun game)
    * Realized i could use for loops to create rows and columns of bricks but struggled with the difference in syntax of lua
    * Then i attempted to add it to the Brick.lua file in my folder but kept getting error messages
    * Then i attempted to add it into my main.lua code but kept getting errors
    * Finally was able to solve it after a LONG TIME looking at the format of other example code
    * had to add another variable to my brick.lua code to make it visible or not and keep track
      
- increasing the speed of the ball every round
    * was having trouble figuring out where to add in the code to increase the ball speed every round
    * I tried to add it to the game state but then it would reset every time and not end up increasing
    * Finally added it to the update section and incorporated my variable "round" to increse the speed based on what round         it is

  THINGS I WISH I COULDVE DONE:
  - Add power ups that fall down (tried to but could not do it without getting errors)
  - make the paddle size decrease every round (was not working consistently/getting errors)
