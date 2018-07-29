import 'package:flutter/services.dart';

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue,
      TextEditingValue newValue) {
    return new TextEditingValue(
        text: newValue.text?.toLowerCase(),
        selection: newValue.selection,
    );
  }
}