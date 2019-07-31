import 'dart:ui';

import 'package:flutter/material.dart';

class AlarmDialog extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final GestureTapCallback onTap;

  const AlarmDialog({
    @required this.icon,
    @required this.text,
    @required this.onTap,
    this.iconColor = Colors.redAccent,
  })  : assert(icon != null),
        assert(text != null),
        assert(onTap != null);

  @override
  _AlarmDialogState createState() => _AlarmDialogState();
}

class _AlarmDialogState extends State<AlarmDialog> {
  final String yes = 'Ja';
  final String no = 'Nein';

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      children: <Widget>[
        Column(
          children: <Widget>[
            Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: Icon(
                widget.icon,
                color: widget.iconColor,
                size: 42.0,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                    elevation: 4.0,
                    highlightElevation: 16.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      no,
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: RaisedButton(
                    highlightColor: Colors.red.withOpacity(0.4),
                    splashColor: Colors.red.withOpacity(0.8),
                    elevation: 4.0,
                    highlightElevation: 16.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(8.0),
                      ),
                    ),
                    onPressed: widget.onTap,
                    child: Text(
                      yes,
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
