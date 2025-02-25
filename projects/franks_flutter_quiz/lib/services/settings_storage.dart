// settings_storage.dart
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../models/appSettings.dart';

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