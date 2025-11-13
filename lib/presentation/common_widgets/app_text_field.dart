import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable text field widget with consistent styling across the app.
///
/// Provides a Material Design text field with customizable decoration,
/// validation, and input formatters.
class AppTextField extends StatelessWidget {
  const AppTextField({
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.expands = false,
    this.textAlignVertical,
    super.key,
  });

  /// Controller for the text field.
  final TextEditingController? controller;

  /// Focus node for the text field.
  final FocusNode? focusNode;

  /// Label text displayed above the text field.
  final String? labelText;

  /// Hint text displayed inside the text field when empty.
  final String? hintText;

  /// Helper text displayed below the text field.
  final String? helperText;

  /// Error text displayed below the text field.
  final String? errorText;

  /// Icon displayed at the start of the text field.
  final Widget? prefixIcon;

  /// Icon displayed at the end of the text field.
  final Widget? suffixIcon;

  /// Whether to obscure the text (for passwords).
  final bool obscureText;

  /// Whether the text field is read-only.
  final bool readOnly;

  /// Whether the text field is enabled.
  final bool enabled;

  /// Maximum number of lines.
  final int? maxLines;

  /// Minimum number of lines.
  final int? minLines;

  /// Maximum length of the input.
  final int? maxLength;

  /// Keyboard type for the text field.
  final TextInputType? keyboardType;

  /// Text input action for the keyboard.
  final TextInputAction? textInputAction;

  /// Input formatters to restrict/format input.
  final List<TextInputFormatter>? inputFormatters;

  /// Callback when the text changes.
  final ValueChanged<String>? onChanged;

  /// Callback when the user submits the text.
  final ValueChanged<String>? onSubmitted;

  /// Validator function for form validation.
  final FormFieldValidator<String>? validator;

  /// Whether the text field should expand to fill available space.
  final bool expands;

  /// Vertical alignment of the text.
  final TextAlignVertical? textAlignVertical;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      readOnly: readOnly,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      expands: expands,
      textAlignVertical: textAlignVertical,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
