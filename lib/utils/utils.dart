import 'package:flutter/material.dart';

class Utils {
  static Offset localPosition(BuildContext context, Offset globalPosition) {
    RenderBox box = context.findRenderObject();
    Offset localPosition = box.globalToLocal(globalPosition);
    localPosition =
        localPosition.translate(0.0, -AppBar().preferredSize.height - 24.0);
    return localPosition;
  }

  static bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
}
