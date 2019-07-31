import 'package:citizen_lab/entries/note.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class NoteItem extends StatelessWidget {
  final Note note;
  final bool isFromNoteSearchPage;
  final Function noteFunction;
  final Function close;
  final GestureTapCallback onLongPress;

  const NoteItem({
    @required this.note,
    @required this.isFromNoteSearchPage,
    @required this.noteFunction,
    @required this.close,
    @required this.onLongPress,
  })  : assert(note != null),
        assert(isFromNoteSearchPage != null),
        assert(noteFunction != null);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double topBarHeight =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        height: (screenHeight + topBarHeight) / 10,
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: RaisedButton(
          color: Color(note.cardColor),
          onPressed: () {
            //close(context, null);
            if (isFromNoteSearchPage) close();
            noteFunction();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _getIcon(note: note),
                  const SizedBox(width: 16.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Container(
                      alignment: Alignment.center,
                      color: Color(note.cardTextColor),
                      height: double.infinity,
                      width: 2.0,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Container(
                    width:
                        (screenWidth - 24.0 - 16.0 - 2.0 - 16.0 - 16.0) / 1.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          note.title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Color(note.cardTextColor)),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          note.isEdited == 0
                              ? 'Erstellt am: ${note.createdAt}'
                              : 'Editiert am: ${note.updatedAt}',
                          style: TextStyle(
                            color: Color(note.cardTextColor),
                            fontStyle: FontStyle.italic,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.touch_app,
                size: 20.0,
                color: Color(note.cardTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Icon _getIcon({@required Note note}) {
    switch (note.type) {
      case 'Text':
        return Icon(
          Icons.create,
          color: Color(note.cardTextColor),
        );
        break;
      case 'Tabelle':
        return Icon(
          Icons.table_chart,
          color: Color(note.cardTextColor),
        );
        break;
      case 'Bild':
        return Icon(
          Icons.camera_alt,
          color: Color(note.cardTextColor),
        );
        break;
      case 'Audio':
        return Icon(
          Icons.mic,
          color: Color(note.cardTextColor),
        );
        break;
      case 'Verlinkung':
        return Icon(
          Icons.link,
          color: Color(note.cardTextColor),
        );
        break;
      default:
        return Icon(Icons.android);
        break;
    }
  }
}
