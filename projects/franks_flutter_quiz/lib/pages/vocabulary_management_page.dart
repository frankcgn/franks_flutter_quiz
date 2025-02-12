// vocabulary_management_page.dart
import 'package:flutter/material.dart';
import '../models.dart';

class VocabularyManagementPage extends StatefulWidget {
  final List<Vocabulary> vocabularies;
  final VoidCallback onUpdate;
  VocabularyManagementPage({required this.vocabularies, required this.onUpdate});

  @override
  _VocabularyManagementPageState createState() => _VocabularyManagementPageState();
}

class _VocabularyManagementPageState extends State<VocabularyManagementPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _german = '';
  String _english = '';
  String _englishSentence = '';
  String _germanSentence = '';
  String? _group; // Neue Variable für die Gruppe

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
                      if (value == null || value.isEmpty)
                        return 'Bitte ein deutsches Wort eingeben';
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
                      if (value == null || value.isEmpty)
                        return 'Bitte ein englisches Wort eingeben';
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
                      if (value == null || value.isEmpty)
                        return 'Bitte einen englischen Beispielsatz eingeben';
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
                      if (value == null || value.isEmpty)
                        return 'Bitte einen deutschen Beispielsatz eingeben';
                      return null;
                    },
                    onSaved: (value) => _germanSentence = value!,
                  ),
                  SizedBox(height: 12),
                  // Neues Feld für die Gruppe (optional)
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Gruppe (optional)',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => _group = value,
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
                  setState(() {
                    widget.vocabularies.add(Vocabulary(
                      german: _german,
                      english: _english,
                      englishSentence: _englishSentence,
                      germanSentence: _germanSentence,
                      group: _group, // Gruppe übernehmen
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
                      if (value == null || value.isEmpty)
                        return 'Bitte ein deutsches Wort eingeben';
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
                      if (value == null || value.isEmpty)
                        return 'Bitte ein englisches Wort eingeben';
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
                      if (value == null || value.isEmpty)
                        return 'Bitte einen englischen Beispielsatz eingeben';
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
                      if (value == null || value.isEmpty)
                        return 'Bitte einen deutschen Beispielsatz eingeben';
                      return null;
                    },
                    onChanged: (value) => editedGermanSentence = value,
                  ),
                  SizedBox(height: 12),
                  // Neues Feld für die Gruppe
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
                      group: editedGroup, // Gruppe übernehmen
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
                      'Gruppe: ${voc.group ?? "keine"}\n'
                      'Deutsch → Englisch: ${voc.deToEnCounter} (Letzte: ${voc.deToEnLastQuery != null ? formatDate(voc.deToEnLastQuery!) : "nie"})\n'
                      'Englisch → Deutsch: ${voc.enToDeCounter} (Letzte: ${voc.enToDeLastQuery != null ? formatDate(voc.enToDeLastQuery!) : "nie"})'
              ),
              isThreeLine: true,
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: _showAddDialog,
      ),
    );
  }
}