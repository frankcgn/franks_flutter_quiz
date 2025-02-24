// widgets/wrong_answer_container.dart
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class WrongAnswerContainer extends StatelessWidget {
  final String expectedAnswer;
  final double height;

  const WrongAnswerContainer({
    Key? key,
    required this.expectedAnswer,
    this.height = 60.0,
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
        child: AutoSizeText(
          expectedAnswer,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: Colors.blue),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
