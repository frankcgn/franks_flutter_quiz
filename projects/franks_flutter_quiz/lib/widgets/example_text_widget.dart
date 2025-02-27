// widgets/example_text_widget.dart
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ExampleTextWidget extends StatelessWidget {
  final String exampleText;
  final TextStyle textStyle;
  final bool isEmptyExample;
  final bool askGerman;

  const ExampleTextWidget({
    super.key,
    required this.exampleText,
    required this.textStyle,
    required this.isEmptyExample,
    required this.askGerman,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Beispielsatz:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        AutoSizeText(
          exampleText,
          style: textStyle,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
