// pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_test_01/services/database_service.dart';
import '../models/models.dart';
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

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService();
  int _selectedIndex = 1;
  List<Vocabulary> vocabularies = [];
  bool quizGerman = true; // true: Deutsch→Englisch, false: Englisch→Deutsch

  @override
  void initState() {
    super.initState();
    _loadVocabularies();
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