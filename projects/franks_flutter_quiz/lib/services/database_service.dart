import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appSettings.dart';
import '../models/vocabulary.dart';

const String TODO_COLLETION_REF = "vocabularies"; // collection name in database

class DatabaseService {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _vocabularyRef;

  DatabaseService() {
    _vocabularyRef = _firestore.collection(TODO_COLLETION_REF).withConverter<Vocabulary>(
        fromFirestore: (snapshots, _) => Vocabulary.fromJson(snapshots.data()!,),
        toFirestore: (Vocabulary, _) => Vocabulary.toJson());
  }



  Stream<List<Vocabulary>> getVocabularyList(Stream<QuerySnapshot> querySnapshotStream) {
    return querySnapshotStream.map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Vocabulary.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Stream<QuerySnapshot> getVocabularies() {
    return _vocabularyRef.snapshots();
  }

  void addVocabulary(Vocabulary voc) async {
    _vocabularyRef.add(voc);
  }

  void updateVocabulary(String vocId, Vocabulary voc) {
    _vocabularyRef.doc(vocId).update(voc.toJson());
  }

  void deleteVocabulary(String vocId) {
    _vocabularyRef.doc(vocId).delete();
  }
}
