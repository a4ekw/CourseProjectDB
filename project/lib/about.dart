import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:http/http.dart' as http;


class About extends StatefulWidget{
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, allowFontScaling: true);
    return Scaffold(
      key: scaffoldKey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: ScreenUtil().setWidth(666.6),
              child: Text('The application is written as a course project',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                  fontSize: ScreenUtil().setSp(66.6),
                ),
              ),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(66.6),
            ),
            Container(
              width: ScreenUtil().setWidth(666.6),
              child: Text('Version: 0.1.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.lightBlueAccent,
                  fontSize: ScreenUtil().setSp(36.6),
                ),
              ),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(100.0),
            ),
            Container(
              child: Image(
                height: ScreenUtil().setWidth(666.6),
                image: AssetImage("assets/flutter.png"),
              ),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(100.0),
            ),
            Container(
              width: ScreenUtil().setWidth(666.6),
              child: Text('Copyright © 2020',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.indigoAccent,
                  fontWeight: FontWeight.w500,
                  fontSize: ScreenUtil().setSp(66.6),
                ),
              ),
            ),
            SizedBox(
              height: ScreenUtil().setWidth(36.6),
            ),
            Container(
              width: ScreenUtil().setWidth(666.6),
              child: Text('Email: lmv1996.96@gmail.com',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.indigo,
                  fontWeight: FontWeight.w700,
                  fontSize: ScreenUtil().setSp(36.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}