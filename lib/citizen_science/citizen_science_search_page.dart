import 'package:citizen_lab/custom_widgets/top_text_card.dart';
import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';

import 'cizizen_science_model.dart';

class CitizenScienceSearchPage extends SearchDelegate<String> {
  List<CitizenScienceModel> citizenScienceList = [];
  bool _darkModeEnabled = false;

  CitizenScienceSearchPage({@required this.citizenScienceList});

  void _checkIfDarkModeEnabled(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    theme.brightness == appDarkTheme().brightness
        ? _darkModeEnabled = true
        : _darkModeEnabled = false;
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    _checkIfDarkModeEnabled(context);
    return _darkModeEnabled ? appDarkTheme() : appLightTheme();
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
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final suggestionList = query.isEmpty
        ? []
        : _getCitizenScienceTitles(citizenScienceList, query);
    return SafeArea(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: screenWidth / (screenHeight / 1.5),
        ),
        itemCount: suggestionList == null ? 0 : suggestionList.length,
        padding: EdgeInsets.all(4.0),
        itemBuilder: (context, index) {
          return TopTextCard(
            title: suggestionList[index].title,
            asset: suggestionList[index].image,
            fontColor: Colors.white,
            fontSize: 20.0,
            onTapTitle: () {},
            onTapImage: () async {
              await Navigator.pushNamed(
                context,
                RouteGenerator.detailPage,
                arguments: {
                  'title': suggestionList[index].title,
                  'image': suggestionList[index].image,
                  'location': suggestionList[index].location,
                  'research_subject': suggestionList[index].researchSubject,
                  'built': suggestionList[index].built,
                  'extended': suggestionList[index].extended,
                  'contact_person': suggestionList[index].contactPerson,
                },
              );
            },
          );
        },
      ),
    );
  }

  List<CitizenScienceModel> _getCitizenScienceTitles(
    List<CitizenScienceModel> notes,
    String query,
  ) {
    List<CitizenScienceModel> notesCopy = [];

    for (int i = 0; i < notes.length; i++) {
      if (notes[i].title.toLowerCase().contains(query)) {
        notesCopy.add(notes[i]);
      }
    }

    return notesCopy;
  }
}
