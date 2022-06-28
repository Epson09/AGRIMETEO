import 'package:flutter/material.dart';

class BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color.fromARGB(0, 2, 183, 2)
      ..style = PaintingStyle.fill;
    final Path bubble = Path()
      ..moveTo(size.width - 15.0, size.height)
      ..lineTo(17.0, size.height)
      ..cubicTo(
          7.61, size.height, 0.0, size.height - 7.61, 0.0, size.height - 17.0)
      ..lineTo(0.0, 17.0)
      ..cubicTo(0.0, 7.61, 7.61, 0.0, 17.0, 0.0)
      ..lineTo(size.width - 21, 0.0)
      ..cubicTo(size.width - 11.61, 0.0, size.width - 4.0, 7.61,
          size.width - 4.0, 17.0)
      ..lineTo(size.width - 4.0, size.height - 11.0)
      ..cubicTo(size.width - 4.0, size.height - 1.0, size.width, size.height,
          size.width, size.height)
      ..lineTo(size.width + 0.05, size.height - 0.01)
      ..cubicTo(size.width - 4.07, size.height + 0.43, size.width - 8.16,
          size.height - 1.06, size.width - 11.04, size.height - 4.04)
      ..cubicTo(size.width - 16.0, size.height, size.width - 19.0, size.height,
          size.width - 22.0, size.height)
      ..close();
    canvas.drawPath(bubble, paint);
  }

  @override
  bool shouldRepaint(BubblePainter oldPainter) => true;
}
