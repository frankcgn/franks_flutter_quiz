// vocabulary_list.dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test_01/services/database_service.dart';
import '../models/vocabulary.dart';



Future<List<Vocabulary>> initialVocabularyFromDB() async {
  print('initialVocabularyFromDB');
  final vocabularyList = await getVocabularyList(FirebaseFirestore.instance.collection(TODO_COLLETION_REF).snapshots());
  print('Alle Vokabeln geladen');
  return vocabularyList;
}

Future<List<Vocabulary>> getVocabularyList(Stream<QuerySnapshot> querySnapshotStream) async {
  final querySnapshot = await querySnapshotStream.first;
  return querySnapshot.docs.map((doc) {
    return Vocabulary.fromJson(doc.data() as Map<String, dynamic>);
  }).toList();
}

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