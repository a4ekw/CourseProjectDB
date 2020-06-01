import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lensky/signin.dart';
import 'package:lensky/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lensky/login.dart';
import 'dart:async';
import 'dart:ui';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (Brightness brightness) => ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: brightness,
      ),
      loadBrightnessOnStart: true,
      themedWidgetBuilder: (BuildContext context, ThemeData theme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}): super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  StreamSubscription connectivitySubscription;
  bool connect;

  _sharedPref() async {
    String email;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = (prefs.getString('email') ?? '');
    String base64Str = (prefs.getString('base64') ?? '');
    if (email != '' && base64Str != '') {
      final result = await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => SignIn(email, base64Str, connect)));
  }
    else {
      await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LoginPage()));
    }
  }

  @override
  void initState() {
    super.initState();
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult connectivityResult) {
      if (connectivityResult == ConnectivityResult.none) {
        connect = false;
      }else{
        connect= true;
      }
    });
    _sharedPref();
  }

  @override
  void dispose() {
    super.dispose();
    connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, allowFontScaling: true);
    return Scaffold(
    );
  }
}











