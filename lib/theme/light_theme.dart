import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.blue,
  primaryColor: Colors.blue,
  brightness: Brightness.light,
  backgroundColor: const Color(0xFFE5E5E5),

  dividerColor: Colors.white54,
  fontFamily: 'Montserrat',
  textTheme: TextTheme(
    headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
    headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
    bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  }),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.all(16),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.blue,
    height: 48,
    minWidth: double.infinity,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textTheme: ButtonTextTheme.primary,
  ),

);