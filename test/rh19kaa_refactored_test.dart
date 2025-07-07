import 'package:flutter_test/flutter_test.dart';
import '../lib/pattern_input_formatter_refactored.dart';
import 'package:flutter/services.dart';

void main() {
  group('PatternInputFormatter RH19KAA Tests', () {
    test('RH19KAA formatting should work correctly step by step', () {
      final formatter = PatternInputFormatter(
        patterns: [
          'AA## AAA', // UK postcode like RH19 KAA
          'AA### AAA', // UK postcode like RH195 KAA
          'A## AAA', // UK postcode like R19 KAA
          'A### AAA', // UK postcode like R195 KAA
          '#A# #AA', // Canadian postal code like K1A 0A6
        ],
        inputType: PatternInputType.postal,
      );

      // Test the character-by-character input

      final testInput = 'RH19KAA';
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

      // Final test - should be "RH19 KAA"
      expect(formatted, equals('RH19 KAA'));
    });

    test('RH19KAA should match AA## AAA pattern correctly', () {
      final formatter = PatternInputFormatter(
        patterns: [
          'AA## AAA', // This should be the correct pattern for RH19KAA
        ],
        inputType: PatternInputType.postal,
      );

      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(
          text: 'RH19KAA',
          selection: TextSelection.collapsed(offset: 7),
        ),
      );

      expect(result.text, equals('RH19 KAA')); // Should format to RH19 KAA
      expect(result.selection.baseOffset, equals(8)); // After the space
    });
  });
}
