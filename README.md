# Space Shooter

A modern space shooter game built with Flutter and Flame engine. Navigate through waves of enemies, collect power-ups, and compete for high scores in this action-packed arcade experience.


## Features

### Gameplay
- Intuitive touch/drag or use Keyboard keys up,down,left,right keys to controls for ship movement
- Automatic shooting system
- Multiple enemy types with unique behaviors
- Progressive difficulty system with waves
- Various power-ups:
  - Shield protection
  - Double fire rate
  - Speed boost
  - Repair (health)
  - Bomb (clear screen)

### Game Mechanics
- Lives system (3 hearts)
- Wave-based progression
- Score tracking
- Achievement system
- Difficulty settings:
  - Easy
  - Normal
  - Hard
  - Insane

### UI Features
- Modern, responsive interface
- Animated menus and effects
- Particle effects for explosions
- Real-time score display
- Health indicator
- Wave counter

### Audio
- Background music
- Sound effects for:
  - Shooting
  - Explosions
  - Power-up collection
- Adjustable music and SFX volume
- Toggle options for music and sound effects

### Additional Features
- Persistent high scores
- Leaderboard system with top 10 scores
- Player name input for high scores
- Settings management
- Pause functionality
- Home screen navigation
- How to play guide

## Controls
- **Movement**: Drag to move ship or use Keyboard keys up,down,left,right keys
- **Shooting**: Automatic
- **Pause**: ESC key or pause button
- **Power-ups**: Collect glowing orbs

## Achievements

- First Blood: Score your first point
- Wave Survivor: Reach wave 5
- Power Player: Collect a power-up
- Sharp Shooter: Achieve high accuracy
- Untouchable: Survive without taking damage

## Technical Details
- Built with Flutter and Flame game engine
- Persistent storage using SharedPreferences
- Efficient particle system for visual effects
- State management using ValueNotifier
- Custom animations and transitions

## Technologies Used

### Core Technologies
- **Flutter**: Cross-platform UI framework by Google (v3.x)
- **Dart**: Programming language optimized for client apps
- **Flame**: 2D game engine built on top of Flutter

### Game Development
- **Flame Engine Components**:
  - `FlameGame`: Base game loop and component management
  - `SpriteComponent`: Rendering game objects
  - `TextComponent`: Rendering text elements
  - `ParticleSystemComponent`: Visual effects
  - `Timer`: Game timing and events

### State Management & Storage
- **ValueNotifier**: Reactive state management for UI updates
- **SharedPreferences**: Local storage for game data
- **JSON**: Data serialization for leaderboard entries

### Audio & Graphics
- **flame_audio**: Sound effects and background music
- **google_fonts**: Custom typography with Orbitron font
- **Particle Systems**: Custom-built effects for explosions and animations

### UI/UX
- **Material Design**: Modern UI components
- **Custom Widgets**: Specialized game interface elements
- **Responsive Design**: Adapts to different screen sizes

## Installation

1. Ensure you have Flutter installed on your system
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the game

## Dependencies
- flutter
- flame
- flame_audio
- google_fonts
- shared_preferences

## Development

### Project Structure
```
lib/
  ├── game/
  │   ├── models/
  │   │   └── leaderboard_entry.dart
  │   ├── space_shooter_game.dart
  │   ├── spaceship.dart
  │   ├── enemy.dart
  │   ├── bullet.dart
  │   ├── powerup.dart
  │   ├── star_background.dart
  │   ├── home_screen.dart
  │   ├── pause_menu.dart
  │   ├── game_over.dart
  │   ├── achievement_notification.dart
  │   ├── hud.dart
  │   └── name_input_dialog.dart
  └── main.dart
```

### Key Components
- **SpaceShooterGame**: Main game logic and state management
- **Spaceship**: Player character controls and behavior
- **Enemy**: Enemy types and behavior patterns
- **PowerUp**: Power-up system and effects
- **HomeScreen**: Main menu and navigation
- **PauseMenu**: Game pause functionality and settings
- **LeaderboardEntry**: Score tracking and persistence

## Version
Current Version: 1.0.0


## Screenshots

### Home Screen
![Home Screen](screenshots/home_screen.png)
The main menu features a sleek, space-themed design with:
- Animated title with gradient effect
- Four main navigation buttons
- Floating stars background animation
- Version display

### Gameplay
![Gameplay](screenshots/gameplay.png)
Active gameplay screen showing:
- Player spaceship with particle effects
- Enemy ships in formation
- Power-up items
- Score and lives HUD
- Wave indicator

### Pause Menu
![Pause Menu](screenshots/pause_menu.png)
Comprehensive pause menu including:
- Difficulty selector
- Audio controls for music and SFX
- Game controls guide
- Resume/Restart/Home options

### Game Over
![Game Over](screenshots/game_over.png)
End game screen featuring:
- Final score display
- High score comparison
- Name input for leaderboard
- Play again option

### Leaderboard
![Leaderboard](screenshots/leaderboard.png)
Top scores display with:
- Player names and scores
- Date/time of achievement
- Medal icons for top 3 positions
- Scrollable list of entries

### Settings
![Settings](screenshots/settings.png)
Game configuration panel with:
- Audio toggles and volume controls
- Score reset functionality
- Visual feedback for changes
