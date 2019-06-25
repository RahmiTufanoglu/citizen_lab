import 'package:citizen_lab/custom_widgets/card_image_with_text.dart';
import 'package:citizen_lab/custom_widgets/feedback_dialog.dart';
import 'package:citizen_lab/home/main_drawer.dart';
import 'package:citizen_lab/themes/theme.dart';
import 'package:citizen_lab/themes/theme_changer_provider.dart';
import 'package:citizen_lab/utils/constants.dart';
import 'package:citizen_lab/utils/route_generator.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
  ThemeChangerProvider _themeChanger;
  bool _valueSwitch = false;

  //bool _darkModeEnabled = false;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _animationController.forward();

    super.initState();
  }

  void _checkIfDarkModeEnabled() {
    final ThemeData theme = Theme.of(context);
    theme.brightness == appDarkTheme().brightness
        ? _valueSwitch = true
        : _valueSwitch = false;

    if (theme.brightness == appDarkTheme().brightness) {
      _valueSwitch = true;
      //_darkModeEnabled = true;
    } else {
      _valueSwitch = false;
      //_darkModeEnabled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);
    _themeChanger.checkIfDarkModeEnabled(context);
    _checkIfDarkModeEnabled();

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildAppBar() {
    final String citizenLab = 'Citizen Lab';

    return AppBar(
      title: GestureDetector(
        onPanStart: (_) => _themeChanger.setTheme(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: citizenLab,
            child: Text(citizenLab),
          ),
        ),
      ),
      actions: <Widget>[
        Image(
          height: 36.0,
          width: 36.0,
          image: AssetImage('assets/ic_launcher.png'),
        ),
        SizedBox(width: 16.0),
      ],
    );
  }

  /*void _enableDarkMode() {
    _darkModeEnabled
        ? _themeChanger.setTheme(appLightTheme())
        : _themeChanger.setTheme(appDarkTheme());
  }*/

  Widget _buildDrawer() {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double drawerHeaderHeight =
        (screenHeight / 3) - kToolbarHeight - statusBarHeight;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double drawerWidth = screenWidth / 1.5;

    final String citizenLab = 'Citizen Lab';

    return MainDrawer(
      drawerWidth: drawerWidth,
      children: <Widget>[
        Container(
          height: drawerHeaderHeight,
          child: Card(
            shape: Border(),
            margin: const EdgeInsets.all(0.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  citizenLab,
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
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RouteGenerator.createProject,
                );
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.assignment,
              title: 'Projekt öffnen',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RouteGenerator.projectPage,
                );
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.public,
              title: 'Citizen Science',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RouteGenerator.citizenSciencePage,
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
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => FeedbackDialog(url: fraunhofer_umsicht_url),
                );
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.info,
              title: 'Über',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RouteGenerator.aboutPage,
                  arguments: {
                    'title': 'Über',
                    'content': lorem,
                  },
                );
              },
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
              Icon(Icons.brightness_2),
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

  void _onChangedSwitch(bool value) {
    value
        //? _themeChanger.setTheme(appDarkTheme())
        ? _themeChanger.setTheme()
        //: _themeChanger.setTheme(appLightTheme());
        : _themeChanger.setTheme();
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
    double height = MediaQuery.of(context).size.height - kToolbarHeight;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: WillPopScope(
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
                          child: CardImageWithText(
                            asset: 'assets/images/home_1.jpg',
                            title: 'Projekt erstellen',
                            fontColor: Colors.white,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                RouteGenerator.createProject,
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Expanded(
                          child: CardImageWithText(
                            asset: 'assets/images/home_2.jpg',
                            title: 'Projekt öffnen',
                            fontColor: Colors.white,
                            onTap: () {
                              return Navigator.pushNamed(
                                context,
                                RouteGenerator.projectPage,
                              );
                            },
                          ),
                        ),
                        /*Container(
                          height: height,
                          child: ClipPath(
                            clipper: TopClipper(),
                            child: CardImageWithText(
                              asset: 'assets/images/home_1.jpg',
                              title: 'Projekt öffnen',
                              fontColor: Colors.white,
                              onTap: () {
                                return Navigator.pushNamed(
                                  context,
                                  RouteGenerator.projectPage,
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          height: height,
                          child: ClipPath(
                            clipper: BottomClipper(),
                            child: CardImageWithText(
                              asset: 'assets/images/home_2.jpg',
                              title: 'Projekt öffnen',
                              fontColor: Colors.white,
                              onTap: () {
                                return Navigator.pushNamed(
                                  context,
                                  RouteGenerator.projectPage,
                                );
                              },
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class BottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.height, 0.0);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
