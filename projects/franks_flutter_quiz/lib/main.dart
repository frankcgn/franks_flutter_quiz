import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_01/pages/settings_page.dart';
import 'package:provider/provider.dart';

import '../models/appSettings.dart';
import '../models/global_state.dart';
import '../models/vocabulary.dart';
import '../pages/home_page.dart';
import '../pages/info_page.dart';
import '../pages/login_page.dart';
import '../pages/quiz_page.dart';
import '../pages/register_page.dart';
import '../pages/voc_mgmt_page.dart';
import 'firebase_options.dart';
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
    debugPrint("Snapshot updated: ${snapshot.docs.length} Dokumente");
    // Hier kannst du weitere Logik einbauen, z.B. Datenverarbeitung oder globales State-Management.
  });
  runApp(
    ChangeNotifierProvider(
      create: (_) => GlobalState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppSettings settings = AppSettings();
  bool settingsLoaded = false;
  bool userAutorized = true;
  final List<Vocabulary> vocabularies = [];
  final bool quizGerman = true;

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
      _loadSettings();
    }

    final ThemeData theme = settings.darkMode
        ? ThemeData.dark().copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          )
        : ThemeData.light().copyWith(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          );

    return MaterialApp(
      title: 'Julias Vokabel Trainer',
      theme: theme,
      restorationScopeId: 'app',
      // gleichbleibender Restoration Scope
      initialRoute: '/info',
      onGenerateRoute: (RouteSettings routeSettings) {
        debugPrint('Navigiere zu Route: ${routeSettings.name}');
        // Hier werden die Routen anhand des Namens erzeugt:
        switch (routeSettings.name) {
          case '/info':
            return MaterialPageRoute(
              builder: (context) => InfoPage(),
            );
          case '/login':
            return MaterialPageRoute(
              builder: (context) => LoginPage(),
            );
          case '/register':
            return MaterialPageRoute(
              builder: (context) => RegisterPage(),
            );
          case '/home-authorized':
            return MaterialPageRoute(
              builder: (context) => HomePage(
                  settings: this.settings, onSettingsChanged: updateSettings),
            );
          case '/home':
            if (userAutorized) {
              return MaterialPageRoute(
                builder: (context) => HomePage(
                    settings: this.settings, onSettingsChanged: updateSettings),
              );
            } else {
              return MaterialPageRoute(
                builder: (context) => LoginPage(),
              );
            }
          case '/settings':
            return MaterialPageRoute(
              builder: (context) => SettingsPage(
                  settings: this.settings, onSettingsChanged: updateSettings),
            );
          case '/quiz':
            final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (context) => QuizPage(
                vocabularies: args['vocabularies'] ?? vocabularies,
                settings: args['settings'] ?? settings,
                onUpdate: args['onUpdate'] ?? (Vocabulary voc) {},
                quizGerman: args['quizGerman'] ?? quizGerman,
              ),
            );
          case '/voc_mgmt':
            final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (context) => VocabularyManagementPage(
                vocabularies: args['vocabularies'] ?? vocabularies,
                onInsert: args['onInsert'] ?? (Vocabulary voc) {},
                onUpdate: args['onUpdate'] ?? (Vocabulary voc) {},
                onDelete: args['onDelete'] ?? (Vocabulary voc) {},
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                    automaticallyImplyLeading: false,
                    title: const Text('Fehler')),
                body: Center(child: Text('Seite nicht gefunden')),
              ),
            );
        }
      },
    );
  }
}
