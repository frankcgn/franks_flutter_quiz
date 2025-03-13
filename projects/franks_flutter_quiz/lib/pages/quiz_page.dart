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

typedef VocabularyCallback = void Function(Vocabulary voc);

enum NewQuizState { waitingForAnswer, correctAnswer, wrongAnswer }

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
  NewQuizState quizState = NewQuizState.waitingForAnswer;
  bool askGerman = true;
  bool showExample = false;
  bool _inputEnabled = true;

  // Speichert die aktuell geprüfte Vokabel.
  Vocabulary? activeVocabulary;

  // Neuer Filtermodus (basierend auf der Anzahl richtiger Antworten).
  // Default: -1 bedeutet "Alle" (keine Level-Einschränkung).
  final RestorableInt _filterMode = RestorableInt(-1);

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

  /// Liefert alle Vokabeln, die anhand der Gruppe, des Suchbegriffs
  /// und – falls ein Level (Filter ungleich -1) ausgewählt wurde – des Levels gefiltert sind.
  List<Vocabulary> get filteredVocabs {
    // Zuerst nach Gruppe filtern:
    List<Vocabulary> list = widget.vocabularies;
    if (Provider.of<GlobalState>(context).selectedGroup != 'Alle') {
      list = list
          .where((voc) =>
              voc.group == Provider.of<GlobalState>(context).selectedGroup)
          .toList();
    }
    // Anschließend den Suchbegriff berücksichtigen:
    if (_searchQuery.isNotEmpty) {
      list = list.where((voc) {
        return voc.german.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            voc.english.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    // Levelfilter anwenden – außer wenn "-1" (Alle) gewählt wurde:
    if (_filterMode.value != -1) {
      list = list.where((voc) {
        final int counter = askGerman ? voc.deToEnCounter : voc.enToDeCounter;
        if (_filterMode.value == 0) {
          return counter == 0;
        } else if (_filterMode.value == 1) {
          return counter == 1 || counter == 2;
        } else if (_filterMode.value == 2) {
          return counter == 3 || counter == 4;
        } else if (_filterMode.value == 3) {
          return counter > 4;
        }
        return true;
      }).toList();
    }
    return list;
  }

  /// Liefert die aktuell geprüfte Vokabel aus der gefilterten Liste.
  /// Hier werden alle Filter (Gruppe, Suchbegriff und Level) berücksichtigt.
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

  /// Berechnet die Anzahl der Vokabeln je Level basierend auf der Gesamtmenge
  /// der Vokabeln in der ausgewählten Gruppe (und dem Suchbegriff), ohne den Level-Filter.
  Map<String, int> _computeLevels() {
    final List<Vocabulary> groupVocabs = widget.vocabularies.where((voc) {
      bool matchesSearch =
          voc.german.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              voc.english.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesGroup =
          Provider.of<GlobalState>(context).selectedGroup == 'Alle' ||
              (voc.group != null &&
                  voc.group == Provider.of<GlobalState>(context).selectedGroup);
      return matchesSearch && matchesGroup;
    }).toList();
    final int total = groupVocabs.length;
    int count0 = 0, count1_2 = 0, count3_4 = 0, countAbove4 = 0;
    for (var voc in groupVocabs) {
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

  /// Baut die Vokabel-Card.
  /// Falls keine Vokabel gefunden wurde (entsprechend der Filter),
  /// wird eine Card mit dem Hinweis "Keine Vokabel für diese Gruppe mit diesem Level gefunden" angezeigt.
  Widget buildVocabularyCard() {
    if (currentVocabulary == null) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              "Keine Vokabel für diese Gruppe mit diesem Level gefunden",
              style: const TextStyle(fontSize: 16, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    Vocabulary voc = currentVocabulary!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        initiallyExpanded: showExample,
        trailing: showExample ? null : const SizedBox.shrink(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: askGerman
                  ? FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                      voc.german,
                      'assets/flags/de.jpg',
                      'de-DE',
                      onLongPress: _speakText,
                    )
                  : FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                      voc.english,
                      'assets/flags/en.jpg',
                      'en-US',
                      onLongPress: _speakText,
                    ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: askGerman
                  ? FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                      voc.germanSentence,
                      '',
                      'de-DE',
                      onLongPress: _speakText,
                    )
                  : FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                      voc.englishSentence,
                      '',
                      'en-US',
                      onLongPress: _speakText,
                    ),
            ),
          ],
        ),
        children: [
          FractionallySizedBox(
            widthFactor: 0.75,
            alignment: Alignment.centerLeft,
            child: const Divider(thickness: 1, color: Colors.grey),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: askGerman
                      ? FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                          voc.english,
                          'assets/flags/en.jpg',
                          'en-US',
                          onLongPress: _speakText,
                        )
                      : FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                          voc.german,
                          'assets/flags/de.jpg',
                          'de-DE',
                          onLongPress: _speakText,
                        ),
                ),
                const SizedBox(height: 1),
                Container(
                  alignment: Alignment.centerLeft,
                  child: askGerman
                      ? FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                          voc.englishSentence,
                          '',
                          'en-US',
                          onLongPress: _speakText,
                        )
                      : FlagHelper.buildFlagTextRowWithSpeakerLongPress(
                          voc.germanSentence,
                          '',
                          'de-DE',
                          onLongPress: _speakText,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildResultCard() {
    if (quizState == NewQuizState.correctAnswer) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 130,
                child: const Text(
                  'Deine Antwort:',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.green[100],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2.0, vertical: 1.0),
                  child: Text(
                    answerController.text,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Nur so hoch wie nötig
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 130,
                    child: const Text(
                      'Deine Antwort:',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.red[100],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2.0, vertical: 1.0),
                      child: Text(
                        answerController.text,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 130,
                    child: const Text(
                      'Richtige Antwort:',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.green[100],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2.0, vertical: 1.0),
                      child: Text(
                        askGerman
                            ? currentVocabulary?.english ?? ''
                            : currentVocabulary?.german ?? '',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget buildAnswerInput(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final TextStyle answerTextStyle = TextStyle(
      fontSize: 16,
      color: showExample
          ? (quizState == NewQuizState.correctAnswer
              ? Colors.green
              : Colors.red)
          : Colors.black,
    );
    const contentPadding = EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0);
    if (orientation == Orientation.landscape) {
      if (showExample) {
        // In Landscape: Bei angezeigter Antwort nur den Button anzeigen
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: ActionButton3(
                  text: '>',
                  onPressed: _nextQuestion,
                ),
              ),
            ],
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              Expanded(
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
                  textStyle: answerTextStyle,
                  contentPadding: contentPadding,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 50,
                height: 50,
                child: ActionButton3(
                  text: '>',
                  onPressed: showExample ? _nextQuestion : _handleAnswer,
                ),
              ),
            ],
          ),
        );
      }
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
          textStyle: answerTextStyle,
          contentPadding: contentPadding,
        ),
      );
    }
  }

  Widget buildFilterSection(BuildContext context, List<String> groups,
      Map<String, int> levels, Map<int, String> levelOptions) {
    final Orientation orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.portrait) {
      // Vertikale Anordnung: Dropdowns untereinander
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          children: [
            Row(
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
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Level:'),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _filterMode.value,
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _filterMode.value = newValue;
                          activeVocabulary = null;
                          quizState = NewQuizState.waitingForAnswer;
                          _inputEnabled = true;
                          answerController.clear();
                        });
                      }
                    },
                    items: levelOptions.entries.map((entry) {
                      // Bei -1: "Alle" -> alle Vokabeln der Gruppe
                      // Bei 0: nur Level 0, etc.
                      final String label = entry.value;
                      final int count = entry.key == -1
                          ? levels['total'] ?? 0
                          : levels[getLevelKey(entry.key)] ?? 0;
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text('$label ($count)'),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // Horizontale Anordnung in Landscape: Wie bisher in einer Row
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
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
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  const Text('Level:'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _filterMode.value,
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _filterMode.value = newValue;
                            activeVocabulary = null;
                            quizState = NewQuizState.waitingForAnswer;
                            _inputEnabled = true;
                            answerController.clear();
                          });
                        }
                      },
                      items: levelOptions.entries.map((entry) {
                        final String label = entry.value;
                        final int count = entry.key == -1
                            ? levels['total'] ?? 0
                            : levels[getLevelKey(entry.key)] ?? 0;
                        return DropdownMenuItem<int>(
                          value: entry.key,
                          child: Text('$label ($count)'),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  /// Gibt den passenden Schlüssel für _computeLevels() zurück.
  /// -1 entspricht dabei "Alle" (keine Filterung, wird im Dropdown separat behandelt).
  String getLevelKey(int key) {
    switch (key) {
      case 0:
        return '0';
      case 1:
        return '1-2';
      case 2:
        return '3-4';
      case 3:
        return '>4';
      default:
        return 'total';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
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

    // _computeLevels() berücksichtigt ausschließlich Gruppe und Suchbegriff.
    final Map<String, int> levels = _computeLevels();
    // Level-Optionen: -1 = "Alle", 0 = "0", 1 = "1-2", 2 = "3-4", 3 = ">4"
    final Map<int, String> levelOptions = {
      -1: 'Alle',
      0: '0',
      1: '1-2',
      2: '3-4',
      3: '>4',
    };

    Widget mainContent;
    if (orientation == Orientation.landscape) {
      mainContent = Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: buildVocabularyCard()),
            if (showExample)
              Flexible(
                fit: FlexFit.loose,
                child: buildResultCard(),
              ),
          ],
        ),
      );
    } else {
      mainContent = Expanded(
        child: ListView(
          children: [
            buildVocabularyCard(),
            if (showExample)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildResultCard(),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter Section: Je nach Orientierung werden die Dropdowns anders angeordnet.
          buildFilterSection(context, groups, levels, levelOptions),
          // Hauptinhalt
          mainContent,
          // Eingabebereich: Bei Landscape wird das Inputfeld ausgeblendet, wenn eine Antwort angezeigt wird.
          if (!(orientation == Orientation.landscape && showExample))
            buildAnswerInput(context),
        ],
      ),
      bottomNavigationBar: orientation == Orientation.portrait
          ? Padding(
              padding: const EdgeInsets.all(16.0),
        child: ActionButton3(
          text: showExample ? 'Nächste Vokabel' : 'Antwort überprüfen',
          onPressed: showExample ? _nextQuestion : _handleAnswer,
        ),
            )
          : null,
    );
  }
}