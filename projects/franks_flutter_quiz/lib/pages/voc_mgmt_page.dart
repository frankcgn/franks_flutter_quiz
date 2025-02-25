// voc_mgmt_page.dart
import 'package:flutter/material.dart';

import '../models/vocabulary.dart';

typedef VocabularyCallback = void Function(Vocabulary voc);

class VocabularyManagementPage extends StatefulWidget {
  final List<Vocabulary> vocabularies;
  final VocabularyCallback onInsert;
  final VocabularyCallback onUpdate;
  final VocabularyCallback onDelete;

  VocabularyManagementPage(
      {required this.vocabularies,
      required this.onInsert,
      required this.onUpdate,
      required this.onDelete});

  @override
  _VocabularyManagementPageState createState() => _VocabularyManagementPageState();
}

class _VocabularyManagementPageState extends State<VocabularyManagementPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _german = '';
  String _english = '';
  String _englishSentence = '';
  String _germanSentence = '';
  String _group = '';
  String _searchQuery = '';

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
                      if (value == null || value.isEmpty) return 'Bitte ein deutsches Wort eingeben';
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
                      if (value == null || value.isEmpty) return 'Bitte ein englisches Wort eingeben';
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
                      if (value == null || value.isEmpty) return 'Bitte einen englischen Beispielsatz eingeben';
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
                      if (value == null || value.isEmpty) return 'Bitte einen deutschen Beispielsatz eingeben';
                      return null;
                    },
                    onSaved: (value) => _germanSentence = value!,
                  ),
                  SizedBox(height: 12),
                  // Optionales Feld für den Gruppennamen
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Gruppe (optional)',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => _group = value!,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(child: Text('Abbrechen'), onPressed: () => Navigator.of(context).pop(),),
            ElevatedButton(
              child: Text('Hinzufügen'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Vocabulary voc = Vocabulary(
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

  void _showEditDialog(int index) {
    Vocabulary voc = widget.vocabularies[index];
    final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();
    String editedGerman = voc.german;
    String editedEnglish = voc.english;
    String editedEnglishSentence = voc.englishSentence;
    String editedGermanSentence = voc.germanSentence;
    String? editedGroup = voc.group;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Vokabel bearbeiten'),
          content: Form(
            key: _editFormKey,
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
                      if (value == null || value.isEmpty) return 'Bitte ein deutsches Wort eingeben';
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
                      if (value == null || value.isEmpty) return 'Bitte ein englisches Wort eingeben';
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
                      if (value == null || value.isEmpty) return 'Bitte einen englischen Beispielsatz eingeben';
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
                      if (value == null || value.isEmpty) return 'Bitte einen deutschen Beispielsatz eingeben';
                      return null;
                    },
                    onChanged: (value) => editedGermanSentence = value,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    initialValue: voc.group ?? '',
                    decoration: InputDecoration(
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
            TextButton(child: Text('Abbrechen'), onPressed: () => Navigator.of(context).pop(),),
            ElevatedButton(
              child: Text('Speichern'),
              onPressed: () {
                if (_editFormKey.currentState!.validate()) {
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
                      group: editedGroup,
                    );
                  });
                  widget.onUpdate(voc);
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
    Vocabulary voc = widget.vocabularies[index];
    widget.onDelete(voc);
    widget.vocabularies.removeAt(index);
  }

  @override
  Widget build(BuildContext context) {
    // Filtere die Vokabelliste anhand des Suchbegriffs.
    List<Vocabulary> filteredVocabs = widget.vocabularies.where((voc) {
      return voc.german.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          voc.english.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Vokabeln verwalten'),
      ),
      body: Column(
        children: [
          // Suchfeld
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
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
          // Gefilterte Liste der Vokabeln, wobei der deutsche und englische Begriff untereinander angezeigt werden.
          Expanded(
            child: ListView.builder(
              itemCount: filteredVocabs.length,
              itemBuilder: (context, index) {
                Vocabulary voc = filteredVocabs[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    title: Text(
                      '${voc.german}\n${voc.english}',
                      textAlign: TextAlign.start,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.edit), onPressed: () => _showEditDialog(index),),
                        IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteVocabulary(index),),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddDialog,
      ),
    );
  }
}