import 'package:google_fonts/google_fonts.dart';
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

class LastMonth extends Model{

  static String table = 'LastMonth';
  int id;
  String day1; String day2; String day3; String day4; String day5; String day6;  String day7;
  String day8; String day9; String day10; String day11; String day12; String day13;
  String day14; String day15; String day16; String day17; String day18; String day19;
  String day20; String day21; String day22; String day23; String day24; String day25;
  String day26; String day27; String day28; String day29; String day30; String day31;

  LastMonth({this.id, this.day1, this.day2, this.day3, this.day4, this.day5, this.day6,
    this.day7, this.day8, this.day9, this.day10, this.day11, this.day12, this.day13,
    this.day14, this.day15, this.day16, this.day17, this.day18, this.day19, this.day20,
    this.day21, this.day22, this.day23, this.day24, this.day25, this.day26, this.day27,
    this.day28, this.day29, this.day30, this.day31});

  factory LastMonth.fromMap(Map<String, dynamic> json){
    return LastMonth(
        id:json['Id'],
        day1: json['Day1'], day2: json['Day2'], day3: json['Day3'], day4: json['Day4'], day5: json['Day5'],
        day6: json['Day6'], day7: json['Day7'], day8: json['Day8'], day9: json['Day9'], day10: json['Day10'],
        day11: json['Day11'], day12: json['Day12'], day13: json['Day13'], day14: json['Day14'], day15: json['Day15'],
        day16: json['Day16'], day17: json['Day17'], day18: json['Day18'], day19: json['Day19'], day20: json['Day20'],
        day21: json['Day21'], day22: json['Day22'], day23: json['Day23'], day24: json['Day24'], day25: json['Day25'],
        day26: json['Day26'], day27: json['Day27'], day28: json['Day28'], day29: json['Day29'], day30: json['Day30'],
        day31: json['Day31']
    );
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      'Id' : id, 'Day1' : day1, 'Day2' : day2, 'Day3' : day3, 'Day4' : day4, 'Day5' : day5, 'Day6' : day6, 'Day7' : day7,
      'Day8' : day8, 'Day9' : day9, 'Day10' : day10, 'Day11' : day11, 'Day12' : day12, 'Day13' : day13, 'Day14' : day14,
      'Day15' : day15, 'Day16' : day16, 'Day17' : day17, 'Day18' : day18, 'Day19' : day19, 'Day20' : day20, 'Day21' : day21,
      'Day22' : day22, 'Day23' : day23, 'Day24' : day24, 'Day25' : day25, 'Day26' : day26, 'Day27' : day27, 'Day28' : day28,
      'Day29' : day29, 'Day30' : day30, 'Day31' : day31
    };
    return map;
  }

  List<String> toList() {
    var list = new List<String>(); list.add(day1);
    list.add(day2); list.add(day3); list.add(day4); list.add(day5); list.add(day6);
    list.add(day7); list.add(day8); list.add(day9); list.add(day10); list.add(day11);
    list.add(day12); list.add(day13); list.add(day14); list.add(day15); list.add(day16);
    list.add(day17); list.add(day18); list.add(day19); list.add(day20); list.add(day21);
    list.add(day22);  list.add(day23); list.add(day24); list.add(day25); list.add(day26);
    list.add(day27); list.add(day28); list.add(day29); list.add(day30); list.add(day31);
    return list;
  }
}

class Month extends Model{

  static String table = 'Month';
  int id;
  String day1; String day2; String day3; String day4; String day5; String day6;  String day7;
  String day8; String day9; String day10; String day11; String day12; String day13;
  String day14; String day15; String day16; String day17; String day18; String day19;
  String day20; String day21; String day22; String day23; String day24; String day25;
  String day26; String day27; String day28; String day29; String day30; String day31;

  Month({this.id, this.day1, this.day2, this.day3, this.day4, this.day5, this.day6,
    this.day7, this.day8, this.day9, this.day10, this.day11, this.day12, this.day13,
    this.day14, this.day15, this.day16, this.day17, this.day18, this.day19, this.day20,
    this.day21, this.day22, this.day23, this.day24, this.day25, this.day26, this.day27,
    this.day28, this.day29, this.day30, this.day31});

