// pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_test_01/services/database_service.dart';

import '../models/appSettings.dart';
import '../models/vocabulary.dart';
import '../pages/grammar_page.dart';
import '../pages/new_quiz_page.dart';
import '../pages/quiz_page.dart';
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
    // Wenn die App in den Hintergrund wechselt oder pausiert, speichere alle Änderungen
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Hier rufst du deine Funktion zum Speichern der Vokabeln auf.
    }
  }

  Future? _loadAllVocabulariesFromFirebase() async {
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

  // Build UI
  List<Widget> _pages() => [
        VocabularyManagementPage(
          vocabularies: vocabularies,
          onInsert: (Vocabulary newVoc) {
            // Beispiel: Eine neue Vocabulary einfügen
            DatabaseService().addVocabulary(newVoc);
            setState(() {});
          },
          onUpdate: (Vocabulary updateVoc) {
            // Beispiel: Eine vorhandene Vocabulary ändern
            DatabaseService().updateVocabulary(updateVoc.uuid, updateVoc);
            setState(() {});
          },
          onDelete: (Vocabulary delVoc) {
            // Beispiel: Eine vorhandene Vocabulary löschen
            DatabaseService().deleteVocabulary(delVoc.uuid);
            setState(() {});
          },
        ),
        NewQuizPage(
          vocabularies: vocabularies,
          settings: widget.settings,
          onUpdate: (Vocabulary updateVoc) {
            // Beispiel: Eine vorhandene Vocabulary ändern
            DatabaseService().updateVocabulary(updateVoc.uuid, updateVoc);
          },
          quizGerman: quizGerman,
        ),
        QuizPage(
          vocabularies: vocabularies,
          settings: widget.settings,
          onUpdate: (Vocabulary updateVoc) {
            // Beispiel: Eine vorhandene Vocabulary ändern
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
            bottomNavigationBar: NavigationBar(
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
          );
        }
      },
    );
  }
}
