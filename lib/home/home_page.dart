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
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;
  ThemeChangerProvider _themeChanger;
  bool _valueSwitch = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
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

    if (theme.brightness == appDarkTheme().brightness) {
      _valueSwitch = true;
    } else {
      _valueSwitch = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    _themeChanger = Provider.of<ThemeChangerProvider>(context);
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
      title: GestureDetector(
        onPanStart: (_) => _themeChanger.setTheme(),
        child: Container(
          width: double.infinity,
          child: Tooltip(
            message: APP_TITLE,
            child: Text(APP_TITLE),
          ),
        ),
      ),
      actions: <Widget>[
        Image(
          height: 36.0,
          width: 36.0,
          image: AssetImage('assets/app_logo.png'),
        ),
        SizedBox(width: 16.0),
      ],
    );
  }

  Widget _buildDrawer() {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double drawerHeaderHeight =
        (screenHeight / 3) - kToolbarHeight - statusBarHeight;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double drawerWidth = screenWidth / 1.5;

    final String createExperiment = 'Experiment erstellen';
    final String openExperiment = 'Experiment öffnen';
    final String about = 'Über';
    final String location = 'Dortmund';

    return MainDrawer(
      drawerWidth: drawerWidth,
      location: location,
      children: <Widget>[
        Container(
          height: drawerHeaderHeight,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ),
            ),
            margin: const EdgeInsets.all(0.0),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  bottom: 8.0,
                ),
                child: Text(
                  APP_TITLE,
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
              title: createExperiment,
              onTap: () => _setNavigation(RouteGenerator.createProject),
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.assignment,
              title: openExperiment,
              onTap: () {
                Map map = Map<String, bool>();
                map['isFromCreateProjectPage'] = false;
                _setNavigation(RouteGenerator.projectPage, map);
              },
            ),
            _buildDrawerItem(
              context: context,
              icon: Icons.public,
              title: APP_TITLE,
              onTap: () => _setNavigation(RouteGenerator.citizenSciencePage),
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
              title: about,
              onTap: () {
                Map map = Map<String, String>();
                map['title'] = 'Über';
                map['content'] = lorem;
                _setNavigation(RouteGenerator.aboutPage, map);
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

  void _setNavigation(String route, [Object arguments]) {
    Navigator.pushNamed(
      context,
      route,
      arguments: arguments,
    );
  }

  void _onChangedSwitch(bool value) {
    value ? _themeChanger.setTheme() : _themeChanger.setTheme();
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
    final Color topColor1 = Color(0xFFBFDFCF);
    final Color topColor2 = Color(0xFF009FE3);
    final Color bottomColor1 = Color(0xFFF1CF7F);
    final Color bottomColor2 = Color(0xFFE7F7C0);

    final String createExperiment = 'Experiment erstellen';
    final String openExperiment = 'Experiment öffnen';

    return SafeArea(
      child: WillPopScope(
        onWillPop: () => SystemNavigator.pop(),
        child: FadeTransition(
          opacity: _animation,
          child: Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: CardImageWithText(
                        asset: 'assets/images/stadtgärtnern_oberhausen.jpg',
                        title: createExperiment,
                        gradientColor1: topColor1,
                        gradientColor2: topColor2,
                        onTap: () =>
                            _setNavigation(RouteGenerator.createProject),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Expanded(
                      child: CardImageWithText(
                        asset: 'assets/images/aquaponik_anlage.jpg',
                        title: openExperiment,
                        gradientColor1: bottomColor2,
                        gradientColor2: bottomColor1,
                        onTap: () {
                          Map map = Map<String, bool>();
                          map['isFromCreateProjectPage'] = false;
                          _setNavigation(RouteGenerator.projectPage, map);
                        },
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
