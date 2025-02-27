import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../models/vocabulary.dart';

const String TODO_COLLETION_REF = "vocabularies"; // collection name in database

class DatabaseService {
  final logger = Logger();
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _vocabularyRef;

  DatabaseService() {
    _vocabularyRef = _firestore.collection(TODO_COLLETION_REF).withConverter<Vocabulary>(
        fromFirestore: (snapshots, _) => Vocabulary.fromJson(snapshots.data()!,),
        toFirestore: (Vocabulary, _) => Vocabulary.toJson());
  }

  // lädt die Vokabeln wenn gebraucht werden
  Stream<List<Vocabulary>> getVocabularyList(Stream<QuerySnapshot> querySnapshotStream) {
    return querySnapshotStream.map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Vocabulary.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // lädt alle Vokabeln auf einmal
  Future<List<Vocabulary>> getCompleteVocabularies() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection(TODO_COLLETION_REF).get();
    return snapshot.docs.map((doc) {
      return Vocabulary.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Stream<QuerySnapshot> getVocabularies() {
    return _vocabularyRef.snapshots();
  }

  void addOrUpdateVocabulary(Vocabulary voc) {
    if (voc.uuid.isEmpty) {
      addVocabulary(voc);
    } else {
      updateVocabulary(voc.uuid, voc);
    }
  }

  void addVocabulary(Vocabulary voc) async {
    logger.d('ADD: VOC: ${voc.german}');
    _vocabularyRef.add(voc);
  }

  void updateVocabulary(String vocId, Vocabulary voc) {
    logger.d('UPDATE: VOC: ${voc.german}');
    _vocabularyRef.doc(vocId).update(voc.toJson());
  }

  void deleteVocabulary(String vocId) {
    logger.d('DELETE: VOC: $vocId');
    _vocabularyRef.doc(vocId).delete();
  }
}
