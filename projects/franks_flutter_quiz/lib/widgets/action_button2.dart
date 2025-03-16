// widgets/action_button.dart
import 'package:flutter/material.dart';

class ActionButton2 extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ActionButton2({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple, // Moderne Farbe
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Abgerundete Ecken
        ),
        elevation: 4, // Leichte Schattenwirkung
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
