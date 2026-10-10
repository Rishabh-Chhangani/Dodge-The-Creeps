# Dodge the Creeps!

A 2D survival game built using the [Godot Engine](https://godotengine.org/). In this game, the player must move around the screen and dodge incoming enemies for as long as possible to achieve a high score.

This project is based on the official Godot beginner's "Your First 2D Game" tutorial.

## Project Structure

- **`Scene/`**: Contains all the visual `.tscn` (scene) files.
  - `main.tscn`: The primary game scene that ties everything together.
  - `player.tscn`: The playable character scene.
  - `mob.tscn`: The enemy scene.
  - `hud.tscn`: The Heads-Up Display (UI) scene.
- **`script/`**: Contains the GDScript (`.gd`) files that drive the game logic.
  - `main.gd`: The core game manager. Spawns enemies, controls the score, and manages the game over/start states.
  - `player.gd`: Handles the player's 8-way movement, input, screen clamping, animation handling, and collision detection.
  - `mob.gd`: The enemy script. Randomly selects a visual appearance on spawn and automatically destroys itself when it leaves the screen.
  - `hud.gd`: Manages UI elements like the start button, score, and temporary messages.
- **`art/`**: Contains all visual (sprites) and audio assets (music and sound effects).
- **`fonts/`**: Contains the `Xolonium-Regular.ttf` font used in the HUD.

## Core Mechanics

1. **Player Movement**: The player is controlled using directional inputs (`move_right`, `move_left`, `move_up`, `move_down`). The `player.gd` script normalizes velocity so diagonal movement isn't faster, and clamps the position to the screen size.
2. **Enemy Spawning**: The `main.gd` script uses a `MobTimer`. On timeout, a new `mob.tscn` is instantiated at a random offset along a `MobPath` (a `Path2D` node outlining the screen). The mob is given a random speed and direction.
3. **Collision Detection**: When an enemy touches the player's `Area2D`, the `_on_body_entered` signal in `player.gd` fires, hiding the player and emitting a custom `hit` signal.
4. **Game Loop**: The `hit` signal notifies `main.gd` to run `game_over()`, stopping spawn timers and updating the HUD. Clicking the start button on the HUD triggers `start_game`, resetting the score, player position, and clearing old enemies.

## Getting Started

1. Open the project folder in Godot Engine (Version 4.5+).
2. Open `res://Scene/main.tscn` as the main scene.
3. Press `F5` (or click the Play button) to run the game.
