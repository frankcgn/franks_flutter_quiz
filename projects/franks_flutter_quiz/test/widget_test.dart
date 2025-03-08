import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

// Hilfsfunktionen zum Formatieren und Parsen von Datumsangaben im Format dd.MM.yyyy
String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.'
         '${date.month.toString().padLeft(2, '0')}.'
         '${date.year}';
}

DateTime parseDate(String dateStr) {
  final parts = dateStr.split('.');
  int day = int.parse(parts[0]);
  int month = int.parse(parts[1]);
  int year = int.parse(parts[2]);
  return DateTime(year, month, day);
}

// WIRD AKTUELL NICHT VERWENDET
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vokabel Trainer',
      restorationScopeId: 'app3', // restorationScopeId festlegen
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

// --- Vocabulary-Klasse ---
// Neben den Basisdaten gibt es:
// - creationDate: Wird beim Erstellen gesetzt.
// - deToEnCounter & deToEnLastQuery: für Deutsch → Englisch
// - enToDeCounter & enToDeLastQuery: für Englisch → Deutsch
class Vocabulary {
  final String german;
  final String english;
  final String englishSentence;
  final String germanSentence;
  final DateTime creationDate;

  int deToEnCounter;
  DateTime? deToEnLastQuery;

  int enToDeCounter;
  DateTime? enToDeLastQuery;

  Vocabulary({
    required this.german,
    required this.english,
    required this.englishSentence,
    required this.germanSentence,
    DateTime? creationDate,
    this.deToEnCounter = 0,
    this.deToEnLastQuery,
    this.enToDeCounter = 0,
    this.enToDeLastQuery,
  }) : creationDate = creationDate ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'german': german,
        'english': english,
        'englishSentence': englishSentence,
        'germanSentence': germanSentence,
        'creationDate': formatDate(creationDate),
        'deToEnCounter': deToEnCounter,
        'deToEnLastQuery': deToEnLastQuery != null ? formatDate(deToEnLastQuery!) : null,
        'enToDeCounter': enToDeCounter,
        'enToDeLastQuery': enToDeLastQuery != null ? formatDate(enToDeLastQuery!) : null,
      };

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      german: json['german'] as String,
      english: json['english'] as String,
      englishSentence: json['englishSentence'] as String,
      germanSentence: json['germanSentence'] as String,
      creationDate: json['creationDate'] != null ? parseDate(json['creationDate'] as String) : DateTime.now(),
      deToEnCounter: json['deToEnCounter'] is int ? json['deToEnCounter'] as int : 0,
      deToEnLastQuery: json['deToEnLastQuery'] != null ? parseDate(json['deToEnLastQuery'] as String) : null,
      enToDeCounter: json['enToDeCounter'] is int ? json['enToDeCounter'] as int : 0,
      enToDeLastQuery: json['enToDeLastQuery'] != null ? parseDate(json['enToDeLastQuery'] as String) : null,
    );
  }
}

// --- Initiale Vokabeln der 5. Schulklasse ---
// Falls die Datei noch leer ist, werden diese Vokabeln inklusive Beispielsätzen gesetzt.
List<Vocabulary> initialVocabularyFor5thGrade() {
  return [
    Vocabulary(
      german: "Apfel",
      english: "apple",
      englishSentence: "I ate an apple.",
      germanSentence: "Ich aß einen Apfel.",
    ),
    Vocabulary(
      german: "Banane",
      english: "banana",
      englishSentence: "She likes a banana.",
      germanSentence: "Sie mag eine Banane.",
    ),
    Vocabulary(
      german: "Schule",
      english: "school",
      englishSentence: "The children go to school.",
      germanSentence: "Die Kinder gehen zur Schule.",
    ),
    Vocabulary(
      german: "Freund",
      english: "friend",
      englishSentence: "He is my friend.",
      germanSentence: "Er ist mein Freund.",
    ),
    Vocabulary(
      german: "Haus",
      english: "house",
      englishSentence: "They built a house.",
      germanSentence: "Sie bauten ein Haus.",
    ),
    Vocabulary(
      german: "Tisch",
      english: "table",
      englishSentence: "The table is wooden.",
      germanSentence: "Der Tisch ist aus Holz.",
    ),
    Vocabulary(
      german: "Stuhl",
      english: "chair",
      englishSentence: "I sat on the chair.",
      germanSentence: "Ich saß auf dem Stuhl.",
    ),
    Vocabulary(
      german: "Buch",
      english: "book",
      englishSentence: "She reads a book.",
      germanSentence: "Sie liest ein Buch.",
    ),
    Vocabulary(
      german: "Lampe",
      english: "lamp",
      englishSentence: "The lamp is bright.",
      germanSentence: "Die Lampe ist hell.",
    ),
    Vocabulary(
      german: "Auto",
      english: "car",
      englishSentence: "He drives a car.",
      germanSentence: "Er fährt ein Auto.",
    ),
  ];
}

