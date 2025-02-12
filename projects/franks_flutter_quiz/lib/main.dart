import 'package:flutter/material.dart';
import 'models.dart';
import 'storage.dart';
import 'pages/info_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppSettings settings = AppSettings();
  bool settingsLoaded = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    settings = await SettingsStorage.loadSettings();
    setState(() {
      settingsLoaded = true;
    });
  }
  
  void updateSettings(AppSettings newSettings) {
    setState(() {
      settings = newSettings;
    });
    SettingsStorage.saveSettings(newSettings);
  }
  
  @override
  Widget build(BuildContext context) {
    if (!settingsLoaded) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    final ThemeData theme = settings.darkMode
        ? ThemeData.dark().copyWith(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
          )
        : ThemeData.light().copyWith(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          );
    return MaterialApp(
      title: 'Vokabel Trainer',
      theme: theme,
      home: InfoPage(settings: settings, onSettingsChanged: updateSettings),
    );
  }
}