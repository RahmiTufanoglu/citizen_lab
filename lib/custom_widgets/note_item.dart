import 'package:citizen_lab/entries/note.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class NoteItem extends StatelessWidget {
  final Note note;
  final GestureTapCallback onTap;
  final GestureTapCallback onLongPress;

  NoteItem({
    @required this.note,
    @required this.onTap,
    this.onLongPress,
    //@required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      color: Color(note.cardColor),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: _getIcon(note),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    //color: Colors.white,
                    color: Color(note.cardTextColor),
                    height: double.infinity,
                    width: 2.0,
                    alignment: Alignment.center,
                  ),
                ),
                SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Text(
                        note.title,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(note.cardTextColor),
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Erstellt am: ' + note.dateCreated,
                      style: TextStyle(
                        //color: Colors.white,
                        color: Color(note.cardTextColor),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.touch_app,
                color: Color(note.cardTextColor),
              ),
            ),
          ],
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
