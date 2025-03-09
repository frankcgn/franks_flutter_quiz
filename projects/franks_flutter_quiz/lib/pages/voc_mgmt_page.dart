// voc_mgmt_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/global_state.dart';
import '../models/vocabulary.dart';
import '../widgets/flag_helper_widget.dart';

typedef VocabularyCallback = void Function(Vocabulary voc);

class VocabularyManagementPage extends StatefulWidget {
  final List<Vocabulary> vocabularies;
  final VocabularyCallback onInsert;
  final VocabularyCallback onUpdate;
  final VocabularyCallback onDelete;

  const VocabularyManagementPage({
    super.key,
    required this.vocabularies,
    required this.onInsert,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  _VocabularyManagementPageState createState() =>
      _VocabularyManagementPageState();
}

class _VocabularyManagementPageState extends State<VocabularyManagementPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _german = '';
  String _english = '';
  String _englishSentence = '';
  String _germanSentence = '';
  String _group = '';
  String _searchQuery = '';

  FlutterTts flutterTts = FlutterTts();
  final Uuid uuidGenerator = Uuid();

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Neue Vokabel hinzufügen'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
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
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
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
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Beispielsatz Englisch',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => _englishSentence = value ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Beispielsatz Deutsch',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => _germanSentence = value ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Gruppe (optional)',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => _group = value ?? '',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Hinzufügen'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  String newUuid = uuidGenerator.v4();
                  Vocabulary voc = Vocabulary(
                    uuid: newUuid,
                    german: _german,
                    english: _english,
                    englishSentence: _englishSentence,
                    germanSentence: _germanSentence,
                    group: _group,
                  );
                  setState(() {
                    widget.vocabularies.add(voc);
                  });
                  widget.onInsert(voc);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Öffnet den Edit-Dialog für das ausgewählte Vocabulary.
  void _showEditDialogForVocabulary(Vocabulary voc) {
    int originalIndex =
        widget.vocabularies.indexWhere((v) => v.uuid == voc.uuid);
    if (originalIndex < 0) return;
    Vocabulary originalVoc = widget.vocabularies[originalIndex];
    final GlobalKey<FormState> editFormKey = GlobalKey<FormState>();
    String editedGerman = originalVoc.german;
    String editedEnglish = originalVoc.english;
    String editedEnglishSentence = originalVoc.englishSentence;
    String editedGermanSentence = originalVoc.germanSentence;
    String? editedGroup = originalVoc.group;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Vokabel bearbeiten'),
          content: Form(
            key: editFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: originalVoc.german,
                    decoration: const InputDecoration(
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
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: originalVoc.english,
                    decoration: const InputDecoration(
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
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: originalVoc.englishSentence,
                    decoration: const InputDecoration(
                      labelText: 'Beispielsatz Englisch',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => editedEnglishSentence = value,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: originalVoc.germanSentence,
                    decoration: const InputDecoration(
                      labelText: 'Beispielsatz Deutsch',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => editedGermanSentence = value,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: originalVoc.group ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Gruppe (optional)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => editedGroup = value,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Abbrechen'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Speichern'),
              onPressed: () {
                if (editFormKey.currentState!.validate()) {
                  Vocabulary updatedVoc = Vocabulary(
                    uuid: originalVoc.uuid,
                    german: editedGerman,
                    english: editedEnglish,
                    englishSentence: editedEnglishSentence,
                    germanSentence: editedGermanSentence,
                    creationDate: originalVoc.creationDate,
                    deToEnCounter: originalVoc.deToEnCounter,
                    deToEnLastQuery: originalVoc.deToEnLastQuery,
                    enToDeCounter: originalVoc.enToDeCounter,
                    enToDeLastQuery: originalVoc.enToDeLastQuery,
                    group: editedGroup,
                  );
                  _updateVocabularyByUUID(updatedVoc);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Aktualisiert das Vocabulary anhand der UUID.
  void _updateVocabularyByUUID(Vocabulary updatedVoc) {
    int idx = widget.vocabularies.indexWhere((v) => v.uuid == updatedVoc.uuid);
    if (idx >= 0) {
      setState(() {
        widget.vocabularies[idx] = updatedVoc;
      });
      widget.onUpdate(updatedVoc);
      debugPrint('Updated vocabulary with uuid: ${updatedVoc.uuid}');
    }
  }

  /// Löscht ein Vocabulary anhand seiner UUID.
  void _deleteVocabularyByUUID(String uuid) {
    int originalIndex = widget.vocabularies.indexWhere((v) => v.uuid == uuid);
    if (originalIndex < 0) return;
    Vocabulary voc = widget.vocabularies[originalIndex];
    widget.onDelete(voc);
    setState(() {
      widget.vocabularies.removeAt(originalIndex);
    });
    debugPrint('Deleted vocabulary with uuid: $uuid');
  }

  Future<void> _speakText(String text, String language) async {
    await flutterTts.setLanguage(language);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    // Ermitteln aller vorhandenen Gruppen
    final List<String> groups = widget.vocabularies
        .map((voc) => voc.group ?? '')
        .where((g) => g.isNotEmpty)
        .toSet()
        .toList();
    groups.sort();

    // Falls der globale Filterwert nicht in den Gruppen vorhanden ist, setze ihn auf "Alle".
    if (!groups.contains(Provider.of<GlobalState>(context).selectedGroup)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<GlobalState>(context, listen: false)
            .setSelectedGroup('Alle');
      });
    }

    // Filtere die Vokabeln anhand von Suche und Gruppenfilter.
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

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const SizedBox.shrink(),
      ),
      body: Column(
        children: [
          // Dropdown für den Gruppenfilter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gruppe:'),
                DropdownButton<String>(
                  isExpanded: true,
                  value: Provider.of<GlobalState>(context).selectedGroup,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      Provider.of<GlobalState>(context, listen: false)
                          .setSelectedGroup(newValue);
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
              ],
            ),
          ),
          // Suchfeld
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Suche (Deutsch oder Englisch)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Liste der gefilterten Vokabeln
          Expanded(
            child: ListView.builder(
              itemCount: filteredVocabs.length,
              itemBuilder: (context, index) {
                Vocabulary voc = filteredVocabs[index];
                return Dismissible(
                  key: Key(voc.uuid),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _deleteVocabularyByUUID(voc.uuid);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vokabel gelöscht')),
                    );
                  },
                  child: GestureDetector(
                    onDoubleTap: () => _showEditDialogForVocabulary(voc),
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ExpansionTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Zeile mit deutscher Vokabel, Flagge und Speaker
                            FlagHelper.buildFlagTextRowWithSpeaker(
                              voc.german,
                              'assets/flags/de.jpg',
                              'de-DE',
                            ),
                            // Zeile mit englischer Vokabel, Flagge und Speaker
                            FlagHelper.buildFlagTextRowWithSpeaker(
                              voc.english,
                              'assets/flags/en.jpg',
                              'en-US',
                            ),
                          ],
                        ),
                        children: [
                          // Divider, der nur 75% der Breite einnimmt und von links beginnt
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
                                // Englischer Beispielsatz mit Flagge und Speaker
                                FlagHelper.buildFlagTextRowWithSpeaker(
                                  voc.englishSentence,
                                  'assets/flags/en.jpg',
                                  'en-US',
                                ),
                                const SizedBox(height: 1),
                                // Deutscher Beispielsatz mit Flagge und Speaker
                                FlagHelper.buildFlagTextRowWithSpeaker(
                                  voc.germanSentence,
                                  'assets/flags/de.jpg',
                                  'de-DE',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}