import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'space_shooter_game.dart';

enum PowerUpType {
  doubleFire,
  shield,
  speedBoost,
  repair,
  bomb
}

class PowerUp extends PositionComponent with HasGameRef<SpaceShooterGame> {
  static const Map<PowerUpType, Color> typeColors = {
    PowerUpType.doubleFire: Colors.orange,
    PowerUpType.shield: Colors.blue,
    PowerUpType.speedBoost: Colors.green,
    PowerUpType.repair: Colors.red,
    PowerUpType.bomb: Colors.purple,
  };

  final PowerUpType type;
  final double speed = 100;

  PowerUp({PowerUpType? type}) 
    : this.type = type ?? PowerUpType.values[Random().nextInt(PowerUpType.values.length)],
      super(size: Vector2(20, 20)) {
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = typeColors[type]!;
    canvas.drawCircle(size.toOffset() / 2, 10, paint);

    // Add a glowing effect
    paint
      ..color = typeColors[type]!.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(size.toOffset() / 2, 12, paint);
  }

  @override
  void update(double dt) {
    position.y += speed * dt;

    if (position.y > gameRef.size.y) {
      removeFromParent();
    }

    // Collision with spaceship
    if (gameRef.spaceship.toRect().overlaps(toRect())) {
      activate();
    }
  }

  void activate() {
    switch (type) {
      case PowerUpType.doubleFire:
        gameRef.activateBulletPowerUp();
        break;
      case PowerUpType.shield:
        gameRef.activateShield();
        break;
      case PowerUpType.speedBoost:
        gameRef.activateSpeedBoost();
        break;
      case PowerUpType.repair:
        gameRef.repairShip();
        break;
      case PowerUpType.bomb:
        gameRef.activateBomb();
        break;
    }
    removeFromParent();
  }
}
