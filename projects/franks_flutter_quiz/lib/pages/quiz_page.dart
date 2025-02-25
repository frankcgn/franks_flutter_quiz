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
import '../widgets/speak_buttons_row.dart';
import '../widgets/status_bar.dart';
import '../widgets/submitted_answer_container.dart';
import '../widgets/wrong_answer_container.dart';

typedef VocabularyCallback = void Function(Vocabulary voc);

enum QuizState { waitingForAnswer, correctAnswer, wrongAnswer }

class QuizPage extends StatefulWidget {
  final List<Vocabulary> vocabularies;
  final AppSettings settings;
  final VocabularyCallback onUpdate;
  final bool quizGerman;

  QuizPage({
    required this.vocabularies,
    required this.settings,
    required this.onUpdate,
    required this.quizGerman,
  });

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Vocabulary>? vocabularies;
  int currentIndex = 0;
  final TextEditingController answerController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FlutterTts flutterTts = FlutterTts();
  QuizState quizState = QuizState.waitingForAnswer;
  bool askGerman = true;
  bool showExample = false;
  bool _inputEnabled = true; // Steuert, ob das Eingabefeld aktiv ist

  // Speichert die aktuell geprüfte Vokabel, damit diese konstant bleibt.
  Vocabulary? activeVocabulary;