// --- Storage-Klasse ---
// Lädt/Speichert die Vokabeln als JSON in einer Datei (im Dokumentenverzeichnis; für iCloud muss in Xcode zusätzlich konfiguriert werden).
class VocabularyStorage {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/vocabularies.json');
  }

  static Future<List<Vocabulary>> loadVocabularies() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        return jsonList.map((jsonItem) => Vocabulary.fromJson(jsonItem)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveVocabularies(List<Vocabulary> vocabularies) async {
    final file = await _localFile;
    final List<Map<String, dynamic>> jsonList = vocabularies.map((v) => v.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
  }
}

// --- HomePage ---
// Lädt beim Start die Vokabeln (und fügt initial die 5. Schulklasse-Vokabeln hinzu, falls die Datei leer ist) und bietet Navigation zwischen Verwaltung und Quiz.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Vocabulary> vocabularies = [];

  @override
  void initState() {
    super.initState();
    _loadVocabularies();
  }

  Future<void> _loadVocabularies() async {
    final loadedVocab = await VocabularyStorage.loadVocabularies();
    if (loadedVocab.isEmpty) {
      loadedVocab.addAll(initialVocabularyFor5thGrade());
      await VocabularyStorage.saveVocabularies(loadedVocab);
    }
    setState(() {
      vocabularies = loadedVocab;
    });
  }

  Future<void> _saveVocabularies() async {
    await VocabularyStorage.saveVocabularies(vocabularies);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
          onUpdate: _saveVocabularies,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vokabel Trainer'),
      ),
      body: _pages()[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: 'Vokabeln'),
          NavigationDestination(icon: Icon(Icons.quiz), label: 'Quiz'),
        ],
      ),
    );
  }
}

// --- Verwaltung der Vokabeln ---
// Neben dem Hinzufügen, Bearbeiten und Löschen werden jetzt auch die Beispielsätze bearbeitet.
// Im ListTile werden zusätzlich das Erstellungsdatum und beide Richtungs-Zähler samt letzter Abfrage angezeigt.
class VocabularyManagementPage extends StatefulWidget {
  final List<Vocabulary> vocabularies;
  final VoidCallback onUpdate;

  const VocabularyManagementPage(
      {super.key, required this.vocabularies, required this.onUpdate});

  @override
  _VocabularyManagementPageState createState() => _VocabularyManagementPageState();
}

