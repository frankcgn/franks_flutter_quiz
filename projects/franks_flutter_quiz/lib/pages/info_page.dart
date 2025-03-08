// pages/info_page.dart
import 'package:flutter/material.dart';

import '../models/appSettings.dart';
import 'home_page.dart';

class InfoPage extends StatefulWidget {
  final AppSettings settings;
  final Function(AppSettings) onSettingsChanged;

  const InfoPage(
      {super.key, required this.settings, required this.onSettingsChanged});

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> with WidgetsBindingObserver {
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomePage(
          settings: widget.settings,
          onSettingsChanged: widget.onSettingsChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToHome,
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
                'Version:\n20250308-001',
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