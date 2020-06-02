import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connection_status_bar/connection_status_bar.dart';
import 'package:connectivity/connectivity.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'package:lensky/addNE.dart';
import 'package:lensky/addTS.dart';
import 'package:lensky/login.dart';
import 'package:lensky/signin.dart';
import 'package:lensky/themes.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Calendar/calendar.dart';
import 'about.dart';
import 'dbHelper.dart';

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> messageMap) {
  Message message = Message.fromNotif(messageMap);
  try {
    DB.insert(Message.table, message);
  }catch(error){}
}

class Message extends Model {

  static String table = 'Message';

  int id;
  String date;
  String body;
  String text;

  Message(this.id, this.date, this.body, this.text);
  factory Message.fromNotif(Map<String, dynamic> map){
    return Message( 0, map['data']['Date'], map['notification']['body'], map['data']['Text']);
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      'Id' : id, 'Date' : date, 'Body' : body, 'Text' : text
    };
    return map;
  }
 }

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

class View extends StatefulWidget {
  int id;
  String email;
  String base64Str;
  var lastMonthList;
  var monthList;
  var nextMonthList;
  Vacation vacation;
  bool isAdmin;
  View(int id, String email, String base64Str, List<String> lastMonthList,
      List<String> monthList, List<String> nextMonthList, Vacation vacation, bool isAdmin){
    this.id = id;
    this.email = email;
    this.base64Str = base64Str;
    this.lastMonthList = lastMonthList;
    this.monthList = monthList;
    this.nextMonthList = nextMonthList;
    this.vacation = vacation;
    this.isAdmin = isAdmin;
}

  @override
  _ViewState createState() => new _ViewState(id, email, base64Str, lastMonthList, monthList, nextMonthList, vacation, isAdmin);
}

class _ViewState extends State<View> with SingleTickerProviderStateMixin {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  _ViewState(this.id, this.email, this.base64Str, this.lastMonthList,
      this.monthList, this.nextMonthList, this.vacation, this.isAdmin);

  List<String> lastMonthList;
  List<String> monthList;
  List<String> nextMonthList;

  var allData, allLastMonth, allMonth, allNextMonth, allVacation;

  final int id;
  final String email;
  final String base64Str;

  EmployeeData employeeData;
  LastMonth lastMonth;
  Month month;
  NextMonth nextMonth;
  Vacation vacation;
  var notifList;

  List<dynamic> employeeList = List<dynamic>();

  StreamSubscription connectivitySubscription;
  Map<DateTime, List> _events = {}, _employees = {};

  List _selectedEvents;
  DateTime _selectedDay, _selected = DateTime.now(), date = DateTime.now();
  String selectedD = '';
  String button = 'Take a day off';
  String event = 'Select date to view';
  String progress = '';

  int lastMonthVal, monthVal, nextMonthVal;
  int lastYearVal, yearVal, nextYearVal;
  int index = 0;
  double hw = ScreenUtil().setWidth(466.6);
  bool isAdmin, flag = true , loaded = false;
  bool connect = true,firstConnect = true, synchronized = false;
  Color notifColor = Colors.deepPurple;

  var style = TextStyle(
      fontSize: ScreenUtil().setSp(66.6),
      color: Colors.blueGrey);

