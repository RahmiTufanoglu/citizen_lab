import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int pageCount;

  const PageIndicator({
    @required this.currentIndex,
    @required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.0,
      height: 25.0,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Row(children: _buildPageIndicators()),
    );
  }

  Widget _indicator(bool isActive) {
    const Color lightGreen = Color(0xFFBFE0D0);
    const Color softBlue = Color(0xFF009FE3);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          height: 12.0,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            color: isActive ? softBlue : lightGreen,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicators() {
    final List<Widget> indicatorList = [];
    for (int i = 0; i < pageCount; i++) {
      indicatorList.add(
        i == currentIndex ? _indicator(true) : _indicator(false),
      );
    }
    return indicatorList;
  }
}
