import 'dart:math';

import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';

import 'package:citizen_lab/citizen_science/card_scroll_widget.dart';
import 'package:citizen_lab/citizen_science/citizen_science_data.dart';
import 'package:citizen_lab/custom_widgets/card_image_with_text.dart';
import 'package:citizen_lab/citizen_science/citizen_science_model.dart';
import 'package:citizen_lab/citizen_science/citizen_science_search_page.dart';

class CitizenSciencePage extends StatefulWidget {
  @override
  _CitizenSciencePageState createState() => _CitizenSciencePageState();
}

class _CitizenSciencePageState extends State<CitizenSciencePage> {
  //PageController _pageController;
  //double _currentPage = citizenScienceImages.length - 1.0;

  List<CitizenScienceModel> _citizenScienceList;

  @override
  void initState() {
    /*_pageController =
        PageController(initialPage: citizenScienceImages.length - 1);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page;
      });
    });*/

    _citizenScienceList = [];
    _createCitizenScienceList();

    super.initState();
  }

  void _createCitizenScienceList() {
    for (int i = 0; i < 4; i++) {
      _citizenScienceList.add(
        CitizenScienceModel(
          citizenScienceTitles[i],
          citizenScienceImages[i],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
      body: _buildBody(),
    );
  }

  Widget _buildAppbar() {
    return AppBar(
      title: Text('Citizen Science'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: CitizenScienceSearchPage(
                citizenScienceList: _citizenScienceList,
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () => null,
        ),
        IconButton(
          icon: Icon(Icons.home),
          onPressed: () => null,
        ),
      ],
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

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: screenWidth / (screenHeight / 1.5),
        //childAspectRatio: screenWidth / (next(iMin, iMax)).toDouble(),
      ),
      itemCount: _citizenScienceList.length,
      padding: EdgeInsets.all(4.0),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: CardImageWithText(
            title: _citizenScienceList[index].title,
            asset: _citizenScienceList[index].image,
            fontColor: Colors.white,
            onTap: () => Navigator.pushNamed(
                  context,
                  RouteGenerator.detailPage,
                ),
          ),
        );
      },
    );
  }
}

/*Widget _buildBody2() {
    return Stack(
      children: <Widget>[
        CardScrollWidget(currentPage: _currentPage),
        Positioned.fill(
          child: PageView.builder(
            itemCount: csImages.length,
            controller: _pageController,
            reverse: true,
            itemBuilder: (context, index) {
              return Container();
            },
          ),
        ),
      ],
    );
  }*/
