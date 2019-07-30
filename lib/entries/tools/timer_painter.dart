import 'dart:math' as math;

import 'package:flutter/material.dart';

class TimerPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;
  final Color backgroundColor;

  TimerPainter({
    @required this.animation,
    @required this.color,
    @required this.backgroundColor,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    final double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    return animation.value != old.animation.value || color != old.color;
  }
}
