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

  // AKTUELL OHNE SPEAKER - Der Abstand der Zeilen ist zu groß
  static Widget buildFlagTextRowWithSpeaker(
      String text, String flagAsset, String language) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          flagAsset,
          width: 24,
          height: 24,
        ),
        const SizedBox(width: 4), // Minimaler horizontaler Abstand
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  static Widget buildFlagTextRowWithSpeaker2(
      String text, String flagAsset, String language) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          flagAsset,
          width: 24,
          height: 24,
        ),
        const SizedBox(width: 4), // Minimaler horizontaler Abstand
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.volume_up, size: 16.0),
          onPressed: () => _speakText(text, language),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: 'Sprich den Text aus',
        ),
      ],
    );
  }

  static Widget buildFlagTextRowWithSpeaker4(
      String text, String flagAsset, String language,
      {double leftPadding = 16.0}) {
    return Container(
      padding: EdgeInsets.only(left: leftPadding),
      // gleicher Padding-Wert für beide Fälle
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up, size: 16.0),
            onPressed: () {
              // Diese Funktion wird in der aufrufenden Klasse implementiert,
              // daher hier nur ein Platzhalter:
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Sprich den Text aus',
          ),
        ],
      ),
    );
  }

  static Future<void> _speakText(String text, String language) async {
    await flutterTts.setLanguage(language);
    await flutterTts.speak(text);
  }
}
