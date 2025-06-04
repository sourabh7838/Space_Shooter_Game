import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flame/game.dart';
import 'space_shooter_game.dart';
import 'home_screen.dart';
import 'game_over.dart';
import 'achievement_notification.dart';
import 'hud.dart';
import 'name_input_dialog.dart';

class PauseMenu extends StatelessWidget {
  final SpaceShooterGame game;

  const PauseMenu(this.game, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.indigo.shade900.withOpacity(0.9),
                Colors.deepPurple.shade900.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white24,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.blue.shade300, Colors.lightBlueAccent],
                  ).createShader(bounds),
                  child: Text(
                    'PAUSED',
                    style: GoogleFonts.orbitron(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildDifficultySelector(),
                const SizedBox(height: 20),
                _buildAudioControls(),
                const SizedBox(height: 20),
                _buildControlsGuide(),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: _buildButton(
                        'RESUME',
                        Icons.play_arrow,
                        () => game.togglePause(),
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: _buildButton(
                        'RESTART',
                        Icons.refresh,
                        () {
                          game.resetGame();
                          game.togglePause();
                        },
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildButton(
                  'HOME',
                  Icons.home,
                  () {
                    // Return to home screen
                    game.returnToHome();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(
                          onGameStart: (newGame) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  body: GameWidget(
                                    game: newGame,
                                    overlayBuilderMap: {
                                      'Hud': (context, game) => 
                                          HudWidget(game: game as SpaceShooterGame),
                                      'GameOver': (context, game) => 
                                          GameOver(game as SpaceShooterGame),
                                      'PauseMenu': (context, game) => 
                                          PauseMenu(game as SpaceShooterGame),
                                      'AchievementNotification': (context, game) => 
                                          AchievementNotification(game as SpaceShooterGame),
                                      'NameInput': (context, game) => 
                                          NameInputDialog(game as SpaceShooterGame),
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  Colors.blue,
                ),
                const SizedBox(height: 20),
                Text(
                  'Press ESC to pause/resume',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Difficulty: ',
            style: GoogleFonts.orbitron(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(width: 10),
          ValueListenableBuilder<String>(
            valueListenable: game.difficultyNotifier,
            builder: (context, difficulty, _) {
              return DropdownButton<String>(
                value: difficulty,
                dropdownColor: Colors.indigo.shade900,
                borderRadius: BorderRadius.circular(15),
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 18,
                ),
                underline: Container(
                  height: 2,
                  color: Colors.blue.shade400,
                ),
                onChanged: (String? value) {
                  if (value != null) game.setDifficulty(value);
                },
                items: ['Easy', 'Normal', 'Hard', 'Insane']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAudioControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AUDIO',
            style: GoogleFonts.orbitron(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Music Controls
          Row(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: game.musicEnabledNotifier,
                builder: (context, enabled, _) => IconButton(
                  icon: Icon(
                    enabled ? Icons.music_note : Icons.music_off,
                    color: enabled ? Colors.blue : Colors.white30,
                  ),
                  onPressed: game.toggleMusic,
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<double>(
                  valueListenable: game.musicVolumeNotifier,
                  builder: (context, volume, _) => Slider(
                    value: volume,
                    onChanged: game.setMusicVolume,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.white24,
                  ),
                ),
              ),
            ],
          ),
          // Sound Effects Controls
          Row(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: game.sfxEnabledNotifier,
                builder: (context, enabled, _) => IconButton(
                  icon: Icon(
                    enabled ? Icons.volume_up : Icons.volume_off,
                    color: enabled ? Colors.green : Colors.white30,
                  ),
                  onPressed: game.toggleSfx,
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<double>(
                  valueListenable: game.sfxVolumeNotifier,
                  builder: (context, volume, _) => Slider(
                    value: volume,
                    onChanged: game.setSfxVolume,
                    activeColor: Colors.green,
                    inactiveColor: Colors.white24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlsGuide() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Controls',
            style: GoogleFonts.orbitron(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildControlRow('Move', 'Drag to move ship'),
          _buildControlRow('Shoot', 'Automatic'),
          _buildControlRow('Power-ups', 'Collect glowing orbs'),
        ],
      ),
    );
  }

  Widget _buildControlRow(String action, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$action: ',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              color: Colors.blue.shade300,
            ),
          ),
          Flexible(
            child: Text(
              description,
              style: GoogleFonts.orbitron(
                fontSize: 16,
                color: Colors.white70,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, VoidCallback onTap, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                text,
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 