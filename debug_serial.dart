import "package:flutter/services.dart";
import "package:pattern_input_formatter/pattern_input_formatter.dart";

void main() {
  final formatter = PatternInputFormatter(patterns: ["AAAA-####-aa"]);

  // Simulate typing "PROD"
  const oldValue = TextEditingValue.empty;
  const newValue = TextEditingValue(
    text: "PROD",
    selection: TextSelection.collapsed(offset: 4),
  );

  final result = formatter.formatEditUpdate(oldValue, newValue);
  print("Input: \"${newValue.text}\"");
  print("Output: \"${result.text}\"");
  print("Expected cursor: 5");
  print("Actual cursor: ${result.selection.baseOffset}");
}
