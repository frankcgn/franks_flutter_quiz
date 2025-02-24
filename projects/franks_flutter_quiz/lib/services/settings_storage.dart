// settings_storage.dart
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../models/appSettings.dart';
import '../../models/vocabulary.dart';

class SettingsStorage {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/settings.json');
  }

  static Future<AppSettings> loadSettings() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final jsonMap = json.decode(contents);
        return AppSettings.fromJson(jsonMap);
      }
    } catch (e) {}
    return AppSettings();
  }

  static Future<void> saveSettings(AppSettings settings) async {
    final file = await _localFile;
    await file.writeAsString(json.encode(settings.toJson()));
  }
}

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
      }
    } catch (e) {}
    return [];
  }

  static Future<void> saveVocabularies(List<Vocabulary> vocabularies) async {
    final file = await _localFile;
    final jsonList = vocabularies.map((v) => v.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
  }

  static Future<void> saveVocabulariesWithName(List<Vocabulary> vocabularies, String fileName) async {
    final path = await _localPath;
    final file = File('$path/$fileName.json');
    final jsonList = vocabularies.map((v) => v.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
  }

  static Future<List<Vocabulary>> loadVocabulariesWithName(String fileName) async {
    final path = await _localPath;
    final file = File('$path/$fileName.json');
    if (await file.exists()) {
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((jsonItem) => Vocabulary.fromJson(jsonItem)).toList();
    }
    return [];
  }
}