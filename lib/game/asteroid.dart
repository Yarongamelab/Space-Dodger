import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'space_dodger_game.dart';

class Asteroid extends SpriteComponent with HasGameRef {
  final double speed;
  final int sizeCategory; // 0 = small, 1 = medium, 2 = large

  Asteroid({required this.speed, this.sizeCategory = 1})
      : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final size = 30.0 + (sizeCategory * 20);
    this.size = Vector2(size, size);

    // Create asteroid sprite programmatically
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final colors = [
      const Color(0xFF8B4513),
      const Color(0xFFA0522D),
      const Color(0xFF696969),
      const Color(0xFF808080),
    ];
    final mainColor = colors[Random().nextInt(colors.length)];

    final paint = Paint()..color = mainColor;
    final shadowPaint = Paint()..color = mainColor.withOpacity(0.7);

    // Draw irregular asteroid shape
    final path = Path();
    const points = 8;
    final random = Random();

    for (int i = 0; i <= points; i++) {
      final angle = (i / points) * 2 * pi;
      final radius = (size / 2) * (0.7 + random.nextDouble() * 0.3);
      final x = (size / 2) + cos(angle) * radius;
      final y = (size / 2) + sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    // Add craters
    final craterPaint = Paint()..color = mainColor.withOpacity(0.5);
    for (int i = 0; i < 3; i++) {
      final craterX = random.nextDouble() * size * 0.6 + size * 0.2;
      final craterY = random.nextDouble() * size * 0.6 + size * 0.2;
      final craterSize = random.nextDouble() * 5 + 3;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(craterX, craterY), width: craterSize, height: craterSize * 0.8),
        craterPaint,
      );
    }

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    sprite = Sprite(image);

    position = Vector2(
      Random().nextDouble() * (gameRef.size.x - size) + size / 2,
      -size,
    );

    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;

    // Remove if off screen - record as avoided asteroid
    if (position.y > gameRef.size.y + 50) {
      (gameRef as SpaceDodgerGame).recordAsteroidDestroyed();
      removeFromParent();
    }
  }
}
