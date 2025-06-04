import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/events.dart';
import 'spaceship.dart';
import 'enemy.dart';
import 'bullet.dart';
import 'powerup.dart';
import 'star_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_over.dart';
import 'pause_menu.dart';
import 'achievement_notification.dart';
import 'hud.dart';
import 'dart:convert';
import 'models/leaderboard_entry.dart';

class SpaceShooterGame extends FlameGame with KeyboardEvents, TapCallbacks {
  late Spaceship spaceship;

  // Game state
  int score = 0;
  int lives = 3;
  int highScore = 0;
  int currentWave = 1;
  bool isGamePaused = false;

  // Audio settings
  double musicVolume = 0.3;
  double sfxVolume = 0.5;
  bool isMusicEnabled = true;
  bool isSfxEnabled = true;

  // Notifiers for UI
  ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  ValueNotifier<int> livesNotifier = ValueNotifier(3);
  ValueNotifier<int> waveNotifier = ValueNotifier(1);
  ValueNotifier<String> difficultyNotifier = ValueNotifier('Normal');
  ValueNotifier<bool> shieldActiveNotifier = ValueNotifier(false);
  ValueNotifier<double> musicVolumeNotifier = ValueNotifier(0.3);
  ValueNotifier<double> sfxVolumeNotifier = ValueNotifier(0.5);
  ValueNotifier<bool> musicEnabledNotifier = ValueNotifier(true);
  ValueNotifier<bool> sfxEnabledNotifier = ValueNotifier(true);

  // Game settings
  String difficulty = 'Normal';
  Map<String, double> difficultySettings = {
    'Easy': 0.7,
    'Normal': 1.0,
    'Hard': 1.3,
    'Insane': 1.6,
  };

  // Timers
  final Random _random = Random();
  late Timer enemyTimer;
  late Timer powerUpTimer;
  late Timer waveTimer;
  Timer? bulletPowerUpTimer;
  Timer? shieldTimer;
  Timer? speedBoostTimer;

  // Achievement tracking
  Map<String, bool> achievements = {
    'First Blood': false,
    'Wave Survivor': false,
    'Power Player': false,
    'Sharp Shooter': false,
    'Untouchable': false,
  };

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load settings from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    isSfxEnabled = prefs.getBool('sfxEnabled') ?? true;
    isMusicEnabled = prefs.getBool('musicEnabled') ?? true;
    sfxEnabledNotifier.value = isSfxEnabled;
    musicEnabledNotifier.value = isMusicEnabled;

    // Load high score first
    highScore = await getHighScore();

    // Load audio files
    await FlameAudio.audioCache.loadAll([
      'shoot.wav',
      'explosion.wav',
      'game_lay_sound.mp3',
    ]);

    // Add background
    add(StarBackground());

    // Add spaceship
    spaceship = Spaceship()..position = Vector2(size.x / 2, size.y - 60);
    add(spaceship);

    // Initialize timers
    setupTimers();

    // Start background music
    if (isMusicEnabled) {
      FlameAudio.bgm.play('game_lay_sound.mp3', volume: musicVolume);
    }