  factory Month.fromMap(Map<String, dynamic> json){
    return Month(
        id:json['Id'],
        day1: json['Day1'], day2: json['Day2'], day3: json['Day3'], day4: json['Day4'], day5: json['Day5'],
        day6: json['Day6'], day7: json['Day7'], day8: json['Day8'], day9: json['Day9'], day10: json['Day10'],
        day11: json['Day11'], day12: json['Day12'], day13: json['Day13'], day14: json['Day14'], day15: json['Day15'],
        day16: json['Day16'], day17: json['Day17'], day18: json['Day18'], day19: json['Day19'], day20: json['Day20'],
        day21: json['Day21'], day22: json['Day22'], day23: json['Day23'], day24: json['Day24'], day25: json['Day25'],
        day26: json['Day26'], day27: json['Day27'], day28: json['Day28'], day29: json['Day29'], day30: json['Day30'],
        day31: json['Day31']
    );
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      'Id' : id, 'Day1' : day1, 'Day2' : day2, 'Day3' : day3, 'Day4' : day4, 'Day5' : day5, 'Day6' : day6, 'Day7' : day7,
      'Day8' : day8, 'Day9' : day9, 'Day10' : day10, 'Day11' : day11, 'Day12' : day12, 'Day13' : day13, 'Day14' : day14,
      'Day15' : day15, 'Day16' : day16, 'Day17' : day17, 'Day18' : day18, 'Day19' : day19, 'Day20' : day20, 'Day21' : day21,
      'Day22' : day22, 'Day23' : day23, 'Day24' : day24, 'Day25' : day25, 'Day26' : day26, 'Day27' : day27, 'Day28' : day28,
      'Day29' : day29, 'Day30' : day30, 'Day31' : day31
    };
    return map;
  }

  List<String> toList() {
    var list = new List<String>(); list.add(day1);
    list.add(day2); list.add(day3); list.add(day4); list.add(day5); list.add(day6);
    list.add(day7); list.add(day8); list.add(day9); list.add(day10); list.add(day11);
    list.add(day12); list.add(day13); list.add(day14); list.add(day15); list.add(day16);
    list.add(day17); list.add(day18); list.add(day19); list.add(day20); list.add(day21);
    list.add(day22);  list.add(day23); list.add(day24); list.add(day25); list.add(day26);
    list.add(day27); list.add(day28); list.add(day29); list.add(day30); list.add(day31);
    return list;
  }
}

class NextMonth extends Model{

  static String table = 'NextMonth';
  int id;
  String day1; String day2; String day3; String day4; String day5; String day6;  String day7;
  String day8; String day9; String day10; String day11; String day12; String day13;
  String day14; String day15; String day16; String day17; String day18; String day19;
  String day20; String day21; String day22; String day23; String day24; String day25;
  String day26; String day27; String day28; String day29; String day30; String day31;

  NextMonth({this.id, this.day1, this.day2, this.day3, this.day4, this.day5, this.day6,
    this.day7, this.day8, this.day9, this.day10, this.day11, this.day12, this.day13,
    this.day14, this.day15, this.day16, this.day17, this.day18, this.day19, this.day20,
    this.day21, this.day22, this.day23, this.day24, this.day25, this.day26, this.day27,
    this.day28, this.day29, this.day30, this.day31});

  factory NextMonth.fromMap(Map<String, dynamic> json){
    return NextMonth(
        id:json['Id'],
        day1: json['Day1'], day2: json['Day2'], day3: json['Day3'], day4: json['Day4'], day5: json['Day5'],
        day6: json['Day6'], day7: json['Day7'], day8: json['Day8'], day9: json['Day9'], day10: json['Day10'],
        day11: json['Day11'], day12: json['Day12'], day13: json['Day13'], day14: json['Day14'], day15: json['Day15'],
        day16: json['Day16'], day17: json['Day17'], day18: json['Day18'], day19: json['Day19'], day20: json['Day20'],
        day21: json['Day21'], day22: json['Day22'], day23: json['Day23'], day24: json['Day24'], day25: json['Day25'],
        day26: json['Day26'], day27: json['Day27'], day28: json['Day28'], day29: json['Day29'], day30: json['Day30'],
        day31: json['Day31']
    );
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      'Id' : id, 'Day1' : day1, 'Day2' : day2, 'Day3' : day3, 'Day4' : day4, 'Day5' : day5, 'Day6' : day6, 'Day7' : day7,
      'Day8' : day8, 'Day9' : day9, 'Day10' : day10, 'Day11' : day11, 'Day12' : day12, 'Day13' : day13, 'Day14' : day14,
      'Day15' : day15, 'Day16' : day16, 'Day17' : day17, 'Day18' : day18, 'Day19' : day19, 'Day20' : day20, 'Day21' : day21,
      'Day22' : day22, 'Day23' : day23, 'Day24' : day24, 'Day25' : day25, 'Day26' : day26, 'Day27' : day27, 'Day28' : day28,
      'Day29' : day29, 'Day30' : day30, 'Day31' : day31
    };
    return map;
  }

  List<String> toList() {
    var list = new List<String>(); list.add(day1);
    list.add(day2); list.add(day3); list.add(day4); list.add(day5); list.add(day6);
    list.add(day7); list.add(day8); list.add(day9); list.add(day10); list.add(day11);
    list.add(day12); list.add(day13); list.add(day14); list.add(day15); list.add(day16);
    list.add(day17); list.add(day18); list.add(day19); list.add(day20); list.add(day21);
    list.add(day22);  list.add(day23); list.add(day24); list.add(day25); list.add(day26);
    list.add(day27); list.add(day28); list.add(day29); list.add(day30); list.add(day31);
    return list;
  }
}

