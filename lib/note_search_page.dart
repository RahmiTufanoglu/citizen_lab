import 'package:citizen_lab/themes/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'custom_widgets/note_item.dart';
import 'entries/note.dart';

class NoteSearchPage extends SearchDelegate<String> {
  List<Note> noteList = [];
  bool isFromNoteSearchPage;
  final Function openNotePage;
  final Function reloadNoteList;
  bool _darkModeEnabled = false;

  NoteSearchPage({
    @required this.noteList,
    @required this.reloadNoteList,
    @required this.isFromNoteSearchPage,
    @required this.openNotePage,
  });

  @override
  ThemeData appBarTheme(BuildContext context) {
    _checkIfDarkModeEnabled(context);
    return _darkModeEnabled ? appDarkTheme() : appLightTheme();
  }

  void _checkIfDarkModeEnabled(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    theme.brightness == appDarkTheme().brightness
        ? _darkModeEnabled = true
        : _darkModeEnabled = false;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () => query = '',
      ),
      SizedBox(width: 8.0),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => null;

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty ? [] : _getNoteTitles(noteList, query);
    return SafeArea(
      child: ListView.builder(
        itemCount: suggestionList == null ? 0 : suggestionList.length,
        padding: EdgeInsets.all(4.0),
        itemBuilder: (context, index) {
          return NoteItem(
            note: suggestionList[index],
            isFromNoteSearchPage: true,
            noteFunction: () => openNotePage(
              suggestionList[index].type,
              suggestionList[index],
            ),
            close: () => close(context, null),
            onLongPress: null,
          );

          /*final double screenHeight = MediaQuery.of(context).size.height;
          final double topBarHeight =
              MediaQuery.of(context).padding.top + kToolbarHeight;

          return Container(
            height: (screenHeight + topBarHeight) / 10,
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _getIcon(suggestionList[index]),
                      SizedBox(width: 16.0),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          color: Color(suggestionList[index].cardTextColor),
                          height: double.infinity,
                          width: 2.0,
                          alignment: Alignment.center,
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            suggestionList[index].title,
                            style: TextStyle(
                                color:
                                    Color(suggestionList[index].cardTextColor)),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Erstellt am: ${suggestionList[index].dateCreated}',
                            style: TextStyle(
                              color: Color(suggestionList[index].cardTextColor),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Icon(
                    Icons.touch_app,
                    color: Color(suggestionList[index].cardTextColor),
                  ),
                ],
              ),
              color: Color(suggestionList[index].cardColor),
              onPressed: () {
                close(context, null);
                openNotePage(
                  suggestionList[index].type,
                  suggestionList[index],
                );
              },
            ),
          );*/
        },
      ),
    );
  }

  List<Note> _getNoteTitles(
    List<Note> notes,
    String query,
  ) {
    final List<Note> notesCopy = [];

    for (int i = 0; i < notes.length; i++) {
      if (notes[i].title.toLowerCase().contains(query)) {
        notesCopy.add(notes[i]);
      }
    }

    return notesCopy;
  }
}
