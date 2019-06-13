import 'package:flutter/material.dart';

final Color mainDarkColor = Color(0xFF242424);

ThemeData appLightTheme() {
  final ThemeData theme = ThemeData.light();
  return theme.copyWith(
    brightness: Brightness.light,
    accentColor: Colors.deepPurpleAccent,
    primaryColor: Colors.white,
    buttonColor: Colors.black,
    backgroundColor: Colors.white,
    primaryTextTheme: TextTheme(
      title: TextStyle(
        color: Colors.black,
      ),
    ),
    primaryIconTheme: theme.iconTheme.copyWith(
      color: Colors.black,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 4.0,
      highlightElevation: 16.0,
      backgroundColor: Colors.white.withOpacity(0.8),
      foregroundColor: Colors.black,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(42.0),
          topLeft: Radius.circular(42.0),
          bottomRight: Radius.circular(42.0),
          bottomLeft: Radius.circular(42.0),
        ),
      ),
    ),
    iconTheme: IconThemeData(
      color: mainDarkColor,
    ),
    appBarTheme: AppBarTheme(
      color: Colors.white,
      elevation: 4.0,
      iconTheme: IconThemeData(
        color: mainDarkColor,
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
    ),
    splashColor: Colors.deepPurpleAccent.withOpacity(0.2),
    highlightColor: Colors.deepPurpleAccent.withOpacity(0.2),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.white,
      splashColor: Colors.deepPurpleAccent.withOpacity(0.2),
      highlightColor: Colors.deepPurpleAccent.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
    ),
    indicatorColor: Colors.black,
    tabBarTheme: TabBarTheme(
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: Colors.grey,
        ),
      ),
    ),
  );
}

ThemeData appDarkTheme() {
  final ThemeData theme = ThemeData.dark();
  return theme.copyWith(
    brightness: Brightness.dark,
    accentColor: Colors.deepOrangeAccent,
    primaryColor: mainDarkColor,
    buttonColor: Colors.white,
    backgroundColor: Colors.black,
    primaryTextTheme: TextTheme(
      title: TextStyle(
        color: Colors.white,
      ),
    ),
    primaryIconTheme: theme.iconTheme.copyWith(
      color: Colors.white,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 4.0,
      highlightElevation: 16.0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(42.0),
          topLeft: Radius.circular(42.0),
          bottomRight: Radius.circular(42.0),
          bottomLeft: Radius.circular(42.0),
        ),
      ),
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      color: mainDarkColor,
      elevation: 4.0,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    cardTheme: CardTheme(
      color: mainDarkColor,
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
    ),
    splashColor: Colors.deepOrangeAccent.withOpacity(0.2),
    highlightColor: Colors.deepOrangeAccent.withOpacity(0.2),
    buttonTheme: ButtonThemeData(
      buttonColor: mainDarkColor,
      splashColor: Colors.deepOrangeAccent.withOpacity(0.2),
      highlightColor: Colors.deepOrangeAccent.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
    ),
    indicatorColor: Colors.white,
    tabBarTheme: TabBarTheme(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: Colors.grey,
        ),
      ),
    ),
  );
}
