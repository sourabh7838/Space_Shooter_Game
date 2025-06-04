# Space Shooter

The Space Shooter Game is a fast-paced, retro-style space combat game created using Flutter and the Flame game engine. It challenges players to navigate waves of enemies, collect game-altering power-ups, and survive increasingly difficult stages. Designed for both casual fun and serious highscore competition, it offers a polished experience across platforms.


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
<img width="158" alt="image" src="https://github.com/user-attachments/assets/2b1f23fd-97ec-4799-8c0a-3441fdff3772" />

The main menu features a sleek, space-themed design with:
- Animated title with gradient effect
- Four main navigation buttons
- Floating stars background animation
- Version display

### Gameplay

<img width="171" alt="image" src="https://github.com/user-attachments/assets/12802777-3f37-41fa-9dad-97b38043f50e" />
<img width="171" alt="image" src="https://github.com/user-attachments/assets/7393370d-4964-48fa-9f58-58de37e1204c" />
<img width="171" alt="image" src="https://github.com/user-attachments/assets/acd9cc33-fc06-4ce6-84c8-7c9e4317f23e" />

Active gameplay screen showing:
- Player spaceship with particle effects
- Enemy ships in formation
- Power-up items
- Score and lives HUD
- Wave indicator

### How To Play

<img width="165" alt="image" src="https://github.com/user-attachments/assets/8bf99ccd-98c5-4799-a335-62d32af1885d" />

Provides users with gameplay instructions. Players can control the spaceship using touch gestures, a mouse, or keyboard arrow keys, making the game accessible across multiple input devices. 

### Pause Menu

<img width="192" alt="image" src="https://github.com/user-attachments/assets/25b92ee4-94b4-4847-ae90-e4232fa539b0" />
<img width="193" alt="image" src="https://github.com/user-attachments/assets/d310aca9-008d-4ae5-9678-089272fb96f0" />

Comprehensive pause menu including:
- Difficulty selector
- Audio controls for music and SFX
- Game controls guide
- Resume/Restart/Home options

### Achievement

<img width="161" alt="image" src="https://github.com/user-attachments/assets/57ad852e-cfd4-42a8-9652-421e74682dbb" />

Display achievement notifications when players reach specific milestones during gameplay: - 

	First Blood: Score your first point
	Wave Survivor: Reach wave 5
	Power Player: Collect a power-up
	Sharp Shooter: Achieve high accuracy
	Untouchable: Survive without taking damage


### Game Over
<img width="161" alt="image" src="https://github.com/user-attachments/assets/5d6610a5-785e-4305-8be9-cfd7eeed460e" />

End game screen featuring:
- Final score display
- High score comparison
- Name input for leaderboard
- Play again option

### Leaderboard
<img width="153" alt="image" src="https://github.com/user-attachments/assets/6717ad5a-3c26-4821-b72d-81e705d96f81" />
<img width="156" alt="image" src="https://github.com/user-attachments/assets/dac23c9d-730f-427c-ad31-d76ca7f22e22" />

Top scores display with:
- Player names and scores
- Date/time of achievement
- Medal icons for top 3 positions
- Scrollable list of entries

### Settings
<img width="171" alt="image" src="https://github.com/user-attachments/assets/226c4e13-1532-4659-88c8-7c45e8e0d335" />
<img width="173" alt="image" src="https://github.com/user-attachments/assets/5c62aa9a-e10b-4a60-a647-0e63eb7ab583" />

Game configuration panel with:
- Audio toggles and volume controls
- Score reset functionality
- Visual feedback for changes
