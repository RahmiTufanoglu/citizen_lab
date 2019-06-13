import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class SpeedDialFloatingActionButton extends StatefulWidget {
  final Key key;
  final IconData firstIcon;
  final IconData secondIcon;
  final List<Icon> iconList;
  final List<Color> colorList;
  final List<String> stringList;
  final Function function;

  SpeedDialFloatingActionButton({
    this.key,
    this.firstIcon = Icons.add,
    this.secondIcon = Icons.add,
    @required this.iconList,
    @required this.colorList,
    @required this.stringList,
    @required this.function,
  }) : super(key: key);

  @override
  _SpeedDialFloatingActionButtonState createState() =>
      _SpeedDialFloatingActionButtonState();
}

class _SpeedDialFloatingActionButtonState
    extends State<SpeedDialFloatingActionButton> with TickerProviderStateMixin {
  AnimationController _animationController;

  static const List<IconData> _iconList = const [
    Icons.link,
    Icons.camera_alt,
    Icons.table_chart,
    Icons.edit,
  ];

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_iconList.length, (int index) {
        Widget child = ScaleTransition(
          scale: CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              0.0,
              1.0 - index / _iconList.length,
              curve: Curves.easeInCirc,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              heroTag: null,
              //mini: true,
              backgroundColor: widget.colorList[index],
              tooltip: '${widget.stringList[index]}note erstellen.',
              child: widget.iconList[index],
              onPressed: () {
                _animationController.reverse();
                widget.function(widget.stringList[index]);
              },
            ),
          ),
        );
        return child;
      }).toList()
        ..add(
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              heroTag: null,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (BuildContext context, Widget child) {
                  return Transform(
                    transform: Matrix4.rotationZ(
                        _animationController.value * 0.25 * pi),
                    alignment: FractionalOffset.center,
                    child: Icon(
                      _animationController.isDismissed
                          ? widget.firstIcon
                          : widget.secondIcon,
                    ),
                  );
                },
              ),
              onPressed: () {
                _animationController.isDismissed
                    ? _animationController.forward()
                    : _animationController.reverse();
              },
            ),
          ),
        ),
    );
  }
}
