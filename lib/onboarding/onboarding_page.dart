import 'package:citizen_lab/onboarding/page_indicator.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';

import 'onboarding_data.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  PageController _pageController;
  int _currentPage = 0;
  bool _lastPage = false;
  AnimationController _animationController;
  Animation<double> _scaleAnimation;

  @override
  void initState() {
    _pageController = PageController(initialPage: _currentPage);

    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween(begin: 0.0, end: 1.0).animate(_animationController);

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageView.builder(
            itemCount: pageList.length,
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                if (_currentPage == pageList.length - 1) {
                  _lastPage = true;
                  _animationController.forward();
                } else {
                  _lastPage = false;
                  _animationController.reset();
                }
              });
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  final PageModel page = pageList[index];
                  return Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          SizedBox(height: 16.0),
                          Expanded(
                            flex: 3,
                            child: Image.asset(
                              page.image,
                              scale: 2,
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              //color: mainLightColor,
                              child: ListView(
                                padding:
                                    EdgeInsets.fromLTRB(36.0, 36.0, 36.0, 80.0),
                                children: <Widget>[
                                  Text(
                                    page.title,
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  SizedBox(height: 36.0),
                                  Text(
                                    page.content,
                                    style: TextStyle(fontSize: 16.0),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 200.0,
                color: Colors.transparent,
                child: PageIndicator(
                  currentIndex: _currentPage,
                  pageCount: pageList.length,
                ),
              ),
            ),
          ),
          Positioned(
            top: statusBarHeight,
            right: 0.0,
            child: IconButton(
              icon: Icon(Icons.close),
              iconSize: 28.0,
              onPressed: () => _setNavigation(),
            ),
          ),
          Positioned(
            right: 16.0,
            bottom: 16.0,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _lastPage
                  ? FloatingActionButton(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      onPressed: () => _setNavigation(),
                      child: Icon(Icons.arrow_forward),
                    )
                  : Container(),
            ),
          ),
        ],
      ),
    );
  }

  void _setNavigation() {
    Navigator.pushNamed(
      context,
      RouteGenerator.homepage,
    );
  }
}
