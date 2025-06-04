import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/space_shooter_game.dart';
import 'game/game_over.dart';
import 'game/pause_menu.dart';
import 'game/achievement_notification.dart';

void main() {
  final game = SpaceShooterGame();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(
              game: game,
              overlayBuilderMap: {
                'GameOver': (_, game) => GameOver(game as SpaceShooterGame),
                'PauseMenu': (_, game) => PauseMenu(game as SpaceShooterGame),
                'AchievementNotification': (_, game) => 
                    AchievementNotification(game as SpaceShooterGame),
                'HudOverlay': (context, game) {
                  final shooterGame = game as SpaceShooterGame;
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        children: [
                          // Top bar with lives, pause and score
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Score and Wave
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black38,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.white10,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ValueListenableBuilder<int>(
                                      valueListenable: shooterGame.scoreNotifier,
                                      builder: (_, score, __) => Text(
                                        'Score: $score',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black54,
                                              offset: Offset(1, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ValueListenableBuilder<int>(
                                      valueListenable: shooterGame.waveNotifier,
                                      builder: (_, wave, __) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.blue.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          'Wave: $wave',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Right side controls
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Pause Button
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white10,
                                        width: 1,
                                      ),
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                      icon: const Icon(
                                        Icons.pause_circle,
                                        color: Colors.white,
                                        size: 32,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            offset: Offset(1, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                      onPressed: shooterGame.togglePause,
                                    ),
                                  ),

                                  // Lives
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white10,
                                        width: 1,
                                      ),
                                    ),
                                    child: ValueListenableBuilder<int>(
                                      valueListenable: shooterGame.livesNotifier,
                                      builder: (_, lives, __) => Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: List.generate(3, (index) {
                                          final isAlive = index < lives;
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 2),
                                            child: Icon(
                                              isAlive ? Icons.favorite : Icons.favorite_border,
                                              color: isAlive ? Colors.red : Colors.white24,
                                              size: 24,
                                              shadows: const [
                                                Shadow(
                                                  color: Colors.black54,
                                                  offset: Offset(1, 1),
                                                  blurRadius: 2,
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              },
              initialActiveOverlays: const ['HudOverlay'],
            ),
          ],
        ),
      ),
    ),
  );
}
