import 'dart:ui';

import 'package:flutter/material.dart';

class AlarmDialog extends StatefulWidget {
  final Key key;
  final IconData icon;
  final Color iconColor;
  final String text;
  final GestureTapCallback onTap;

  const AlarmDialog({
    @required this.icon,
    @required this.text,
    @required this.onTap,
    this.key,
    this.iconColor = Colors.redAccent,
  }) : super(key: key);

  @override
  _AlarmDialogState createState() => _AlarmDialogState();
}

class _AlarmDialogState extends State<AlarmDialog> {
  final String _yes = 'Ja';
  final String _no = 'Nein';

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(16.0),
      elevation: 4.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      children: <Widget>[
        Column(
          children: <Widget>[
            Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
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
                  child: _buildRaisedButton(
                    Colors.grey.withOpacity(0.4),
                    Colors.grey.withOpacity(0.8),
                    onPressed: () => Navigator.pop(context, false),
                    text: _no,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: _buildRaisedButton(
                    Colors.red.withOpacity(0.4),
                    Colors.red.withOpacity(0.8),
                    onPressed: widget.onTap,
                    text: _yes,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRaisedButton(
    Color highlightColor,
    Color splashColor, {
    @required VoidCallback onPressed,
    @required String text,
  }) {
    return RaisedButton(
      highlightColor: highlightColor,
      splashColor: splashColor,
      elevation: 4.0,
      highlightElevation: 16.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }
}