class _VocabularyManagementPageState extends State<VocabularyManagementPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _german = '';
  String _english = '';
  String _englishSentence = '';
  String _germanSentence = '';

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Neue Vokabel hinzufügen'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Deutsch',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte ein deutsches Wort eingeben';
                      }
                      return null;
                    },
                    onSaved: (value) => _german = value!,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Englisch',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte ein englisches Wort eingeben';
                      }
                      return null;
                    },
                    onSaved: (value) => _english = value!,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Beispielsatz Englisch',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte einen englischen Beispielsatz eingeben';
                      }
                      return null;
                    },
                    onSaved: (value) => _englishSentence = value!,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Beispielsatz Deutsch',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte einen deutschen Beispielsatz eingeben';
                      }
                      return null;
                    },
                    onSaved: (value) => _germanSentence = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Hinzufügen'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  setState(() {
                    widget.vocabularies.add(Vocabulary(
                      german: _german,
                      english: _english,
                      englishSentence: _englishSentence,
                      germanSentence: _germanSentence,
                    ));
                  });
                  widget.onUpdate();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(int index) {
    Vocabulary voc = widget.vocabularies[index];
    final GlobalKey<FormState> editFormKey = GlobalKey<FormState>();
    String editedGerman = voc.german;
    String editedEnglish = voc.english;
    String editedEnglishSentence = voc.englishSentence;
    String editedGermanSentence = voc.germanSentence;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Vokabel bearbeiten'),
          content: Form(
            key: editFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: voc.german,
                    decoration: InputDecoration(
                      labelText: 'Deutsch',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte ein deutsches Wort eingeben';
                      }
                      return null;
                    },
                    onChanged: (value) => editedGerman = value,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    initialValue: voc.english,
                    decoration: InputDecoration(
                      labelText: 'Englisch',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte ein englisches Wort eingeben';
                      }
                      return null;
                    },
                    onChanged: (value) => editedEnglish = value,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    initialValue: voc.englishSentence,
                    decoration: InputDecoration(
                      labelText: 'Beispielsatz Englisch',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte einen englischen Beispielsatz eingeben';
                      }
                      return null;
                    },
                    onChanged: (value) => editedEnglishSentence = value,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    initialValue: voc.germanSentence,
                    decoration: InputDecoration(
                      labelText: 'Beispielsatz Deutsch',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte einen deutschen Beispielsatz eingeben';
                      }
                      return null;
                    },
                    onChanged: (value) => editedGermanSentence = value,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Speichern'),
              onPressed: () {
                if (editFormKey.currentState!.validate()) {
                  setState(() {
                    widget.vocabularies[index] = Vocabulary(
                      german: editedGerman,
                      english: editedEnglish,
                      englishSentence: editedEnglishSentence,
                      germanSentence: editedGermanSentence,
                      creationDate: voc.creationDate,
                      deToEnCounter: voc.deToEnCounter,
                      deToEnLastQuery: voc.deToEnLastQuery,
                      enToDeCounter: voc.enToDeCounter,
                      enToDeLastQuery: voc.enToDeLastQuery,
                    );
                  });
                  widget.onUpdate();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteVocabulary(int index) {
    setState(() {
      widget.vocabularies.removeAt(index);
    });
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: widget.vocabularies.length,
        itemBuilder: (context, index) {
          Vocabulary voc = widget.vocabularies[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              title: Text('${voc.german} - ${voc.english}'),
              subtitle: Text(
                'Erstellt: ${formatDate(voc.creationDate)}\n'
                'Deutsch → Englisch: ${voc.deToEnCounter} (Letzte: ${voc.deToEnLastQuery != null ? formatDate(voc.deToEnLastQuery!) : "nie"})\n'
                'Englisch → Deutsch: ${voc.enToDeCounter} (Letzte: ${voc.enToDeLastQuery != null ? formatDate(voc.enToDeLastQuery!) : "nie"})'
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _showEditDialog(index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteVocabulary(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

// --- Quiz-Seite ---
// Es gibt einen Toggle zwischen den beiden Abfragerichtungen:
// Bei "Deutsch → Englisch" wird die deutsche Vokabel mit dem deutschen Beispielsatz angezeigt,
// und es wird die englische Übersetzung abgefragt, wobei deToEnCounter und deToEnLastQuery aktualisiert werden.
// Bei "Englisch → Deutsch" wird analog die englische Vokabel samt Beispielsatz angezeigt.
enum QuizState { waitingForAnswer, wrongAnswer, correctAnswer }

class QuizPage extends StatefulWidget {
  final List<Vocabulary> vocabularies;
  final VoidCallback onUpdate;

  const QuizPage(
      {super.key, required this.vocabularies, required this.onUpdate});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentIndex = 0;
  TextEditingController answerController = TextEditingController();
  QuizState quizState = QuizState.waitingForAnswer;
  // true: Abfrage Deutsch → Englisch, false: Englisch → Deutsch
  bool askGerman = true;

  Vocabulary? get currentVocabulary {
    if (widget.vocabularies.isEmpty) return null;
    return widget.vocabularies[currentIndex % widget.vocabularies.length];
  }

  void _handleAnswer() {
    if (currentVocabulary == null) return;
    String givenAnswer = answerController.text.trim();
    String expectedAnswer;
    if (askGerman) {
      // Deutsch → Englisch: Es wird die englische Übersetzung erwartet.
      expectedAnswer = currentVocabulary!.english;
    } else {
      // Englisch → Deutsch: Es wird die deutsche Übersetzung erwartet.
      expectedAnswer = currentVocabulary!.german;
    }
    if (givenAnswer.toLowerCase() == expectedAnswer.toLowerCase()) {
      setState(() {
        if (askGerman) {
          if (quizState == QuizState.wrongAnswer) {
            currentVocabulary!.deToEnCounter = 1;
          } else {
            currentVocabulary!.deToEnCounter++;
          }
          currentVocabulary!.deToEnLastQuery = DateTime.now();
        } else {
          if (quizState == QuizState.wrongAnswer) {
            currentVocabulary!.enToDeCounter = 1;
          } else {
            currentVocabulary!.enToDeCounter++;
          }
          currentVocabulary!.enToDeLastQuery = DateTime.now();
        }
        quizState = QuizState.correctAnswer;
      });
      widget.onUpdate();
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          answerController.clear();
          quizState = QuizState.waitingForAnswer;
          currentIndex++;
        });
      });
    } else {
      setState(() {
        if (askGerman) {
          currentVocabulary!.deToEnCounter = 0;
          currentVocabulary!.deToEnLastQuery = DateTime.now();
        } else {
          currentVocabulary!.enToDeCounter = 0;
          currentVocabulary!.enToDeLastQuery = DateTime.now();
        }
        quizState = QuizState.wrongAnswer;
      });
      widget.onUpdate();
    }
  }

  void _toggleQuizDirection() {
    setState(() {
      askGerman = !askGerman;
      answerController.clear();
      quizState = QuizState.waitingForAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.vocabularies.isEmpty) {
      return Center(child: Text('Keine Vokabeln vorhanden. Bitte füge welche hinzu.'));
    }
    Vocabulary currentVoc = currentVocabulary!;
    String questionText;
    String exampleText;
    String expectedAnswer;
    if (askGerman) {
      questionText = currentVoc.german;
      exampleText = currentVoc.germanSentence;
      expectedAnswer = currentVoc.english;
    } else {
      questionText = currentVoc.english;
      exampleText = currentVoc.englishSentence;
      expectedAnswer = currentVoc.german;
    }
    Color borderColor;
    if (quizState == QuizState.correctAnswer) {
      borderColor = Colors.green;
    } else if (quizState == QuizState.wrongAnswer) {
      borderColor = Colors.red;
    } else {
      borderColor = Colors.grey;
    }

    // Anzeige des aktuellen Zählers und der letzten Abfrage, je nach Richtung
    String counterText = askGerman
        ? 'Deutsch → Englisch: ${currentVoc.deToEnCounter} (Letzte: ${currentVoc.deToEnLastQuery != null ? formatDate(currentVoc.deToEnLastQuery!) : "nie"})'
        : 'Englisch → Deutsch: ${currentVoc.enToDeCounter} (Letzte: ${currentVoc.enToDeLastQuery != null ? formatDate(currentVoc.enToDeLastQuery!) : "nie"})';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                askGerman
                    ? 'Was ist die englische Übersetzung von:'
                    : 'Was ist die deutsche Übersetzung von:',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                questionText,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Beispielsatz:',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                exampleText,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: answerController,
                  decoration: InputDecoration(
                    hintText: askGerman
                        ? 'Deine Antwort (englisches Wort)'
                        : 'Deine Antwort (deutsches Wort)',
                    contentPadding: EdgeInsets.all(12),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (value) => _handleAnswer(),
                ),
              ),
              if (quizState == QuizState.wrongAnswer)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Falsch! Richtige Antwort: $expectedAnswer',
                    style: TextStyle(color: Colors.red, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleAnswer,
                child: Text('Antwort überprüfen'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _toggleQuizDirection,
                child: Text('Quiz Richtung wechseln'),
              ),
              SizedBox(height: 20),
              Text(
                counterText,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
