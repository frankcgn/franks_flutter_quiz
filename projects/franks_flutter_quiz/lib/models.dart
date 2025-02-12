// models.dart
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

class Vocabulary {
  final String german;
  final String english;
  final String englishSentence;
  final String germanSentence;
  final DateTime creationDate;
  final String? group; // Neuer Gruppennamen (optional)

  int deToEnCounter;
  DateTime? deToEnLastQuery;
  int enToDeCounter;
  DateTime? enToDeLastQuery;

  Vocabulary({
    required this.german,
    required this.english,
    required this.englishSentence,
    required this.germanSentence,
    DateTime? creationDate,
    this.deToEnCounter = 0,
    this.deToEnLastQuery,
    this.enToDeCounter = 0,
    this.enToDeLastQuery,
    this.group, // Neuer Parameter für den Gruppennamen
  }) : creationDate = creationDate ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'german': german,
    'english': english,
    'englishSentence': englishSentence,
    'germanSentence': germanSentence,
    'creationDate': formatDate(creationDate),
    'deToEnCounter': deToEnCounter,
    'deToEnLastQuery': deToEnLastQuery != null ? formatDate(deToEnLastQuery!) : null,
    'enToDeCounter': enToDeCounter,
    'enToDeLastQuery': enToDeLastQuery != null ? formatDate(enToDeLastQuery!) : null,
    'group': group, // Neuer JSON-Eintrag
  };

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      german: json['german'] as String,
      english: json['english'] as String,
      englishSentence: json['englishSentence'] as String,
      germanSentence: json['germanSentence'] as String,
      creationDate: json['creationDate'] != null ? parseDate(json['creationDate'] as String) : DateTime.now(),
      deToEnCounter: json['deToEnCounter'] is int ? json['deToEnCounter'] as int : 0,
      deToEnLastQuery: json['deToEnLastQuery'] != null ? parseDate(json['deToEnLastQuery'] as String) : null,
      enToDeCounter: json['enToDeCounter'] is int ? json['enToDeCounter'] as int : 0,
      enToDeLastQuery: json['enToDeLastQuery'] != null ? parseDate(json['enToDeLastQuery'] as String) : null,
      group: json['group'] as String?, // Neuer Gruppennamen
    );
  }
}

/// Hilfsfunktionen zum Formatieren und Parsen von Daten.
/// Diese können ggf. auch in utilities.dart ausgelagert werden.
String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

DateTime parseDate(String dateStr) {
  final parts = dateStr.split('.');
  return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
}