  // Neuer Filtermode: 0 = alle, 1 = 0 richtige, 2 = 1 oder 2 richtige, 3 = 3 oder 4 richtige, 4 = mehr als 4 richtige
  int filterMode = 0;

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
        activeVocabulary = null; // Bei Richtungswechsel zurücksetzen.
      });
    }
  }

  /// Liefert die gefilterte Liste der Vokabeln basierend auf dem aktuellen Filtermode.
  List<Vocabulary> get filteredVocabularies {
    return widget.vocabularies.where((voc) {
      final int counter = askGerman ? voc.deToEnCounter : voc.enToDeCounter;
      switch (filterMode) {
        case 0: // Alle Vokabeln
          return true;
        case 1: // Nur Vokabeln mit 0 richtigen Antworten
          return counter == 0;
        case 2: // Nur Vokabeln mit 1 oder 2 richtigen Antworten
          return counter == 1 || counter == 2;
        case 3: // Nur Vokabeln mit 3 oder 4 richtigen Antworten
          return counter == 3 || counter == 4;
        case 4: // Nur Vokabeln mit mehr als 4 richtigen Antworten
          return counter > 4;
        default:
          return true;
      }
    }).toList();
  }

  /// Liefert die aktuell anzuzeigende Vokabel aus der gefilterten Liste.
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
    final int total = widget.vocabularies.length;
    int count0 = 0, count1_2 = 0, count3_4 = 0, countAbove4 = 0;
    for (var voc in widget.vocabularies) {
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
      if (voc.deToEnCounter == 3)
        return _isDueHelper(voc.deToEnLastQuery, settings.intervalFor3, today);
      if (voc.deToEnCounter == 4)
        return _isDueHelper(voc.deToEnLastQuery, settings.intervalFor4, today);
      return _isDueHelper(voc.deToEnLastQuery, settings.intervalFor5, today);
    } else {
      if (voc.enToDeCounter < 3) return true;
      if (voc.enToDeCounter == 3)
        return _isDueHelper(voc.enToDeLastQuery, settings.intervalFor3, today);
      if (voc.enToDeCounter == 4)
        return _isDueHelper(voc.enToDeLastQuery, settings.intervalFor4, today);
      return _isDueHelper(voc.enToDeLastQuery, settings.intervalFor5, today);
    }
  }

  /// Spricht die englische Vokabel per Text-to-Speech aus.
  Future<void> _speakEnglish() async {
    final Vocabulary? voc = currentVocabulary;
    if (voc == null) return;
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(voc.english);
  }

  /// Spricht den englischen Beispielsatz per Text-to-Speech aus.
  Future<void> _speakEnglishSentence() async {
    final Vocabulary? voc = currentVocabulary;
    if (voc == null) return;
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(voc.englishSentence);
  }

  /// Prüft die Antwort anhand der aktuellen Vokabel.
  void _handleAnswer() {
    final Vocabulary? voc = currentVocabulary;
    if (voc == null) return;
    final String givenAnswer = answerController.text.trim().toLowerCase();
    final String expectedAnswer = askGerman ? voc.english : voc.german;
    final List<String> validAnswers = expectedAnswer
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();
    final bool correct = validAnswers.contains(givenAnswer);
    setState(() {
      if (askGerman) {
        voc.deToEnCounter = correct ? voc.deToEnCounter + 1 : 0;
        voc.deToEnLastQuery = DateTime.now();
      } else {
        voc.enToDeCounter = correct ? voc.enToDeCounter + 1 : 0;
        voc.enToDeLastQuery = DateTime.now();
      }
      quizState = correct ? QuizState.correctAnswer : QuizState.wrongAnswer;
      showExample = true;
      _inputEnabled = false;
    });
    widget.onUpdate(voc);
  }

  /// Setzt activeVocabulary zurück, sodass beim nächsten Zugriff eine neue Vokabel gewählt wird.
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
    if (filteredVocabularies.isEmpty || currentVocabulary == null) {
      return const Center(child: Text('Keine fälligen Vokabeln vorhanden.'));
    }
    final Vocabulary currentVoc = currentVocabulary!;
    final String questionText = askGerman ? currentVoc.german : currentVoc.english;
    final String rawExampleText = askGerman ? currentVoc.germanSentence : currentVoc.englishSentence;
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
    final String expectedAnswer = askGerman ? currentVoc.english : currentVoc.german;
    const double containerHeight = 60.0;
    final bool darkMode = widget.settings.darkMode;
    final Color inputBorderColor = quizState == QuizState.correctAnswer
        ? Colors.green
        : quizState == QuizState.wrongAnswer
        ? Colors.red
        : Colors.grey;
    final Map<String, int> stats = _computeStats();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Übergabe des neuen onFilterSelected-Callbacks an die StatusBar:
                          StatusBar(
                            stats: stats,
                            darkMode: darkMode,
                            onFilterSelected: (int index) {
                              setState(() {
                                filterMode = index;
                                activeVocabulary =
                                    null; // Reset der aktuellen Vokabel, damit beim Filterwechsel neu gewählt wird.
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: QuestionContainer(questionText: questionText)),
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
                          InputFieldContainer(
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
                            textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: showExample
                                  ? (quizState == QuizState.correctAnswer ? Colors.green : Colors.red)
                                  : Colors.black,
                            ),
                          ),
                          if (showExample && quizState == QuizState.correctAnswer)
                            SubmittedAnswerContainer(
                              answerText: answerController.text,
                              borderColor: inputBorderColor,
                            ),
                          if (showExample && quizState == QuizState.wrongAnswer)
                            WrongAnswerContainer(expectedAnswer: expectedAnswer),
                          if (showExample)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AutoSizeText(
                                'Beispielsatz (${askGerman ? "Englisch" : "Deutsch"}):\n${(askGerman ? currentVoc.englishSentence : currentVoc.germanSentence).trim().isEmpty ? (askGerman ? "no text available" : "kein text vorhanden") : (askGerman ? currentVoc.englishSentence : currentVoc.germanSentence)}',
                                style: ((askGerman ? currentVoc.englishSentence : currentVoc.germanSentence).trim().isEmpty)
                                    ? Theme.of(context).textTheme.bodyLarge!.copyWith(fontStyle: FontStyle.italic)
                                    : Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (showExample)
                            SpeakButtonsRow(
                              onSpeakVocabulary: _speakEnglish,
                              onSpeakSentence: _speakEnglishSentence,
                            ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: ActionButton(
                      text: showExample ? 'Nächste Vokabel' : 'Antwort überprüfen',
                      onPressed: showExample ? _nextQuestion : _handleAnswer,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}