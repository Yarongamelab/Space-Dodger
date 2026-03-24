import 'package:flutter/material.dart';

class SpaceLogoWidget extends StatelessWidget {
  final double size;
  const SpaceLogoWidget({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: SpaceLogoPainter(),
      ),
    );
  }
}

class SpaceLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final s = size.width;

    // Outer Glow (matching the cyan vibe)
    final glowPaint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center, s * 0.45, glowPaint);

    // 1. Draw the Main Ship Triangle
    final shipPath = Path();
    shipPath.moveTo(center.dx, center.dy - s * 0.45); // Top tip
    shipPath.lineTo(center.dx + s * 0.35, center.dy + s * 0.3); // Bottom right
    shipPath.lineTo(center.dx, center.dy + s * 0.2); // Center bottom indent
    shipPath.lineTo(center.dx - s * 0.35, center.dy + s * 0.3); // Bottom left
    shipPath.close();

    final shipPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF00FFFF), Color(0xFF0066FF)],
      ).createShader(Rect.fromLTWH(0, 0, s, s));
    
    canvas.drawPath(shipPath, shipPaint);

    // 2. The Yellow Thruster/Light at the bottom (matching your image)
    final thrusterPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center + Offset(0, s * 0.32), s * 0.08, thrusterPaint);

    // 3. The Cockpit (Light blue teardrop)
    final cockpitPath = Path();
    cockpitPath.moveTo(center.dx, center.dy - s * 0.2);
    cockpitPath.quadraticBezierTo(center.dx + s * 0.07, center.dy - s * 0.05, center.dx, center.dy + s * 0.05);
    cockpitPath.quadraticBezierTo(center.dx - s * 0.07, center.dy - s * 0.05, center.dx, center.dy - s * 0.2);
    
    final cockpitPaint = Paint()..color = const Color(0xFFE0FFFF).withOpacity(0.9);
    canvas.drawPath(cockpitPath, cockpitPaint);

    // 4. Wing Accents (White lines)
    final detailPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    canvas.drawLine(center + Offset(-s * 0.15, s * 0.05), center + Offset(-s * 0.2, s * 0.2), detailPaint);
    canvas.drawLine(center + Offset(s * 0.15, s * 0.05), center + Offset(s * 0.2, s * 0.2), detailPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
