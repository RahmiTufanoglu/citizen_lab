import 'package:flutter/material.dart';

class NoYesDialog extends StatelessWidget {
  final String text;
  final GestureTapCallback onPressed;

  const NoYesDialog({
    @required this.text,
    @required this.onPressed,
  })  : assert(text != null),
        assert(onPressed != null);

  @override
  Widget build(BuildContext context) {
    return _buildNoYesDialog(context);
  }

  Widget _buildNoYesDialog(BuildContext context) {
    const String no = 'Nein';
    const String yes = 'Ja';

    return SimpleDialog(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      ),
      contentPadding: const EdgeInsets.all(16.0),
      titlePadding: const EdgeInsets.only(
        top: 16.0,
        left: 16.0,
        right: 16.0,
      ),
      title: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      children: <Widget>[
        Icon(
          Icons.warning,
          size: 50.0,
          color: Colors.redAccent,
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: RaisedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  no,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: RaisedButton(
                onPressed: onPressed,
                child: Text(
                  yes,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
