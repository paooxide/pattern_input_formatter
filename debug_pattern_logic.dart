import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pattern_input_formatter/pattern_input_formatter_refactored.dart';

void main() {
  group('Debug Pattern Matching Logic', () {
    test('should match pattern AA## #AA against RH19K correctly', () {
      // The pattern AA## #AA should be:
      // Position 0: A (letter) -> R ✓
      // Position 1: A (letter) -> H ✓
      // Position 2: # (digit) -> 1 ✓
      // Position 3: # (digit) -> 9 ✓
      // Position 4: ' ' (separator - doesn't consume input)
      // Position 5: # (digit) -> K ✗ (K is a letter!)

      print('Pattern: AA## #AA');
      print('Input: RH19K');
      print('Expected mapping:');
      print('  A -> R (letter to letter) ✓');
      print('  A -> H (letter to letter) ✓');
      print('  # -> 1 (digit to digit) ✓');
      print('  # -> 9 (digit to digit) ✓');
      print('  (space separator)');
      print('  # -> K (digit to letter) ✗');
      print('');
      print('This pattern should NOT match RH19K because K is not a digit');
      print('');

      // The pattern AA# #AA should be:
      // Position 0: A (letter) -> R ✓
      // Position 1: A (letter) -> H ✓
      // Position 2: # (digit) -> 1 ✓
      // Position 3: ' ' (separator - doesn't consume input)
      // Position 4: # (digit) -> 9 ✓
      // Position 5: A (letter) -> K ✓

      print('Pattern: AA# #AA');
      print('Input: RH19K');
      print('Expected mapping:');
      print('  A -> R (letter to letter) ✓');
      print('  A -> H (letter to letter) ✓');
      print('  # -> 1 (digit to digit) ✓');
      print('  (space separator)');
      print('  # -> 9 (digit to digit) ✓');
      print('  A -> K (letter to letter) ✓');
      print('');
      print('This pattern SHOULD match RH19K and should be preferred');
      print(
        'But we have a bug in pattern selection where AA# #AA is incorrectly',
      );
      print('consuming both 9 and K for its placeholders after the space.');

      // Let's test the actual formatter
      final formatter = PatternInputFormatter(
        patterns: ['AA# #AA', 'AA## #AA'],
        inputType: PatternInputType.postal,
        letterCase: LetterCase.upper,
      );

      var result = formatter.formatEditUpdate(
        const TextEditingValue(
          text: 'RH19',
          selection: TextSelection.collapsed(offset: 4),
        ),
        const TextEditingValue(
          text: 'RH19K',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );

      print('');
      print('Actual formatter result: "${result.text}"');
      print('Expected result: "RH19 K"');

      if (result.text == 'RH19 K') {
        print('✓ FIXED!');
      } else {
        print('✗ Still broken - formatter selected wrong pattern');
      }
    });
  });
}
