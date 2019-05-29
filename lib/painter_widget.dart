import 'package:flutter/material.dart';
import 'package:citizen_lab/custom_stroke.dart';

class PainterWidget extends CustomPainter {
  final List<CustomStroke> strokes;
  final Color color;
  final double strokeWidth;

  PainterWidget({
    this.strokes,
    this.color,
    this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < strokes.length - 1; i++) {
      final CustomStroke from = strokes[i];
      final CustomStroke to = strokes[i + 1];

      if (from != null && to != null) {
        final paint = Paint()
          ..color = from.color
          ..strokeWidth = from.strokeWidth
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(from.offset, to.offset, paint);
      }
    }
  }

  @override
  bool shouldRepaint(PainterWidget oldDelegate) =>
      strokes != oldDelegate.strokes;

/*
  ui.Image get rendered {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    SignaturePainter painter = SignaturePainter(points: _points);
    var size = context.size;
    painter.paint(canvas, size);
    return recorder.endRecording()
        .toImage(size.width.floor(), size.height.floor());
  }
  */
}
