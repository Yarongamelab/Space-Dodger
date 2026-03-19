import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'asteroid.dart';
import 'powerup.dart';
import 'space_dodger_game.dart';

class Player extends SpriteComponent with HasGameRef, CollisionCallbacks {
  double speed = 400;
  int lives = 3;
  bool isInvincible = false;
  double shieldTime = 0;
  Vector2? targetPosition;

  Player() : super(size: Vector2(50, 60), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create player sprite programmatically (spaceship shape)
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = const Color(0xFF00D4FF);
    final glowPaint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // Draw spaceship body
    final path = Path();
    path.moveTo(25, 0);
    path.lineTo(50, 60);
    path.lineTo(25, 50);
    path.lineTo(0, 60);
    path.close();

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Draw cockpit
    final cockpitPaint = Paint()..color = const Color(0xFF00FFFF);
    canvas.drawOval(Rect.fromCenter(center: const Offset(25, 30), width: 15, height: 20), cockpitPaint);

    // Draw engine flame
    final flamePaint = Paint()..color = const Color(0xFFFF6600);
    final flamePath = Path();
    flamePath.moveTo(15, 55);
    flamePath.lineTo(25, 70 + Random().nextDouble() * 10);
    flamePath.lineTo(35, 55);
    canvas.drawPath(flamePath, flamePaint);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(50, 80);
    sprite = Sprite(image);

    if (gameRef.size.x > 0 && gameRef.size.y > 0) {
      position = Vector2(gameRef.size.x / 2, gameRef.size.y - 100);
    }

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isInvincible) {
      shieldTime -= dt;
      if (shieldTime <= 0) {
        isInvincible = false;
      }
    }

    // Smooth movement toward target
    if (targetPosition != null && gameRef.size.x > 0) {
      final direction = targetPosition! - position;
      if (direction.length > 5) {
        position.add(direction.normalized() * speed * dt);
      } else {
        position.setFrom(targetPosition!);
      }
    }

    // Keep player in bounds - only if size is valid
    if (gameRef.size.x > 50 && gameRef.size.y > 60) {
      position.x = position.x.clamp(25, gameRef.size.x - 25);
      position.y = position.y.clamp(30, gameRef.size.y - 30);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw shield if invincible
    if (isInvincible) {
      final paint = Paint()
        ..color = const Color(0xFF00FFFF).withOpacity(0.3 + sin(DateTime.now().millisecondsSinceEpoch / 200).abs() * 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x * 0.8, paint);
      
      final glowPaint = Paint()
        ..color = const Color(0xFF00FFFF).withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x * 0.85, glowPaint);
    }
  }

  void moveLeft() {
    position.x -= speed * 0.016;
  }

  void moveRight() {
    position.x += speed * 0.016;
  }

  void moveUp() {
    position.y -= speed * 0.016;
  }

  void moveDown() {
    position.y += speed * 0.016;
  }

  void activateShield(double duration) {
    isInvincible = true;
    shieldTime = duration;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (!isInvincible && other is Asteroid) {
      lives--;
      isInvincible = true;
      shieldTime = 2.0;
    } else if (other is PowerUp) {
      // Collect power-up
      (gameRef as SpaceDodgerGame).applyPowerUp(other.type);
      (gameRef as SpaceDodgerGame).recordPowerUpCollected();
      other.removeFromParent();
    }
  }
}
