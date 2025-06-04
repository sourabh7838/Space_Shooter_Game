import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'space_shooter_game.dart';
import 'bullet.dart';

enum EnemyType {
  basic,    // Scout ship
  shooter,  // Fighter ship
  bomber,   // Heavy ship
  zigzag    // Interceptor ship
}

class Enemy extends PositionComponent with HasGameRef<SpaceShooterGame> {
  final double speed;
  final Color color;
  final EnemyType type;
  Timer? shootTimer;
  double health;
  Vector2 direction = Vector2(0, 1);
  double zigzagTime = 0;

  Enemy({
    required this.speed,
    required this.color,
    this.type = EnemyType.basic,
    this.health = 1,
    Vector2? size,
  }) : super(size: size ?? Vector2(40, 40)) {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    // Initialize based on type
    switch (type) {
      case EnemyType.shooter:
        health = 2;
        shootTimer = Timer(2, repeat: true, onTick: shoot)..start();
        break;
      case EnemyType.bomber:
        health = 3;
        break;
      case EnemyType.zigzag:
        health = 1.5;
        break;
      default:
        break;
    }
  }

  @override
  void render(Canvas canvas) {
    // Base metallic paint with gradient
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.9),
          color.withOpacity(0.7),
          color.withOpacity(0.9),
        ],
      ).createShader(size.toRect());

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Detail paint for ship components
    final detailPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Engine glow paint
    final engineGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.cyan.withOpacity(0.8),
          Colors.blue.withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.x / 2, size.y - 5),
        radius: 8,
      ));

    switch (type) {
      case EnemyType.shooter:
        _drawFighterShip(canvas, paint, glowPaint, detailPaint, engineGlowPaint);
        break;
      case EnemyType.bomber:
        _drawHeavyShip(canvas, paint, glowPaint, detailPaint, engineGlowPaint);
        break;
      case EnemyType.zigzag:
        _drawInterceptorShip(canvas, paint, glowPaint, detailPaint, engineGlowPaint);
        break;
      default:
        _drawScoutShip(canvas, paint, glowPaint, detailPaint, engineGlowPaint);
    }
  }

  void _drawScoutShip(Canvas canvas, Paint paint, Paint glowPaint, Paint detailPaint, Paint engineGlowPaint) {
    // Main body - sleek teardrop shape pointing downward
    final path = Path()
      ..moveTo(size.x / 2, size.y)  // Point at bottom
      ..quadraticBezierTo(size.x, size.y * 0.6, size.x * 0.8, 0)
      ..lineTo(size.x * 0.2, 0)
      ..quadraticBezierTo(0, size.y * 0.6, size.x / 2, size.y)
      ..close();

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Cockpit
    final cockpitPath = Path()
      ..moveTo(size.x * 0.4, size.y * 0.7)
      ..quadraticBezierTo(size.x / 2, size.y * 0.8, size.x * 0.6, size.y * 0.7)
      ..quadraticBezierTo(size.x / 2, size.y * 0.6, size.x * 0.4, size.y * 0.7);
    canvas.drawPath(cockpitPath, detailPaint);

    // Engine glow
    canvas.drawCircle(
      Offset(size.x / 2, 5),
      4,
      engineGlowPaint,
    );
  }

  void _drawFighterShip(Canvas canvas, Paint paint, Paint glowPaint, Paint detailPaint, Paint engineGlowPaint) {
    // Main body - angular fighter design pointing downward
    final path = Path()
      ..moveTo(size.x / 2, size.y)  // Nose at bottom
      ..lineTo(size.x * 0.8, size.y * 0.7)  // Right wing
      ..lineTo(size.x, size.y * 0.3)
      ..lineTo(size.x * 0.7, 0)
      ..lineTo(size.x * 0.3, 0)
      ..lineTo(0, size.y * 0.3)
      ..lineTo(size.x * 0.2, size.y * 0.7)  // Left wing
      ..close();

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Wing details
    canvas.drawLine(
      Offset(size.x * 0.2, size.y * 0.7),
      Offset(size.x * 0.4, size.y * 0.4),
      detailPaint,
    );
    canvas.drawLine(
      Offset(size.x * 0.8, size.y * 0.7),
      Offset(size.x * 0.6, size.y * 0.4),
      detailPaint,
    );

    // Dual engine glow
    canvas.drawCircle(
      Offset(size.x * 0.35, 5),
      3,
      engineGlowPaint,
    );
    canvas.drawCircle(
      Offset(size.x * 0.65, 5),
      3,
      engineGlowPaint,
    );
  }

  void _drawHeavyShip(Canvas canvas, Paint paint, Paint glowPaint, Paint detailPaint, Paint engineGlowPaint) {
    // Main body - bulky hexagonal shape pointing downward
    final path = Path()
      ..moveTo(size.x * 0.3, size.y)
      ..lineTo(size.x * 0.7, size.y)
      ..lineTo(size.x, size.y * 0.7)
      ..lineTo(size.x * 0.8, 0)
      ..lineTo(size.x * 0.2, 0)
      ..lineTo(0, size.y * 0.7)
      ..close();

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Armor plating details
    canvas.drawLine(
      Offset(size.x * 0.3, size.y * 0.8),
      Offset(size.x * 0.7, size.y * 0.8),
      detailPaint,
    );
    canvas.drawLine(
      Offset(size.x * 0.2, size.y * 0.6),
      Offset(size.x * 0.8, size.y * 0.6),
      detailPaint,
    );
    canvas.drawLine(
      Offset(size.x * 0.1, size.y * 0.4),
      Offset(size.x * 0.9, size.y * 0.4),
      detailPaint,
    );

    // Triple engine glow
    canvas.drawCircle(
      Offset(size.x * 0.3, 5),
      4,
      engineGlowPaint,
    );
    canvas.drawCircle(
      Offset(size.x * 0.5, 5),
      4,
      engineGlowPaint,
    );
    canvas.drawCircle(
      Offset(size.x * 0.7, 5),
      4,
      engineGlowPaint,
    );
  }

  void _drawInterceptorShip(Canvas canvas, Paint paint, Paint glowPaint, Paint detailPaint, Paint engineGlowPaint) {
    // Main body - sleek arrow shape pointing downward
    final path = Path()
      ..moveTo(size.x / 2, size.y)  // Point at bottom
      ..lineTo(size.x, size.y * 0.6)
      ..lineTo(size.x * 0.7, size.y * 0.4)
      ..lineTo(size.x * 0.6, 0)
      ..lineTo(size.x * 0.4, 0)
      ..lineTo(size.x * 0.3, size.y * 0.4)
      ..lineTo(0, size.y * 0.6)
      ..close();

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Wing details
    canvas.drawLine(
      Offset(size.x * 0.3, size.y * 0.4),
      Offset(size.x * 0.7, size.y * 0.4),
      detailPaint,
    );

    // Energy trail effect
    final trailPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Colors.cyan.withOpacity(0.6),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y * 0.4));

    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.45, 0, size.x * 0.1, size.y * 0.4),
      trailPaint,
    );

    // Engine glow
    canvas.drawCircle(
      Offset(size.x / 2, 5),
      5,
      engineGlowPaint,
    );
  }

  void shoot() {
    if (!isMounted) return;
    
    final bullet = Bullet(
      isEnemy: true,
      speed: 150,
      direction: Vector2(0, 1),
    )..position = position + Vector2(size.x / 2, size.y);
    
    gameRef.add(bullet);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    switch (type) {
      case EnemyType.zigzag:
        zigzagTime += dt;
        direction.x = sin(zigzagTime * 3) * 2;
        position += direction * speed * dt;
        break;
      case EnemyType.bomber:
        position += direction * (speed * 0.7) * dt;
        break;
      default:
        position += direction * speed * dt;
    }

    shootTimer?.update(dt);

    if (position.y > gameRef.size.y) {
      gameRef.loseLife();
      removeFromParent();
    }

    for (final comp in gameRef.children.whereType<Bullet>()) {
      if (toRect().overlaps(comp.toRect())) {
        gameRef.addScore();
        comp.removeFromParent();
        removeFromParent();
        gameRef.addExplosion(position);
        break;
      }
    }
  }

  void takeDamage(double damage) {
    health -= damage;
    if (health <= 0) {
      gameRef.addScore();
      gameRef.addExplosion(position);
      removeFromParent();
    }
  }
}
