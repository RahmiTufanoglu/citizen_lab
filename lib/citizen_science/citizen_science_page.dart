import 'package:citizen_lab/citizen_science/citizen_science_data.dart';
import 'package:citizen_lab/citizen_science/citizen_science_search_page.dart';
import 'package:citizen_lab/custom_widgets/no_yes_dialog.dart';
import 'package:citizen_lab/custom_widgets/top_text_card.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CitizenSciencePage extends StatefulWidget {
  @override
  _CitizenSciencePageState createState() => _CitizenSciencePageState();
}

class _CitizenSciencePageState extends State<CitizenSciencePage> {
  //PageController _pageController;
  //double _currentPage = citizenScienceImages.length - 1.0;

  //List<CitizenScienceModel> _citizenScienceList;

  ThemeChangerProvider _themeChanger;

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildAppBar() {
    const String citizenScience = 'Citizen Science';

    return AppBar(
      title: GestureDetector(
        onPanStart: (_) => _themeChanger.setTheme(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: citizenScience,
            child: const Text(citizenScience),
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: CitizenScienceSearchPage(
                citizenScienceList: citizenScienceModelList,
              ),
            );
          },
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

  void _setInfoPage() {
    Navigator.pushNamed(
      context,
      aboutPage,
      arguments: {
        'title': 'Info',
        'content': 'dfsafsdfsdfweqw111',
      },
    );
  }

  Future<void> _backToHomePage() async {
    const String cancel = 'Notiz abbrechen und zur Hauptseite zurückkehren?';

    await showDialog(
      context: context,
      builder: (_) {
        return NoYesDialog(
          text: cancel,
          onPressed: () {
            Navigator.popUntil(
              context,
              ModalRoute.withName(routeHomePage),
            );
          },
        );
      },
    );
  }

  Widget _buildBody() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    /*double dMin = screenHeight / 4;
    double dMax = screenHeight / 2;

    int iMin = dMin.round();
    int iMax = dMax.round();

    final _random = Random();
    int next(int min, int max) => min + _random.nextInt(max - min);

    next(iMin, iMax);*/

    /*return GridView.custom(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: screenWidth / (screenHeight / 1.5),
        //childAspectRatio: screenWidth / (next(iMin, iMax)).toDouble(),
      ),
      childrenDelegate: SliverChildListDelegate(
        List.generate(
          20,
          (index) {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: CardImageWithText(
                asset: 'assets/images/mushroom.jpg',
                title: '$index',
                fontColor: Colors.white,
                onTap: () => null,
              ),
            );
          },
        ),
      ),
    );*/

    return SafeArea(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: screenWidth / (screenHeight / 1.5),
          //childAspectRatio: screenWidth / (next(iMin, iMax)).toDouble(),
        ),
        itemCount: citizenScienceModelList.length,
        padding: const EdgeInsets.all(4.0),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: TopTextCard(
              title: citizenScienceModelList[index].title,
              asset: citizenScienceModelList[index].image,
              fontColor: Colors.white,
              fontSize: 20.0,
              onTapTitle: () {
                _showContent(
                  citizenScienceModelList[index].title,
                  citizenScienceModelList[index].built,
                  citizenScienceModelList[index].contactPerson,
                );
              },
              onTapImage: () {
                Navigator.pushNamed(
                  context,
                  detailPage,
                  arguments: {
                    'title': citizenScienceModelList[index].title,
                    'image': citizenScienceModelList[index].image,
                    'location': citizenScienceModelList[index].location,
                    'research_subject':
                        citizenScienceModelList[index].researchSubject,
                    'built': citizenScienceModelList[index].built,
                    'extended': citizenScienceModelList[index].extended,
                    'contact_person':
                        citizenScienceModelList[index].contactPerson,
                    'url': citizenScienceModelList[index].url,
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showContent(
    String title,
    String built,
    String contactPerson,
  ) async {
    await showDialog(
      context: context,
      builder: (_) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(8.0),
            ),
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
