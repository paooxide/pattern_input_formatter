import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pattern_input_formatter/pattern_input_formatter_refactored.dart';

void main() {
  group('Debug Pattern Selection', () {
    test('should debug pattern selection for RH19', () {
      print('Available UK postcode patterns:');
      final patterns = PatternInputFormatter.ukPostcodePatterns();
      for (int i = 0; i < patterns.length; i++) {
        print('  $i: ${patterns[i]}');
      }

      final formatter = PatternInputFormatter(
        patterns: patterns,
        inputType: PatternInputType.postal,
        letterCase: LetterCase.upper,
      );

      // Test up to RH19
      const oldValue = TextEditingValue.empty;
      const newValue = TextEditingValue(
        text: 'RH19',
        selection: TextSelection.collapsed(offset: 4),
      );
      final result = formatter.formatEditUpdate(oldValue, newValue);
      print('Input: RH19 -> Output: "${result.text}"');

      // Let's also test what would happen with manual pattern testing
      print('\nManual pattern testing for input "RH19":');
      final testInput = 'RH19';

      for (final pattern in patterns) {
        print('Pattern: $pattern');
        // Test if this pattern can match RH19
        bool canMatch = _testPattern(testInput, pattern);
        print('  Can match: $canMatch');
      }
    });
  });
}

bool _testPattern(String input, String pattern) {
  int inputIndex = 0;
  for (int i = 0; i < pattern.length && inputIndex < input.length; i++) {
    final char = pattern[i];
    if (RegExp(r'[A-Za-z#]').hasMatch(char)) {
      // This is a placeholder
      final inputChar = input[inputIndex];
      final isLetter = RegExp(r'[A-Za-z]').hasMatch(inputChar);
      final isDigit = RegExp(r'[0-9]').hasMatch(inputChar);

      if (char == '#' && !isDigit) return false;
      if (char != '#' && !isLetter) return false;

      inputIndex++;
    }
  }
  return true;
}
