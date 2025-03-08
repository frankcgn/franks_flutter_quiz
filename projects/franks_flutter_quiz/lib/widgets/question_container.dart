// widgets/question_container.dart
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class QuestionContainer extends StatelessWidget {
  final String questionText;
  final double height;

  const QuestionContainer({
    super.key,
    required this.questionText,
    this.height = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 3),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: AutoSizeText(
        questionText,
        style: Theme.of(context).textTheme.headlineSmall,
        maxLines: 1,
        textAlign: TextAlign.center,
      ),
    );
  }
}
