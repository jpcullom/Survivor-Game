# Vampire Survivors Inspired Game

## Overview
This project is a web-based game inspired by the mechanics of Vampire Survivors, developed using Godot 4.5.1. Players will face waves of enemies while upgrading their character and weapons to survive as long as possible.

## Current Status
**Early Prototype** - Basic movement, combat, and enemy AI are functional.

## Controls
- **Arrow Keys**: Move player in all directions
- **Spacebar**: Attack (damages all enemies within 100 pixels)

## Current Features
### Player
- Movement with CharacterBody2D physics
- 100 HP with max health tracking
- Manual attack system (100 pixel range, 10 damage)
- Invulnerability period after taking damage (1 second)
- Visual damage feedback (red flash when hit)

### Enemies
- Automatic spawning every 2 seconds
- AI that chases the player
- 50 HP per enemy
- Deal 10 damage on contact
- 1 second attack cooldown
- Flash white when damaged
- Die when health reaches 0

### UI
- Real-time health display (current/max HP)
- Score counter (framework in place)

## Features

## Planned Features
- **Automatic Attacking**: Player automatically attacks nearby enemies (true Vampire Survivors style)
- **Experience & Leveling**: Enemies drop XP, level up to choose upgrades
- **Dynamic Enemy Waves**: Scaling difficulty over time
- **Upgrade System**: Choose abilities and weapon improvements on level-up
- **Multiple Weapons**: Different weapon types with unique mechanics
- **Better Graphics**: Sprites and animations
- **Audio**: Sound effects and background music
- **Web Export**: Playable in browser

## Development Notes
- Engine: Godot 4.5.1
- Language: GDScript
- Target Platform: Web (HTML5)

## Project Structure
```
vampire-survivors-inspired-game
├── project.godot
├── scenes
│   ├── main.tscn
│   ├── player
│   │   └── player.tscn
│   ├── enemies
│   │   ├── enemy_base.tscn
│   │   └── enemy_spawner.tscn
│   ├── ui
│   │   ├── hud.tscn
│   │   └── upgrade_menu.tscn
│   └── weapons
│       └── weapon_base.tscn
├── scripts
│   ├── player.gd
│   ├── enemy.gd
│   ├── enemy_spawner.gd
│   ├── weapon.gd
│   ├── game_manager.gd
│   └── upgrade_system.gd
├── assets
│   ├── sprites
│   └── audio
├── export_presets.cfg
└── README.md
```

## Setup Instructions
1. Clone the repository to your local machine.
2. Open the project in Godot.
3. Ensure all assets are correctly linked in the scenes.
4. Run the main scene to start the game.

## Gameplay Mechanics
- Players control a character that automatically attacks enemies.
- Collect upgrades and power-ups dropped by defeated enemies.
- Survive as long as possible against increasingly difficult waves of enemies.

## Future Enhancements
- Additional enemy types with unique behaviors.
- More weapon varieties and upgrade paths.
- Online leaderboards to track high scores.

## License
This project is open-source and available for modification and distribution under the MIT License.
