// models.dart
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum QuizState { waitingForAnswer, wrongAnswer, correctAnswer }

class AppSettings {
  bool darkMode;
  int intervalFor3;
  int intervalFor4;
  int intervalFor5;

  AppSettings({
    this.darkMode = false,
    this.intervalFor3 = 7,
    this.intervalFor4 = 14,
    this.intervalFor5 = 28,
  });

  Map<String, dynamic> toJson() => {
    'darkMode': darkMode,
    'intervalFor3': intervalFor3,
    'intervalFor4': intervalFor4,
    'intervalFor5': intervalFor5,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    darkMode: json['darkMode'] ?? false,
    intervalFor3: json['intervalFor3'] ?? 7,
    intervalFor4: json['intervalFor4'] ?? 14,
    intervalFor5: json['intervalFor5'] ?? 28,
  );
}
