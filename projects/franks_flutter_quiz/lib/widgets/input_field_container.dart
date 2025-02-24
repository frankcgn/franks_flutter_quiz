// widgets/input_field_container.dart
import 'package:flutter/material.dart';

class InputFieldContainer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final Color borderColor;
  final Function(String) onSubmitted;
  final TextStyle? textStyle;

  const InputFieldContainer({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.borderColor,
    required this.onSubmitted,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 3),
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
        decoration: const InputDecoration(
          hintText: 'Deine Antwort',
          contentPadding: EdgeInsets.all(12),
          border: InputBorder.none,
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: onSubmitted,
      ),
    );
  }
}
