import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flame/particles.dart';
import 'space_shooter_game.dart';
import 'bullet.dart';
import 'dart:math';

class Spaceship extends PositionComponent 
    with HasGameRef<SpaceShooterGame>, DragCallbacks {
  
  double speed = 300;
  bool powerUpActive = false;
  Vector2 moveDirection = Vector2.zero();
  late Timer shootTimer;
  bool isDragging = false;
  Vector2? dragDelta;
  Vector2 initialPosition = Vector2.zero();
  
  // Flash effect properties
  bool isFlashing = false;
  double flashOpacity = 0.0;
  Timer flashTimer = Timer(0.1);

  bool isDestroyed = false;
  bool isInvulnerable = false;
  Timer? invulnerabilityTimer;

  Spaceship() : super(size: Vector2(60, 80)) {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    shootTimer = Timer(
      0.5,
      repeat: true,
      onTick: shoot,
    )..start();

    // Initialize flash timer
    flashTimer = Timer(
      0.1,
      onTick: () {
        isFlashing = false;
        flashOpacity = 0.0;
      },
    );

    // Set initial invulnerability
    isInvulnerable = true;
    invulnerabilityTimer = Timer(
      2.0,
      onTick: () {
        isInvulnerable = false;
      },
    )..start();
  }

  void flash() {
    isFlashing = true;
    flashOpacity = 1.0;
    flashTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    shootTimer.update(dt);
    flashTimer.update(dt);
    invulnerabilityTimer?.update(dt);

    if (isFlashing) {
      flashOpacity = flashTimer.progress;
    }

    // Only use dragDelta if absolute positioning failed
    if (isDragging && dragDelta != null) {
      position.add(dragDelta! * dt * speed);
      position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);
      position.y = position.y.clamp(size.y / 2, gameRef.size.y - size.y / 2);
    }

    // Check for collisions with enemy bullets
    for (final bullet in gameRef.children.whereType<Bullet>()) {
      if (bullet.isEnemy && !isDestroyed && !isInvulnerable && toRect().overlaps(bullet.toRect())) {
        bullet.removeFromParent();
        
        if (gameRef.shieldActiveNotifier.value) {
          gameRef.shieldActiveNotifier.value = false;
          flash();
        } else {
          destroy();
          gameRef.loseLife();
        }
        break;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Calculate pulsing effect for invulnerability
    double opacity = 1.0;
    if (isInvulnerable) {
      final time = (gameRef.currentTime() * 10) % (2 * pi);
      opacity = 0.7 + 0.3 * sin(time);
    }

    // Draw ship body with invulnerability effect
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.blue.shade400.withOpacity(opacity),
          Colors.blue.shade700.withOpacity(opacity),
        ],
      ).createShader(size.toRect());

    final path = Path()
      ..moveTo(size.x / 2, 0)
      ..lineTo(size.x, size.y)
      ..lineTo(0, size.y)
      ..close();
    canvas.drawPath(path, paint);

    // Draw cockpit
    paint
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.lightBlueAccent, Colors.blue.shade300],
      ).createShader(Rect.fromCircle(
        center: Offset(size.x / 2, size.y / 2),
        radius: size.x / 3,
      ));
    canvas.drawCircle(
      Offset(size.x / 2, size.y * 0.4),
      size.x / 3,
      paint,
    );

    // Draw side boosters
    paint
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.blue.shade700, Colors.blue.shade900],
      ).createShader(size.toRect());
    
    // Left booster
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(5, size.y * 0.6, 15, size.y * 0.3),
        const Radius.circular(3),
      ),
      paint,
    );
    
    // Right booster
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x - 20, size.y * 0.6, 15, size.y * 0.3),
        const Radius.circular(3),
      ),
      paint,
    );

    // Draw engine flames
    if (isDragging) {
      final flamePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.orange, Colors.red],
        ).createShader(Rect.fromLTWH(0, size.y, size.x, 25));

      // Main engine flame
      final flamePath = Path()
        ..moveTo(size.x * 0.3, size.y)
        ..lineTo(size.x * 0.5, size.y + 25)
        ..lineTo(size.x * 0.7, size.y)
        ..close();
      canvas.drawPath(flamePath, flamePaint);

      // Side booster flames
      canvas.drawPath(
        Path()
          ..moveTo(5, size.y * 0.9)
          ..lineTo(12.5, size.y + 15)
          ..lineTo(20, size.y * 0.9)
          ..close(),
        flamePaint,
      );
      canvas.drawPath(
        Path()
          ..moveTo(size.x - 20, size.y * 0.9)
          ..lineTo(size.x - 12.5, size.y + 15)
          ..lineTo(size.x - 5, size.y * 0.9)
          ..close(),
        flamePaint,
      );
    }

    // Draw power-up effect
    if (powerUpActive) {
      paint
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.yellow.withOpacity(0.2), Colors.orange.withOpacity(0.3)],
        ).createShader(size.toRect());
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x / 1.2,
        paint,
      );
    }

    // Draw shield effect
    if (gameRef.shieldActiveNotifier.value) {
      paint
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.withOpacity(0.2),
            Colors.lightBlueAccent.withOpacity(0.3),
          ],
        ).createShader(size.toRect())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x / 1.2,
        paint,
      );
    }

    // Draw flash effect
    if (isFlashing) {
      paint
        ..shader = null
        ..color = Colors.red.withOpacity(flashOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);
    }
  }

  void shoot() {
    if (!isMounted) return;
    
    FlameAudio.play('shoot.wav', volume: 0.5);

    if (powerUpActive) {
      // Triple shot with wider spread
      final positions = [
        Vector2(-20, -10), // Wider left shot
        Vector2(0, -20),   // Center shot
        Vector2(20, -10),  // Wider right shot
      ];

      for (final offset in positions) {
        final bullet = Bullet(
          isEnemy: false,
          speed: 500,
          direction: Vector2(offset.x / 15, -1)..normalize(), // Adjusted angle
        )..position = position + offset;
        
        gameRef.add(bullet);
      }
    } else {
      // Single shot
      final bullet = Bullet(
        isEnemy: false,
        speed: 500,
        direction: Vector2(0, -1),
      )..position = position + Vector2(0, -size.y / 2);
      
      gameRef.add(bullet);
    }
  }

  @override
  bool onDragStart(DragStartEvent event) {
    if (!isDestroyed) {
      isDragging = true;
      dragDelta = Vector2.zero();
      initialPosition = position.clone();
    }
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    if (isDragging && !isDestroyed) {
      // Use localDelta for smooth control
      position += event.localDelta;
      
      // Clamp position to screen bounds with padding
      final padding = size.x / 2;
      position.x = position.x.clamp(padding, gameRef.size.x - padding);
      position.y = position.y.clamp(padding, gameRef.size.y - padding);
    }
    return true;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    isDragging = false;
    dragDelta = null;
    return true;
  }

  @override
  bool onDragCancel(DragCancelEvent event) {
    isDragging = false;
    dragDelta = null;
    return true;
  }

  void reset() {
    position = Vector2(gameRef.size.x / 2, gameRef.size.y - 60);
    powerUpActive = false;
    isDragging = false;
    dragDelta = null;
    isDestroyed = false;
    isInvulnerable = true;
    invulnerabilityTimer?.stop();
    invulnerabilityTimer = Timer(
      2.0,
      onTick: () {
        isInvulnerable = false;
      },
    )..start();
  }

  void destroy() {
    if (!isDestroyed) {
      isDestroyed = true;
      
      // Create ship debris particles
      final random = Random();
      final debrisColors = [
        Colors.blue.shade400,
        Colors.blue.shade700,
        Colors.lightBlueAccent,
      ];

      // Ship parts explosion
      for (int i = 0; i < 15; i++) {
        final debrisParticle = ParticleSystemComponent(
          particle: Particle.generate(
            count: 1,
            lifespan: 0.8 + random.nextDouble() * 0.5,
            generator: (i) => AcceleratedParticle(
              acceleration: Vector2(0, 200),
              child: RotatingParticle(
                child: ComputedParticle(
                  renderer: (canvas, particle) {
                    final paint = Paint()
                      ..color = debrisColors[random.nextInt(debrisColors.length)]
                          .withOpacity((1 - particle.progress) * 0.9);
                    
                    // Random ship debris shapes
                    if (random.nextBool()) {
                      canvas.drawRect(
                        Rect.fromCenter(
                          center: Offset.zero,
                          width: 4.0 * (1 - particle.progress),
                          height: 8.0 * (1 - particle.progress),
                        ),
                        paint,
                      );
                    } else {
                      canvas.drawPath(
                        Path()
                          ..moveTo(0, -4.0 * (1 - particle.progress))
                          ..lineTo(4.0 * (1 - particle.progress), 4.0 * (1 - particle.progress))
                          ..lineTo(-4.0 * (1 - particle.progress), 4.0 * (1 - particle.progress))
                          ..close(),
                        paint,
                      );
                    }
                  },
                ),
              ),
              position: position + Vector2(
                (random.nextDouble() - 0.5) * size.x,
                (random.nextDouble() - 0.5) * size.y,
              ),
              speed: Vector2(
                (random.nextDouble() - 0.5) * 400,
                -random.nextDouble() * 200,
              ),
            ),
          ),
        );
        
        gameRef.add(debrisParticle);
      }

      // Trigger main explosion effect
      gameRef.addExplosion(position);
      
      // Remove the ship
      removeFromParent();
    }
  }

  void moveWithKeyboard(Vector2 direction, double dt) {
    if (!isDestroyed) {
      position.add(direction * speed * dt);
      position.x = position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2);
      position.y = position.y.clamp(size.y / 2, gameRef.size.y - size.y / 2);
      
      // Simulate engine flames for keyboard movement
      if (!direction.isZero()) {
        isDragging = true;
      } else {
        isDragging = false;
      }
    }
  }
}
