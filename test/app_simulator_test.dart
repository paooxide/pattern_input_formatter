import 'package:flutter_test/flutter_test.dart';
import 'package:pattern_input_formatter/pattern_input_formatter.dart';
import 'package:flutter/services.dart';

void main() {
  group('UK Postcode RH19KAA App Test', () {
    test('Test formatter with same configuration as example app', () {
      // Test the formatter with the same configuration as the UK postcode field
      final formatter = PatternInputFormatter(
        patterns: [
          'AA# #AA',
          'A# #AA',
          'A#A #AA',
          'AA## #AA', // Handles RH15 9AA and similar
          'AA## AAA', // Handles RH15 KAA and similar (newly added)
        ],
        inputType: PatternInputType.postal,
      );

      print('Testing UK postcode formatter with RH15KAA input...\n');

      // Simulate typing "RH15KAA" character by character
      String currentText = '';
      int currentCursor = 0;

      final inputChars = ['R', 'H', '1', '5', 'K', 'A', 'A'];

      for (int i = 0; i < inputChars.length; i++) {
        final char = inputChars[i];
        final newText = currentText + char;
        final newCursor = currentCursor + 1;

        print('--- Step ${i + 1}: Adding "$char" ---');
        print('Before: "$currentText" (cursor at $currentCursor)');
        print('Input:  "$newText" (cursor at $newCursor)');

        // Create TextEditingValue for input
        final oldValue = TextEditingValue(
          text: currentText,
          selection: TextSelection.collapsed(offset: currentCursor),
        );

        final newValue = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newCursor),
        );

        try {
          // Apply formatter
          final result = formatter.formatEditUpdate(oldValue, newValue);

          print(
            'Result: "${result.text}" (cursor at ${result.selection.baseOffset})',
          );

          // Update for next iteration
          currentText = result.text;
          currentCursor = result.selection.baseOffset;

          print('State: "$currentText" (cursor at $currentCursor)\n');
        } catch (e) {
          print('ERROR: $e\n');
          fail('Formatter failed at step ${i + 1}');
        }
      }

      print('Final result: "$currentText"');
      print('Expected:     "RH19 KAA"');

      expect(currentText, equals('RH19 KAA'));
    });
  });
}