class EmployeeData extends Model{

  static String table = 'EmployeeData';

  int id;
  String fullName;

  EmployeeData({this.id, this.fullName});

  factory EmployeeData.fromMap(Map<String, dynamic> map){
    return EmployeeData(
        id: map['Id'],
        fullName: map['FullName'],
    );
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      'Id' : id, 'FullName' : fullName
    };
    return map;
  }
}

class EmployeeClass extends Model{

  static String table = 'EmployeeClass';

  int id;
  String category;
  double experience;
  int hours;

  EmployeeClass({this.id, this.category, this.experience, this.hours});

  factory EmployeeClass.fromMap(Map<String, dynamic> json){
    return EmployeeClass(
      id: json['Id'],
      category: json['Category'],
      experience: json['Experience'],
      hours: json['Hours']
    );
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      'Id' : id,
      'Category' : category,
      'Experience' : experience,
      'Hours' : hours,
    };
    return map;
  }
}

class Vacation extends Model{

  static String table = 'Vacation';

  int id;
  String date;

  Vacation({this.id, this.date});
  factory Vacation.fromMap(Map<String, dynamic> json){
    return Vacation(
        id: json['Id'],
        date: json['Date']
    );
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map = {
      'Id' : id, 'Date' : date
    };
    return map;
  }
}

class  SignIn extends StatefulWidget {
  String email;
  String base64Str;
  bool connection;

  SignIn(String email, String base64Str, bool connection) {
    this.email = email;
    this.base64Str = base64Str;
    this.connection = connection;
  }

  @override
  _SignInState createState() => new _SignInState(email, base64Str, connection);
}

