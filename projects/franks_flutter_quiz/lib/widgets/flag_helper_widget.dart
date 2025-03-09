import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FlagHelper {
  static final FlutterTts flutterTts = FlutterTts();

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

  static Widget buildFlagTextRowWithSpeaker(
      String text, String flagAsset, String language,
      {double leftPadding = 16.0}) {
    return GestureDetector(
      onLongPress: () {
        _speakText(text, language);
        // Hier wird der Callback nicht direkt ausgeführt,
        // sondern der aufrufende Code (z.B. in der voc_mgmt_page) übernimmt den _speakText-Aufruf.
        // Alternativ kannst Du hier auch direkt eine globale Methode aufrufen.
      },
      child: Container(
        padding: EdgeInsets.only(left: leftPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              flagAsset,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
                //maxLines: 1,
                //overflow: TextOverflow.ellipsis,
                softWrap:
                    true, // Erlaubt den Umbruch, sodass der Text vollständig angezeigt wird
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildFlagTextRowWithSpeakerLongPress(
    String text,
    String? flagAsset,
    String language, {
    double leftPadding = 16.0,
    required Function(String, String) onLongPress,
  }) {
    // Erstelle eine Liste der Widgets, die in der Zeile erscheinen sollen.
    final List<Widget> rowChildren = [];

    if (flagAsset != null && flagAsset.isNotEmpty) {
      rowChildren.add(
        Image.asset(
          flagAsset,
          width: 24,
          height: 24,
        ),
      );
      rowChildren.add(const SizedBox(width: 4));
    }

    rowChildren.add(
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 16),
          softWrap: true,
        ),
      ),
    );

    return GestureDetector(
      onLongPress: () => onLongPress(text, language),
      child: Container(
        padding: EdgeInsets.only(left: leftPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          // Flagge und Text oben ausgerichtet
          mainAxisSize: MainAxisSize.min,
          children: rowChildren,
        ),
      ),
    );
  }

  static Future<void> _speakText(String text, String language) async {
    await flutterTts.setLanguage(language);
    await flutterTts.speak(text);
  }
}
