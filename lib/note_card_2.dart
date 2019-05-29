import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:citizen_lab/note.dart';

class NoteCard2 extends StatefulWidget {
  final BuildContext context;
  final List<Note> noteList;
  final int index;
  final GestureTapCallback onTap;
  final GestureTapCallback onLongPress;
  final GestureTapCallback onDeletePress;

  NoteCard2({
    @required this.context,
    @required this.noteList,
    @required this.index,
    @required this.onTap,
    @required this.onDeletePress,
    @required this.onLongPress,
  });

  @override
  _NoteCardState createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard2> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 2.0,
      color: _getColor(widget.noteList[widget.index].type),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: InkWell(
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              customBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 16.0),
                  _getIcon(widget.noteList[widget.index].type),
                  SizedBox(width: 16.0),
                  Container(
                    color: Colors.white,
                    height: double.infinity,
                    width: 2.0,
                    alignment: Alignment.center,
                  ),
                  SizedBox(width: 16.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        //_noteList[_index].title,
                        widget.noteList[widget.index].title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          'Erstellt am: ${widget.noteList[widget.index].dateCreated}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(
                Icons.remove_circle,
                color: Colors.white,
                size: 28.0,
              ),
              onPressed: widget.onDeletePress,
            ),
          ),
        ],
      ),
    );
  }

  /*
  @override
  Widget build2(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 8.0,
      color: _getColor(noteList[index].type),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getIcon(noteList[index].type),
            SizedBox(width: 16.0),
            Container(
              color: Colors.white,
              height: 36.0,
              width: 2.0,
              alignment: Alignment.center,
            ),
          ],
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              //_noteList[_index].title,
              noteList[index].title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: Text(
                'Erstellt am: ${noteList[index].dateCreated}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        onLongPress: onLongPress,
        trailing: Listener(
          key: Key(noteList[index].title),
          child: Icon(
            Icons.remove_circle,
            color: Colors.white,
            size: 28.0,
          ),
          //onPointerDown: onPointerDown,
          onPointerUp: onPointerUp,
        ),
      ),
    );
  }
*/

  Color _getColor(String type) {
    switch (type) {
      case 'Text':
        return Colors.green;
        break;
      case 'Zeichnung':
        return Colors.blue;
        break;
      case 'Tabelle':
        return Colors.deepOrange;
        break;
      case 'Bild':
        return Colors.purple;
        break;
      case 'Sensor':
        return Colors.brown;
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
      case 'Zeichnung':
        return Icon(Icons.brush, color: Colors.white);
        break;
      case 'Tabelle':
        return Icon(Icons.table_chart, color: Colors.white);
        break;
      case 'Bild':
        return Icon(Icons.camera_alt, color: Colors.white);
        break;
      case 'Sensor':
        return Icon(Icons.extension, color: Colors.white);
      default:
        return null;
        break;
    }
  }
}
