// global_state.dart
//setzt globale variablen wir den Gruppenfilter
import 'package:flutter/material.dart';

class GlobalState extends ChangeNotifier {
  String _selectedGroup = 'Alle';

  String get selectedGroup => _selectedGroup;

  void setSelectedGroup(String newValue) {
    if (_selectedGroup != newValue) {
      _selectedGroup = newValue;
      notifyListeners();
    }
  }
}