class _SignInState extends State< SignIn> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  EmployeeData employeeData;
  EmployeeClass employeeClass;
  LastMonth lastMonth;
  Month month;
  NextMonth nextMonth;
  Vacation vacation;
  Color color = Colors.blue;

  List<String> lastMonthList;
  List<String> monthList;
  List<String> nextMonthList;

  int id;
  String email;
  String userData;
  bool connection,
      isAdmin = false;

  String progress;

  _SignInState(String email, String base64str, bool connection) {
    this.email = email;
    this.userData = base64str;
    this.connection = connection;
  }

  void _choose() async {
    if (connection == false) {
      setState(() {
        color = Colors.red;
        progress = 'Offline mod';
      });
      _checkDB();
    } else {
      _checkLogin();
    }
  }

  void _checkLogin() {
    setState(() {
      progress = 'Data checking...';
    });

    http.get('http://192.168.1.10/api/getid',
        headers: {"Authorization": "Basic $userData"})
        .then((response) async {
      if (response.statusCode == 200) {
        id = json.decode(response.body)['valueId'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('id', id);
        _getData();
      } else if (response.statusCode == 401) {
        Navigator.pop(context, 'Wrong login or password.');
      } else {
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
    }).catchError((error) {
      final snackbar = SnackBar(
        backgroundColor: Colors.black54,
        content: Text(error,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),),
      );
      scaffoldKey.currentState.showSnackBar(snackbar);
    });
  }

  void _getData() {
    setState(() {
      progress = 'Data loading...';
    });

    http.get('http://192.168.1.10/api/EmployeeDatas/$id',
        headers: {"Authorization": "Basic $userData"})
        .then((response) async {
      var fromMap = json.decode(response.body);
      Map<String, dynamic> map = fromMap != null ? Map.from(fromMap) : null;
      try {
        employeeData = EmployeeData.fromMap(map);
      }
      catch (error) {
        employeeData = null;
      }

      fromMap = json.decode(response.body)['EmployeeClass'];
      map = fromMap != null ? Map.from(fromMap) : null;
      try {
        employeeClass = EmployeeClass.fromMap(map);
      }
      catch (error) {
        employeeClass = null;
      }

      fromMap = json.decode(response.body)['LastMonth'];
      map = fromMap != null ? Map.from(fromMap) : null;
      try {
        lastMonth = LastMonth.fromMap(map);
      }
      catch (error) {
        lastMonth = null;
      }

      fromMap = json.decode(response.body)['Month'];
      map = fromMap != null ? Map.from(fromMap) : null;
      try {
        month = Month.fromMap(map);
      }
      catch (error) {
        month = null;
      }

      fromMap = json.decode(response.body)['NextMonth'];
      map = fromMap != null ? Map.from(fromMap) : null;
      try {
        nextMonth = NextMonth.fromMap(map);
      }
      catch (error) {
        nextMonth = null;
      }

      fromMap = json.decode(response.body)['Vacation'];
      map = fromMap != null ? Map.from(fromMap) : null;
      try {
        vacation = Vacation.fromMap(map);
      }
      catch (error) {
        vacation = null;
      }

      _updateDB();
    }).catchError((error) {
      final snackbar = SnackBar(
        backgroundColor: Colors.black54,
        content: Text(error,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),),
      );
      scaffoldKey.currentState.showSnackBar(snackbar);
    });
  }

  void _updateDB() async {
    setState(() {
      progress = 'Updating data...';
    });

    try {
      await DB.init();
      await DB.clear();

      if (employeeData != null)
        await DB.insert(EmployeeData.table, employeeData);

      if (employeeClass != null) {
        await DB.insert(EmployeeClass.table, employeeClass);
        if (employeeClass.category == 'Admin') {
          isAdmin = true;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isAdmin', isAdmin);
        }
      }

      if (vacation != null)
        await DB.insert(Vacation.table, vacation);

      if (lastMonth != null) {
        await DB.insert(LastMonth.table, lastMonth);
        lastMonthList = lastMonth.toList();
      }

      if (month != null) {
        await DB.insert(Month.table, month);
        monthList = month.toList();
      }

      if (nextMonth != null) {
        await DB.insert(NextMonth.table, nextMonth);
        nextMonthList = nextMonth.toList();
      }
      setState(() {
        progress = 'Data processing...';
      });
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  View(
                      id,
                      email,
                      userData,
                      lastMonthList,
                      monthList,
                      nextMonthList,
                      vacation,
                      isAdmin)));
    } catch (error) {
      final snackbar = SnackBar(
        backgroundColor: Colors.black54,
        content: Text(error.toString(),
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

  void _checkDB() async {
    try {
      await DB.init();

      var listLast = await DB.query(LastMonth.table);
      if (listLast.length > 0) {
        lastMonth = LastMonth.fromMap(listLast.elementAt(0));
        lastMonthList = lastMonth.toList();
      }

      var listM = await DB.query(Month.table);
      if (listM.length > 0) {
        month = Month.fromMap(listM.elementAt(0));
        monthList = month.toList();
      }

      var listNext = await DB.query(NextMonth.table);
      if (listNext.length > 0) {
        nextMonth = NextMonth.fromMap(listNext.elementAt(0));
        nextMonthList = nextMonth.toList();
      }

      var listV = await DB.query(Vacation.table);
      if (listV.length > 0)
        vacation = Vacation.fromMap(listV.elementAt(0));
      SharedPreferences prefs = await SharedPreferences.getInstance();
      isAdmin = prefs.getBool('isAdmin') ?? false;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  View(
                      id,
                      email,
                      userData,
                      lastMonthList,
                      monthList,
                      nextMonthList,
                      vacation,
                      isAdmin)));
    } catch (error) {
      final snackbar = SnackBar(
        backgroundColor: Colors.black54,
        content: Text(error,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),),
      );
      scaffoldKey.currentState.showSnackBar(snackbar);
    }
  }

  @override
  void initState() {
    super.initState();
    _choose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, allowFontScaling: true);
    return Scaffold(
      key: scaffoldKey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LoadingBouncingGrid.circle(
              borderColor: color,
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
  }
}