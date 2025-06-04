import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'space_shooter_game.dart';

// Flutter Widget for overlay UI elements
class HudWidget extends StatelessWidget {
  final SpaceShooterGame game;

  const HudWidget({required this.game, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top bar with score, lives, and pause button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score and High Score
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ValueListenableBuilder<int>(
                        valueListenable: game.scoreNotifier,
                        builder: (context, score, _) => Text(
                          'Score: $score',
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                color: Colors.blue.shade700,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        'High: ${game.highScore}',
                        style: GoogleFonts.orbitron(
                          color: Colors.amber,
                          fontSize: 12,
                          shadows: [
                            Shadow(
                              color: Colors.orange.shade700,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Lives and Pause Button
                Row(
                  children: [
                    // Lives display
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: ValueListenableBuilder<int>(
                        valueListenable: game.livesNotifier,
                        builder: (context, lives, _) => Row(
                          children: List.generate(
                            3,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Text(
                                index < lives ? '❤️' : '🖤',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Pause button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.pause_circle,
                          color: Colors.white,
                          size: 24,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        onPressed: game.togglePause,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Wave indicator
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ValueListenableBuilder<int>(
                valueListenable: game.waveNotifier,
                builder: (context, wave, _) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    'Wave $wave',
                    style: GoogleFonts.orbitron(
                      color: Colors.greenAccent,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Colors.green.shade700,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
