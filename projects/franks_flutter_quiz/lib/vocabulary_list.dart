// vocabulary_list.dart
import 'package:flutter/services.dart' show rootBundle;
import 'models.dart';

Future<List<Vocabulary>> initialVocabulary() async {
  final String csvData = await rootBundle.loadString('assets/vocabulary.csv');
  List<Vocabulary> vocabList = [];
  final List<String> lines = csvData.split('\n');

  for (String line in lines) {
    line = line.trim();
    if (line.isEmpty) continue;
    List<String> parts = line.split(';');
    if (parts.length < 2) continue;
    final String english = parts[0].trim();
    final String german = parts[1].trim();
    final String englishSentence = parts.length >= 3 ? parts[2].trim() : '';
    final String germanSentence = parts.length >= 4 ? parts[3].trim() : '';
    vocabList.add(Vocabulary(
      german: german,
      english: english,
      englishSentence: englishSentence,
      germanSentence: germanSentence,
    ));
  }
  return vocabList;
}