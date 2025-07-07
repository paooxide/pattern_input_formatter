// Debug trace for RH19K issue
import 'package:flutter/services.dart';
import 'lib/pattern_input_formatter_refactored.dart';

void main() {
  print('Debug trace for RH19K issue');

  final formatter = PatternInputFormatter(
    patterns: PatternInputFormatter.ukPostcodePatterns(),
    letterCase: LetterCase.upper,
    inputType: PatternInputType.postal,
  );

  // Test step by step
  final tests = ['RH19', 'RH19K'];

  for (final input in tests) {
    print('\n--- Testing input: "$input" ---');

    final oldValue = const TextEditingValue();
    final newValue = TextEditingValue(
      text: input,
      selection: TextSelection.collapsed(offset: input.length),
    );

    // Extract alphanumeric
    final alphanumeric = input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    print('Alphanumeric input: "$alphanumeric"');

    // Print patterns being checked
    print('Available patterns:');
    for (final pattern in PatternInputFormatter.ukPostcodePatterns()) {
      print('  $pattern');
    }

    final result = formatter.formatEditUpdate(oldValue, newValue);
    print(
      'Formatted result: "${result.text}" (cursor: ${result.selection.baseOffset})',
    );
  }
}
