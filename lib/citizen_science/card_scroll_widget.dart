import 'dart:math';

import 'package:flutter/material.dart';

import 'citizen_science_data.dart';

class CardScrollWidget extends StatelessWidget {
  final double currentPage;

  CardScrollWidget({@required this.currentPage});

  @override
  Widget build(BuildContext context) {
    double _cardAspectRatio = 12.0 / 16.0;
    double _widgetAspectRatio = _cardAspectRatio * 1.2;
    double padding = 20.0;
    double verticalInset = 20.0;

    return Center(
      child: AspectRatio(
        aspectRatio: _widgetAspectRatio,
        child: LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth;
            double height = constraints.maxHeight;

            double safeWidth = width - 2 * padding;
            double safeHeight = height - 2 * padding;

            double heightOfPrimaryCard = safeHeight;
            double widthOfPrimaryCard = heightOfPrimaryCard * _cardAspectRatio;
            double primaryCardLeft = safeWidth - widthOfPrimaryCard;
            double horizontalInset = primaryCardLeft / 2;

            List<Widget> cardList = List();

            for (int i = 0; i < citizenScienceImages.length; i++) {
              double delta = i - currentPage;
              bool isOnRight = delta > 0;

              double start = padding +
                  max(
                      primaryCardLeft -
                          horizontalInset * -delta * (isOnRight ? 15 : 1),
                      0.0);

              Positioned cardItem = Positioned.directional(
                top: padding + verticalInset * max(-delta, 0.0),
                bottom: padding + verticalInset * max(-delta, 0.0),
                start: start,
                textDirection: TextDirection.rtl,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(16.0),
                    ),
                  ),
                  elevation: 8.0,
                  child: AspectRatio(
                    aspectRatio: _cardAspectRatio,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(16.0),
                      child: Image.asset(citizenScienceImages[i], fit: BoxFit.cover),
                    ),
                  ),
                ),
              );
              cardList.add(cardItem);
            }
            return Stack(
              children: cardList,
            );
          },
        ),
      ),
    );
  }
}
