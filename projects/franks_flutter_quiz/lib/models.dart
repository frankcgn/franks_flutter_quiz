// models.dart
import 'package:uuid/uuid.dart';
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

// models.dart

/// Beispielhafte Hilfsfunktionen zum Formatieren/Parsen von Datumsangaben
String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';
}

DateTime parseDate(String dateStr) {
  final parts = dateStr.split('.');
  return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
}

class Vocabulary {
  final String uuid; // UUID statt einfachem ID-Feld
  final String german;
  final String english;
  final String englishSentence;
  final String germanSentence;
  final DateTime creationDate;
  final String? group; // Optionaler Gruppenname

  int deToEnCounter;
  DateTime? deToEnLastQuery;
  int enToDeCounter;
  DateTime? enToDeLastQuery;

  Vocabulary({
    String? uuid,
    required this.german,
    required this.english,
    required this.englishSentence,
    required this.germanSentence,
    DateTime? creationDate,
    this.deToEnCounter = 0,
    this.deToEnLastQuery,
    this.enToDeCounter = 0,
    this.enToDeLastQuery,
    this.group,
  })  : uuid = uuid ?? Uuid().v4(), // Falls keine UUID übergeben wurde, generiere eine neue.
        creationDate = creationDate ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'german': german,
    'english': english,
    'englishSentence': englishSentence,
    'germanSentence': germanSentence,
    'creationDate': formatDate(creationDate),
    'deToEnCounter': deToEnCounter,
    'deToEnLastQuery': deToEnLastQuery != null ? formatDate(deToEnLastQuery!) : null,
    'enToDeCounter': enToDeCounter,
    'enToDeLastQuery': enToDeLastQuery != null ? formatDate(enToDeLastQuery!) : null,
    'group': group,
  };

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      uuid: json['uuid'] as String?, // Falls null, wird im Konstruktor automatisch eine neue UUID erzeugt.
      german: json['german'] as String,
      english: json['english'] as String,
      englishSentence: json['englishSentence'] as String,
      germanSentence: json['germanSentence'] as String,
      creationDate: json['creationDate'] != null ? parseDate(json['creationDate'] as String) : DateTime.now(),
      deToEnCounter: json['deToEnCounter'] is int ? json['deToEnCounter'] as int : 0,
      deToEnLastQuery: json['deToEnLastQuery'] != null ? parseDate(json['deToEnLastQuery'] as String) : null,
      enToDeCounter: json['enToDeCounter'] is int ? json['enToDeCounter'] as int : 0,
      enToDeLastQuery: json['enToDeLastQuery'] != null ? parseDate(json['enToDeLastQuery'] as String) : null,
      group: json['group'] as String?,
    );
  }
}

