// pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_test_01/services/database_service.dart';

import '../models/appSettings.dart';
import '../models/vocabulary.dart';
import '../pages/grammar_page.dart';
import '../pages/quiz_page.dart';
import '../pages/quiz_page_old_style.dart';
import '../pages/settings_page.dart';
import '../pages/voc_mgmt_page.dart';

class HomePage extends StatefulWidget {
  final AppSettings settings;
  final Function(AppSettings) onSettingsChanged;

  const HomePage(
      {super.key, required this.settings, required this.onSettingsChanged});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _selectedIndex = 1;
  List<Vocabulary> vocabularies = [];
  bool quizGerman = true; // true: Deutsch→Englisch, false: Englisch→Deutsch

  @override
  void initState() {
    super.initState();
    _loadAllVocabulariesFromFirebase();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Speichern, wenn die App pausiert oder in den Hintergrund wechselt.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Hier ggf. Speichern-Logik einfügen.
    }
  }

  Future<void> _loadAllVocabulariesFromFirebase() async {
    print('_loadAllVocabulariesFromFirebase BEGIN');
    vocabularies = await DatabaseService().getCompleteVocabularies();
    print('_loadAllVocabulariesFromFirebase: ${vocabularies.length} - END');
  }

  void _onItemTapped(int index) {
    setState(() {
      if (index == _selectedIndex && index == 1) {
        quizGerman = !quizGerman;
      } else {
        _selectedIndex = index;
        if (_selectedIndex == 1) quizGerman = true;
      }
    });
  }

  // Generiere die Seitenliste
  List<Widget> _pages() => [
        VocabularyManagementPage(
          vocabularies: vocabularies,
          onInsert: (Vocabulary newVoc) {
            DatabaseService().addVocabulary(newVoc);
            setState(() {});
          },
          onUpdate: (Vocabulary updateVoc) {
            DatabaseService().updateVocabulary(updateVoc.uuid, updateVoc);
            setState(() {});
          },
          onDelete: (Vocabulary delVoc) {
            DatabaseService().deleteVocabulary(delVoc.uuid);
            setState(() {});
          },
        ),
        QuizPage(
          vocabularies: vocabularies,
          settings: widget.settings,
          onUpdate: (Vocabulary updateVoc) {
            DatabaseService().updateVocabulary(updateVoc.uuid, updateVoc);
          },
          quizGerman: quizGerman,
        ),
        OldQuizPage(
          vocabularies: vocabularies,
          settings: widget.settings,
          onUpdate: (Vocabulary updateVoc) {
            DatabaseService().updateVocabulary(updateVoc.uuid, updateVoc);
          },
          quizGerman: quizGerman,
        ),
        GrammarPage(),
        SettingsPage(
          settings: widget.settings,
          onSettingsChanged: widget.onSettingsChanged,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Vocabulary>>(
      future: DatabaseService().getCompleteVocabularies(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Fehler beim Laden: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Keine Vokabeln gefunden'));
        } else {
          vocabularies = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false,
                title: const Text('Vokabel Trainer')),
            body: _pages()[_selectedIndex],
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              // Zusätzlicher Abstand nach unten
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  height: 50, // Kleinere Höhe
                  labelTextStyle: MaterialStateProperty.all(
                    const TextStyle(
                        fontSize: 12), // Kleinere Schriftgröße für Labels
                  ),
                  iconTheme: MaterialStateProperty.all(
                    const IconThemeData(size: 20), // Kleinere Icons
                  ),
                ),
                child: NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  destinations: [
                    const NavigationDestination(
                        icon: Icon(Icons.list), label: 'Liste'),
                    NavigationDestination(
                        icon: const Icon(Icons.flash_on),
                        label: quizGerman ? 'Deu-Eng' : 'Eng-Deu'),
                    NavigationDestination(
                        icon: const Icon(Icons.quiz),
                        label: quizGerman ? 'Deu-Eng' : 'Eng-Deu'),
                    const NavigationDestination(
                        icon: Icon(Icons.book), label: 'Grammar'),
                    const NavigationDestination(
                        icon: Icon(Icons.settings), label: 'Einstellungen'),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}