import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connection_status_bar/connection_status_bar.dart';
import 'package:connectivity/connectivity.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animations/loading_animations.dart';

class NewEmployee extends StatefulWidget{

  String base64Str;

  NewEmployee(String base64Str){
    this.base64Str = base64Str;
  }

  @override
  _NewEmployeeState createState() => _NewEmployeeState(base64Str: base64Str);
}

class _NewEmployeeState extends State<NewEmployee> {

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  _NewEmployeeState({this.base64Str});

  String base64Str,
      name,
      surname,
      phone,
      email,
      password,
      dropdownC = 'Category 1',
      dropdownE = '0';

  bool connect = true,
      hide = false,
      sending = false;

  List<String> list = List<String>();

  StreamSubscription connectivitySubscription;

  void _asyncConfirmDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm action'),
          content: const Text(
              'Add a new employee?'),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                _sending();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void _sending() async {
    if (connect) {
      setState(() {
        sending = true;
      });
      try {
        var data = {
          "FullName": name + ' ' + surname,
          "Phone": phone,
          "Email": email,
          "Password": password,
          "Category": dropdownC,
          "Exp": dropdownE,
        };
        var toJson = json.encode(data);
        await http.post('http://192.168.1.10/API/Admin',
            headers: {
              "Authorization": "Basic $base64Str",
              "Content-Type": "application/json"
            },
            body: toJson)
            .then((response) async {
          if (response.statusCode == HttpStatus.ok) {
            setState(() {
              sending = false;
            });
            final snackbar = SnackBar(
              backgroundColor: Colors.black54,
              content: Text('Success',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
            scaffoldKey.currentState.showSnackBar(snackbar);
          } else {
            setState(() {
              sending = false;
            });
            final snackbar = SnackBar(
              backgroundColor: Colors.black54,
              content: Text('Code: ' + response.statusCode.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),),
            );
            scaffoldKey.currentState.showSnackBar(snackbar);
          }
        });
      } catch (error) {
        setState(() {
          sending = false;
        });
        final snackbar = SnackBar(
          backgroundColor: Colors.black54,
          content: Text(error,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        scaffoldKey.currentState.showSnackBar(snackbar);
      }
    }
  }

  @override
  void initState() {
    for (int i = 0; i < 100; i++)
      list.add(i.toString());
    super.initState();
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((
        ConnectivityResult connectivityResult) {
      if (connectivityResult == ConnectivityResult.none) {
        connect = false;
      } else {
        connect = true;
      }
    });
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
        appBar: AppBar(title: Text('Add new employee')),
        resizeToAvoidBottomPadding: false,
        key: scaffoldKey,
        body: _switcher(),
      ),
    );
  }

  Widget _switcher() {
    if (!sending) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(66.0),
                right: ScreenUtil().setWidth(66.0)),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: ScreenUtil().setWidth(180.0),
                          width: ScreenUtil().setWidth(440.0),
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Name'),
                            validator: (val) =>
                            val.length > 0 ? null : 'Empty field.',
                            onSaved: (val) => name = val,
                          ),
                        ),
                        SizedBox(width: ScreenUtil().setWidth(66.6)),
                        Container(
                          height: ScreenUtil().setWidth(180.0),
                          width: ScreenUtil().setWidth(440.0),
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Surame'),
                            validator: (val) =>
                            val.length > 0 ? null : 'Empty field.',
                            onSaved: (val) => surname = val,
                          ),
                        ),
                      ]
                  ),
                  Container(
                    height: ScreenUtil().setWidth(180.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Mobile (x(xxx)xxx-xx-xx)'),
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                      validator: (val) {
                        if (val.length == 0)
                          return 'Empty field.';
                        if (val.length < 11)
                          return 'Number is not valid.';
                        return null;
                      },
                      onSaved: (val) => phone = val,
                    ),
                  ),
                  Container(
                    height: ScreenUtil().setWidth(180.0),
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (val) {
                        if (EmailValidator.validate(val, true))
                          return null;
                        if (val.length == 0)
                          return 'Empty field.';
                        return 'Not a valid email.';
                      },
                      onSaved: (val) => email = val,
                    ),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: ScreenUtil().setWidth(180.0),
                          width: ScreenUtil().setWidth(830.0),
                          child: TextFormField(
                            decoration: InputDecoration(
                                labelText: 'Password'),
                            validator: (val) {
                              if (val.length == 0)
                                return 'Empty field.';
                              if (val.length < 6)
                                return 'Password shorter than 6 characters.';
                              String pattern = r'(?!^[0-9]*$)(?!^[a-zA-Z]*$)^([a-zA-Z0-9]{6,50})$$';
                              RegExp regExp = new RegExp(pattern);
                              if (regExp.hasMatch(val))
                                return null;
                              else
                                return 'Password must contain at least one number, upper and lower case letters.';
                            },
                            onSaved: (val) => password = val,
                            obscureText: hide == false ? true : false,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Checkbox(
                              value: hide,
                              onChanged: (value) {
                                FocusScope.of(context).requestFocus(
                                    FocusNode());
                                setState(() {
                                  hide = value;
                                });
                              },
                              activeColor: Colors.indigoAccent,
                              tristate: false,
                            ),
                            Text('Show',
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w400,
                                fontSize: ScreenUtil().setSp(30.0),
                              ),
                            ),
                          ],
                        ),
                      ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Category: ',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w400,
                          fontSize: ScreenUtil().setSp(46.0),
                        ),
                      ),
                      Container(
                        child: DropdownButton<String>(
                          value: dropdownC,
                          icon: Icon(
                              Icons.arrow_downward, color: Colors.blueGrey),
                          style: TextStyle(color: Colors.blue,
                              fontSize: ScreenUtil().setSp(46.0)),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              dropdownC = newValue;
                            });
                          },
                          items: <String>[
                            'Category 1',
                            'Category 2',
                            'Category 3',
                            'Category 4',
                            'Category 5'
                          ]
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(width: ScreenUtil().setWidth(66.6)),
                      Text('Experience: ',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w400,
                          fontSize: ScreenUtil().setSp(46.0),
                        ),
                      ),
                      Container(
                        child: DropdownButton<String>(
                          value: dropdownE,
                          icon: Icon(
                              Icons.arrow_downward, color: Colors.blueGrey),
                          style: TextStyle(color: Colors.blue,
                              fontSize: ScreenUtil().setSp(46.0)),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String newValue) {
                            setState(() {
                              dropdownE = newValue;
                            });
                          },
                          items: list.map<DropdownMenuItem<String>>((
                              String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setWidth(100.0)),
                  Container(
                    width: ScreenUtil().setHeight(300.0),
                    height: ScreenUtil().setWidth(100.0),
                    child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        final form = formKey.currentState;
                        if (form.validate()) {
                          form.save();
                          _asyncConfirmDialog(context);
                        }
                      },
                      child: Material(
                        borderRadius: BorderRadius.circular(20.0),
                        shadowColor: Colors.deepPurple,
                        color: Colors.black54,
                        elevation: 6,
                        child: Center(
                          child: Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.deepPurpleAccent,
                              fontWeight: FontWeight.w700,
                              fontSize: ScreenUtil().setSp(66.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LoadingBouncingGrid.circle(
              borderColor: Colors.blue,
              borderSize: ScreenUtil().setHeight(18.0),
              size: ScreenUtil().setHeight(200.0),
              backgroundColor: Colors.deepPurple,
            ),
            SizedBox(
              height: ScreenUtil().setWidth(22.0),
            ),
            Text('Sending...',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                color: Colors.blueGrey,
                fontSize: ScreenUtil().setSp(66.0),
              ),
            ),
          ],
        ),
      );
    }
  }
}