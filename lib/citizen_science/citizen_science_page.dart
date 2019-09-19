import 'package:citizen_lab/citizen_science/citizen_science_data.dart';
import 'package:citizen_lab/citizen_science/citizen_science_search_page.dart';
import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';
import 'package:citizen_lab/custom_widgets/top_text_card.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/constants.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CitizenSciencePage extends StatefulWidget {
  @override
  _CitizenSciencePageState createState() => _CitizenSciencePageState();
}

class _CitizenSciencePageState extends State<CitizenSciencePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Consumer<ThemeChangerProvider>(
        builder: (BuildContext context, ThemeChangerProvider provider, Widget child) {
          return GestureDetector(
            onPanStart: (_) => provider.setTheme(),
            child: Container(
              width: double.infinity,
              child: Tooltip(
                message: Constants.citizenScience,
                child: const Text(Constants.citizenScience),
              ),
            ),
          );
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () => _setSearch(),
        ),
        IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () => _setInfoPage(),
        ),
        IconButton(
          icon: Icon(Icons.home),
          onPressed: () => _backToHomePage(),
        ),
      ],
    );
  }

  void _setSearch() {
    showSearch(
      context: context,
      delegate: CitizenScienceSearchPage(
        citizenScienceList: citizenScienceModels,
      ),
    );
  }

  void _setInfoPage() {
    Navigator.pushNamed(
      context,
      CustomRoute.aboutPage,
      arguments: {
        'title': 'Info',
        'content': 'dfsafsdfsdfweqw111',
      },
    );
  }

  void _backToHomePage() {
    const String cancel = 'Zur Hauptseite zurückkehren?';

    showDialog(
      context: context,
      builder: (_) {
        return NoYesDialog(
          text: cancel,
          onPressed: () {
            Navigator.popUntil(
              context,
              ModalRoute.withName(CustomRoute.routeHomePage),
            );
          },
        );
      },
    );
  }

  Widget _buildBody() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: screenWidth / (screenHeight / 1.5),
        ),
        itemCount: citizenScienceModels.length,
        padding: const EdgeInsets.all(4.0),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: TopTextCard(
              title: citizenScienceModels[index].title,
              asset: citizenScienceModels[index].image,
              fontColor: Colors.white,
              fontSize: 20.0,
              onTapTitle: () => _onTapTitle(index),
              onTapImage: () => _onTapImage(index),
            ),
          );
        },
      ),
    );
  }

  void _onTapTitle(int index) {
    _showContent(
      citizenScienceModels[index].title,
      citizenScienceModels[index].built,
      citizenScienceModels[index].contactPerson,
    );
  }

  void _onTapImage(int index) {
    Navigator.pushNamed(
      context,
      CustomRoute.detailPage,
      arguments: {
        'title': citizenScienceModels[index].title,
        'image': citizenScienceModels[index].image,
        'location': citizenScienceModels[index].location,
        'research_subject': citizenScienceModels[index].researchSubject,
        'built': citizenScienceModels[index].built,
        'extended': citizenScienceModels[index].extended,
        'contact_person': citizenScienceModels[index].contactPerson,
        'url': citizenScienceModels[index].url,
      },
    );
  }

  void _showContent(String title, String built, String contactPerson) {
    showDialog(
      context: context,
      builder: (_) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(16.0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text('Erstellt am: $built'),
            const SizedBox(height: 16.0),
            Text(
              contactPerson,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        );
      },
    );
  }
}
