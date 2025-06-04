import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'space_shooter_game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/leaderboard_entry.dart';

class LeaderboardEntry {
  final String playerName;
  final int score;
  final DateTime date;

  LeaderboardEntry({
    required this.playerName,
    required this.score,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'playerName': playerName,
    'score': score,
    'date': date.toIso8601String(),
  };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      playerName: json['playerName'] as String,
      score: json['score'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Function(SpaceShooterGame) onGameStart;

  const HomeScreen({required this.onGameStart, Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<LeaderboardEntry> leaderboardEntries = [];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final leaderboardJson = prefs.getStringList('leaderboard') ?? [];
    
    setState(() {
      leaderboardEntries = leaderboardJson
          .map((json) => LeaderboardEntry.fromJson(Map<String, dynamic>.from(
              Map<String, dynamic>.from(jsonDecode(json)))))
          .toList();
      
      // Sort by score in descending order
      leaderboardEntries.sort((a, b) => b.score.compareTo(a.score));
    });
  }

  Future<void> _saveLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final leaderboardJson = leaderboardEntries
        .map((entry) => jsonEncode(entry.toJson()))
        .toList();
    await prefs.setStringList('leaderboard', leaderboardJson);
  }

  Future<void> addScore(String playerName, int score) async {
    final entry = LeaderboardEntry(
      playerName: playerName,
      score: score,
      date: DateTime.now(),
    );

    setState(() {
      leaderboardEntries.add(entry);
      leaderboardEntries.sort((a, b) => b.score.compareTo(a.score));
      // Keep only top 10 scores
      if (leaderboardEntries.length > 10) {
        leaderboardEntries = leaderboardEntries.take(10).toList();
      }
    });

    await _saveLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          // Animated stars background
          _buildStarBackground(),
          
          // Main content
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Game title with glowing effect
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Colors.blue.shade300,
                        Colors.purple.shade300,
                        Colors.pink.shade300,
                      ],
                    ).createShader(bounds),
                    child: Column(
                      children: [
                        Text(
                          'SPACE',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.orbitron(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.blue.shade700,
                                blurRadius: 20,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'SHOOTER',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.orbitron(
                            fontSize: 58,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.blue.shade700,
                                blurRadius: 20,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  
                  // Main menu buttons
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildButton(
                        'START GAME',
                        Icons.play_arrow_rounded,
                        Colors.green,
                        () => widget.onGameStart(SpaceShooterGame()),
                      ),
                      const SizedBox(height: 16),
                      _buildButton(
                        'SETTINGS',
                        Icons.settings,
                        Colors.orange,
                        () => showDialog(
                          context: context,
                          builder: (context) => _buildSettingsDialog(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildButton(
                        'LEADERBOARD',
                        Icons.leaderboard,
                        Colors.purple,
                        () => showDialog(
                          context: context,
                          builder: (context) => _buildLeaderboardDialog(context),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildButton(
                        'HOW TO PLAY',
                        Icons.help_outline,
                        Colors.blue,
                        () => showDialog(
                          context: context,
                          builder: (context) => _buildHowToPlayDialog(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Version text at bottom
          Positioned(
            bottom: 16,
            right: 16,
            child: Text(
              'v1.0.0',
              style: GoogleFonts.orbitron(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 200,
            maxWidth: 300,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.5),
                color.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white24,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarBackground() {
    return CustomPaint(
      painter: StarBackgroundPainter(),
      child: Container(),
    );
  }

  Widget _buildSettingsDialog(BuildContext context) {
    return _SettingsDialog(
      onScoresReset: () {
        setState(() {
          leaderboardEntries.clear();
        });
      },
    );
  }

  Widget _buildLeaderboardDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.indigo.shade900.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.2),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LEADERBOARD',
              style: GoogleFonts.orbitron(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            if (leaderboardEntries.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No scores yet!',
                  style: GoogleFonts.orbitron(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              )
            else
              ...leaderboardEntries.asMap().entries.map((entry) {
                final index = entry.key;
                final score = entry.value;
                return _buildLeaderboardEntry(
                  '${index + 1}',
                  score.playerName,
                  score.score.toString(),
                  date: score.date,
                );
              }),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CLOSE',
                style: GoogleFonts.orbitron(
                  color: Colors.purple,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardEntry(String rank, String name, String score, {DateTime? date}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Rank with medal icons for top 3
          SizedBox(
            width: 40,
            child: rank == '1' ? const Icon(Icons.emoji_events, color: Colors.amber)
                : rank == '2' ? const Icon(Icons.emoji_events, color: Colors.grey)
                : rank == '3' ? const Icon(Icons.emoji_events, color: Colors.orange)
                : Text(
                    '#$rank',
                    style: GoogleFonts.orbitron(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          // Player name and score
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (date != null)
                  Text(
                    _formatDate(date),
                    style: GoogleFonts.orbitron(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Score with shine effect
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade700, Colors.purple.shade900],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              score,
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildHowToPlayDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.indigo.shade900.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'HOW TO PLAY',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildInstructionItem(
              Icons.keyboard_arrow_right,
              'Use arrow keys or WASD to move',
            ),
            _buildInstructionItem(
              Icons.keyboard_arrow_right,
              'SPACE to shoot',
            ),
            _buildInstructionItem(
              Icons.keyboard_arrow_right,
              'ESC to pause game',
            ),
            _buildInstructionItem(
              Icons.keyboard_arrow_right,
              'Collect power-ups for special abilities',
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'CLOSE',
                  style: GoogleFonts.orbitron(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.orbitron(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StarBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final random = Random();
    
    for (var i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SettingsDialog extends StatefulWidget {
  final VoidCallback onScoresReset;
  
  const _SettingsDialog({
    Key? key,
    required this.onScoresReset,
  }) : super(key: key);

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  bool isSfxEnabled = true;
  bool isMusicEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isSfxEnabled = prefs.getBool('sfxEnabled') ?? true;
      isMusicEnabled = prefs.getBool('musicEnabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sfxEnabled', isSfxEnabled);
    await prefs.setBool('musicEnabled', isMusicEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.indigo.shade900.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SETTINGS',
              style: GoogleFonts.orbitron(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(
                isSfxEnabled ? Icons.volume_up : Icons.volume_off,
                color: Colors.white70,
              ),
              title: Text(
                'Sound Effects',
                style: GoogleFonts.orbitron(color: Colors.white70),
              ),
              trailing: Switch(
                value: isSfxEnabled,
                onChanged: (value) {
                  setState(() {
                    isSfxEnabled = value;
                  });
                  _saveSettings();
                },
                activeColor: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(
                isMusicEnabled ? Icons.music_note : Icons.music_off,
                color: Colors.white70,
              ),
              title: Text(
                'Music',
                style: GoogleFonts.orbitron(color: Colors.white70),
              ),
              trailing: Switch(
                value: isMusicEnabled,
                onChanged: (value) {
                  setState(() {
                    isMusicEnabled = value;
                  });
                  _saveSettings();
                },
                activeColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () async {
                // Show confirmation dialog
                final shouldReset = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.indigo.shade900,
                    title: Text(
                      'Reset All Scores?',
                      style: GoogleFonts.orbitron(color: Colors.white),
                    ),
                    content: Text(
                      'This will permanently delete all high scores and leaderboard data. This action cannot be undone.',
                      style: GoogleFonts.orbitron(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'CANCEL',
                          style: GoogleFonts.orbitron(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'RESET',
                          style: GoogleFonts.orbitron(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (shouldReset == true) {
                  // Create a temporary game instance to access resetAllScores
                  final game = SpaceShooterGame();
                  await game.resetAllScores();
                  // Notify parent to refresh the leaderboard
                  widget.onScoresReset();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text(
                'RESET ALL SCORES',
                style: GoogleFonts.orbitron(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CLOSE',
                style: GoogleFonts.orbitron(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 