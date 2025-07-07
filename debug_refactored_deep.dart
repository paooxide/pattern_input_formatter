import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pattern_input_formatter/pattern_input_formatter_refactored.dart';

void main() {
  group('Debug Refactored Pattern Selection', () {
    test('should debug exactly why RH19K fails', () {
      final patterns = PatternInputFormatter.ukPostcodePatterns();
      print('Available patterns: $patterns');

      // Test each pattern against RH19K manually
      final input = 'RH19K';
      for (int i = 0; i < patterns.length; i++) {
        final pattern = patterns[i];
        print('\nPattern $i: $pattern');

        // Manually check if pattern can match
        bool canMatch = true;
        int inputIndex = 0;

        for (int j = 0; j < pattern.length && inputIndex < input.length; j++) {
          final patternChar = pattern[j];
          if (RegExp(r'[A-Za-z#]').hasMatch(patternChar)) {
            // This is a placeholder
            if (inputIndex >= input.length) {
              print('  Input too short at position $inputIndex');
              break;
            }

            final inputChar = input[inputIndex];
            final isInputLetter = RegExp(r'[a-zA-Z]').hasMatch(inputChar);
            final isInputDigit = RegExp(r'[0-9]').hasMatch(inputChar);

            print(
              '  Position $inputIndex: pattern=$patternChar, input=$inputChar',
            );

            if (patternChar == '#' && !isInputDigit) {
              print('  MISMATCH: Expected digit, got letter');
              canMatch = false;
              break;
            }
            if (patternChar != '#' && !isInputLetter) {
              print('  MISMATCH: Expected letter, got digit');
              canMatch = false;
              break;
            }

            inputIndex++;
          }
        }

        print('  Can match: $canMatch, filled placeholders: $inputIndex');
      }
    });
  });
}
