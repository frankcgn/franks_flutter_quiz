import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  final bool noLoginPage = false;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _username = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Hier die eigentliche Login-Logik einfügen, z. B. mit Firebase:
      // await FirebaseAuth.instance.signInWithEmailAndPassword(
      //   email: _username,
      //   password: _password,
      // );

      // Firebase-Anmeldung
      // UserCredential userCredential = await FirebaseAuth.instance
      //     .signInWithEmailAndPassword(
      //     email: _emailController.text.trim(),
      //     password: _passwordController.text);
      // Bei Erfolg weiterleiten:

      // Für dieses Beispiel simulieren wir einen Netzwerkaufruf:
      await Future.delayed(const Duration(seconds: 2));

      // Bei Erfolg: Navigation zur Hauptseite
      //Navigator.pushReplacementNamed(context, '/home');
      if (_username.toLowerCase() == 'frank' ||
          _username.toLowerCase() == 'julia') {
        Navigator.pushReplacementNamed(context, '/home-authorized');
      } else {
        throw Exception("Die Benutzerdaten sind nicht korrekt.");
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Login fehlgeschlagen: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(automaticallyImplyLeading: false, title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Benutzername',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Bitte gib deinen Benutzernamen ein';
                        }
                        return null;
                      },
                      onSaved: (value) => _username = value!.trim(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Passwort',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bitte gib dein Passwort ein';
                        }
                        if (value.length < 6) {
                          return 'Passwort muss mindestens 6 Zeichen lang sein';
                        }
                        return null;
                      },
                      onSaved: (value) => _password = value!,
                    ),
                    const SizedBox(height: 24),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _login,
                            child: const Text('Anmelden'),
                          ),
                    // Registrieren-Button:
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text('Registrieren'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
