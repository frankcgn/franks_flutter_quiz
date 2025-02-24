// widgets/action_button.dart
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;

  const ActionButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.height = 60.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double? fontSize = Theme.of(context).textTheme.headlineSmall?.fontSize;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          minimumSize: Size(double.infinity, height),
        ),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontSize: fontSize, color: Colors.white),
        ),
      ),
    );
  }
}
