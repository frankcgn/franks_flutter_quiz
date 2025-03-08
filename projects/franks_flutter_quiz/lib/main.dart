import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../models/appSettings.dart';
import 'firebase_options.dart';
import 'pages/info_page.dart';
import 'services/settings_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Firestore offline persistenz aktivieren
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Globaler Snapshot-Listener für die Collection "vocabularies"
  FirebaseFirestore.instance
      .collection('vocabularies')
      .snapshots()
      .listen((snapshot) {
    print("Snapshot updated: ${snapshot.docs.length} Dokumente");
    // Hier kannst du weitere Logik einbauen, z.B. Datenverarbeitung oder globales State-Management.
  });
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
        title: 'Vokabel Trainer 1',
        restorationScopeId: 'app', // restorationScopeId festlegen
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    final ThemeData theme = settings.darkMode
        ? ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
          )
        : ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          );
    return MaterialApp(
      title: 'Vokabel Trainer 2',
      theme: theme,
      restorationScopeId: 'app2', // restorationScopeId festlegen
      home: InfoPage(settings: settings, onSettingsChanged: updateSettings),
    );
  }
}