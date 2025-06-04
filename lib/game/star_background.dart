import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class StarBackground extends Component with HasGameRef {
  final List<Vector2> stars = [];
  final Random _random = Random();
  final Paint starPaint = Paint()..color = Colors.white.withOpacity(0.8);
  final double speed = 20.0;

  @override
  Future<void> onLoad() async {
    for (int i = 0; i < 100; i++) {
      stars.add(Vector2(
        _random.nextDouble() * gameRef.size.x,
        _random.nextDouble() * gameRef.size.y,
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, gameRef.size.x, gameRef.size.y);
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.deepPurple.shade900, Colors.black],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);

    canvas.drawRect(rect, gradientPaint);

    for (var star in stars) {
      canvas.drawCircle(Offset(star.x, star.y), 1.5, starPaint);
    }
  }

  @override
  void update(double dt) {
    for (var star in stars) {
      star.y += speed * dt;
      if (star.y > gameRef.size.y) {
        star.y = 0;
        star.x = _random.nextDouble() * gameRef.size.x;
      }
    }
  }
}
