import 'package:flutter/services.dart';

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.toLowerCase();
    return TextEditingValue(
      text: newText,
      selection: newValue.selection,
      composing: newText == newValue.text ? newValue.composing : TextRange.empty,
    );
  }
}