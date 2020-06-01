import 'package:sqflite/sqflite.dart';


abstract class Model {

  int id;

  static fromMap() {}
  toMap() {}
}

abstract class DB {

  static Database _db;

  static int get _version => 1;

  static Future<void> init() async {
    if (_db != null) {
      return;
    }

    try {
      String _path = await getDatabasesPath();
      _db = await openDatabase(
          _path + '/database', version: _version, onCreate: onCreate);
    }
    catch (ex) {}
  }

  static void onCreate(Database db, int version) async =>
      {
        await db.execute(
            'CREATE TABLE Action (Id INTEGER, Month STRING, Day STRING, Val STRING);'),
        await db.execute(
            'CREATE TABLE Message (Id INTEGER, Date STRING, Body STRING, Text STRING);'),
        await db.execute(
            'CREATE TABLE EmployeeData (Id INTEGER PRIMARY KEY NOT NULL, FullName STRING);'),
        await db.execute(
            'CREATE TABLE EmployeeClass (Id INTEGER PRIMARY KEY NOT NULL, Category STRING, Experience DOUBLE, Hours INTEGER);'),
        await db.execute(
            'CREATE TABLE Vacation (Id INTEGER PRIMARY KEY NOT NULL, Date STRING);'),
        await db.execute('''CREATE TABLE LastMonth (
      Id INTEGER PRIMARY KEY NOT NULL, Day1 STRING, Day2 STRING, Day3 STRING, Day4 STRING,
      Day5 STRING, Day6 STRING, Day7 STRING, Day8 STRING, Day9 STRING, Day10 STRING,
      Day11 STRING, Day12 STRING, Day13 STRING, Day14 STRING, Day15 STRING, Day16 STRING,
      Day17 STRING, Day18 STRING, Day19 STRING, Day20 STRING, Day21 STRING, Day22 STRING,
      Day23 STRING, Day24 STRING, Day25 STRING, Day26 STRING, Day27 STRING, Day28 STRING,
      Day29 STRING, Day30 STRING, Day31 STRING);'''),
        await db.execute('''CREATE TABLE Month (
      Id INTEGER PRIMARY KEY NOT NULL, Day1 STRING, Day2 STRING, Day3 STRING, Day4 STRING,
      Day5 STRING, Day6 STRING, Day7 STRING, Day8 STRING, Day9 STRING, Day10 STRING,
      Day11 STRING, Day12 STRING, Day13 STRING, Day14 STRING, Day15 STRING, Day16 STRING,
      Day17 STRING, Day18 STRING, Day19 STRING, Day20 STRING, Day21 STRING, Day22 STRING,
      Day23 STRING, Day24 STRING, Day25 STRING, Day26 STRING, Day27 STRING, Day28 STRING,
      Day29 STRING, Day30 STRING, Day31 STRING);'''),
        await db.execute('''CREATE TABLE NextMonth (
      Id INTEGER PRIMARY KEY NOT NULL, Day1 STRING, Day2 STRING, Day3 STRING, Day4 STRING,
      Day5 STRING, Day6 STRING, Day7 STRING, Day8 STRING, Day9 STRING, Day10 STRING,
      Day11 STRING, Day12 STRING, Day13 STRING, Day14 STRING, Day15 STRING, Day16 STRING,
      Day17 STRING, Day18 STRING, Day19 STRING, Day20 STRING, Day21 STRING, Day22 STRING,
      Day23 STRING, Day24 STRING, Day25 STRING, Day26 STRING, Day27 STRING, Day28 STRING,
      Day29 STRING, Day30 STRING, Day31 STRING);'''),
      };

  static Future<List<Map<String, dynamic>>> query(String table) async =>
      _db.query(table);

  static Future<int> insert(String table, Model model) async =>
      await _db.insert(table, model.toMap());

  static Future<int> update(String table, Model model) async =>
      await _db.update(
          table, model.toMap(), where: 'id = ?', whereArgs: [model.id]);

  static Future<int> delete(String table, Model model) async =>
      await _db.delete(table, where: 'id = ?', whereArgs: [model.id]);

  static Future<int> deleteNotif(String date, String text) async =>
      await _db.delete('Message', where: 'Date = ? AND Text = ?', whereArgs: [date, text]);

  static void clear() async =>
      {
        _db.execute('DELETE FROM EmployeeData'),
        _db.execute('DELETE FROM EmployeeClass'),
        _db.execute('DELETE FROM Vacation'),
        _db.execute('DELETE FROM LastMonth'),
        _db.execute('DELETE FROM Month'),
        _db.execute('DELETE FROM NextMonth'),
      };

  static void clearMsg() async =>
      {
        _db.execute('DELETE FROM Message'),
      };

  static void clearAct() async =>
      {
        _db.execute('DELETE FROM Action')
      };
}