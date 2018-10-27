# The-Maze-Towers-RBX
A Roblox game built around the idea of running through a tower of mazes while being attacked by hoards of enemies.

## Game Overview

### Concept
In this game, players are transported into the bottom floor of a randomly generated maze and have to escape (by finding the exit on the top floor). 
If players are killed, they lose; otherwise, if they escape the tower, they win.

### Characters
The game features a number of characters, such as leprechauns, cats, dogs and humans. Each of these has a unique look, size, movement speed, luck and vision
which will affect the way the game is played. For example, leprechauns can run fast but have poor vision, so these characters will often run into deadends and
have to backtrack. Cats are slower but with better vision, allowing them to be more efficient in their movements.

### Powerups
Powerups are additional objects that will spawn at deadends in the maze. These can either give the players a short boost, such as having faster movement or increasing
their health, but may also have negative effects, such as unleashing trap doors, dropping a player's health, or decreasing their speed. It is up to players how they wish
to use these powerups and the helpfulness of a powerup is directly linked to the character being used (through the character's luck stat).

### Enemies
The game has a number of enemies which will attack human players. The AI characters will either move around the maze, or, if a player has been spotted,
chase after the player in an attempt to kill them. Players can escape these computer characters by either outrunning them or by defeating them.

### Attack System
The game features a very simple attack system of clicks/taps. Each click will fire a ball in the direction of the mouse which will deal damage to enemy players.
With special characters, such as the leprechaun, attacks will also deal additional effect damage (such as Damage Over Time for leprechauns).

### Coins
The game awards coins to players for tasks such as defeating enemy players and escaping the maze. By default, each player will earn 20 coins for a successful
escape, but this value quickly escalates when the player is involved in battles (earning between 5 and 10 coins for each successful kill). Once a player has earned
enough coins, they can use these to purchase additional characters, changing their play of the game.


## Engine Overview
### Server-Sided Modules
The majority of the code for the game engine is located within `ServerScriptService > Modules`. Each module is responsible for a single aspect of the game, such as
the maze generation, enemy AI or characters, and is largely decoupled from the other modules used for the engine.

### Client-Sided Modules
There are additional modules which control the user's experience with the game, such as with the user interface, messages for the user, ensuring the game has loaded,
etc. Much of this code is located within `ReplicatedStorage` with additional UI control located within `StarterGui`.

### The Main Engine
The engine itself is controlled by a single module located within `ServerScriptService > Main > Engine`. This links all of the modules together into a single, main interface,
with available methods for setting up the game and changing game settings.

### Minigames Control
To provide a game experience for users, the engine works in tandem with a minigames controller. This controls the player's experience outside of the game, such as
providing players with time between games, allowing additional players to join games, and giving players time to browse the shops.
The code for the minigames controller is located within `ServerScriptService > Main > MinigamesController`.

### Main Game
Finally, there is a single script which controls linking the minigames controller to the main engine and ensuring the game runs smoothly. This script is located within
`ServerScriptService > Main`.

## Playing the Game
The game is available to play on Roblox at [link](https://www.roblox.com/games/2158884655/The-Maze-Towers). This requires a Roblox account to play.
