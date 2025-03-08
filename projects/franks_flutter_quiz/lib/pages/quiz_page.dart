// pages/quiz_page.dart
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/appSettings.dart';
import '../models/vocabulary.dart';
import '../widgets/action_button.dart';
import '../widgets/example_text_widget.dart';
import '../widgets/input_field_container.dart';
import '../widgets/question_container.dart';
import '../widgets/status_bar.dart';
import '../widgets/wrong_answer_container.dart';

typedef VocabularyCallback = void Function(Vocabulary voc);

enum QuizState { waitingForAnswer, correctAnswer, wrongAnswer }

class QuizPage extends StatefulWidget {
  final List<Vocabulary> vocabularies;
  final AppSettings settings;
  final VocabularyCallback onUpdate;
  final bool quizGerman;

  const QuizPage({
    super.key,
    required this.vocabularies,
    required this.settings,
    required this.onUpdate,
    required this.quizGerman,
  });

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with RestorationMixin {
  int currentIndex = 0;
  final TextEditingController answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FlutterTts flutterTts = FlutterTts();
  QuizState quizState = QuizState.waitingForAnswer;
  bool askGerman = true;
  bool showExample = false;
  bool _inputEnabled = true;

  // Speichert die aktuell geprüfte Vokabel.
  Vocabulary? activeVocabulary;

  // Neuer Filtermode (z.B. basierend auf der Anzahl richtiger Antworten)
  final RestorableInt _filterMode = RestorableInt(0);

  // Neuer State für den Gruppenfilter – "Alle" zeigt alle Gruppen an.
  String _selectedGroup = 'Alle';

  // Suchbegriff
  String _searchQuery = '';

  @override
  String? get restorationId => 'quiz_page';

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
  void didUpdateWidget(covariant QuizPage oldWidget) {
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

  List<Vocabulary> get filteredVocabularies {
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
    if (_selectedGroup != 'Alle') {
      list = list.where((voc) => voc.group == _selectedGroup).toList();
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
    if (filteredVocabularies.isEmpty) return null;
    final Map<int, List<Vocabulary>> groups = {};
    for (var voc in filteredVocabularies) {
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

  Map<String, int> _computeStats() {
    final int total = filteredVocabularies.length;
    int count0 = 0, count1_2 = 0, count3_4 = 0, countAbove4 = 0;
    for (var voc in filteredVocabularies) {
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

  bool _isDueHelper(DateTime? lastQuery, int intervalDays, DateTime today) =>
      lastQuery == null ||
          !lastQuery.add(Duration(days: intervalDays)).isAfter(today);

  bool isDue(Vocabulary voc, bool askGerman, AppSettings settings) {
    final DateTime today = DateTime.now();
    if (askGerman) {
      if (voc.deToEnCounter < 3) return true;
      if (voc.deToEnCounter == 3) {
        return _isDueHelper(voc.deToEnLastQuery, settings.intervalFor3, today);
      }
      if (voc.deToEnCounter == 4) {
        return _isDueHelper(voc.deToEnLastQuery, settings.intervalFor4, today);
      }
      return _isDueHelper(voc.deToEnLastQuery, settings.intervalFor5, today);
    } else {
      if (voc.enToDeCounter < 3) return true;
      if (voc.enToDeCounter == 3) {
        return _isDueHelper(voc.enToDeLastQuery, settings.intervalFor3, today);
      }
      if (voc.enToDeCounter == 4) {
        return _isDueHelper(voc.enToDeLastQuery, settings.intervalFor4, today);
      }
      return _isDueHelper(voc.enToDeLastQuery, settings.intervalFor5, today);
    }
  }

  Future<void> _speakEnglish() async {
    final Vocabulary? voc = currentVocabulary;
    if (voc == null) return;
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(voc.english);
  }

  Future<void> _speakEnglishText(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
  }

  Future<void> _speakEnglishSentence() async {
    final Vocabulary? voc = currentVocabulary;
    if (voc == null) return;
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(voc.englishSentence);
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
      quizState = correct ? QuizState.correctAnswer : QuizState.wrongAnswer;
      showExample = true;
      _inputEnabled = false;
    });
    widget.onUpdate(voc);
  }

  void _nextQuestion() {
    setState(() {
      answerController.clear();
      quizState = QuizState.waitingForAnswer;
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
    final List<String> groups = widget.vocabularies
        .map((voc) => voc.group ?? '')
        .where((g) => g.isNotEmpty)
        .toSet()
        .toList();
    groups.sort();

    if (filteredVocabularies.isEmpty || currentVocabulary == null) {
      return const Center(child: Text('Keine fälligen Vokabeln vorhanden.'));
    }
    final Vocabulary currentVoc = currentVocabulary!;
    final String questionText =
        askGerman ? currentVoc.german : currentVoc.english;
    final String rawExampleText =
        askGerman ? currentVoc.germanSentence : currentVoc.englishSentence;
    final bool noExample = rawExampleText.trim().isEmpty;
    final String exampleText = noExample
        ? (askGerman ? 'kein text vorhanden' : 'no text available')
        : rawExampleText;
    final TextStyle exampleStyle = noExample
        ? Theme.of(context)
        .textTheme
        .bodyLarge!
        .copyWith(fontStyle: FontStyle.italic)
        : Theme.of(context).textTheme.bodyLarge!;
    final String expectedAnswer =
        askGerman ? currentVoc.english : currentVoc.german;
    final bool darkMode = widget.settings.darkMode;
    final Color inputBorderColor = quizState == QuizState.correctAnswer
        ? Colors.green
        : quizState == QuizState.wrongAnswer
        ? Colors.red
        : Colors.grey;
    final Map<String, int> stats = _computeStats();

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    // Dropdown für den Gruppenfilter (über der Statusbar)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Gruppe:'),
                          DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedGroup,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedGroup = newValue!;
                                activeVocabulary = null;
                                quizState = QuizState.waitingForAnswer;
                                _inputEnabled = true;
                                answerController.clear();
                              });
                            },
                            items: <String>['Alle', ...groups]
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    // Statusbar, die nun auch den Gruppenfilter berücksichtigt
                    StatusBar(
                      stats: stats,
                      darkMode: darkMode,
                      selectedFilterIndex: _filterMode.value,
                      onFilterSelected: (int index) {
                        setState(() {
                          _filterMode.value = index;
                          activeVocabulary = null;
                          quizState = QuizState.waitingForAnswer;
                          showExample = false;
                          _inputEnabled = true;
                          answerController.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Abgefragt: ${currentVoc.answerCount}    Richtig: ${askGerman ? currentVoc.deToEnCounter : currentVoc.enToDeCounter}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    // Scrollbarer Bereich, der Frage, Beispieltext, Eingabefeld und Antwort umfasst
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: QuestionContainer(
                                      questionText: questionText),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ExampleTextWidget(
                              exampleText: exampleText,
                              textStyle: exampleStyle,
                              isEmptyExample: noExample,
                              askGerman: askGerman,
                            ),
                            const SizedBox(height: 20),
                            // Eingabefeld mit Antwort, daneben das Speak-Icon für _speakEnglish
                            Row(
                              children: [
                                Expanded(
                                  child: InputFieldContainer(
                                    controller: answerController,
                                    focusNode: _focusNode,
                                    enabled: _inputEnabled,
                                    borderColor: inputBorderColor,
                                    onSubmitted: (value) {
                                      if (!_inputEnabled) {
                                        _nextQuestion();
                                      } else {
                                        _handleAnswer();
                                      }
                                    },
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: showExample
                                              ? (quizState ==
                                                      QuizState.correctAnswer
                                                  ? Colors.green
                                                  : Colors.red)
                                              : Colors.black,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            if (showExample &&
                                quizState == QuizState.wrongAnswer)
                              WrongAnswerContainer(
                                expectedAnswer: expectedAnswer,
                                onPressed: () {},
                              ),
                            if (showExample)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: AutoSizeText(
                                        'Beispielsatz (${askGerman ? "Englisch" : "Deutsch"}):\n${(askGerman ? currentVoc.englishSentence : currentVoc.germanSentence).trim().isEmpty ? (askGerman ? "no text available" : "kein text vorhanden") : (askGerman ? currentVoc.englishSentence : currentVoc.germanSentence)}',
                                        style: ((askGerman
                                                    ? currentVoc.englishSentence
                                                    : currentVoc.germanSentence)
                                                .trim()
                                                .isEmpty)
                                            ? Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                    fontStyle: FontStyle.italic)
                                            : Theme.of(context)
                                                .textTheme
                                                .bodyLarge,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.volume_up,
                                          size: 16.0),
                                      onPressed: () => _speakEnglishText(
                                          askGerman
                                              ? currentVoc.englishSentence
                                              : currentVoc.germanSentence),
                                      tooltip: 'Sprich den Beispielsatz aus',
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ActionButton(
          text: showExample ? 'Nächste Vokabel' : 'Antwort überprüfen',
          onPressed: showExample ? _nextQuestion : _handleAnswer,
        ),
      ),
    );
  }
}