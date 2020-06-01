import 'dart:async';

import 'package:connection_status_bar/connection_status_bar.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:lensky/view.dart';
import 'dart:convert';

import 'dbHelper.dart';

class Action extends Model {

  static String table = 'Action';

  int id;
  int month;
  String day;
  String val;

  Action({this.id, this.month, this.day, this.val});

  factory Action.fromMap(Map<String, dynamic> map){
    return Action(
      id: map['Id'],
      month: map['Month'],
      day: map['Day'],
      val: map['Val'],
    );
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      'Id' : id, 'Month' : month,
      'Day' : day, 'Val' : val
    };
    return map;
  }
}

class  AddTS extends StatefulWidget {

  DateTime _selected;
  String base64Str;

  AddTS(DateTime _selected, String base64Str) {
    this._selected = _selected;
    this.base64Str = base64Str;
  }

  @override
  _AddTSState createState() => new _AddTSState(_selected, base64Str);
}

class _AddTSState extends State<AddTS> {

  DateTime _selected;
  String base64Str;

  _AddTSState(DateTime _selected, String base64Str) {
    this._selected = _selected;
    this.base64Str = base64Str;
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();

  StreamSubscription connectivitySubscription;
  TextEditingController editingController = TextEditingController();

  var duplicateItems;
  var items = List<String>();
  var list;
  List<String> idList = List<String>();
  bool loaded = false,
      isNoWaiting = true,
      connect = true;
  TimeOfDay _time = TimeOfDay.now();
  TimeOfDay picked;

  void _getAdminsData() async {
    await http.get('http://192.168.1.10/api/EmployeeDatas',
        headers: {"Authorization": "Basic $base64Str"})
        .then((response) {
      if (response.statusCode == 200) {
        list = json.decode(response.body).cast<Map<String, dynamic>>();
        duplicateItems =
            list.map<String>((json) => _dataToString(json)).toList();
        items.addAll(duplicateItems);
      }
      else {
        final snackbar = SnackBar(
          backgroundColor: Colors.black54,
          content: Text(response.body,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),),
        );
        scaffoldKey.currentState.showSnackBar(snackbar);
      }
    });
    setState(() {
      loaded = true;
    });
  }

  String _dataToString(Map<String, dynamic> map) {
    idList.add(map['Id'].toString());
    String str = map['FullName'];
    return str;
  }

  void filterSearchResults(String query) {
    List<String> dummySearchList = List<String>();
    dummySearchList.addAll(duplicateItems);
    if (query.isNotEmpty) {
      List<String> dummyListData = List<String>();
      dummySearchList.forEach((item) {
        if (item.contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateItems);
      });
    }
  }

  Future<Null> selectTime(BuildContext context, int index) async {
    picked = await showTimePicker(
        context: context,
        initialTime: _time
    );
    if (picked != null) {
      if (connect = true) {
        _sending(index);
        setState(() {
          isNoWaiting = false;
          _time = picked;
        });
      }
      else {
        _saving(index);
        setState(() {
          isNoWaiting = false;
          _time = picked;
        });
      }
    }
    else
      _time = TimeOfDay.now();
  }

  void _sending(int index) async {
    var data = {
      "Month": _selected.month.toString(),
      "Day": 'Day' + _selected.day.toString(),
      "Value": picked.hour.toString() + ':' + picked.minute.toString()
    };
    var toJson = json.encode(data);
    await http.put('http://192.168.1.10/API/Admin/' + idList.elementAt(index),
        headers: {
          "Authorization": "Basic $base64Str",
          "Content-Type": "application/json"
        },
        body: toJson)
        .then((response) async {
      if (response.statusCode == 200) {
        items.removeAt(index);
        final snackbar = SnackBar(
          backgroundColor: Colors.black54,
          content: Text('Success',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),),
        );
        scaffoldKey.currentState.showSnackBar(snackbar);
      } else {
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
    setState(() {
      isNoWaiting = true;
    });
  }

  void _saving( int index) async{
    Action action = Action(
        id: int.parse(idList.elementAt(index)),
        month: _selected.month,
        day: 'Day' + _selected.day.toString(),
        val: picked.hour.toString() + ':' + picked.minute.toString()
    );
    await DB.insert(Action.table, action);

    final snackbar = SnackBar(
      duration: Duration(seconds: 5),
      backgroundColor: Colors.black54,
      content: Text(
        'The action will be synchronized when access to the Internet',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
        ),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  void _synchronization() async {
    Action action;
    var listLast = await DB.query(Action.table);

    if (listLast.length > 0) {
      for (int i = 0; i < listLast.length; i++) {
        action = Action.fromMap(listLast.elementAt(i));
        var data = {
          "Month": action.month,
          "Day": 'Day' + action.day,
          "Value": action.val
        };
        var toJson = json.encode(data);
        await http.put('http://192.168.1.10/API/Admin/' + action.id.toString(),
            headers: {
              "Authorization": "Basic $base64Str",
              "Content-Type": "application/json"
            },
            body: toJson)
            .then((response) async {
          if (response.statusCode == 200) {
            DB.delete(Action.table, action);
          } else
            _syncWait();
        });
      }
      listLast = await DB.query(Action.table);
      if (listLast.length > 0)
        _syncWait();
      else {
        final snackbar = SnackBar(
          backgroundColor: Colors.black54,
          content: Text('Sync completed',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),),
        );
        scaffoldKey.currentState.showSnackBar(snackbar);
      }
    }
  }

  void _syncWait() async{
    Duration(seconds: 15);
    _synchronization();
  }

  @override
  void initState() {
    _getAdminsData();
    super.initState();
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult connectivityResult) {
      if (connectivityResult == ConnectivityResult.none) {
        connect = false;
      }else{
        connect = true;
        _synchronization();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: scaffoldKey,
        appBar: _appBar(),
        body: _body()
    );
  }

  Widget _appBar() {
    if (isNoWaiting == true)
      return AppBar(
        title: Text('Employee selection'),
      );
    else
      return AppBar(
        title: Text('Sending...'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.swap_vertical_circle,
              color: Colors.blueGrey,
            ),
          )
        ],
      );
  }

  Widget _body() {
    if (loaded)
      return Container(
        child: Column(
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
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0))
                    )
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent)
                    ),
                    width: 5000.0,
                    child: Material(
                      shadowColor: Colors.deepPurple,
                      color: Colors.black54,
                      elevation: 6,
                      child: InkWell(
                          enableFeedback: isNoWaiting,
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            print(index);
                            selectTime(context, index);
                          },
                          child: Container(
                              padding: EdgeInsets.only(
                                  left: ScreenUtil().setHeight(40.0),
                                  right: ScreenUtil().setHeight(40.0),
                                  top: ScreenUtil().setHeight(66.6),
                                  bottom: ScreenUtil().setHeight(66.6)),
                              child: Row(
                                  children: <Widget>[
                                    Text('${items[index]}',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w400,
                                        fontSize: ScreenUtil().setSp(46.0),
                                      ),
                                    ),
                                  ]
                              )
                          )
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    else
      return Center(
        child: Container(
          height: ScreenUtil().setWidth(350.0),
          child:
          Column(
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
              Text('Data loading...',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  color: Colors.blueGrey,
                  fontSize: ScreenUtil().setSp(66.0),
                ),
              ),
            ],
          ),
        ),
      );
  }
}