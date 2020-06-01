import 'dart:async';
import 'dart:io';

import 'package:connection_status_bar/connection_status_bar.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:lensky/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:email_validator/email_validator.dart';
import 'package:lensky/about.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

final GlobalKey<NavigatorState> nav = GlobalKey<NavigatorState>();

class _LoginPageState extends State<LoginPage> {

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  String email;
  String password;
  bool isSave = false;
  bool connect;

  void toggleCheckbox(bool value) {
    if (isSave == false) {
      setState(() {
        isSave = true;
      });
    }
    else {
      setState(() {
        isSave = false;
      });
    }
  }

  void _saving() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    var bytes = utf8.encode(email + ":" + password);
    String base64Str = base64Encode(bytes);
    prefs.setString('base64', base64Str);
  }

  void _submitCommand() async{
      final form = formKey.currentState;

      if (form.validate()) {
        form.save();
        if (isSave) {
         await _saving();
        }
        var bytes = utf8.encode(email + ":" + password);
        var base64Str = base64Encode(bytes);
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          connect = true;
        }
        else{
          connect = false;
        }
        final returnedResult = await Navigator.push(context, MaterialPageRoute(
            builder: (context) => SignIn(email, base64Str, connect)));
        if(returnedResult != null){
          final snackbar = SnackBar(
            backgroundColor: Colors.black54,
            content: Text(returnedResult,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),),
          );
          scaffoldKey.currentState.showSnackBar(snackbar);
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, allowFontScaling: true);
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Stack(
                children: <Widget>[
                  ConnectionStatusBar(
                    height: 25,
                    width: double.maxFinite,
                    color: Colors.redAccent,
                    lookUpAddress: 'google.com',
                    endOffset: const Offset(0.0, 0.0),
                    beginOffset: const Offset(0.0, -1.0),
                    animationDuration: const Duration(milliseconds: 200),
                    title: const Text(
                      'Please check your internet connection',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(66.0),
                          top: ScreenUtil().setWidth(250.0)),
                      child: Text(
                          'Hello',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(160.0),
                            fontWeight: FontWeight.bold,
                          )
                      )
                  ),
                  Container(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setWidth(80.0),
                          top: ScreenUtil().setWidth(400.0)),
                      child: Text(
                          'There',
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(125.0),
                            fontWeight: FontWeight.bold,
                          )
                      )
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(66.0),
                  right: ScreenUtil().setWidth(66.0)),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Container(
                      height: ScreenUtil().setWidth(180.0),
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Email'),
                        validator: (val) =>
                        !EmailValidator.validate(val, true)
                            ? 'Not a valid email.'
                            : null,
                        onSaved: (val) => email = val,
                      ),
                    ),
                    Container(
                      height: ScreenUtil().setWidth(180.0),
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Password'),
                        validator: (val) =>
                        val.length < 6
                            ? 'Password shorter than 6 characters.'
                            : null,
                        onSaved: (val) => password = val,
                        obscureText: true,
                      ),
                    ),
                    Container(
                        child: Row(
                          children: <Widget>[
                            Checkbox(
                              value: isSave,
                              onChanged: (value) {
                                FocusScope.of(context).requestFocus(
                                    FocusNode());
                                toggleCheckbox(value);
                              },
                              activeColor: Colors.green,
                              tristate: false,
                            ),
                            Text(
                              'Remember',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: ScreenUtil().setSp(45.0),
                                fontWeight: FontWeight.normal,
                              ),
                            )
                          ],
                        )
                    ),
                    Container(
                      width: ScreenUtil().setHeight(300.0),
                      padding: EdgeInsets.only(
                          top: ScreenUtil().setHeight(30.0)),
                      height: ScreenUtil().setWidth(130.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(20.0),
                        shadowColor: Colors.greenAccent,
                        color: Colors.green,
                        elevation: 6,
                        child: GestureDetector(
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            _submitCommand();
                          },
                          child: Center(
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: ScreenUtil().setSp(66.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setWidth(100.0)),
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                padding: EdgeInsets.only(top: ScreenUtil().setWidth(500.0)),
                child: Text(
                  'Powered by Flutter',
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(50.0),
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
