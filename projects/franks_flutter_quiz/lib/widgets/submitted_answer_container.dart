// widgets/submitted_answer_container.dart
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class SubmittedAnswerContainer extends StatelessWidget {
  final String answerText;
  final Color borderColor;
  final double height;

  const SubmittedAnswerContainer({
    super.key,
    required this.answerText,
    required this.borderColor,
    this.height = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 3),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: AutoSizeText(
          answerText,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: borderColor),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
