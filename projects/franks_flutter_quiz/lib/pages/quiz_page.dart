// pages/quiz_page.dart
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models.dart';

class QuizPage extends StatefulWidget {
  final List<Vocabulary> vocabularies;
  final AppSettings settings;
  final VoidCallback onUpdate;
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

  @override
  void initState() {
    super.initState();
    askGerman = widget.quizGerman;
    _focusNode.requestFocus(); // Optional: Beim Seitenstart den Cursor setzen.
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

  /// Liefert die aktuell anzuzeigende Vokabel.
  /// Falls activeVocabulary noch nicht gesetzt ist, wird sie anhand der Gruppierung ermittelt.
  Vocabulary? get currentVocabulary {
    if (activeVocabulary != null) return activeVocabulary;
    if (widget.vocabularies.isEmpty) return null;
    final Map<int, List<Vocabulary>> groups = {};
    for (var voc in widget.vocabularies) {
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
      lastQuery == null || !lastQuery.add(Duration(days: intervalDays)).isAfter(today);

  bool isDue(Vocabulary voc, bool askGerman, AppSettings settings) {
    final DateTime today = DateTime.now();
    if (askGerman) {
      if (voc.deToEnCounter < 3) return true;
      if (voc.deToEnCounter == 3) return _isDueHelper(voc.deToEnLastQuery, settings.intervalFor3, today);
      if (voc.deToEnCounter == 4) return _isDueHelper(voc.deToEnLastQuery, settings.intervalFor4, today);
      return _isDueHelper(voc.deToEnLastQuery, settings.intervalFor5, today);
    } else {
      if (voc.enToDeCounter < 3) return true;
      if (voc.enToDeCounter == 3) return _isDueHelper(voc.enToDeLastQuery, settings.intervalFor3, today);
      if (voc.enToDeCounter == 4) return _isDueHelper(voc.enToDeLastQuery, settings.intervalFor4, today);
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

  /// Spricht die englische Vokabel per Text-to-Speech aus.
  Future<void> _speakEnglishSentence() async {
    final Vocabulary? voc = currentVocabulary;
    if (voc == null) return;
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(voc.englishSentence);
  }

  /// Prüft die Antwort auf Basis der aktuell festgelegten Vokabel.
  /// Unterstützt mehrere korrekte Lösungen (durch Komma getrennt).
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
    if (widget.vocabularies.isEmpty || currentVocabulary == null) {
      return const Center(child: Text('Keine fälligen Vokabeln vorhanden.'));
    }
    final Vocabulary currentVoc = currentVocabulary!;
    final String questionText = askGerman ? currentVoc.german : currentVoc.english;
    final String rawExampleText = askGerman ? currentVoc.germanSentence : currentVoc.englishSentence;
    final bool noExample = rawExampleText.trim().isEmpty;
    final String exampleText = noExample
        ? (askGerman ? 'kein Text vorhanden' : 'no text available')
        : rawExampleText;
    final TextStyle exampleStyle = noExample
        ? Theme.of(context).textTheme.bodyLarge!.copyWith(fontStyle: FontStyle.italic)
        : Theme.of(context).textTheme.bodyLarge!;
    final String expectedAnswer = askGerman ? currentVoc.english : currentVoc.german;
    const double containerHeight = 60.0;

    // Fragecontainer mit AutoSizeText
    final Widget questionContainer = Container(
      height: containerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: AutoSizeText(
        questionText,
        style: Theme.of(context).textTheme.headlineSmall,
        maxLines: 1,
        textAlign: TextAlign.center,
      ),
    );

    final Color inputBorderColor = quizState == QuizState.correctAnswer
        ? Colors.green
        : quizState == QuizState.wrongAnswer
        ? Colors.red
        : Colors.grey;

    final Map<String, int> stats = _computeStats();
    final Widget statusBar = Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Alle: ${stats['total']}'),
          Text('0: ${stats['0']}'),
          Text('1-2: ${stats['1-2']}'),
          Text('3-4: ${stats['3-4']}'),
          Text('>4: ${stats['>4']}'),
        ],
      ),
    );

    // Eingabefeld in einem Container mit Rahmen
    final Widget inputFieldContainer = Container(
      decoration: BoxDecoration(
        border: Border.all(color: inputBorderColor, width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        enabled: _inputEnabled,
        focusNode: _focusNode,
        autocorrect: false,
        enableSuggestions: false,
        textCapitalization: TextCapitalization.none,
        controller: answerController,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: showExample
              ? (quizState == QuizState.correctAnswer ? Colors.green : Colors.red)
              : Colors.black,
        ),
        decoration: const InputDecoration(
          hintText: 'Deine Antwort',
          contentPadding: EdgeInsets.all(12),
          border: InputBorder.none,
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (value) {
          if (!_inputEnabled) return;
          _handleAnswer();
        },
      ),
    );

    // Container für die eingetragene Antwort wird nur angezeigt, wenn die Antwort korrekt ist.
    final Widget submittedAnswerContainer = (showExample && quizState == QuizState.correctAnswer)
        ? Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        height: containerHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: inputBorderColor, width: 3),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: AutoSizeText(
          answerController.text,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: inputBorderColor),
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
      ),
    )
        : const SizedBox();

