// pages/new_quiz_page.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../models/appSettings.dart';
import '../models/global_state.dart';
import '../models/vocabulary.dart';
import '../widgets/action_button3.dart';
import '../widgets/flag_helper_widget.dart';
import '../widgets/input_field_container.dart';
import '../widgets/status_bar.dart';

typedef VocabularyCallback = void Function(Vocabulary voc);

enum NewQuizState { waitingForAnswer, correctAnswer, wrongAnswer }

class NewQuizPage extends StatefulWidget {
  final List<Vocabulary> vocabularies;
  final AppSettings settings;
  final VocabularyCallback onUpdate;
  final bool quizGerman;

  const NewQuizPage({
    super.key,
    required this.vocabularies,
    required this.settings,
    required this.onUpdate,
    required this.quizGerman,
  });

  @override
  _NewQuizPageState createState() => _NewQuizPageState();
}

class _NewQuizPageState extends State<NewQuizPage> with RestorationMixin {
  int currentIndex = 0;
  final TextEditingController answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FlutterTts flutterTts = FlutterTts();
  NewQuizState quizState = NewQuizState.waitingForAnswer;
  bool askGerman = true;
  bool showExample = false;
  bool _inputEnabled = true;

  // Speichert die aktuell geprüfte Vokabel.
  Vocabulary? activeVocabulary;

  // Neuer Filtermodus (basierend auf der Anzahl richtiger Antworten)
  final RestorableInt _filterMode = RestorableInt(0);

  // Suchbegriff (falls verwendet)
  String _searchQuery = '';

