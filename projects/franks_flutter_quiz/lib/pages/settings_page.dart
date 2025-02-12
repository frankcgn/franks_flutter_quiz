// pages/settings_page.dart
import 'package:flutter/material.dart';
import '../models.dart';

class SettingsPage extends StatefulWidget {
  final AppSettings settings;
  final Function(AppSettings) onSettingsChanged;
  final Function(String) onSaveVocabularyList;
  final Future<void> Function(String) onLoadVocabularyList;
  SettingsPage({
    required this.settings,
    required this.onSettingsChanged,
    required this.onSaveVocabularyList,
    required this.onLoadVocabularyList,
  });

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool darkMode;
  late TextEditingController interval3Controller;
  late TextEditingController interval4Controller;
  late TextEditingController interval5Controller;
  
  @override
  void initState() {
    super.initState();
    darkMode = widget.settings.darkMode;
    interval3Controller = TextEditingController(text: widget.settings.intervalFor3.toString());
    interval4Controller = TextEditingController(text: widget.settings.intervalFor4.toString());
    interval5Controller = TextEditingController(text: widget.settings.intervalFor5.toString());
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
  
  Future<void> _showSaveDialog() async {
    String fileName = "";
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Vokabelliste speichern'),
          content: TextField(
            decoration: const InputDecoration(
              labelText: 'Dateiname (ohne .json)',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              fileName = value;
            },
          ),
          actions: [
            TextButton(child: const Text('Abbrechen'), onPressed: () => Navigator.of(context).pop(),),
            ElevatedButton(
              child: const Text('Speichern'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    if (fileName.isNotEmpty) {
      widget.onSaveVocabularyList(fileName);
    }
  }
  
  Future<void> _showLoadDialog() async {
    String fileName = "";
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Vokabelliste laden'),
          content: TextField(
            decoration: const InputDecoration(
              labelText: 'Dateiname (ohne .json)',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              fileName = value;
            },
          ),
          actions: [
            TextButton(child: const Text('Abbrechen'), onPressed: () => Navigator.of(context).pop(),),
            ElevatedButton(
              child: const Text('Laden'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    if (fileName.isNotEmpty) {
      await widget.onLoadVocabularyList(fileName);
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
              _saveSettings(); // Speichert die neuen Einstellungen und löst Theme-Aktualisierung aus.
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
            onPressed: _showSaveDialog,
            child: const Text('Vokabelliste speichern'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _showLoadDialog,
            child: const Text('Vokabelliste laden'),
          ),
        ],
      ),
    );
  }
  
}