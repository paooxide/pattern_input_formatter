import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pattern_input_formatter/pattern_input_formatter_refactored.dart';

void main() {
  group('Deep Debug Pattern Selection', () {
    test('should debug step by step pattern selection for RH19K', () {
      final patterns = PatternInputFormatter.ukPostcodePatterns();
      print('Available patterns: $patterns');

      final formatter = PatternInputFormatter(
        patterns: patterns,
        inputType: PatternInputType.postal,
        letterCase: LetterCase.upper,
      );

      // Build up to RH19K step by step
      var currentValue = const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );

      for (final char in ['R', 'H', '1', '9', 'K']) {
        final newText = currentValue.text + char;
        final newValue = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );

        final result = formatter.formatEditUpdate(currentValue, newValue);
        print('Input: "$newText" -> Output: "${result.text}"');

        // Update for next iteration
        currentValue = result;
      }
    });
  });
}
