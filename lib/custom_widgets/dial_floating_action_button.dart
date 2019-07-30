import 'dart:math';

import 'package:flutter/material.dart';

class DialFloatingActionButton extends StatefulWidget {
  final IconData firstIcon;
  final IconData secondIcon;
  final List<Icon> iconList;

  //final List<Color> colorList;
  final List<String> stringList;
  final Function function;

  DialFloatingActionButton({
    this.firstIcon = Icons.add,
    this.secondIcon = Icons.add,
    @required this.iconList,
    //@required this.colorList,
    @required this.stringList,
    @required this.function,
  })  : assert(iconList != null),
        assert(stringList != null),
        assert(function != null);

  @override
  _DialFloatingActionButtonState createState() =>
      _DialFloatingActionButtonState();
}

class _DialFloatingActionButtonState extends State<DialFloatingActionButton>
    with TickerProviderStateMixin {
  AnimationController _animationController;

  /*static const List<IconData> _iconList = const [
    Icons.link,
    Icons.camera_alt,
    Icons.table_chart,
    Icons.edit,
  ];*/

  @override
  void initState() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
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
      children: List.generate(widget.iconList.length, (int index) {
        Widget child = ScaleTransition(
          scale: CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              0.0,
              1.0 - index / widget.iconList.length,
              curve: Curves.easeInCirc,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              heroTag: null,
              //mini: true,
              //backgroundColor: widget.colorList[index],
              tooltip: '${widget.stringList[index]}note erstellen.',
              onPressed: () {
                _animationController.reverse();
                widget.function(widget.stringList[index]);
              },
              child: widget.iconList[index],
            ),
          ),
        );
        return child;
      }).toList()
        ..add(
          Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              heroTag: null,
              onPressed: () {
                _animationController.isDismissed
                    ? _animationController.forward()
                    : _animationController.reverse();
              },
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
            ),
          ),
        ),
    );
  }
}
