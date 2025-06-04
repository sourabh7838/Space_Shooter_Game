import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/space_shooter_game.dart';
import 'game/game_over.dart';
import 'game/pause_menu.dart';
import 'game/achievement_notification.dart';
import 'game/home_screen.dart';
import 'game/hud.dart';
import 'game/name_input_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameWrapper(),
    );
  }
}

class GameWrapper extends StatefulWidget {
  const GameWrapper({super.key});

  @override
  State<GameWrapper> createState() => _GameWrapperState();
}

class _GameWrapperState extends State<GameWrapper> {
  SpaceShooterGame? game;

  void startGame(SpaceShooterGame newGame) {
    setState(() {
      game = newGame;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (game == null) {
      return HomeScreen(onGameStart: startGame);
    }

    return Scaffold(
      body: GameWidget(
        game: game!,
        overlayBuilderMap: {
          'Hud': (context, game) => HudWidget(game: game as SpaceShooterGame),
          'GameOver': (context, game) => GameOver(game as SpaceShooterGame),
          'PauseMenu': (context, game) => PauseMenu(game as SpaceShooterGame),
          'AchievementNotification': (context, game) => 
              AchievementNotification(game as SpaceShooterGame),
          'NameInput': (context, game) => NameInputDialog(game as SpaceShooterGame),
        },
      ),
    );
  }
}
