import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

class FirebaseRepository {
  final CollectionReference _collection =
  FirebaseFirestore.instance.collection('vocabularies');

  Future<void> saveOrUpdateVocabulary(Vocabulary voc) async {
    // Verwende die UUID als Dokument-ID
    final DocumentReference docRef = _collection.doc(voc.uuid);
    final DocumentSnapshot docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      // Aktualisieren
      await docRef.update(voc.toJson());
    } else {
      // Neu anlegen
      await docRef.set(voc.toJson());
    }
  }
}