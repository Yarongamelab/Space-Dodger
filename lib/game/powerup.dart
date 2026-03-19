import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

enum PowerUpType { shield, extraLife, scoreBoost, speedBoost }

class PowerUp extends SpriteComponent with HasGameRef {
  final PowerUpType type;
  final double speed = 200;

  PowerUp({required this.type}) : super(anchor: Anchor.center, size: Vector2(40, 40));

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Create power-up sprite based on type
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    Color color;

    switch (type) {
      case PowerUpType.shield:
        color = const Color(0xFF00FFFF);
        break;
      case PowerUpType.extraLife:
        color = const Color(0xFFFF4444);
        break;
      case PowerUpType.scoreBoost:
        color = const Color(0xFFFFD700);
        break;
      case PowerUpType.speedBoost:
        color = const Color(0xFF00FF00);
        break;
    }

    // Draw glowing circle background
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(20, 20), width: 40, height: 40),
      glowPaint,
    );

    final bgPaint = Paint()..color = color;
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(20, 20), width: 35, height: 35),
      bgPaint,
    );

    // Draw inner circle
    final innerPaint = Paint()..color = color.withOpacity(0.5);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(20, 20), width: 25, height: 25),
      innerPaint,
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(40, 40);
    sprite = Sprite(image);

    position = Vector2(
      Random().nextDouble() * (gameRef.size.x - 80) + 40,
      -40,
    );

    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
    
    // Rotate effect
    angle += 2 * dt;
    
    // Remove if off screen
    if (position.y > gameRef.size.y + 50) {
      removeFromParent();
    }
  }
  
  String get description {
    switch (type) {
      case PowerUpType.shield:
        return 'Shield';
      case PowerUpType.extraLife:
        return 'Extra Life';
      case PowerUpType.scoreBoost:
        return '2x Score';
      case PowerUpType.speedBoost:
        return 'Speed Boost';
    }
  }
}
