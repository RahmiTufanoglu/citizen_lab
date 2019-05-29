import 'package:citizen_lab/theme.dart';
import 'package:citizen_lab/theme_changer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:citizen_lab/feedback_dialog.dart';
import 'package:citizen_lab/image_with_text.dart';
import 'package:citizen_lab/main_drawer.dart';
import 'package:citizen_lab/route_generator.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'constants.dart';

class HomePage extends StatefulWidget {
  final Key key;

  HomePage({this.key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;
  ThemeChanger _themeChanger;
  bool _valueSwitch = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _animationController.forward();
  }

  void _checkIfDarkModeEnabled() {
    final ThemeData theme = Theme.of(context);
    theme.brightness == appDarkTheme().brightness
        ? _valueSwitch = true
        : _valueSwitch = false;
  }

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChanger>(context);

    _checkIfDarkModeEnabled();

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      elevation: 4.0,
      title: Text('Citizen Lab'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.tag_faces),
          onPressed: () {},
        ),
        SizedBox(width: 8.0),
      ],
    );
  }

  Widget _buildDrawer() {
    return MainDrawer(
      children: <Widget>[
        Container(
          height: 150.0,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
          ),
          child: Card(
            shape: Border(),
            margin: const EdgeInsets.all(0.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  app_title,
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
            ),
          ),
        ),
        Column(
          children: <Widget>[
            SizedBox(height: 16.0),
            _buildDrawerItem(
              context: context,
              icon: Icons.border_color,
              title: 'Projekt erstellen',
              onTap: () => Navigator.pushNamed(
                    context,
                    RouteGenerator.createProject,
                  ),
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.assignment,
              title: 'Projekt öffnen',
              onTap: () => Navigator.pushNamed(
                    context,
                    RouteGenerator.projectPage,
                  ),
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.public,
              title: 'Citizen Science',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RouteGenerator.detailPage,
                );
              },
            ),
          ],
        ),
        Divider(
          color: Colors.black,
          height: 0.5,
        ),
        Column(
          children: <Widget>[
            _buildDrawerItem(
              context: context,
              icon: Icons.feedback,
              title: feedback,
              onTap: () => showDialog(
                    context: context,
                    builder: (_) => FeedbackDialog(url: fraunhofer_umsicht_url),
                  ),
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.info,
              title: 'Über',
              onTap: () => null,
            ),
          ],
        ),
        Divider(
          color: Colors.black,
          height: 0.5,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.lightbulb_outline),
              Switch(
                inactiveTrackColor: Color(0xFF191919),
                activeTrackColor: Colors.white,
                inactiveThumbColor: Colors.white,
                activeColor: Color(0xFF191919),
                value: _valueSwitch,
                onChanged: (value) => _onChangedSwitch(value),
              ),
            ],
          ),
        ),
        SizedBox(height: 32.0),
      ],
    );
  }

  _onChangedSwitch(bool value) {
    value
        ? _themeChanger.setTheme(appDarkTheme())
        : _themeChanger.setTheme(appLightTheme());
    setState(() {
      _valueSwitch = value;
    });
  }

  Widget _buildDrawerItem({
    BuildContext context,
    IconData icon,
    String title,
    Widget widget,
    @required GestureTapCallback onTap,
  }) {
    return Container(
      height: 60.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(icon),
                Text(title),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return WillPopScope(
      onWillPop: () => SystemNavigator.pop(),
      child: FadeTransition(
        opacity: _animation,
        child: Container(
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: ImageWithText(
                        asset: 'assets/images/notes_2.jpg',
                        title: 'Projekt erstellen',
                        fontColor: Colors.white,
                        onTap: () => Navigator.pushNamed(
                              context,
                              RouteGenerator.createProject,
                            ),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Expanded(
                      child: ImageWithText(
                        asset: 'assets/images/notes_1.jpg',
                        title: 'Projekt öffnen',
                        fontColor: Colors.white,
                        onTap: () => Navigator.pushNamed(
                              context,
                              RouteGenerator.projectPage,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
