// widgets/status_bar.dart
import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  final Map<String, int> stats;
  final bool darkMode;

  const StatusBar({
    Key? key,
    required this.stats,
    required this.darkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> statusTexts = [
      'Alle: ${stats['total']}',
      '0: ${stats['0']}',
      '1-2: ${stats['1-2']}',
      '3-4: ${stats['3-4']}',
      '>4: ${stats['>4']}'
    ];

    List<Widget> statusWidgets = [];
    for (int i = 0; i < statusTexts.length; i++) {
      statusWidgets.add(Text(
        statusTexts[i],
        style: TextStyle(color: darkMode ? Colors.white : Colors.black),
      ));
      if (i < statusTexts.length - 1) {
        statusWidgets.add(Text(
          ' | ',
          style: TextStyle(color: darkMode ? Colors.white : Colors.black),
        ));
      }
    }
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: darkMode ? Colors.black : Colors.grey[200],
        border: darkMode ? Border.all(color: Colors.grey) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: statusWidgets,
      ),
    );
  }
}