    // Add HUD overlay
    overlays.add('Hud');
  }

  @override
  void onMount() {
    super.onMount();
    overlays.addEntry('GameOver', (_, game) => GameOver(game as SpaceShooterGame));
    overlays.addEntry('PauseMenu', (_, game) => PauseMenu(game as SpaceShooterGame));
    overlays.addEntry('AchievementNotification', (_, game) => AchievementNotification(game as SpaceShooterGame));
  }

  void setupTimers() {
    double difficultyMod = difficultySettings[difficulty] ?? 1.0;
    
    enemyTimer = Timer(
      1.0 / difficultyMod,
      repeat: true,
      onTick: spawnEnemy,
    )..start();

    // More frequent power-ups
    powerUpTimer = Timer(
      difficulty == 'Easy' ? 5.0 : 8.0 * difficultyMod,
      repeat: true,
      onTick: spawnPowerUp,
    )..start();

    waveTimer = Timer(
      30.0,
      repeat: true,
      onTick: nextWave,
    )..start();
  }

  void spawnEnemy() {
    final enemyCount = children.whereType<Enemy>().length;
    if (enemyCount >= 4 + (currentWave ~/ 2)) return;

    EnemyType type;
    // Increase chance of special enemies and add bias for shooter type
    double specialEnemyChance = 0.15 * currentWave; // Increased from 0.1
    if (_random.nextDouble() < specialEnemyChance) {
      // 40% chance for shooter, 60% chance for other special types
      if (_random.nextDouble() < 0.6) {
        type = EnemyType.shooter;
      } else {
        // Pick from remaining types (excluding basic and shooter)
        final remainingTypes = EnemyType.values.where(
          (t) => t != EnemyType.basic && t != EnemyType.shooter
        ).toList();
        type = remainingTypes[_random.nextInt(remainingTypes.length)];
      }
    } else {
      type = EnemyType.basic;
    }

    double difficultyMod = difficultySettings[difficulty] ?? 1.0;
    
    // Calculate safe spawn area
    final enemySize = 35.0;
    final minX = enemySize;
    final maxX = size.x - enemySize;
    
    // Ensure enemy is spawned in a reachable position
    final spawnX = minX + _random.nextDouble() * (maxX - minX);

    final enemy = Enemy(
      speed: (60 + _random.nextDouble() * 60) * difficultyMod,
      color: _randomEnemyColor(),
      type: type,
      size: Vector2(enemySize, enemySize),
    )..position = Vector2(spawnX, -enemySize);

    add(enemy);
  }

  void spawnPowerUp() {
    // Base number of power-ups to spawn
    int numPowerUps = difficulty == 'Easy' ? 2 : 1;
    
    // Chance to spawn an extra power-up based on wave
    if (_random.nextDouble() < currentWave * 0.1) {
      numPowerUps++;
    }

    // Keep track of spawned types to avoid duplicates
    final spawnedTypes = <PowerUpType>{};
    
    for (int i = 0; i < numPowerUps; i++) {
      PowerUpType type;
      
      // Ensure variety in power-ups
      do {
        // Weighted random selection based on usefulness
        final roll = _random.nextDouble();
        if (roll < 0.3) {
          // 30% chance for defensive power-ups
          type = _random.nextBool() ? PowerUpType.shield : PowerUpType.repair;
        } else if (roll < 0.6) {
          // 30% chance for offensive power-ups
          type = _random.nextBool() ? PowerUpType.doubleFire : PowerUpType.bomb;
        } else {
          // 40% chance for speed boost
          type = PowerUpType.speedBoost;
        }
      } while (spawnedTypes.contains(type));
      
      spawnedTypes.add(type);

      // Calculate spawn position with spacing (ensuring double values)
      final double xPos = 40.0 + _random.nextDouble() * (size.x - 80.0);
      final double yPos = -20.0 - (i * 50.0);
      
      final powerUp = PowerUp(type: type)
        ..position = Vector2(xPos, yPos);
      
    add(powerUp);
    }
  }

  Color _randomEnemyColor() {
    final colors = [
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.amber,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  void nextWave() {
    currentWave++;
    waveNotifier.value = currentWave;
    
    // Increase difficulty with waves
    setupTimers();
    
    // Check achievement
    if (currentWave >= 5 && !achievements['Wave Survivor']!) {
      unlockAchievement('Wave Survivor');
    }
  }

  void activateBulletPowerUp() {
    spaceship.powerUpActive = true;
    
    bulletPowerUpTimer?.stop();
    bulletPowerUpTimer = Timer(12, onTick: () {  // Increased duration
      spaceship.powerUpActive = false;
    })..start();

    checkPowerUpAchievement();
  }

  void activateShield() {
    shieldActiveNotifier.value = true;
    
    shieldTimer?.stop();
    shieldTimer = Timer(8, onTick: () {  // Increased duration
      shieldActiveNotifier.value = false;
    })..start();

    checkPowerUpAchievement();
  }

  void activateSpeedBoost() {
    spaceship.speed *= 1.5;
    
    speedBoostTimer?.stop();
    speedBoostTimer = Timer(10, onTick: () {  // Increased duration
      spaceship.speed /= 1.5;
    })..start();

    checkPowerUpAchievement();
  }

  void repairShip() {
    if (lives < 3) {
      lives++;
      livesNotifier.value = lives;
      // FlameAudio.play('powerup.mp3');
    }
    checkPowerUpAchievement();
  }

  void activateBomb() {
    // FlameAudio.play('explosion.mp3');
    final enemies = children.whereType<Enemy>().toList();
    for (final enemy in enemies) {
      enemy.takeDamage(999);
    }
    checkPowerUpAchievement();
  }

  void checkPowerUpAchievement() {
    if (!achievements['Power Player']!) {
      unlockAchievement('Power Player');
    }
  }

  void setDifficulty(String value) {
    difficulty = value;
    difficultyNotifier.value = value;
    setupTimers();
  }

  void addScore() {
    score++;
    scoreNotifier.value = score;
    
    if (score == 1 && !achievements['First Blood']!) {
      unlockAchievement('First Blood');
    }
  }

  void loseLife() {
    if (shieldActiveNotifier.value) {
      shieldActiveNotifier.value = false;
      return;
    }

    lives--;
    livesNotifier.value = lives;
    
    // Play explosion sound
    if (isSfxEnabled) {
      FlameAudio.play('explosion.wav', volume: sfxVolume);
    }

    if (lives <= 0) {
      spaceship.destroy();
      gameOver();
    } else {
      // Temporary invulnerability and respawn logic
      spaceship.destroy();
      
      // Respawn the ship after a short delay
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!isGamePaused && !overlays.isActive('GameOver')) {
          spaceship = Spaceship();
          spaceship.position = Vector2(size.x / 2, size.y - 60);
          add(spaceship);
          
          // Add spawn protection effect
          add(
            ParticleSystemComponent(
              position: spaceship.position,
              particle: Particle.generate(
                count: 1,
                lifespan: 2.0,
                generator: (i) => ComputedParticle(
                  renderer: (canvas, particle) {
                    final paint = Paint()
                      ..color = Colors.blue.withOpacity(0.2 * (1 - particle.progress))
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 2;
                    canvas.drawCircle(
                      Offset.zero,
                      30 + (10 * sin(particle.progress * 6 * pi)),
                      paint,
                    );
                  },
                ),
              ),
            ),
          );
        }
      });
    }
  }

  void gameOver() async {
    FlameAudio.bgm.stop();
    pauseEngine();
    
    // Save high score
    if (score > highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', score);
      highScore = score;
    }

    // Get existing leaderboard
    final prefs = await SharedPreferences.getInstance();
    final leaderboardJson = prefs.getStringList('leaderboard') ?? [];
    final leaderboardEntries = leaderboardJson
        .map((json) => LeaderboardEntry.fromJson(Map<String, dynamic>.from(
            Map<String, dynamic>.from(jsonDecode(json)))))
        .toList();

    // Check if current score is in top 10
    leaderboardEntries.sort((a, b) => b.score.compareTo(a.score));
    final isTopScore = leaderboardEntries.length < 10 || score > (leaderboardEntries.lastOrNull?.score ?? 0);

    if (isTopScore) {
      // Show name input dialog
      overlays.add('NameInput');
    } else {
      // Just show game over screen
      overlays.add('GameOver');
    }
  }

  Future<void> saveScore(String playerName) async {
    final prefs = await SharedPreferences.getInstance();
    final leaderboardJson = prefs.getStringList('leaderboard') ?? [];
    final leaderboardEntries = leaderboardJson
        .map((json) => LeaderboardEntry.fromJson(Map<String, dynamic>.from(
            Map<String, dynamic>.from(jsonDecode(json)))))
        .toList();

    // Add new score
    leaderboardEntries.add(LeaderboardEntry(
      playerName: playerName,
      score: score,
      date: DateTime.now(),
    ));

    // Sort and keep top 10
    leaderboardEntries.sort((a, b) => b.score.compareTo(a.score));
    if (leaderboardEntries.length > 10) {
      leaderboardEntries.removeRange(10, leaderboardEntries.length);
    }

    // Save updated leaderboard
    await prefs.setStringList(
      'leaderboard',
      leaderboardEntries.map((e) => jsonEncode(e.toJson())).toList(),
    );

    // Show game over screen
    overlays.remove('NameInput');
    overlays.add('GameOver');
  }

  void resetGame() {
    score = 0;
    lives = 3;
    currentWave = 1;
    scoreNotifier.value = 0;
    livesNotifier.value = 3;
    waveNotifier.value = 1;

    // Remove all game objects including the spaceship
    children.whereType<Enemy>().forEach(remove);
    children.whereType<Bullet>().forEach(remove);
    children.whereType<PowerUp>().forEach(remove);
    children.whereType<Spaceship>().forEach(remove);  // Remove any existing spaceships
    
    // Create and add a new spaceship
    spaceship = Spaceship()..position = Vector2(size.x / 2, size.y - 60);
    add(spaceship);

    setupTimers();

    overlays.remove('GameOver');
    overlays.remove('PauseMenu');
    
    if (isMusicEnabled) {
      FlameAudio.bgm.play('game_lay_sound.mp3', volume: musicVolume);
    }
    resumeEngine();
  }

  void togglePause() {
    isGamePaused = !isGamePaused;
    if (isGamePaused) {
      // Add a pause animation effect
      add(
        ParticleSystemComponent(
          particle: Particle.generate(
            count: 20,
            lifespan: 0.5,
            generator: (i) => AcceleratedParticle(
              position: Vector2(size.x / 2, size.y / 2),
              speed: Vector2.random(_random) * 100,
              acceleration: Vector2.zero(),
              child: CircleParticle(
                radius: 2,
                paint: Paint()..color = Colors.blue.withOpacity(0.5),
              ),
            ),
          ),
        ),
      );

      pauseEngine();
      FlameAudio.bgm.pause();
      overlays.add('PauseMenu');
    } else {
      resumeEngine();
      if (isMusicEnabled) {
        FlameAudio.bgm.resume();
      }
      overlays.remove('PauseMenu');
    }
  }

  void addExplosion(Vector2 position) {
    if (isSfxEnabled) {
      FlameAudio.play('explosion.wav', volume: sfxVolume);
    }

    // Core explosion
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 20,
          lifespan: 0.8,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 30),
            child: CircleParticle(
              radius: 2 + Random().nextDouble() * 3,
              paint: Paint()..color = Colors.orange.withOpacity(0.9),
            ),
            position: position.clone(),
            speed: Vector2.random(Random()) * 200,
          ),
        ),
      ),
    );

    // Fire particles
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 15,
          lifespan: 0.6,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, -50),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final paint = Paint()
                  ..color = Colors.red.withOpacity((1 - particle.progress) * 0.9);
                canvas.drawCircle(
                  Offset.zero,
                  4 * (1 - particle.progress),
                  paint,
                );
              },
            ),
            position: position.clone(),
            speed: Vector2.random(Random()) * 150,
          ),
        ),
      ),
    );

    // Smoke effect
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 10,
          lifespan: 1.0,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, -20),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final paint = Paint()
                  ..color = Colors.grey.withOpacity((1 - particle.progress) * 0.5);
                canvas.drawCircle(
                  Offset.zero,
                  5 * (1 - particle.progress),
                  paint,
                );
              },
            ),
            position: position.clone(),
            speed: Vector2.random(Random()) * 100,
          ),
        ),
      ),
    );

    // Spark particles
    add(
      ParticleSystemComponent(
        particle: Particle.generate(
          count: 25,
          lifespan: 0.5,
          generator: (i) => AcceleratedParticle(
            acceleration: Vector2(0, 50),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final paint = Paint()
                  ..color = Colors.yellow.withOpacity((1 - particle.progress) * 0.9);
                canvas.drawCircle(
                  Offset.zero,
                  1.5 * (1 - particle.progress),
                  paint,
                );
              },
            ),
            position: position.clone(),
            speed: Vector2.random(Random()) * 300,
          ),
        ),
      ),
    );

    // Shockwave effect
    add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 1,
          lifespan: 0.4,
          generator: (i) => ComputedParticle(
            renderer: (canvas, particle) {
              final paint = Paint()
                ..color = Colors.white.withOpacity(0.3 * (1 - particle.progress));
              canvas.drawCircle(
                Offset.zero,
                2 + 48 * particle.progress, // Grows from 2 to 50
                paint,
              );
            },
          ),
        ),
      ),
    );
  }

  void unlockAchievement(String name) {
    achievements[name] = true;
    // Show achievement notification
    overlays.add('AchievementNotification');
    Future.delayed(Duration(seconds: 3), () {
      overlays.remove('AchievementNotification');
    });
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isGamePaused && !overlays.isActive('GameOver')) {
      // Handle continuous keyboard input for movement
      final keyboard = HardwareKeyboard.instance;
      final bool leftPressed = 
          keyboard.logicalKeysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
          keyboard.logicalKeysPressed.contains(LogicalKeyboardKey.keyA);
      
      final bool rightPressed = 
          keyboard.logicalKeysPressed.contains(LogicalKeyboardKey.arrowRight) ||
          keyboard.logicalKeysPressed.contains(LogicalKeyboardKey.keyD);
      
      final bool upPressed = 
          keyboard.logicalKeysPressed.contains(LogicalKeyboardKey.arrowUp) ||
          keyboard.logicalKeysPressed.contains(LogicalKeyboardKey.keyW);
      
      final bool downPressed = 
          keyboard.logicalKeysPressed.contains(LogicalKeyboardKey.arrowDown) ||
          keyboard.logicalKeysPressed.contains(LogicalKeyboardKey.keyS);

      if (leftPressed || rightPressed || upPressed || downPressed) {
        Vector2 movement = Vector2.zero();
        
        if (leftPressed) movement.x -= 1;
        if (rightPressed) movement.x += 1;
        if (upPressed) movement.y -= 1;
        if (downPressed) movement.y += 1;
        
        // Normalize for consistent speed in all directions
        if (!movement.isZero()) {
          movement.normalize();
          spaceship.moveWithKeyboard(movement, dt);
        }
      } else {
        // Only reset engine flames if not dragging
        if (!spaceship.isDragging) {
          spaceship.isDragging = false;
        }
      }
    }

    enemyTimer.update(dt);
    powerUpTimer.update(dt);
    waveTimer.update(dt);
    bulletPowerUpTimer?.update(dt);
    shieldTimer?.update(dt);
    speedBoostTimer?.update(dt);
  }

  @override
  bool onTapDown(TapDownEvent event) {
    if (!isGamePaused && !overlays.isActive('GameOver')) {
      // Only shoot if tap is in the upper 2/3 of the screen
      if (event.canvasPosition.y < size.y * 0.8) {
        spaceship.shoot();
      }
    }
    return true;
  }

  Future<void> saveHighScore() async {
    if (score > highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', score);
      highScore = score;
    }
  }

  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('highScore') ?? 0;
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.escape:
        case LogicalKeyboardKey.pause:
          togglePause();
          return KeyEventResult.handled;
        
        case LogicalKeyboardKey.space:
          if (!isGamePaused && !overlays.isActive('GameOver')) {
            spaceship.shoot();
          }
          return KeyEventResult.handled;
        
        case LogicalKeyboardKey.keyR:
          if (overlays.isActive('GameOver')) {
            resetGame();
          }
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void setMusicVolume(double volume) {
    musicVolume = volume;
    musicVolumeNotifier.value = volume;
    if (isMusicEnabled) {
      FlameAudio.bgm.audioPlayer.setVolume(volume);
    }
  }

  void setSfxVolume(double volume) {
    sfxVolume = volume;
    sfxVolumeNotifier.value = volume;
  }

  void toggleMusic() {
    isMusicEnabled = !isMusicEnabled;
    musicEnabledNotifier.value = isMusicEnabled;
    
    // Save the setting
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('musicEnabled', isMusicEnabled);
    });

    if (isMusicEnabled) {
      FlameAudio.bgm.resume();
      FlameAudio.bgm.audioPlayer.setVolume(musicVolume);
    } else {
      FlameAudio.bgm.pause();
    }
  }

  void toggleSfx() {
    isSfxEnabled = !isSfxEnabled;
    sfxEnabledNotifier.value = isSfxEnabled;
    
    // Save the setting
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('sfxEnabled', isSfxEnabled);
    });
  }

  @override
  void shoot() {
    if (!isMounted) return;
    
    if (isSfxEnabled) {
      FlameAudio.play('shoot.wav', volume: sfxVolume);
    }
    // ... rest of shoot code ...
  }

  Future<void> resetAllScores() async {
    // Reset current game scores
    score = 0;
    highScore = 0;
    scoreNotifier.value = 0;
    
    // Clear SharedPreferences data
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('highScore');
    await prefs.remove('leaderboard');
  }

  void returnToHome() {
    // Stop music and pause game
    FlameAudio.bgm.stop();
    pauseEngine();
    
    // Remove all overlays
    overlays.removeAll(['PauseMenu', 'GameOver', 'Hud', 'NameInput', 'AchievementNotification']);
    
    // Reset game state
    score = 0;
    lives = 3;
    currentWave = 1;
    scoreNotifier.value = 0;
    livesNotifier.value = 3;
    waveNotifier.value = 1;
    
    // Remove all game objects
    children.whereType<Enemy>().forEach(remove);
    children.whereType<Bullet>().forEach(remove);
    children.whereType<PowerUp>().forEach(remove);
    children.whereType<Spaceship>().forEach(remove);
  }
}
