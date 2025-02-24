// widgets/question_container.dart
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class QuestionContainer extends StatelessWidget {
  final String questionText;
  final double height;

  const QuestionContainer({
    Key? key,
    required this.questionText,
    this.height = 60.0,
  }) : super(key: key);

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
