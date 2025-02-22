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

  Stream<QuerySnapshot> getVocabularies() {
    return _vocabularyRef.snapshots();
  }

  void addVocabulary(Vocabulary voc) async {
    _vocabularyRef.add(voc);
  }


}
