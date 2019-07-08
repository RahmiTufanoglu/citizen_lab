import 'package:citizen_lab/entries/note.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class NoteItem extends StatelessWidget {
  final Note note;
  final bool isNote;
  final bool isFromNoteSearchPage;
  final Function noteFunction;
  final Function close;
  final GestureTapCallback onLongPress;

  NoteItem({
    @required this.note,
    @required this.isNote,
    @required this.isFromNoteSearchPage,
    @required this.noteFunction,
    @required this.close,
    @required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topBarHeight =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        height: (screenHeight + topBarHeight) / 10,
        padding: const EdgeInsets.all(4.0),
        child: RaisedButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  isNote ? _getIcon(note) : null,
                  isNote ? SizedBox(width: 16.0) : null,
                  isNote
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            color: Color(note.cardTextColor),
                            height: double.infinity,
                            width: 2.0,
                            alignment: Alignment.center,
                          ),
                        )
                      : null,
                  isNote ? SizedBox(width: 16.0) : null,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        note.title,
                        style: TextStyle(color: Color(note.cardTextColor)),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Erstellt am: ${note.dateCreated}',
                        style: TextStyle(
                          color: Color(note.cardTextColor),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(
                Icons.touch_app,
                color: Color(note.cardTextColor),
              ),
            ],
          ),
          color: Color(note.cardColor),
          onPressed: () {
            //close(context, null);
            if (isFromNoteSearchPage) close();
            noteFunction();
          },
        ),
      ),
    );
  }

  Icon _getIcon(Note note) {
    switch (note.type) {
      case 'Text':
        return Icon(
          Icons.create,
          //color: Colors.white,
          color: Color(note.cardTextColor),
        );
        break;
      case 'Tabelle':
        return Icon(
          Icons.table_chart,
          //color: Colors.white,
          color: Color(note.cardTextColor),
        );
        break;
      case 'Bild':
        return Icon(
          Icons.camera_alt,
          //color: Colors.white,
          color: Color(note.cardTextColor),
        );
        break;
      case 'Verlinkung':
        return Icon(
          Icons.link,
          //color: Colors.white,
          color: Color(note.cardTextColor),
        );
        break;
      default:
        return null;
        break;
    }
  }
}
