// pages/info_page.dart
import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> with WidgetsBindingObserver {
  void _navigate() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigate,
      child: Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Entwickler:\nFrank Rollmann',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.black),
              ),
              const SizedBox(height: 16),
              Text(
                'Version:\n20250309-001',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}