  @override
  String? get restorationId => 'new_quiz_page';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_filterMode, 'filter_mode');
  }

  @override
  void initState() {
    super.initState();
    askGerman = widget.quizGerman;
    _focusNode.requestFocus();
  }

  @override
  void didUpdateWidget(covariant NewQuizPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quizGerman != widget.quizGerman) {
      setState(() {
        askGerman = widget.quizGerman;
        activeVocabulary = null;
      });
    }
  }

  String normalizeAnswer(String s) {
    return s.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
  }

  List<Vocabulary> get filteredVocabs {
    List<Vocabulary> list = widget.vocabularies.where((voc) {
      final int counter = askGerman ? voc.deToEnCounter : voc.enToDeCounter;
      switch (_filterMode.value) {
        case 0:
          return true;
        case 1:
          return counter == 0;
        case 2:
          return counter == 1 || counter == 2;
        case 3:
          return counter == 3 || counter == 4;
        case 4:
          return counter > 4;
        default:
          return true;
      }
    }).toList();
    // Zusätzlich nach Gruppen filtern:
    if (Provider.of<GlobalState>(context).selectedGroup != 'Alle') {
      list = list
          .where((voc) =>
              voc.group == Provider.of<GlobalState>(context).selectedGroup)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((voc) {
        return voc.german.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            voc.english.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    return list;
  }

  Vocabulary? get currentVocabulary {
    if (activeVocabulary != null) return activeVocabulary;
    if (filteredVocabs.isEmpty) return null;
    final Map<int, List<Vocabulary>> groups = {};
    for (var voc in filteredVocabs) {
      final int counter = askGerman ? voc.deToEnCounter : voc.enToDeCounter;
      groups.putIfAbsent(counter, () => []).add(voc);
    }
    final List<int> sortedKeys = groups.keys.toList()..sort();
    if (sortedKeys.isEmpty) return null;
    final List<Vocabulary> lowestGroup = groups[sortedKeys.first]!;
    lowestGroup.shuffle(Random());
    activeVocabulary = lowestGroup.first;
    return activeVocabulary;
  }

  Map<String, int> _computeLevels() {
    final int total = filteredVocabs.length;
    int count0 = 0, count1_2 = 0, count3_4 = 0, countAbove4 = 0;
    for (var voc in filteredVocabs) {
      final int counter = askGerman ? voc.deToEnCounter : voc.enToDeCounter;
      if (counter == 0) {
        count0++;
      } else if (counter <= 2) {
        count1_2++;
      } else if (counter <= 4) {
        count3_4++;
      } else {
        countAbove4++;
      }
    }
    return {
      'total': total,
      '0': count0,
      '1-2': count1_2,
      '3-4': count3_4,
      '>4': countAbove4,
    };
  }

  Future<void> _speakText(String text, String language) async {
    await flutterTts.setLanguage(language);
    await flutterTts.speak(text);
  }

  void _handleAnswer() {
    final Vocabulary? voc = currentVocabulary;
    if (voc == null) return;
    final String givenAnswer = answerController.text.trim().toLowerCase();
    final String expectedAnswer = askGerman ? voc.english : voc.german;
    final String normalizedGiven = normalizeAnswer(givenAnswer).toLowerCase();
    final List<String> validAnswers = expectedAnswer
        .split(',')
        .map((s) => normalizeAnswer(s).toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();
    final bool correct = validAnswers.contains(normalizedGiven);
    setState(() {
      voc.answerCount++;
      if (askGerman) {
        if (correct) {
          voc.deToEnCounter = voc.deToEnCounter + 1;
        } else {
          voc.deToEnCounter = max(voc.deToEnCounter - 1, 0);
        }
        voc.deToEnLastQuery = DateTime.now();
      } else {
        if (correct) {
          voc.enToDeCounter = voc.enToDeCounter + 1;
        } else {
          voc.enToDeCounter = max(voc.enToDeCounter - 1, 0);
        }
        voc.enToDeLastQuery = DateTime.now();
      }
      quizState =
          correct ? NewQuizState.correctAnswer : NewQuizState.wrongAnswer;
      showExample = true;
      _inputEnabled = false;
    });
    widget.onUpdate(voc);
  }

  void _nextQuestion() {
    setState(() {
      answerController.clear();
      quizState = NewQuizState.waitingForAnswer;
      showExample = false;
      activeVocabulary = null;
      _inputEnabled = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ermitteln der Gruppen aus den Vokabeln:
    final List<String> groups = widget.vocabularies
        .map((voc) => voc.group ?? '')
        .where((g) => g.isNotEmpty)
        .toSet()
        .toList();
    groups.sort();

    if (!groups.contains(Provider.of<GlobalState>(context).selectedGroup)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<GlobalState>(context, listen: false)
            .setSelectedGroup('Alle');
      });
    }

    // Anwenden der Filterlogik (Gruppenfilter, Filtermodus und Suchbegriff)
    List<Vocabulary> filteredVocabs = widget.vocabularies.where((voc) {
      bool matchesSearch =
          voc.german.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              voc.english.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesGroup =
          Provider.of<GlobalState>(context).selectedGroup == 'Alle' ||
              (voc.group != null &&
                  voc.group == Provider.of<GlobalState>(context).selectedGroup);
      return matchesSearch && matchesGroup;
    }).toList();
    filteredVocabs.sort((a, b) => a.german.compareTo(b.german));

    final Map<String, int> levels = _computeLevels();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dropdown-Filter als Row (nebeneinander: Label + Dropdown)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                const Text('Gruppe:'),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: Provider.of<GlobalState>(context).selectedGroup,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        Provider.of<GlobalState>(context, listen: false)
                            .setSelectedGroup(newValue);
                        setState(() {
                          activeVocabulary = null;
                          quizState = NewQuizState.waitingForAnswer;
                          _inputEnabled = true;
                          answerController.clear();
                        });
                      }
                    },
                    items: <String>['Alle', ...groups]
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Levelinformationen (z.B. gruppierte Anzeige der richtigen Antworten)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: LevelStatusBar(
              levelCounter: levels,
              darkMode: widget.settings.darkMode,
              selectedFilterIndex: _filterMode.value,
              onFilterSelected: (int index) {
                setState(() {
                  _filterMode.value = index;
                  activeVocabulary = null;
                  quizState = NewQuizState.waitingForAnswer;
                  _inputEnabled = true;
                  answerController.clear();
                });
              },
            ),
          ),
          // Karte mit Vokabelinformationen (aktuelle Frage)
          Expanded(
            child: ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                Vocabulary voc = currentVocabulary!;
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ExpansionTile(
                    // Hier verwenden wir den ExpansionTile nur, wenn showExample true ist.
                    // Andernfalls werden keine Vokabelergebnisse angezeigt und der Pfeil (trailing) ausgeblendet.
                    initiallyExpanded: showExample,
                    trailing: showExample ? null : const SizedBox.shrink(),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Zeile mit deutscher Vokabel (mit Flagge, Text und LongPress)
                        if (askGerman)
                          FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                          voc.german,
                          'assets/flags/de.jpg',
                          'de-DE',
                          onLongPress: _speakText,
                        ),
                        if (!askGerman)
                          FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                            voc.english,
                            'assets/flags/en.jpg',
                            'en-US',
                            onLongPress: _speakText,
                          ),
                        if (askGerman)
                          // Zeile mit englischer Vokabel (mit Flagge, Text und LongPress)
                        FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                          voc.germanSentence,
                          '',
                          'de-DE',
                          onLongPress: _speakText,
                        ),
                        if (!askGerman)
                          // Zeile mit englischer Vokabel (mit Flagge, Text und LongPress)
                          FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                            voc.englishSentence,
                            '',
                            'en-US',
                            onLongPress: _speakText,
                          ),
                      ],
                    ),
                    children: [
                      // Divider: 75 % der Breite, links ausgerichtet
                      FractionallySizedBox(
                        widthFactor: 0.75,
                        alignment: Alignment.centerLeft,
                        child: const Divider(thickness: 1, color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (askGerman)
                              // Englischer Beispielsatz (mit Flagge und LongPress)
                            FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                              voc.english,
                              'assets/flags/en.jpg',
                              'en-US',
                              onLongPress: _speakText,
                            ),
                            if (!askGerman)
                              FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                                voc.german,
                                'assets/flags/de.jpg',
                                'de-DE',
                                onLongPress: _speakText,
                              ),
                            const SizedBox(height: 1),
                            if (askGerman)
                              // Deutscher Beispielsatz (mit Flagge und LongPress)
                            FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                              voc.englishSentence,
                              '',
                              'en-US',
                              onLongPress: _speakText,
                            ),
                            if (!askGerman)
                              FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                                voc.germanSentence,
                                '',
                                'de-DE',
                                onLongPress: _speakText,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Das Eingabefeld direkt unterhalb der Karte
          if (!(showExample && quizState == NewQuizState.wrongAnswer))
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: InputFieldContainer(
                controller: answerController,
                focusNode: _focusNode,
                enabled: _inputEnabled,
                borderColor: quizState == NewQuizState.correctAnswer
                    ? Colors.green
                    : quizState == NewQuizState.wrongAnswer
                        ? Colors.red
                        : Colors.grey,
                onSubmitted: (value) {
                  if (!_inputEnabled) {
                    _nextQuestion();
                  } else {
                    _handleAnswer();
                  }
                },
                textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: showExample
                          ? (quizState == NewQuizState.correctAnswer
                              ? Colors.green
                              : Colors.red)
                          : Colors.black,
                    ),
              ),
            ),
          // Anzeige der Antworten, falls die Antwort falsch ist:
          if (showExample && quizState == NewQuizState.wrongAnswer)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: Colors.red[50],
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Deine Antwort:    ${answerController.text}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Card(
                    color: Colors.green[50],
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Richtige Antwort: ${askGerman ? currentVocabulary?.english : currentVocabulary?.german}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ActionButton3(
          text: showExample ? 'Nächste Vokabel' : 'Antwort überprüfen',
          onPressed: showExample ? _nextQuestion : _handleAnswer,
        ),
      ),
    );
  }
}