  void _showChooser() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return BrightnessSwitcherDialog(
          onSelectedTheme: (Brightness brightness) {
            if (brightness == Brightness.dark) {
              DynamicTheme.of(context).setBrightness(brightness);
            }
            else {
              DynamicTheme.of(context).setBrightness(brightness);
            }
          },
        );
      },
    );
  }

  void  _asyncConfirmDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm action'),
          content: const Text(
              'Are you sure you want to logout?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Accept'),
              onPressed: () {
                _deleting();
              },
            )
          ],
        );
      },
    );
  }

  void _deleting() async {
    _asyncConfirmDialog(context);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', '');
      prefs.setString('base64', '');
      prefs.setBool('isAdmin', false);
      await DB.clear();
      await DB.clearAct();
      await DB.clearMsg();
    } catch (c) {}
    await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage()));
  }

  void _dates() async {
    lastMonthVal = date.month - 1;
    monthVal = date.month;
    nextMonthVal = date.month + 1;
    lastYearVal = yearVal = nextYearVal = date.year;

    if (date.month == 1) {
      lastMonthVal = 12;
      monthVal = 1;
      nextYearVal = 2;
      lastYearVal = date.year - 1;
      yearVal = nextYearVal = date.year;
    }
    if (date.month == 12) {
      lastMonthVal = 11;
      monthVal = 12;
      nextYearVal = 1;
      lastYearVal = yearVal = date.year;
      nextYearVal = date.year;
    }

    for (int i = 0; i < 31; i++) {
      if (lastMonthList.elementAt(i) != null)
        _events.addAll({
          DateTime(lastYearVal, lastMonthVal, i + 1): [
            {
              'name': lastMonthList.elementAt(i),
              'isDone': true
            }
          ]
        });

      if (monthList.elementAt(i) != null)
        _events.addAll({
          DateTime(yearVal, monthVal, i + 1): [
            {
              'name': monthList.elementAt(i),
              'isDone': i + 1 < date.day ? true : false
            }
          ]
        });

      for (int i = 0; i < 31; i++) {
        if (nextMonthList.elementAt(i) != null)
          _events.addAll({
            DateTime(nextYearVal, nextMonthVal, i + 1): [
              {
                'name': nextMonthList.elementAt(i),
                'isDone': false
              }
            ]
          });
      }
    }
    setState(() {});
  }

  void _getAdminsData() async {
    setState(() {
      progress = 'Data loading...';
    });
    await http.get('http://192.168.1.10/api/EmployeeDatas',
        headers: {"Authorization": "Basic $base64Str"})
        .then((response) {
      var list = json.decode(response.body).cast<Map<String, dynamic>>();
      allData = list.map<List<String>>((json) => _dataToList(json)).toList();
    });
    await http.get('http://192.168.1.10/api/LastMonths',
        headers: {"Authorization": "Basic $base64Str"})
        .then((response) {
      var list = json.decode(response.body).cast<Map<String, dynamic>>();
      allLastMonth =
          list.map<List<String>>((json) => _monthToList(json)).toList();
    });
    await http.get('http://192.168.1.10/api/Months',
        headers: {"Authorization": "Basic $base64Str"})
        .then((response) {
      var list = json.decode(response.body).cast<Map<String, dynamic>>();
      allMonth = list.map<List<String>>((json) => _monthToList(json)).toList();
    });
    await http.get('http://192.168.1.10/api/NextMonths',
        headers: {"Authorization": "Basic $base64Str"})
        .then((response) {
      var list = json.decode(response.body).cast<Map<String, dynamic>>();
      allNextMonth =
          list.map<List<String>>((json) => _monthToList(json)).toList();
    });
    await http.get('http://192.168.1.10/api/Vacations',
        headers: {"Authorization": "Basic $base64Str"})
        .then((response) {
      var list = json.decode(response.body).cast<Map<String, dynamic>>();
      allVacation = list.map<List<String>>((json) => _vacToList(json)).toList();
    });
    setState(() {
      synchronized = true;
      loaded = true;
    });
  }

  void _handleNewDate(date) async {
    await getVac();
    _selectedDay = date;
    _selectedEvents = _events[_selectedDay] ?? [];
    try {
      String mm = _selectedEvents[0]['name'];
      if(mm.length <= 4)
        mm = mm + '0';
      event = _selectedDay.toString().substring(0, 10) + ': ' + mm;
      if (_selectedEvents[0].toString().contains('true')) {
        event += '   (Done)';
        style =
            TextStyle(fontSize: ScreenUtil().setSp(66.0), color: Colors.blue,);
        hw = ScreenUtil().setWidth(466.6);
        flag = true;
      }
      else {
        style =
            TextStyle(fontSize: ScreenUtil().setSp(66.0), color: Colors.green,);
        flag = false;
        hw = ScreenUtil().setWidth(666.6);
        selectedD = _selectedDay.toString().substring(0, 10);
        if (vacation.date.toString().contains(selectedD)) {
          button = 'Application has already been sent';
        }
        else {
          button = 'Take a day off';
        }
      }
    } catch (e) {
      hw = ScreenUtil().setWidth(466.6);
      event = 'No work shift';
      flag = true;
    }
    setState(() {});
  }

  void _handleDateMgr(date) {
    _selected = date;
    employeeList.clear();
    int ind = _selected.day;
    var lm, m, nm;
    if (_selected.month == lastMonthVal) {
      for (int i = 0; i < allLastMonth.length; i++) {
        lm = allLastMonth.elementAt(i);
        if (lm.elementAt(ind) != null)
          employeeList.add(allData.elementAt(i));
      }
    }
    if (_selected.month == monthVal) {
      for (int i = 0; i < allMonth.length; i++) {
        m = allMonth.elementAt(i);
        if (m.elementAt(ind) != null)
          employeeList.add(allData.elementAt(i));
      }
    }
    if (_selected.month == nextMonthVal) {
      for (int i = 0; i < allNextMonth.length; i++) {
        nm = allNextMonth.elementAt(i);
        if (nm.elementAt(ind) != null)
          employeeList.add(allData.elementAt(i));
      }
    }
    setState(() { });
  }

  void _removeFS(var selId) async {
    if (connect == false) {
      Action action = Action(
          id: int.parse(selId.elementAt(0)),
          month: _selected.month,
          day: 'Day' + _selected.day.toString(),
          val: 'NULL'
      );
      await DB.init();
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
    else {
      var data = {
        "Month": _selected.month.toString(),
        "Day": 'Day' + _selected.day.toString(),
        "Value": 'NULL'
      };
      var toJson = json.encode(data);
      http.put('http://192.168.1.10/API/Admin/' + selId.elementAt(0),
          headers: {
            "Authorization": "Basic $base64Str",
            "Content-Type": "application/json"
          },
          body: toJson)
          .then((response) async {
        if (response.statusCode == 200)  {
          await http.get('http://192.168.1.10/api/Months',
              headers: {"Authorization": "Basic $base64Str"})
              .then((response) {
            var list = json.decode(response.body).cast<Map<String, dynamic>>();
            allMonth = list.map<List<String>>((json) => _monthToList(json)).toList();
          });
          await http.get('http://192.168.1.10/api/NextMonths',
              headers: {"Authorization": "Basic $base64Str"})
              .then((response) {
            var list = json.decode(response.body).cast<Map<String, dynamic>>();
            allNextMonth =
                list.map<List<String>>((json) => _monthToList(json)).toList();
          });
          employeeList.remove(selId);
          setState(() {});
        } else {
          final snackbar = SnackBar(
            backgroundColor: Colors.black54,
            content: Text(response.statusCode.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),),
          );
          scaffoldKey.currentState.showSnackBar(snackbar);
        }
      });
    }
  }

  void _synchronization() async {
    Action action;
    var listLast = await DB.query(Action.table);

    if (listLast.length > 0) {
      for (int i = 0; i < listLast.length; i++) {
        action = Action.fromMap(listLast.elementAt(i));
        String v = action.val == null ? 'NULL' : action.val;
        var data = {
          "Month": action.month,
          "Day": action.day,
          "Value": v
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
          }
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

  void _aboutView(){
    Navigator.push(
        context,
        MaterialPageRoute(
        builder: (context) => About()));
  }

  void _messageFromDB() async{
    notifList = await DB.query(Message.table);
    setState(() { });
  }

  Future<void> _messageInDB(Map<String, dynamic> messageMap) async {
    Message message = Message.fromNotif(messageMap);
    await DB.init();
    await DB.insert(Message.table, message);
    await _messageFromDB();
    setState(() {
      notifColor = Colors.blue;
    });
  }

  List<String> _dataToList(Map<String, dynamic> map) {
    List<String> list = List<String>();
    list.add(map['Id'].toString());
    list.add(map['FullName']);
    return list;
  }

  List<String> _monthToList(Map<String, dynamic> map){
    List<String> list = List<String>();
    list.add(map['Id'].toString()); list.add(map['Day1']); list.add(map['Day2']);
    list.add(map['Day3']); list.add(map['Day4']); list.add(map['Day5']);
    list.add(map['Day6']); list.add(map['Day7']); list.add(map['Day8']);
    list.add(map['Day9']); list.add(map['Day10']); list.add(map['Day11']);
    list.add(map['Day12']); list.add(map['Day13']); list.add(map['Day14']);
    list.add(map['Day15']); list.add(map['Day16']); list.add(map['Day17']);
    list.add(map['Day18']); list.add(map['Day19']); list.add(map['Day20']);
    list.add(map['Day21']); list.add(map['Day22']); list.add(map['Day23']);
    list.add(map['Day24']); list.add(map['Day25']); list.add(map['Day26']);
    list.add(map['Day27']); list.add(map['Day28']); list.add(map['Day29']);
    list.add(map['Day30']); list.add(map['Day31']);
    return list;
  }

  List<String> _vacToList(Map<String, dynamic> map) {
    List<String> list = List<String>();
    list.add(map['Id'].toString());
    list.add(map['Date']);
    return list;
  }

  Vacation getVac() {
    http.get('http://192.168.1.10/api/Vacations/$id',
        headers: {"Authorization": "Basic $base64Str"})
        .then((response) async {
      var fromMap = json.decode(response.body);
      Map<String, dynamic> map = fromMap != null ? Map.from(fromMap) : null;
      try {
        return vacation = Vacation.fromMap(map);
      }
      catch (error) {
        return vacation = null;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _dates();
    _messageFromDB();
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult connectivityResult) {
      if (connectivityResult == ConnectivityResult.none) {
        connect = false;
      }else{
        if(connect = false && synchronized == false) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => SignIn(email, base64Str, true)));
        }
        firstConnect = true;
        connect = true;
        _synchronization();
      }
    });
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) => _messageInDB(message),
      onLaunch: (Map<String, dynamic> message) => _messageInDB(message),
      onResume: (Map<String, dynamic> message) => _messageInDB(message),
      onBackgroundMessage: myBackgroundMessageHandler
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true,
            badge: true,
            alert: true,
            provisional: true
        )
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, allowFontScaling: true);
    return Scaffold(
        appBar: AppBar(),
        bottomNavigationBar: _isAdminCurved(),
        drawer: _isAdminDrawer(),
        key: scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: _curved()
    );
  }

  Widget _isAdminDrawer() {
    if (isAdmin)
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/flutter.png"),
                    fit: BoxFit.scaleDown
                ),
                color: Colors.deepPurple,
              ),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Add new employee',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(55.0),
                ),
              ),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NewEmployee(base64Str))),
            ),
            ListTile(
              leading: Icon(Icons.android),
              title: Text('Themes',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(55.0),
                ),
              ),
              onTap: () => _showChooser(),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(55.0),
                ),
              ),
              subtitle: Text(email),
              onTap: () {
                _asyncConfirmDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(55.0),
                ),
              ),
              onTap: () {
                _aboutView();
              },
            ),
          ],
        ),
      );
    else
      return Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/flutter.png"),
                    fit: BoxFit.scaleDown
                ),
                color: Colors.deepPurple,
              ),
            ),
            ListTile(
              leading: Icon(Icons.android),
              title: Text('Themes',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(55.0),
                ),
              ),
              onTap: () => _showChooser(),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(55.0),
                ),
              ),
              subtitle: Text(email),
              onTap: () {
                _asyncConfirmDialog(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About',
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(55.0),
                ),
              ),
              onTap: () {
                _aboutView();
              },
            ),
          ],
        ),
      );
  }

  Widget _isAdminCurved() {
    if (isAdmin)
      return CurvedNavigationBar(
        index: 0,
        height: 50.0,
        items: <Widget>[
          Icon(Icons.event, color: Colors.deepPurple, size: 30),
          Icon(Icons.notifications_active, color: notifColor, size: 30),
          Icon(Icons.perm_identity, color: Colors.deepPurple, size: 30),
        ],
        color: Colors.black87,
        buttonBackgroundColor: Colors.black87,
        backgroundColor: Colors.deepPurple,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 0),
        onTap: (i) {
          setState(() {
            index = i;
          });
        },
      );
    else
      return CurvedNavigationBar(
          index: 0,
          height: 50.0,
          items: <Widget>[
            Icon(Icons.event, color: Colors.deepPurple, size: 30),
            Icon(Icons.notifications_active, color: notifColor, size: 30),
          ],
          color: Colors.black87,
          buttonBackgroundColor: Colors.black87,
          backgroundColor: Colors.deepPurple,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 0),
          onTap: (i) {
            setState(() {
              setState(() {
                index = i;
              });
            });
          }
      );
  }

  Widget _curved() {
    switch (index) {
      case 0:
        {
          return Column(
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
                  height: ScreenUtil().setHeight(850.0),
                  child: Calendar(
                    startOnMonday: true,
                    weekDays: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
                    events: _events,
                    onRangeSelected: (range) =>
                        print("Range is ${range.from}, ${range.to}"),
                    onDateSelected: (date) => _handleNewDate(date),
                    isExpandable: true,
                    selectedColor: Colors.black12,
                    todayColor: Color.fromARGB(255, 205, 91, 69),
                    eventDoneColor: Colors.black45,
                    eventColor: Colors.red,
                    dayOfWeekStyle: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w800,
                      fontSize: ScreenUtil().setSp(66.0),
                    ),
                  ),
                ),
                Container(
                  width: ScreenUtil().setHeight(777.7),
                  height: hw,
                  child: Material(
                    borderRadius: BorderRadius.circular(66.6),
                    shadowColor: Colors.deepPurple,
                    color: Color.fromARGB(230, 10, 10, 20),
                    elevation: 16,
                    child: Column(
                      children: <Widget>[
                        Center(
                          heightFactor: 4.0,
                          child: Text('Start of work shift:', style: TextStyle(
                            fontSize: ScreenUtil().setSp(66.0),
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                          ),
                          ),
                        ),
                        Center(
                          heightFactor: 0,
                          child: Text(event, style: style
                          ),
                        ),
                        _button(flag, selectedD)
                      ],
                    ),
                  ),
                ),
              ]
          );
        }
      case 1:
        {
          notifColor = Colors.deepPurple;
          if (notifList.length != 0)
            return ListView.builder(
                shrinkWrap: true,
                itemCount: notifList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Slidable(
                    actionPane: SlidableBehindActionPane(),
                    closeOnScroll: true,
                    actionExtentRatio: 0.30,
                    secondaryActions:
                    <Widget>[
                      IconSlideAction(
                        caption: 'Delete',
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () {
                          DB.deleteNotif(
                              notifList.elementAt(index)['Date'].toString(),
                              notifList.elementAt(index)['Text'].toString()
                          );
                          _messageFromDB();
                        },
                      ),
                    ],
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent)
                      ),
                      width: 5000.0,
                      child: Material(
                        shadowColor: Colors.deepPurple,
                        color: Colors.black54,
                        elevation: 6,
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(
                                  bottom: ScreenUtil().setHeight(36.6)),
                              child: Text(
                                notifList.elementAt(index)['Body'].toString() ==
                                    'null' ?
                                '' : notifList.elementAt(index)['Body']
                                    .toString(),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w700,
                                  fontSize: ScreenUtil().setSp(50.0),
                                ),
                              ),

                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  left: ScreenUtil().setHeight(66.6),
                                  right: ScreenUtil().setHeight(66.6),
                                  bottom: ScreenUtil().setHeight(36.6)),
                              child: Text(
                                notifList.elementAt(index)['Text'].toString(),
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w700,
                                  fontSize: ScreenUtil().setSp(50.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
            );
          else
            return Center(
                child: Container(
                  child: Text(
                    'Empty',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                )
            );
          break;
        }
      case 2:
        {
          _getAdminsData();
          if (firstConnect)
            if (loaded == true)
              return Column(
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
                      height: ScreenUtil().setHeight(850.0),
                      child: Calendar(
                        startOnMonday: true,
                        weekDays: [
                          "Mon",
                          "Tue",
                          "Wed",
                          "Thu",
                          "Fri",
                          "Sat",
                          "Sun"
                        ],
                        events: _employees,
                        onDateSelected: (date) => _handleDateMgr(date),
                        isExpandable: true,
                        selectedColor: Colors.black12,
                        eventDoneColor: Colors.black45,
                        eventColor: Colors.greenAccent,
                        todayColor: Color.fromARGB(255, 205, 91, 69),
                        dayOfWeekStyle: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w800,
                          fontSize: ScreenUtil().setSp(66.0),
                        ),
                      ),
                    ),
                    _addButton(),
                    SizedBox(height: ScreenUtil().setWidth(30.0)),
                    _listView()
                  ]
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
                      Text(progress,
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
          else
            return Center(
              child: Container(
                height: ScreenUtil().setWidth(350.0),
                child:
                Column(
                  children: <Widget>[
                    Container(
                      child: Text('Internet connection required',
                        style: TextStyle(
                            fontWeight: FontWeight.w300,
                            color: Colors.blueGrey,
                            fontSize: ScreenUtil().setSp(66.0)
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
        }
    }
  }

  Widget _addButton() {
    if (_selected.month == date.month || _selected.month == date.month + 1)
      return Container(
        width: ScreenUtil().setHeight(600.0),
        height: ScreenUtil().setWidth(100.0),
        child: Material(
          borderRadius: BorderRadius.circular(20.0),
          shadowColor: Colors.deepPurple,
          color: Colors.black54,
          elevation: 6,
          child: GestureDetector(
            onTap: () {
              print('tap!');
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddTS(_selected, base64Str)));
            },
            child: Center(
              child: Text(
                'Add person to shift',
                style: TextStyle(
                  color: Colors.indigoAccent,
                  fontWeight: FontWeight.w300,
                  fontSize: ScreenUtil().setSp(66.0),
                ),
              ),
            ),
          ),
        ),
      );
    else return Container();
  }

  Widget _listView(){
    if(_selected.month == date.month || _selected.month == date.month + 1)
      return ListView.builder(
          shrinkWrap: true,
          itemCount: employeeList == null ? 0 : employeeList
              .length,
          itemBuilder: (BuildContext context, int index) {
            int num = index + 1;
            return Slidable(
              actionPane: SlidableBehindActionPane(),
              closeOnScroll: true,
              actionExtentRatio: 0.20,
              secondaryActions:
              <Widget>[
                IconSlideAction(
                  caption: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: () {
                    _removeFS(
                        employeeList
                            .elementAt(index)
                    );
                  },
                ),
              ],
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent)
                ),
                width: 5000.0,
                child: Material(
                  shadowColor: Colors.deepPurple,
                  color: Colors.black54,
                  elevation: 6,
                  child:
                  Container(
                      padding: EdgeInsets.only(
                          left: ScreenUtil().setHeight(6.6),
                          top: ScreenUtil().setHeight(26.6),
                          right: ScreenUtil().setHeight(6.6),
                          bottom: ScreenUtil().setHeight(26.6)
                      ),
                      child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                              children: <Widget>[
                                RichText(
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    text: "$num) ",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w400,
                                      fontSize: ScreenUtil()
                                          .setSp(46.0),
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: employeeList
                                            .elementAt(index)
                                            .elementAt(1),
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight
                                              .w300,
                                          fontSize: ScreenUtil()
                                              .setSp(46.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                          )
                      )
                  ),
                ),
              ),
            );
          }
      );
    else
    return Container(
      padding: EdgeInsets.only(left: ScreenUtil().setHeight(260.0),right: ScreenUtil().setHeight(260.0)),
      height: ScreenUtil().setHeight(120.0),
      child: Material(
        borderRadius: BorderRadius.circular(66.6),
        shadowColor: Colors.deepPurple,
        color: Color.fromARGB(230, 10, 10, 20),
        elevation: 16,
        child: Center(
          child: Center(
              heightFactor: 0,
              child: Text('Сhange unavailable', style: style
              ),
            ),
        ),
      ),
    );
  }

  Widget _button(bool flag, String date) {
    if (flag == false) {
      return Container(
        padding: EdgeInsets.only(
            top: ScreenUtil().setHeight(170.0),
            left: ScreenUtil().setHeight(150.0),
            right: ScreenUtil().setHeight(150.0)),
        child: Material(
          borderRadius: BorderRadius.circular(10.0),
          color: Color.fromARGB(0, 0, 0, 0),
          elevation: 26,
          child: GestureDetector(
            onTap: () {
              _sending(date);
            },
            child: Center(
              child: Text(
                button,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w200,
                  fontSize: ScreenUtil().setSp(60.0),
                ),
              ),
            ),
          ),
        ),
      );
    }
    else
      return Container();
  }

  Widget _sending(String date) {
    String last = '';
    getVac();
    if (vacation != null && vacation.date != null) {
      if (!vacation.date.toString().contains(date))
        last = vacation.date = date + '; ' + vacation.date;
      else
        last = vacation.date;
    }
    else
      last = date + '; ';
    if (id != null) {
      var d = {"Id": id, "Date": last};
      var toJson = json.encode(d);
      http.put('http://192.168.1.10/API/Vacations/$id',
          headers: {
            "Authorization": "Basic $base64Str",
            "Content-Type": "application/json"
          },
          body: toJson)
          .timeout(Duration(seconds: 15))
          .then((response) async {
        if (response.statusCode == 204) {
          button = 'Success';
          setState(() {});
          getVac();
          if (vacation != null)
            await DB.insert(Vacation.table, vacation);
        } else {
          final snackbar = SnackBar(
            backgroundColor: Colors.black54,
            content: Text(response.statusCode.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),),
          );
          scaffoldKey.currentState.showSnackBar(snackbar);
        }
      });
    } else {
      final snackbar = SnackBar(
        backgroundColor: Colors.black54,
        content: Text('Offline mod. Please, restart App',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),),
      );
      scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }
}