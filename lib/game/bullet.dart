import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'space_shooter_game.dart';

class Bullet extends PositionComponent with HasGameRef<SpaceShooterGame> {
  final bool isEnemy;
  final double speed;
  final Vector2 direction;

  Bullet({
    required this.isEnemy,
    required this.speed,
    required this.direction,
  }) : super(size: Vector2(6, 20));

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isEnemy 
          ? [Colors.red, Colors.orange]
          : [Colors.cyan, Colors.blue],
      ).createShader(size.toRect());

    // Draw bullet body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        size.toRect(),
        const Radius.circular(3),
      ),
      paint,
    );

    // Draw glow effect
    paint
      ..shader = null
      ..color = (isEnemy ? Colors.red : Colors.cyan).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        size.toRect().inflate(2),
        const Radius.circular(4),
      ),
      paint,
    );
  }

  @override
  void update(double dt) {
    position += direction * speed * dt;

    // Remove if off screen
    if (position.y < -size.y || position.y > gameRef.size.y) {
      removeFromParent();
    }
  }
}
