// pages/settings_page.dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart'; // Import für Firebase
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/appSettings.dart';
import '../models/vocabulary.dart'; // Stelle sicher, dass dein Vocabulary-Modell das Feld "uuid" enthält.

class SettingsPage extends StatefulWidget {
  final AppSettings settings;
  final Function(AppSettings) onSettingsChanged;

  const SettingsPage({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool darkMode;
  late TextEditingController interval3Controller;
  late TextEditingController interval4Controller;
  late TextEditingController interval5Controller;

  // Uuid-Generator, um für importierte Vokabeln eindeutige IDs zu erzeugen.
  final Uuid uuidGenerator = Uuid();

  @override
  void initState() {
    super.initState();
    darkMode = widget.settings.darkMode;
    interval3Controller =
        TextEditingController(text: widget.settings.intervalFor3.toString());
    interval4Controller =
        TextEditingController(text: widget.settings.intervalFor4.toString());
    interval5Controller =
        TextEditingController(text: widget.settings.intervalFor5.toString());
  }

  @override
  void dispose() {
    interval3Controller.dispose();
    interval4Controller.dispose();
    interval5Controller.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final int interval3 = int.tryParse(interval3Controller.text) ?? 7;
    final int interval4 = int.tryParse(interval4Controller.text) ?? 14;
    final int interval5 = int.tryParse(interval5Controller.text) ?? 28;
    final AppSettings newSettings = AppSettings(
      darkMode: darkMode,
      intervalFor3: interval3,
      intervalFor4: interval4,
      intervalFor5: interval5,
    );
    widget.onSettingsChanged(newSettings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Einstellungen gespeichert.')),
    );
  }

  /// Importiert CSV-Daten per Dateiauswahl (wie bisher).
  Future<void> _importCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        File file = File(filePath);
        String csvString = await file.readAsString();
        _parseAndImportCSV(csvString);
      }
    }
  }

  /// Öffnet einen Dialog, in dem CSV-Daten in ein Textfeld eingegeben werden können.
  Future<void> _importCSVFromText() async {
    TextEditingController csvController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('CSV-Daten eingeben'),
          content: TextField(
            controller: csvController,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Hier CSV-Daten einfügen...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialog schließen
              },
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                String csvString = csvController.text;
                Navigator.of(context).pop();
                _parseAndImportCSV(csvString);
              },
              child: const Text('Importieren'),
            ),
          ],
        );
      },
    );
  }

  /// Parst den CSV-Text, erstellt daraus Vokabel-Objekte und speichert sie in der Datenbank.
  Future<void> _parseAndImportCSV(String csvString) async {
    // CSV parsen mit Semikolon als Trenner
    List<List<dynamic>> csvTable =
        const CsvToListConverter(fieldDelimiter: ';', eol: '\n')
            .convert(csvString);

    // Wenn eine Kopfzeile vorhanden ist, überspringe sie.
    List<List<dynamic>> rows = csvTable;
    if (csvTable.isNotEmpty &&
        csvTable[0].isNotEmpty &&
        csvTable[0][0].toString().toLowerCase().contains("german")) {
      rows = csvTable.sublist(1);
    }

    List<Vocabulary> importedVocabs = [];
    for (var row in rows) {
      // Annahme: Spalte 0: German, 1: English, 2: GermanSentence, 3: EnglishSentence, 4: Gruppe (optional)
      String german = row.length > 0 ? row[0].toString() : "";
      String english = row.length > 1 ? row[1].toString() : "";
      String germanSentence = row.length > 2 ? row[2].toString() : "";
      String englishSentence = row.length > 3 ? row[3].toString() : "";
      String group = row.length > 4 ? row[4].toString() : "";
      // Generiere eine neue UUID
      String newUuid = uuidGenerator.v4();
      Vocabulary voc = Vocabulary(
        uuid: newUuid,
        german: german,
        english: english,
        germanSentence: germanSentence,
        englishSentence: englishSentence,
        group: group,
      );
      importedVocabs.add(voc);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('Es wurden ${importedVocabs.length} Vokabeln importiert.')),
    );
    for (var voc in importedVocabs) {
      print('Imported: ${voc.german} (uuid: ${voc.uuid})');
    }
    // Speichere die importierten Vokabeln in der Datenbank (z.B. Firestore)
    for (var voc in importedVocabs) {
      await FirebaseFirestore.instance
          .collection('vocabularies')
          .doc(voc.uuid)
          .set(voc.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          SwitchListTile(
            title: const Text('Darkmode'),
            value: darkMode,
            onChanged: (val) {
              setState(() {
                darkMode = val;
              });
              _saveSettings();
            },
          ),
          const SizedBox(height: 16),
          const Text('Intervall für 3 richtige Antworten (Tage):'),
          TextField(
            controller: interval3Controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          const Text('Intervall für 4 richtige Antworten (Tage):'),
          TextField(
            controller: interval4Controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          const Text('Intervall für 5 (oder mehr) richtige Antworten (Tage):'),
          TextField(
            controller: interval5Controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('Einstellungen speichern'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _importCSV,
            child: const Text('Vokabeln aus CSV importieren (Datei)'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _importCSVFromText,
            child: const Text('CSV-Daten aus Textfeld importieren'),
          ),
        ],
      ),
    );
  }
}