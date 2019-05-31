import 'package:citizen_lab/onboarding/page_indicator.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/material.dart';

import 'package:citizen_lab/utils/constants.dart';
import 'onboarding_data.dart';

class Onboarding extends StatefulWidget {
  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> with TickerProviderStateMixin {
  PageController _controller;
  int _currentPage = 0;
  bool _lastPage = false;
  AnimationController _animationController;
  Animation<double> _scaleAnimation;

  @override
  void initState() {
    _controller = PageController(initialPage: _currentPage);

    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween(begin: 0.0, end: 1.0).animate(
      _animationController,
    );

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    //double screenWidth = MediaQuery.of(context).size.width;

    double appBarHeight = AppBar().preferredSize.height;

    return MaterialApp(
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            PageView.builder(
              itemCount: pageList.length,
              controller: _controller,
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
                  animation: _controller,
                  builder: (context, child) {
                    final PageModel page = pageList[index];
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(
                          top: 16.0,
                          bottom: 64.0,
                          left: 16.0,
                          right: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Image.asset(
                              page.image,
                              height: (screenHeight / 2) - appBarHeight,
                              fit: BoxFit.fill,
                            ),
                            SizedBox(height: 42.0),
                            Center(
                              child: Text(
                                page.title,
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Text(
                              lorem,
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
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
              right: 16.0,
              bottom: 16.0,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _lastPage
                    ? FloatingActionButton(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        child: Icon(Icons.arrow_forward),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            RouteGenerator.home,
                          );
                        },
                      )
                    : Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
