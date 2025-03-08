// widgets/speak_buttons_row.dart
import 'package:flutter/material.dart';

class SpeakButtonsRow extends StatelessWidget {
  final VoidCallback onSpeakVocabulary;
  final VoidCallback onSpeakSentence;

  const SpeakButtonsRow({
    super.key,
    required this.onSpeakVocabulary,
    required this.onSpeakSentence,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 16.0,
              icon: const Icon(Icons.volume_up),
              onPressed: onSpeakVocabulary,
              tooltip: 'Sprich die Vokabel aus',
            ),
            const Text("Vokabel"),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 16.0,
              icon: const Icon(Icons.volume_up),
              onPressed: onSpeakSentence,
              tooltip: 'Sprich den Beispielsatz aus',
            ),
            const Text("Beispielsatz"),
          ],
        ),
      ],
    );
  }
}
