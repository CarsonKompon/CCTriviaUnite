# Trivia Unite
 A trivia game made in ComputerCraft designed for 1 player. Powered by [OpenTDB](https://opentdb.com/).
 
 For multiplayer, check out [Trivia Unite Together](https://github.com/cklidify/CCTriviaUniteTogether)
 
 ![Showcase](/screenshots/showcase.gif)
 
 [![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
 
## How it works
 Using the [OpenTDB API](https://opentdb.com/api_config.php), the game receives 10 questions at the start of the game.
 Each round, the game will type out a question, and present you with either True/False or Multiple Choice options.
 The quicker you answer, the more points you receive. Try to go for the highest score!

## Installation
 If you wish to play with a monitor/speaker setup, you should create a setup similar to the image below (Position of monitor and speaker does not matter)
 
 ![Guide](/screenshots/setup.png)
 
 Then enter the Advanced Computer, and enter `pastebin run czuQVY5F` into the terminal.
 
 Once it's been installed to your Computer, run the game by entering `triviaunite` into the terminal.
 
 ## Startup Script
 
 If you want the game to boot with the computer, create a new startup file by entering `edit startup.lua` and then enter the following code:
 
 ```lua
 shell.run("triviaunite")
 ```
