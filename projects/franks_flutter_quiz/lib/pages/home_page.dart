// pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_test_01/services/database_service.dart';
import '../firebase_repository.dart';
import '../storage.dart';
import '../vocabulary_list.dart';
import 'quiz_page.dart';
import 'vocabulary_management_page.dart';
import 'settings_page.dart';
import '../models/appSettings.dart';
import '../models/vocabulary.dart';

class HomePage extends StatefulWidget {
  final AppSettings settings;
  final Function(AppSettings) onSettingsChanged;
  HomePage({required this.settings, required this.onSettingsChanged});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final DatabaseService _databaseService = DatabaseService();
  int _selectedIndex = 1;
  List<Vocabulary> vocabularies = [];
  List<Vocabulary> updatedVocabularies = [];
  bool quizGerman = true; // true: Deutsch→Englisch, false: Englisch→Deutsch

  @override
  void initState() {
    super.initState();
    _loadVocabulariesFromDB();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Wenn die App in den Hintergrund wechselt oder pausiert, speichere alle Änderungen
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // Hier rufst du deine Funktion zum Speichern der Vokabeln auf.
      _saveUpdatedVocabulariesInDB();
    }
  }

  Future<void> _loadVocabulariesFromDB() async {
    print('_loadVocabulariesFromDB BEGIN');
    final List<Vocabulary> loadedVocab = await initialVocabularyFromDB();
    setState(() {
      vocabularies = loadedVocab;
      print('_loadVocabulariesFromDB COUNT: ${vocabularies.length}');
    });
    print('_loadVocabulariesFromDB END');
  }

  Future<void> _saveAllVocabulariesInDB() async {
    print('_saveAllVocabulariesInDB BEGIN');
    final FirebaseRepository firebaseRepo = FirebaseRepository();

    for (Vocabulary voc in vocabularies) {
      print('${voc.german}');
      await firebaseRepo.saveOrUpdateVocabulary(voc);
    }
    print('_saveAllVocabulariesInDB END');
  }

  Future<void> _saveUpdatedVocabulariesInDB() async {
    print('_saveUpdatedVocabulariesInDB BEGIN');
    final FirebaseRepository firebaseRepo = FirebaseRepository();

    for (Vocabulary voc in updatedVocabularies) {
      print('${voc.german}');
      await firebaseRepo.saveOrUpdateVocabulary(voc);
    }
    updatedVocabularies.clear();
    print('_saveUpdatedVocabulariesInDB END');
  }

  Future<void> _loadVocabularies() async {
    final List<Vocabulary> loadedVocab = await VocabularyStorage.loadVocabularies();
    if (loadedVocab.isEmpty) {
      final List<Vocabulary> initialVocabs = await initialVocabulary();
      loadedVocab.addAll(initialVocabs);
      await VocabularyStorage.saveVocabularies(loadedVocab);
    }
    setState(() {
      vocabularies = loadedVocab;
    });
  }

  Future<void> _saveVocabularies() async {
    await VocabularyStorage.saveVocabularies(vocabularies);
  }

  void _saveVocabularyList(String fileName) async {
    await VocabularyStorage.saveVocabulariesWithName(vocabularies, fileName);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vokabelliste gespeichert')),
    );
  }

  Future<void> _loadVocabularyList(String fileName) async {
    final List<Vocabulary> loaded = await VocabularyStorage.loadVocabulariesWithName(fileName);
    if (loaded.isNotEmpty) {
      setState(() {
        vocabularies = loaded;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vokabelliste geladen')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keine Vokabelliste unter diesem Namen gefunden')),
      );
    }
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
          onUpdate: () {
            _saveVocabularies();
            setState(() {});
          },
        ),
        QuizPage(
          vocabularies: vocabularies,
          updatedVocabularies: updatedVocabularies,
          settings: widget.settings,
          onUpdate: _saveVocabularies,
          quizGerman: quizGerman,
        ),
        SettingsPage(
          settings: widget.settings,
          onSettingsChanged: widget.onSettingsChanged,
          onSaveVocabularyList: _saveVocabularyList,
          onLoadVocabularyList: _loadVocabularyList,
          vocabularies: vocabularies,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vokabel Trainer')),
      body: _pages()[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          const NavigationDestination(icon: Icon(Icons.list), label: 'Vokabeln'),
          NavigationDestination(icon: const Icon(Icons.quiz), label: quizGerman ? 'Deu-Eng' : 'Eng-Deu'),
          const NavigationDestination(icon: Icon(Icons.settings), label: 'Einstellungen'),
        ],
      ),
    );
  }
}