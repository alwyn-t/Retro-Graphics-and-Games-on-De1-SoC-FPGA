# ECE 241 Games
All game run on a 60Hz clock to run at the same tick rate as the display as calculating other frames is unnecessary. There is a game select screen to handle the enabling and disabling of different games. To access any game, use the up arrow or down arrow key to hover over a game and the enter key to begin running the game. Within any game, use the escape key to go back to the game select screen. If a game is still running when going to the game select screen, the game will be paused.

```
WARNING: 
THIS PAGE HAS NOT BEEN DEVELOPED FULLY, READ AT YOUR OWN CAUTION, IT MAY NOT MAKE ANY SENSE
```

## Pong
The classic pong game with two controllable paddles on either side of the screen. The left paddle is controlled by the W and S key while the right paddle is controlled by the up arrow and down arrow key. 

Key features, 
PS2 inputs, using the PS2 clock and reading the data, able to handle as many keys as I want, in this case, I used this to have W and S to control the left paddle, while having the UP and DOWN arrow keys to control the right paddle.
Physics including ball bounces using unique method of having a wire mapping the next position of the ball and the paddles. When the next frame is supposed to be calculated, the FPGA does a check to make sure it is in bounds. If the ball intersects the paddle or goes above or below the visible screen, the ball's new velocity, and position is calculated with this collision in mind. As for the left and right sides of the screen, I used the attribute that the required wire width to include the visible area also included the imaginary blanking and sync zones, so similarly, I used the next position wires to detect where in the blank or sync zones the ball would land to determine the appropriate score to change and the next velocity to set to (the ball goes to the opponent which just scored to give the player who just got scored on a bit of rest time).
The score utilized a modified version of the hex decoder I made earlier in the year. It was a bit tricky to take into account the horizontal shift required for the right side scores as when hitting the double digits, the number shifts.
## Dino


Key features, 
As the game goes on, the dinosaur runs faster
More advanced physics, using the basics from the pong game, I implemented gravity based physics onto the dinosaur and control so the player can have a short or high jump by either tapping or holding the jump button. With the rapidly changing positive and negative values, I had to shift the velocity values by 128 to ensure consistent behaviour. With additional checks and unique behaviour wires like, max velocity, normal fall velocity, slow fall velocity, stop velocity and a jump counter to track the time in the air.
Hit detection has smaller hit boxes to allow for more easy game play as it can be frustrating if the dinosaur is running too fast and you die because you hit one pixel which feels unfair.
Implemented a randomizer module responsible for adding randomness to the system. Uses the 50MHz clock and 4 prime number counters, of which, the last 2 bits of each are placed in an output value. With each counter overflowing at different rates, this simulates random values. This randomizer is constantly running in the background and is 'random' based on the amount of time that has passed. This allows the game to have a semi randomized game as it is inhuman to be able to start the game at the exact same nanosecond. This randomizer is implemented into the height of the birds, the height of the cactus and the 'cooldown' of both the birds and cactus.
Using similar techniques from game design, I have 4 bird entities and 4 cactus entities to avoid large amounts of computations. After going off screen on the left, all entities get stored at the right most value (1023) and when the cooldown (responsible for keeping the cactus and birds spaced) goes to 0, a bird or cactus respectively gets 'dispatched' and begins to move to the left. There are also 4 heights of the cactus which all have their respective hit boxes
Sprite, using the block memory, I created sprite maps for the dino game for all the assets. This includes, birds, dinosaur, cactuses, and the numbers. Because I had a sprite map to reduce the amount of space used, I created a custom address module which took the type of sprite that needed to be displayed (using the underlying box hit boxes) and found the correct address to get the value. Additionally, due to the limited VGA buffer that I implemented (I will talk about it later). I had a custom RGB layout which allows for the sprite to overlap and where there are transparent pixels on the foreground sprite, the FPGA will display the background sprite. This allows for the dino game to have more refined look. 

## Game Select
Before moving on to the game selection page, I added a finite state machine for both games to handle the end game, pausing and starting state. For pong, I have a start, game, pause and end state. Start will always reset all registers for a new game, the game runs all the physics and scoring while pause occurs when hitting escape and end state occurs when a player hits 15 points and wins a match. To play a new game or unpause, the state machine waits for a space key press. While for dino, I have a start, game, pause, end_check and end state. The main difference is because the main game input is the space key, the end_check state ensure the user isn't holding the space bar allowing for them to see their score and how they died. These state machines also operate at the same time as the game select finite state machine (which handles overarching behaviour). I have hover_pong, load_pong, ingame_pong, hover_dino, load_dino, ingame_dino states. You can observe the hover states when you hit escape and can switch between pong and dino. During the hover states, I disable both dino and pong on top of the two games going into a paused state when exiting to the game select menu; additionally, the display outputs of the games are disabled and a new video controller is routed to the display module to be displayed. The load states are responsible for loading any assets if need be like scores. The ingame states simply re enable the games and reroutes the display signals to the respective display module.
ASCII characters, based on the sprite map rom modules I had for the dino game, I created an ASCII ROM which has all the capital and lowercase alphabets and a handful of special characters. Although you can't see many characters, I have the full file loaded onto the FPGA (and can be seen on my computer).


