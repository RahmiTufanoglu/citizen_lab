import 'package:citizen_lab/citizen_science/citizen_science_data.dart';
import 'package:citizen_lab/citizen_science/citizen_science_search_page.dart';
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
  void initState() {
    /*_pageController =
        PageController(initialPage: citizenScienceImages.length - 1);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page;
      });
    });*/

    //_citizenScienceList = [];
    _createCitizenScienceList();

    super.initState();
  }

  void _createCitizenScienceList() {
    // TODO:
    /*for (int i = 0; i < 3; i++) {
      _citizenScienceList.add(
        CitizenScienceModel(
          citizenScienceTitles[i],
          citizenScienceImages[i],
          citizenScienceContent[i],
        ),
      );*/
  }

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);
    _themeChanger.checkIfDarkModeEnabled(context);

    return Scaffold(
      appBar: _buildAppbar(),
      body: _buildBody(),
    );
  }

  Widget _buildAppbar() {
    final String citizenScience = 'Citizen Science';

    return AppBar(
      title: GestureDetector(
        onPanStart: (_) => _themeChanger.setTheme(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: citizenScience,
            child: Text(citizenScience),
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
          onPressed: () => null,
        ),
      ],
    );
  }

  void _setInfoPage() {
    Navigator.pushNamed(
      context,
      RouteGenerator.aboutPage,
      arguments: {
        'title': 'Info',
        'content': 'dfsafsdfsdfweqw111',
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
        padding: EdgeInsets.all(4.0),
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
                return Navigator.pushNamed(
                  context,
                  RouteGenerator.detailPage,
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
      String title, String built, String contactPerson) async {
    await showDialog(
      context: context,
      builder: (_) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16.0),
            ),
          ),
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text('Erstellt am: $built'),
            SizedBox(height: 16.0),
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
