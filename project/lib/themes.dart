import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class BrightnessSwitcherDialog extends StatelessWidget {
  const BrightnessSwitcherDialog({Key key, this.onSelectedTheme})
      : super(key: key);

  final ValueChanged<Brightness> onSelectedTheme;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Select Theme'),
      children: <Widget>[
        RadioListTile<Brightness>(
          value: Brightness.light,
          groupValue: Theme.of(context).brightness,
          onChanged: (Brightness value) {
            onSelectedTheme(Brightness.light);
          },
          title: const Text('Light  ☀'),
        ),
        RadioListTile<Brightness>(
          value: Brightness.dark,
          groupValue: Theme.of(context).brightness,
          onChanged: (Brightness value) {
            onSelectedTheme(Brightness.dark);
          },
          title: const Text('Dark  👻'),
        ),
      ],
    );
  }
}


typedef ThemedWidgetBuilder = Widget Function(
    BuildContext context, ThemeData data);

typedef ThemeDataWithBrightnessBuilder = ThemeData Function(
    Brightness brightness);

class DynamicTheme extends StatefulWidget {
  const DynamicTheme({
    Key key,
    this.data,
    this.themedWidgetBuilder,
    this.defaultBrightness = Brightness.light,
    this.loadBrightnessOnStart = true,
  }) : super(key: key);

  final ThemedWidgetBuilder themedWidgetBuilder;

  final ThemeDataWithBrightnessBuilder data;

  final Brightness defaultBrightness;

  final bool loadBrightnessOnStart;

  @override
  DynamicThemeState createState() => DynamicThemeState();

  static DynamicThemeState of(BuildContext context) {
    return context.findAncestorStateOfType<State<DynamicTheme>>();
  }
}

class DynamicThemeState extends State<DynamicTheme> {
  ThemeData _themeData;

  Brightness _brightness;

  bool _shouldLoadBrightness;

  static const String _sharedPreferencesKey = 'isDark';

  ThemeData get themeData => _themeData;

  Brightness get brightness => _brightness;

  @override
  void initState() {
    super.initState();
    _initVariables();
    _loadBrightness();
  }

  Future<void> _loadBrightness() async {
    if (!_shouldLoadBrightness) {
      return;
    }
    final bool isDark = await _getBrightnessBool();
    _brightness = isDark ? Brightness.dark : Brightness.light;
    _themeData = widget.data(_brightness);
    if (mounted) {
      setState(() {});
    }
  }

  void _initVariables() {
    _brightness = widget.defaultBrightness;
    _themeData = widget.data(_brightness);
    _shouldLoadBrightness = widget.loadBrightnessOnStart;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeData = widget.data(_brightness);
  }

  @override
  void didUpdateWidget(DynamicTheme oldWidget) {
    super.didUpdateWidget(oldWidget);
    _themeData = widget.data(_brightness);
  }

  Future<void> setBrightness(Brightness brightness) async {
    // Update state with new values
    setState(() {
      _themeData = widget.data(brightness);
      _brightness = brightness;
    });
    // Save the brightness
    await _saveBrightness(brightness);
  }

  Future<void> toggleBrightness() async {
    // If brightness is dark, set it to light
    // If it's not dark, set it to dark
    if (_brightness == Brightness.dark)
      await setBrightness(Brightness.light);
    else
      await setBrightness(Brightness.dark);
  }

  void setThemeData(ThemeData data) {
    setState(() {
      _themeData = data;
    });
  }

  Future<void> _saveBrightness(Brightness brightness) async {
    //! Shouldn't save the brightness if you don't want to load it
    if (!_shouldLoadBrightness) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Saves whether or not the provided brightness is dark
    await prefs.setBool(
        _sharedPreferencesKey, brightness == Brightness.dark ? true : false);
  }

  Future<bool> _getBrightnessBool() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Gets the bool stored in prefs
    // Or returns whether or not the `defaultBrightness` is dark
    return prefs.getBool(_sharedPreferencesKey) ??
        widget.defaultBrightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    return widget.themedWidgetBuilder(context, _themeData);
  }
}
