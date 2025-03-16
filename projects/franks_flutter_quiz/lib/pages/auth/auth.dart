import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithUserAndPassword({
    required String email,
    required String password,
  }) async {
    debugPrint('Auth: signInWithUserAndPassword ${email} - ${password}');
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> createUserWithEmailAndPasswort({
    required String email,
    required String password,
  }) async {
    debugPrint('Auth: createUserWithEmailAndPasswort ${email} - ${password}');
    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
