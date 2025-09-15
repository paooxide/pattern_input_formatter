import 'package:flutter_test/flutter_test.dart';
import 'package:pattern_input_formatter/pattern_input_formatter.dart';
import 'package:flutter/services.dart';

void main() {
  group('PatternInputFormatter RH159AA Tests', () {
    test('RH159AA formatting should work correctly step by step', () {
      final formatter = PatternInputFormatter(
        patterns: [
          'AA## #AA', // UK postcode like RH19 KAA
          'AA### AAA', // UK postcode like RH195 KAA
          'A## AAA', // UK postcode like R19 KAA
          'A### AAA', // UK postcode like R195 KAA
          '#A# #AA', // Canadian postal code like K1A 0A6
        ],
        inputType: PatternInputType.postal,
      );

      // Test the character-by-character input

      final testInput = 'RH159AA';
      String formatted = '';

      for (int i = 0; i < testInput.length; i++) {
        final char = testInput[i];
        final newText = formatted + char;

        final oldValue = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
        final newValue = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );

        final result = formatter.formatEditUpdate(oldValue, newValue);
        formatted = result.text;
        // Verify each step works correctly
      }

      // Final test - should be "RH159 AA"
      expect(formatted, equals('RH159 AA'));
    });

    test('RH159AA should match AA## #AA pattern correctly', () {
      final formatter = PatternInputFormatter(
        patterns: [
          'AA## #AA', // This should be the correct pattern for RH159AA
        ],
        inputType: PatternInputType.postal,
      );

      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(
          text: 'RH159AA',
          selection: TextSelection.collapsed(offset: 7),
        ),
      );

      expect(result.text, equals('RH15 9AA')); // Should format to RH159 AA
      expect(result.selection.baseOffset, equals(8)); // After the space
    });
  });
}
