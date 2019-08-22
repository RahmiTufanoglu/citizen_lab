import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

Offset localPosition(BuildContext context, Offset globalPosition) {
  final RenderBox box = context.findRenderObject();
  /*Offset localPosition = box.globalToLocal(globalPosition);
    localPosition =
        localPosition.translate(0.0, -AppBar().preferredSize.height - 24.0);*/
  final Offset localPosition = box
      .globalToLocal(globalPosition)
      .translate(0.0, -AppBar().preferredSize.height - 24.0);
  return localPosition;
}

bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}

/*static int getRandomNumber() {
    Random random = Random();
    // Integer between 0 and 100 (0 can be 100 not)
    int num = random.nextInt(1000);
    return num;
  }*/

String generateRandomUuid() {
  final Uuid uuid = Uuid();
  return uuid.v4();
}

String removeWhiteSpace(String text) {
  return text.split(' ').join('');
}
