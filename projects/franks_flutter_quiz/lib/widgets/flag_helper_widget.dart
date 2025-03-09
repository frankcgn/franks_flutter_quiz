import 'package:flutter/material.dart';

class FlagHelper {
  /// Gibt ein Widget zurück, das die passende Flagge basierend auf dem
  /// übergebenen Gruppenwert anzeigt.
  ///
  /// - Wenn der Gruppenwert "de" (oder ähnlich) enthält, wird die Deutschland-Flagge verwendet.
  /// - Wenn er "en" (oder ähnlich) enthält, wird die Großbritannien-Flagge verwendet.
  /// - Ansonsten wird ein Standard-Icon angezeigt.
  static Widget buildFlagIcon(String? group) {
    if (group != null) {
      final lower = group.toLowerCase();
      if (lower.contains('de')) {
        return Image.asset(
          'assets/flags/de.jpg',
          width: 32,
          height: 32,
        );
      } else if (lower.contains('en')) {
        return Image.asset(
          'assets/flags/en.jpg',
          width: 32,
          height: 32,
        );
      }
    }
    return const Icon(Icons.flag, size: 32);
  }

  static Widget buildFlagTextRow(String text, String flagAsset) {
    return Row(
      children: [
        Image.asset(
          flagAsset,
          width: 24,
          height: 24,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }
}
