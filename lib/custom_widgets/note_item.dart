import 'package:citizen_lab/entries/note.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class NoteItem extends StatelessWidget {
  final Key key;
  final Note note;
  final GestureTapCallback onTap;
  final GestureTapCallback onLongPress;

  NoteItem({
    this.key,
    @required this.note,
    @required this.onTap,
    this.onLongPress,
    //@required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      color: _getColor(note.type),
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
                  child: _getIcon(note.type),
                ),
                Padding(
                  //padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    color: Colors.white,
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
                      //width: MediaQuery.of(context).size.width - 144.0,
                      width: MediaQuery.of(context).size.width / 2,
                      child: Text(
                        note.title,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Erstellt am: ' + note.dateCreated,
                      style: TextStyle(
                        color: Colors.white,
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
              child: Icon(Icons.touch_app, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor(String type) {
    switch (type) {
      case 'Text':
        return Colors.green;
        break;
      case 'Tabelle':
        return Colors.indigoAccent;
        break;
      case 'Bild':
        return Colors.deepOrange;
        break;
      case 'Verlinkung':
        return Colors.purple;
        break;
      default:
        return null;
        break;
    }
  }

  Icon _getIcon(String type) {
    switch (type) {
      case 'Text':
        return Icon(Icons.create, color: Colors.white);
        break;
      case 'Tabelle':
        return Icon(Icons.table_chart, color: Colors.white);
        break;
      case 'Bild':
        return Icon(Icons.camera_alt, color: Colors.white);
        break;
      case 'Verlinkung':
        return Icon(Icons.link, color: Colors.white);
        break;
      default:
        return null;
        break;
    }
  }
}
