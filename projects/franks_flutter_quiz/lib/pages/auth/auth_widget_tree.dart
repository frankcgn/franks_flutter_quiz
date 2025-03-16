// auth_widget_tree.dart
import 'package:flutter/material.dart';

import '../../models/appSettings.dart';
import 'auth.dart';
import 'auth_home_page.dart';
import 'auth_login_register_page.dart';

class AuthWidgetTree extends StatefulWidget {
  // ohne Parameter
/*  const AuthWidgetTree({Key? key}) : super(key: key);

  @override
  _AuthWidgetTreeState createState() => _AuthWidgetTreeState();
*/

// mit Parameter
  final AppSettings settings;
  final Function(AppSettings) onSettingsChanged;

  const AuthWidgetTree(
      {super.key, required this.settings, required this.onSettingsChanged});

  @override
  _AuthWidgetTreeState createState() => _AuthWidgetTreeState();
}

class _AuthWidgetTreeState extends State<AuthWidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return AuthHomePage();
          // return const HomePage(
          //     settings: settings,
          //     onSettingsChanged: onSettingsChanged);
        } else {
          return const AuthLoginPage();
        }
      },
    );
  }
}
