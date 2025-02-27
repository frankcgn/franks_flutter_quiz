import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  final Map<String, int> stats;
  final bool darkMode;
  final int selectedFilterIndex; // Aktueller Filter, übergeben vom Parent
  final ValueChanged<int> onFilterSelected; // Callback zum Setzen des Filters

  const StatusBar({
    super.key,
    required this.stats,
    required this.darkMode,
    required this.selectedFilterIndex,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> statusTexts = [
      'Alle: ${stats['total']}',
      '0: ${stats['0']}',
      '1-2: ${stats['1-2']}',
      '3-4: ${stats['3-4']}',
      '>4: ${stats['>4']}',
    ];
    // Schlüssel zur Zuordnung des Wertes aus stats
    final List<String> statKeys = ['total', '0', '1-2', '3-4', '>4'];

    List<Widget> buttonWidgets = [];
    for (int i = 0; i < statusTexts.length; i++) {
      final String text = statusTexts[i];
      // Button deaktivieren, wenn der zugehörige Wert 0 ist.
      final bool isDisabled = stats[statKeys[i]] == 0;
      buttonWidgets.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: isDisabled
                  ? null
                  : () {
                      onFilterSelected(i);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.zero,
                fixedSize: const Size.fromHeight(24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: isDisabled
                      ? const BorderSide(color: Colors.yellow, width: 2)
                      : (selectedFilterIndex == i
                          ? BorderSide(color: Colors.blue.shade900, width: 2)
                          : BorderSide.none),
                ),
              ),
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    maxLines: 1,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: buttonWidgets,
      ),
    );
  }
}