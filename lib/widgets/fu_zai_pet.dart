import 'package:flutter/material.dart';

enum PetExpression { normal, happy }

class VirtualPet extends StatefulWidget {
  const VirtualPet({super.key});

  @override
  State<VirtualPet> createState() => _VirtualPetState();
}

class _VirtualPetState extends State<VirtualPet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blinkAnimation;
  PetExpression _currentExpression = PetExpression.normal;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _blinkAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 5,
      ),
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 3),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 5,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 87),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void changeExpression(PetExpression expression) {
    setState(() {
      _currentExpression = expression;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: PetPainter(
                    expression: _currentExpression,
                    blinkProgress: _blinkAnimation.value,
                    leftHandAngle: 650,
                    rightHandAngle: 0,
                  ),
                  size: const Size(200, 200),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class PetPainter extends CustomPainter {
  final PetExpression expression;
  final double blinkProgress;
  final double leftHandAngle;
  final double rightHandAngle;

  PetPainter({
    required this.expression,
    required this.blinkProgress,
    required this.leftHandAngle,
    required this.rightHandAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    const double baseSize = 230;
    final scaleX = size.width / baseSize;
    final scaleY = size.height / baseSize;
    canvas.scale(scaleX, scaleY);

    // Draw white outer oval (body)
    paint.color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: 160,
        height: 130,
      ),
      paint..style = PaintingStyle.fill,
    );
    paint
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: 160,
        height: 130,
      ),
      paint,
    );

    // Draw black inner oval (face) near the top of the body
    paint.color = Colors.black;
    const faceOffsetY = -15.0; // Adjust this value to move face upward
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2 + faceOffsetY),
        width: 120,
        height: 75,
      ),
      paint..style = PaintingStyle.fill,
    );
    // Draw border for inner oval
    paint
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2 + -15.0),
        width: 120,
        height: 75,
      ),
      paint,
    );

    // Eyes
    final eyeWidth = 10.0 * blinkProgress.clamp(0.0, 1.0);
    final eyeHeight = 20.0 * blinkProgress.clamp(0.0, 1.0);
    final eyeRadius = Radius.circular(10);
    final eyePaint = Paint()..color = Colors.white;

    final leftEyeCenter = Offset(size.width / 2 - 20, size.height / 2 - 20);
    final rightEyeCenter = Offset(size.width / 2 + 20, size.height / 2 - 20);

    final leftEyeRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: leftEyeCenter,
        width: eyeWidth,
        height: eyeHeight,
      ),
      topLeft: eyeRadius,
      topRight: eyeRadius,
      bottomLeft: eyeRadius,
      bottomRight: eyeRadius,
    );

    final rightEyeRect = RRect.fromRectAndCorners(
      Rect.fromCenter(
        center: rightEyeCenter,
        width: eyeWidth,
        height: eyeHeight,
      ),
      topLeft: eyeRadius,
      topRight: eyeRadius,
      bottomLeft: eyeRadius,
      bottomRight: eyeRadius,
    );

    // Draw eyes
    canvas.drawRRect(leftEyeRect, eyePaint);
    canvas.drawRRect(rightEyeRect, eyePaint);

    // Draw pupils if eyes are not closed
    if (blinkProgress > 0.1) {
      final pupilPaint = Paint()..color = Colors.black;
      final pupilWidth = 8.0 * blinkProgress.clamp(0.0, 1.0);
      final pupilHeight = 16.0 * blinkProgress.clamp(0.0, 1.0);
      const pupilRadius = Radius.circular(10);

      final leftEyePupilRect = RRect.fromRectAndCorners(
        Rect.fromCenter(
          center: leftEyeCenter,
          width: pupilWidth,
          height: pupilHeight,
        ),
        topLeft: pupilRadius,
        topRight: pupilRadius,
        bottomLeft: pupilRadius,
        bottomRight: pupilRadius,
      );

      final rightEyePupilRect = RRect.fromRectAndCorners(
        Rect.fromCenter(
          center: rightEyeCenter,
          width: pupilWidth,
          height: pupilHeight,
        ),
        topLeft: pupilRadius,
        topRight: pupilRadius,
        bottomLeft: pupilRadius,
        bottomRight: pupilRadius,
      );

      canvas.drawRRect(leftEyePupilRect, pupilPaint);
      canvas.drawRRect(rightEyePupilRect, pupilPaint);
    }

    // Left hand
    canvas.save();
    final leftHandTop = Offset(size.width / 2 - 100, size.height / 2);
    canvas.translate(leftHandTop.dx, leftHandTop.dy);
    canvas.rotate(leftHandAngle); // radians
    paint
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromLTWH(-10, 0, 20, 50), // 20x50 oval with top as origin
      paint,
    );
    // Draw border for left hand
    paint
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawOval(Rect.fromLTWH(-10, 0, 20, 50), paint);
    canvas.restore();

    // Right hand
    canvas.save();
    final rightHandTop = Offset(size.width / 2 + 100, size.height / 2);
    canvas.translate(rightHandTop.dx, rightHandTop.dy);
    canvas.rotate(rightHandAngle); // radians
    paint
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromLTWH(-10, 0, 20, 50), paint);
    // Draw border for right hand
    paint
      ..color = Colors.black26
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawOval(Rect.fromLTWH(-10, 0, 20, 50), paint);
    canvas.restore();

    // Draw eyes and mouth based on expression
    if (expression == PetExpression.happy) {
      // Draw cyan curved eyes for happy expression
      paint.color = Colors.cyan;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 4;

      // Left eye
      canvas.drawArc(
        Rect.fromLTWH(size.width / 2 - 35, size.height / 2 - 30, 30, 30),
        3.14, // Start angle (π radians = 180 degrees)
        3.14, // Sweep angle (π radians = 180 degrees)
        false,
        paint,
      );

      // Right eye
      canvas.drawArc(
        Rect.fromLTWH(size.width / 2 + 5, size.height / 2 - 30, 30, 30),
        3.14, // Start angle
        3.14, // Sweep angle
        false,
        paint,
      );

      // Draw smile
      canvas.drawArc(
        Rect.fromLTWH(size.width / 2 - 20, size.height / 2 - 10, 40, 40),
        0.3, // Start angle (slightly offset from 0)
        2.54, // Sweep angle (slightly less than π)
        false,
        paint,
      );
    } else {
      // Normal expression (can be modified as needed)
    }

    // Draw 福 character in yellow
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFFE5C165);
    TextPainter(
        text: const TextSpan(
          text: '福',
          style: TextStyle(color: Color(0xFFE5C165), fontSize: 20),
        ),
        textDirection: TextDirection.ltr,
      )
      ..layout()
      ..paint(canvas, Offset(size.width / 2 - 10, size.height / 2 + 30));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
