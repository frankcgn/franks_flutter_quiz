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
    _focusNode.requestFocus(); // Cursor wird beim Laden der Seite in das Eingabefeld gesetzt.
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
  
  /// Prüft die Antwort auf Basis der aktuell festgelegten Vokabel.
  /// Unterstützt mehrere korrekte Lösungen, getrennt durch Komma.
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
    _focusNode.requestFocus(); // Nach dem Wechsel zur nächsten Vokabel wird der Cursor in das Eingabefeld gesetzt.
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.vocabularies.isEmpty || currentVocabulary == null) {
      return const Center(child: Text('Keine fälligen Vokabeln vorhanden.'));
    }
    final Vocabulary currentVoc = currentVocabulary!;
    final String questionText = askGerman ? currentVoc.german : currentVoc.english;
    final String exampleText = askGerman ? currentVoc.germanSentence : currentVoc.englishSentence;
    final String expectedAnswer = askGerman ? currentVoc.english : currentVoc.german;
    const double containerHeight = 60.0;
    
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
    
    // Container für die eingegebene Antwort, mit Rahmen in Textfarbe.
    final Widget submittedAnswerContainer = showExample
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
    
    // Action-Button, der seine Beschriftung und Funktion dynamisch wechselt.
    final double? fontSize = Theme.of(context).textTheme.headlineSmall?.fontSize;
    final Widget actionButton = SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: showExample ? _nextQuestion : _handleAnswer,
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          minimumSize: Size(double.infinity, containerHeight),
        ),
        child: Text(
          showExample ? 'Nächste Vokabel' : 'Antwort überprüfen',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: fontSize),
        ),
      ),
    );
    
    // Lautsprechersymbol-Button: Wird hinter der Antwortnachricht angezeigt.
    final Widget speakButton = showExample
        ? IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: _speakEnglish,
            tooltip: 'Sprich die Vokabel aus',
          )
        : const SizedBox();
    
    // Gesamtlayout: Oberer (scrollbarer) Content und fixierter Action-Button am unteren Rand.
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
                          questionContainer,
                          const SizedBox(height: 12),
                          const Text(
                            'Beispielsatz:',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          AutoSizeText(
                            exampleText,
                            style: Theme.of(context).textTheme.bodyLarge,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            enabled: _inputEnabled,
                            focusNode: _focusNode,
                            autocorrect: false,
                            enableSuggestions: false,
                            textCapitalization: TextCapitalization.none,
                            controller: answerController,
                            textAlign: showExample ? TextAlign.center : TextAlign.start,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: showExample
                                      ? (quizState == QuizState.correctAnswer ? Colors.green : Colors.red)
                                      : Colors.black,
                                ),
                            decoration: InputDecoration(
                              hintText: askGerman
                                  ? 'Deine Antwort (englisches Wort)'
                                  : 'Deine Antwort (deutsches Wort)',
                              contentPadding: const EdgeInsets.all(12),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: inputBorderColor, width: 3),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: inputBorderColor, width: 3),
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) {
                              if (!_inputEnabled) return;
                              _handleAnswer();
                            },
                          ),
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(color: Colors.blue),
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          if (showExample)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AutoSizeText(
                                'Beispielsatz (${askGerman ? "Englisch" : "Deutsch"}):\n${askGerman ? currentVoc.englishSentence : currentVoc.germanSentence}',
                                style: Theme.of(context).textTheme.bodyLarge,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          // Lautsprechersymbol-Button direkt hinter der Antwortnachricht.
                          if (showExample) speakButton,
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