    // Action-Button: Zeigt "Antwort überprüfen" oder "Nächste Vokabel" an.
    final double? fontSize = Theme.of(context).textTheme.headlineSmall?.fontSize;
    final Widget actionButton = SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: showExample ? _nextQuestion : _handleAnswer,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          minimumSize: Size(double.infinity, containerHeight),
        ),
        child: Text(
          showExample ? 'Nächste Vokabel' : 'Antwort überprüfen',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: fontSize, color: Colors.white),
        ),
      ),
    );

    // Lautsprechersymbol-Button: Wird direkt hinter der Antwortanzeige (submittedAnswerContainer) angezeigt.
    final Widget speakButton = showExample
        ? IconButton(
      icon: const Icon(Icons.volume_up),
      onPressed: _speakEnglish,
      tooltip: 'Sprich die Vokabel aus',
    )
        : const SizedBox();

    // Lautsprechersymbol-Button: Wird direkt hinter der Antwortanzeige (submittedAnswerContainer) angezeigt.
    final Widget speakButton2 = showExample
        ? IconButton(
      icon: const Icon(Icons.volume_up),
      onPressed: _speakEnglishSentence,
      tooltip: 'Sprich den Beispielsatz aus',
    )
        : const SizedBox();

    // Gesamtlayout: Oberer Bereich (scrollbar) und fixierter Action-Button am unteren Rand.
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
                          statusBar,
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: questionContainer),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Beispielsatz:',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          AutoSizeText(
                            exampleText,
                            style: exampleStyle,
                            maxLines: 3,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          inputFieldContainer,
                          submittedAnswerContainer,
                          if (showExample && quizState == QuizState.wrongAnswer)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: containerHeight,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue, width: 3),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: AutoSizeText(
                                  expectedAnswer,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.blue),
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          if (showExample)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AutoSizeText(
                                'Beispielsatz (${askGerman ? "Englisch" : "Deutsch"}):\n${(askGerman ? currentVoc.englishSentence : currentVoc.germanSentence).trim().isEmpty ? (askGerman ? "no text available" : "kein text vorhanden") : (askGerman ? currentVoc.englishSentence : currentVoc.germanSentence)}',
                                style: ((askGerman ? currentVoc.englishSentence : currentVoc.germanSentence).trim().isEmpty)
                                    ? Theme.of(context).textTheme.bodyLarge!.copyWith(fontStyle: FontStyle.italic)
                                    : Theme.of(context).textTheme.bodyLarge,
                                maxLines: 3,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (showExample) speakButton, speakButton2
                        ],
                      ),
                    ),
                  ),
                  // Fixierter Action-Button am unteren Rand.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: actionButton,
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