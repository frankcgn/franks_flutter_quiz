// widgets/example_text_widget.dart
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ExampleTextWidget extends StatelessWidget {
  final String exampleText;
  final TextStyle textStyle;
  final bool isEmptyExample;
  final bool askGerman;

  const ExampleTextWidget({
    Key? key,
    required this.exampleText,
    required this.textStyle,
    required this.isEmptyExample,
    required this.askGerman,
  }) : super(key: key);

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
