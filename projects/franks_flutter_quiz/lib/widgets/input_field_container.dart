// widgets/input_field_container.dart
import 'package:flutter/material.dart';

class InputFieldContainer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final Color borderColor;
  final Function(String) onSubmitted;
  final TextStyle? textStyle;
  final EdgeInsets? contentPadding;

  const InputFieldContainer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.borderColor,
    required this.onSubmitted,
    this.textStyle,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 40, // Höhe des Antwortfeldes
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        enabled: enabled,
        focusNode: focusNode,
        autocorrect: false,
        enableSuggestions: false,
        textCapitalization: TextCapitalization.none,
        controller: controller,
        textAlign: TextAlign.center,
        style: textStyle ?? Theme.of(context).textTheme.headlineSmall,
        decoration: InputDecoration(
          hintText: 'Deine Antwort',
          contentPadding: contentPadding,
          border: InputBorder.none,
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
