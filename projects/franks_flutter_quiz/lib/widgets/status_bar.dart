import 'package:flutter/material.dart';

class LevelStatusBar extends StatelessWidget {
  final Map<String, int> levelCounter;
  final bool darkMode;
  final int selectedFilterIndex; // Aktueller Filter, übergeben vom Parent
  final ValueChanged<int> onFilterSelected; // Callback zum Setzen des Filters

  const LevelStatusBar({
    super.key,
    required this.levelCounter,
    required this.darkMode,
    required this.selectedFilterIndex,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> levelTexts = [
      'Alle: ${levelCounter['total']}',
      '0: ${levelCounter['0']}',
      '1-2: ${levelCounter['1-2']}',
      '3-4: ${levelCounter['3-4']}',
      '>4: ${levelCounter['>4']}',
    ];
    // Schlüssel zur Zuordnung des Wertes aus levels
    final List<String> levelsCategories = ['total', '0', '1-2', '3-4', '>4'];

    List<Widget> buttonWidgets = [];
    for (int i = 0; i < levelTexts.length; i++) {
      final String text = levelTexts[i];
      // Button deaktivieren, wenn der zugehörige Wert 0 ist.
      final bool isDisabled = levelCounter[levelsCategories[i]] == 0;
      buttonWidgets.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: ElevatedButton(
              onPressed: isDisabled
                  ? null
                  : () {
                      onFilterSelected(i);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                padding: EdgeInsets.zero,
                fixedSize: const Size.fromHeight(24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: isDisabled
                      ? const BorderSide(color: Colors.white, width: 2)
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