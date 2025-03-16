// auth_login_register_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_01/pages/auth/auth.dart';

class AuthLoginPage extends StatefulWidget {
  const AuthLoginPage({Key? key}) : super(key: key);

  @override
  _AuthLoginPageState createState() => _AuthLoginPageState();
}

class _AuthLoginPageState extends State<AuthLoginPage> {
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  bool isLogin = false;
  String? errorMessage = '';

  Future<void> signInWithUserAndPassword() async {
    try {
      await Auth().signInWithUserAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage:
        e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPasswort(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage:
        e.message;
      });
    }
  }

  Widget _title() {
    return const Text('Firebase Login or Register');
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
      ),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? 'kein error' : '$errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
        onPressed: isLogin
            ? signInWithUserAndPassword
            : createUserWithEmailAndPassword,
        child: Text(isLogin ? 'Login' : 'Register'));
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(isLogin ? 'Register instead' : 'login instead'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, title: _title()),
      body: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _entryField('email', _controllerEmail),
              _entryField('password', _controllerPassword),
              _errorMessage(),
              _submitButton(),
              _loginOrRegisterButton()
            ],
          )),
    );
  }
}
