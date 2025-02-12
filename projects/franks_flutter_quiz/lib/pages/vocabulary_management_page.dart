// pages/vocabulary_management_page.dart
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

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Neue Vokabel hinzufügen'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    autocorrect: false,
                    enableSuggestions: false,
                    textCapitalization: TextCapitalization.none,
                    decoration: const InputDecoration(
                      labelText: 'Deutsch',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Bitte ein deutsches Wort eingeben'
                        : null,
                    onSaved: (value) => _german = value!,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    autocorrect: false,
                    enableSuggestions: false,
                    textCapitalization: TextCapitalization.none,
                    decoration: const InputDecoration(
                      labelText: 'Englisch',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Bitte ein englisches Wort eingeben'
                        : null,
                    onSaved: (value) => _english = value!,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    autocorrect: false,
                    enableSuggestions: false,
                    textCapitalization: TextCapitalization.none,
                    decoration: const InputDecoration(
                      labelText: 'Beispielsatz Englisch',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Bitte einen englischen Beispielsatz eingeben'
                        : null,
                    onSaved: (value) => _englishSentence = value!,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    autocorrect: false,
                    enableSuggestions: false,
                    textCapitalization: TextCapitalization.none,
                    decoration: const InputDecoration(
                      labelText: 'Beispielsatz Deutsch',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Bitte einen deutschen Beispielsatz eingeben'
                        : null,
                    onSaved: (value) => _germanSentence = value!,
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
    final GlobalKey<FormState> _editFormKey = GlobalKey<FormState>();
    String editedGerman = voc.german;
    String editedEnglish = voc.english;
    String editedEnglishSentence = voc.englishSentence;
    String editedGermanSentence = voc.germanSentence;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Vokabel bearbeiten'),
          content: Form(
            key: _editFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: voc.german,
                    autocorrect: false,
                    enableSuggestions: false,
                    textCapitalization: TextCapitalization.none,
                    decoration: const InputDecoration(
                      labelText: 'Deutsch',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Bitte ein deutsches Wort eingeben'
                        : null,
                    onChanged: (value) => editedGerman = value,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: voc.english,
                    autocorrect: false,
                    enableSuggestions: false,
                    textCapitalization: TextCapitalization.none,
                    decoration: const InputDecoration(
                      labelText: 'Englisch',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Bitte ein englisches Wort eingeben'
                        : null,
                    onChanged: (value) => editedEnglish = value,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: voc.englishSentence,
                    autocorrect: false,
                    enableSuggestions: false,
                    textCapitalization: TextCapitalization.none,
                    decoration: const InputDecoration(
                      labelText: 'Beispielsatz Englisch',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Bitte einen englischen Beispielsatz eingeben'
                        : null,
                    onChanged: (value) => editedEnglishSentence = value,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: voc.germanSentence,
                    autocorrect: false,
                    enableSuggestions: false,
                    textCapitalization: TextCapitalization.none,
                    decoration: const InputDecoration(
                      labelText: 'Beispielsatz Deutsch',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Bitte einen deutschen Beispielsatz eingeben'
                        : null,
                    onChanged: (value) => editedGermanSentence = value,
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
          final Vocabulary voc = widget.vocabularies[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              title: Text('${voc.german} - ${voc.english}'),
              subtitle: Text(
                'Erstellt: ${formatDate(voc.creationDate)}\n'
                'Deutsch → Englisch: ${voc.deToEnCounter} (Letzte: ${voc.deToEnLastQuery != null ? formatDate(voc.deToEnLastQuery!) : "nie"})\n'
                'Englisch → Deutsch: ${voc.enToDeCounter} (Letzte: ${voc.enToDeLastQuery != null ? formatDate(voc.enToDeLastQuery!) : "nie"})',
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditDialog(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteVocabulary(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _showAddDialog,
      ),
    );
  }
}