## Video Buffer and VGA
One of the first things I implemented was my display adapter, responsible for the timings directly to the VGA DAC (digital to analog converter). I ended up creating my own custom VGA module which uses the SVGA standard to display 800 by 600 pixels (about double the VGA standard) all at 60Hz. This required me to run the adapter at 40MHz and also learn all the required timings for the SVGA standard to work properly.
I also created a video buffer module comprised of two components. One being a FIFO controller and one being a SDRAM controller. The SDRAM controller is responsible for either writing data into the SDRAM or reading data from the SDRAM. By sending signals down the column address strobe and row address strobe and their respective address along the address and bank address data lines; I can specify the address to either read or write, the command is determined by whether the write enable signal is sent when the row address is sent. One of the issues I can across was the data not being writing and so I did a deep dive and eventually found out that I needed to have a shifted clock cycle to ensure all data or signal lines were stable before the SDRAM can read the data/signals.
The FIFO controller works in conjunction and acts like a smaller buffer. Because the SDRAM takes a few cycles to read or write, I needed to pre-read data before it was needed by my display module. I ended up with a cool module which has two cursors, one is reading out of the FIFO buffer and one is writing into the buffer with data from the SDRAM. The cursor writing continuously tries to read from the SDRAM and writes in as long as the reading cursor is ahead. While the reading cursor takes from the buffer whenever the display module needs it. This ends up causing two different clocks to work on the same register memory space without conflict.
One last note, I ended up pushing the SDRAM to the highest clock rate of 200MHz to allow for enough bandwidth and additionally, I modified the pong and dino video controllers to only send pixels that need to be updated. This requires storing the last position of the entities that are moving but ensures that whenever an entity moves, the new position can be drawn and the old position can be erased. Overall the SDRAM controller took the longest to implement with it taking about 2 weeks of constant work, trying to learn how it works with little external help.

Additionally, each key is used to reset either one game or both games or all the modules at the same time.
And the switches can be used for the game, although I would recommend using the keyboard

I also wanted to mention that I created multiple scripts for the sprite maps which took in css files and converted them to mif files with proper syntax.



# PONG
## PS2 Controller - 
used negative edge of PS2 clock to read data a read make/break codes and then used that to toggle flags for keys (multiple key presses at the same time)
## Physics - 
used offscreen to detect scoring and next position
## Hex decoder - 
score display is based on hex decoder base

# DINO
## Advanced physics - 
gravity acceleration and variable jump height based on how long you hold the jump button
## Hit Detection - 
for cactus it's thinner width wise for bird it's thinner height wise and for cactus, hit box for the height is based directly on the height of the cactus itself
## Entities - 
4 birds, 4 cactus, start from the right and when cooldown timer goes low, dispatch new bird or cactus respectively
## Randomness - 
4 prime number counters are created, highest 2 bits are put together to make one byte output and runs on the 50MHz clock, so a human can't start the game at the exact same time and you get random values
## Sprites - 
used block memory ROM to store sprite map, made special addressing module to make it easy to get the ROM address needed, I was able to add an alpha bit so sprite can overlap without any issue

# GAME SELECT
## Finite State Machines - 
pong has start, game, pause, end, while dino has a special end_check state which ensures that when jumping, if you die, the game will wait for the space bar to be released before restarting. Game select is the overarching which has hover, load and ingame for each game. when in hover, both games are disabled and the display output of the game select video controller is pushed through, while when ingame, the respective game video controller will be routed. additionally, when going back to the game select screen the game is paused and saved so when you re-enter, you are back where you left it
## ASCII - 
extension of DINO sprite ROM concept but dedicated to a different format where I store 8x16 character sprites with 1 byte for each row as binary on/off 
## Recolouring - 
with the ASCII in mind, we can easily recolour it which is where I used the switches to set the colours of the background and text colour

# VIDEO BUFFER AND VGA
## VGA - 
implemented 800 x 600 60hz SVGA standard with a custom adapter, it requires a 40MHz clock which I used a PLL for.
## VIDEO BUFFER - 
two components, FIFO controller and SDRAM controller
## SDRAM controller - 
responsible for read and writing to the SDRAM. I had lots of troubles but it ended up being the clock of the SDRAM needed to be shifted to ensure all data/signal lines were stable before the SDRAM reads them. Due to limitations I will talk about, I ended up running the SDRAM at the max clock rate of 200MHz.
## FIFO controller - 
The FIFO controller works in conjunction and acts like a smaller buffer. Because the SDRAM takes a few cycles to read or write, I needed to pre-read data before it was needed by my display module. I ended up with a cool module which has two cursors, one is reading out of the FIFO buffer and one is writing into the buffer with data from the SDRAM. The cursor writing continuously tries to read from the SDRAM and writes in as long as the reading cursor is ahead. While the reading cursor takes from the buffer whenever the display module needs it. This ends up causing two different clocks to work on the same register memory space without conflict. Additionally, I modified the pong and dino video controllers to only send pixels that need to be updated. This requires storing the last position of the entities that are moving but ensures that whenever an entity moves, the new position can be drawn and the old position can be erased. Overall the SDRAM controller took the longest to implement with it taking about 2 weeks of constant work, trying to learn how it works with little external help.