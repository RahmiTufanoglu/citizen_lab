import 'package:citizen_lab/notes/note.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class NoteItem extends StatelessWidget {
  final Key key;
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
    this.key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double topBarHeight = MediaQuery.of(context).padding.top + kToolbarHeight;

    /*final DateFormat formatter = DateFormat('yyyy-MM.dd dd:mm:ss');
    final DateTime dt = formatter.parse(note.createdAt);
    final String createdDate =
        '${dt.day}.${dt.month}.${dt.year} ${dt.minute}:${dt.second}:${dt.millisecondsSinceEpoch}';*/

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
                    width: (screenWidth - 24.0 - 16.0 - 2.0 - 16.0 - 16.0) / 1.5,
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
                          //note.isEdited == 0 ? 'Erstellt am: ${note.createdAt}' : 'Editiert am: ${note.updatedAt}',
                          note.isEdited == 0
                              ? 'Erstellt am: ${_getFormattedDate(note.createdAt)}'
                              : 'Editiert am: ${_getFormattedDate(note.updatedAt)}',
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

  String _getFormattedDate(String s) {
    final String year = s.substring(0, 4);
    final String month = s.substring(5, 7);
    final String day = s.substring(8, 10);
    final String min = s.substring(11, 13);
    final String sec = s.substring(14, 16);
    final String milliSec = s.substring(17, 19);

    final String date = '$day.$month.$year $min:$sec:$milliSec';

    return date;
  }

  Widget _getIcon({@required Note note}) {
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
