// widgets/wrong_answer_container.dart
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class WrongAnswerContainer extends StatelessWidget {
  final String expectedAnswer;
  final double height;
  final VoidCallback onPressed;

  // FlutterTts-Instanz initialisieren
  final FlutterTts flutterTts = FlutterTts();

  WrongAnswerContainer({
    Key? key,
    required this.expectedAnswer,
    this.height = 45.0,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 3),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Row(
          children: [
            Expanded(
              child: AutoSizeText(
                expectedAnswer,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up, size: 16.0),
              onPressed: () => _speakEnglish(expectedAnswer),
              tooltip: 'Sprich die Vokabel aus',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _speakEnglish(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak(text);
  }
}