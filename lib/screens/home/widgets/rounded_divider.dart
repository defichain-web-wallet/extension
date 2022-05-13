import 'package:flutter/material.dart';

class RoundedDivider extends CustomPainter {
  RoundedDivider(this.radius, {this.initialAngle = 0});

  final double radius;
  final double initialAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final _paint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.translate(size.width / 2, size.height / 2);
    canvas.drawCircle(Offset(-170, 8), radius, _paint);
    canvas.translate(0, -radius);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
