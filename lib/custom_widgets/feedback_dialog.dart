import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class FeedbackDialog extends StatefulWidget {
  final String title;
  final String titleButtonLeft;
  final String titleButtonRight;
  final String labelText;
  final String isEmptyText;
  final String url;
  final IconData iconButtonLeft;
  final IconData iconButtonRight;

  FeedbackDialog({
    Key key,
    this.title = 'Feedback',
    this.titleButtonLeft = 'Email',
    this.titleButtonRight = 'Webseite',
    this.labelText = 'Feedback eingeben',
    this.isEmptyText = 'Bitte etwas eingeben',
    this.iconButtonLeft = Icons.email,
    this.iconButtonRight = Icons.public,
    @required this.url,
  }) : super(key: key);

  @override
  _FeedbackDialogState createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<FeedbackDialog> {
  TextEditingController _feedbackMessage = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidate: true,
      child: SimpleDialog(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(widget.title),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.all(16.0),
        titlePadding: const EdgeInsets.only(left: 16.0),
        children: <Widget>[
          TextFormField(
            controller: _feedbackMessage,
            maxLength: 100,
            maxLines: 5,
            keyboardType: TextInputType.text,
            autovalidate: true,
            decoration: InputDecoration(
              labelText: widget.labelText,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.deepOrange,
                  width: 2.0,
                ),
              ),
            ),
            validator: (text) {
              return text.isEmpty ? widget.isEmptyText : null;
            },
          ),
          SizedBox(height: 32.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                  elevation: 4.0,
                  highlightElevation: 16.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(widget.titleButtonLeft),
                        SizedBox(height: 8.0),
                        Icon(widget.iconButtonLeft),
                      ],
                    ),
                  ),
                  onPressed: () => _formKey.currentState.validate()
                      ? Share.share(_feedbackMessage.text)
                      : null,
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: RaisedButton(
                  elevation: 2.0,
                  highlightElevation: 16.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(widget.titleButtonRight),
                        SizedBox(height: 8.0),
                        Icon(widget.iconButtonRight),
                      ],
                    ),
                  ),
                  onPressed: () async {
                    if (await canLaunch(widget.url)) {
                      await launch(widget.url);
                    } else {
                      throw 'Could not launch ${widget.url}';
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
