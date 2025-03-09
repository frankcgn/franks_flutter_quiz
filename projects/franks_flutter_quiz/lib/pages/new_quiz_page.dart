// pages/new_quiz_page.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../models/appSettings.dart';
import '../models/global_state.dart';
import '../models/vocabulary.dart';
import '../widgets/action_button.dart';
import '../widgets/flag_helper_widget.dart';
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

  // Neuer Filtermode (basierend auf der Anzahl richtiger Antworten)
  final RestorableInt _filterMode = RestorableInt(0);

  // Suchbegriff
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
    // Filtere zusätzlich nach Gruppen, wenn diese nicht "Alle" ist.
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

    if (filteredVocabularies.isEmpty || currentVocabulary == null) {
      return const Center(child: Text('Keine fälligen Vokabeln vorhanden.'));
    }

    final Vocabulary currentVoc = currentVocabulary!;

    if (!groups.contains(Provider.of<GlobalState>(context).selectedGroup)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<GlobalState>(context, listen: false)
            .setSelectedGroup('Alle');
      });
    }

    final Map<String, int> stats = _computeStats();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const SizedBox.shrink(),
      ),
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
          // Statusinformationen (z.B. gruppierte Anzeige der richtigen Antworten)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: StatusBar(
              stats: stats,
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
          // Vokabelinformationen als Block
          Expanded(
            child: ListView.builder(
              itemCount: 1,
              // es soll nur eine Vokabel gleichzeitig angezeigt werden
              itemBuilder: (context, index) {
                Vocabulary voc = currentVoc;
                return GestureDetector(
                  // onDoubleTap: () => _showEditDialogForVocabulary(voc),
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ExpansionTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Zeile mit deutscher Vokabel (mit Flagge, Text und LongPress)
                          FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                            voc.german,
                            'assets/flags/de.jpg',
                            'de-DE',
                            onLongPress: _speakText,
                          ),
                          FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                            voc.germanSentence,
                            '',
                            'de-DE',
                            onLongPress: _speakText,
                          ),
                        ],
                      ),
                      children: [
                        // Divider: 75 % der Breite, links ausgerichtet
                        FractionallySizedBox(
                          widthFactor: 0.75,
                          alignment: Alignment.centerLeft,
                          child:
                              const Divider(thickness: 1, color: Colors.grey),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Englischer Beispielsatz (mit Flagge und LongPress)
                              FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                                voc.english,
                                'assets/flags/en.jpg',
                                'en-US',
                                onLongPress: _speakText,
                              ),
                              const SizedBox(height: 1),
                              // Deutscher Beispielsatz (mit Flagge und LongPress)
                              FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                                voc.englishSentence,
                                '',
                                'en-US',
                                onLongPress: _speakText,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
