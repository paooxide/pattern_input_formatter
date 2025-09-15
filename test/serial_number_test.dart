import 'package:flutter_test/flutter_test.dart';
import 'package:pattern_input_formatter/pattern_input_formatter.dart';
import 'package:flutter/services.dart';

void main() {
  group('Serial Number Formatting Tests', () {
    test('Serial number uppercase formatting should work', () {
      final formatter = PatternInputFormatter(
        patterns: ['AAAA-####-AA'],
        letterCase: LetterCase.upper,
        inputType: PatternInputType.serial,
      );

      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(
          text: 'abcd1234ef',
          selection: TextSelection.collapsed(offset: 10),
        ),
      );

      expect(result.text, equals('ABCD-1234-EF'));
      print('Uppercase: ${result.text}');
    });

    test('Serial number lowercase formatting should work', () {
      final formatter = PatternInputFormatter(
        patterns: ['AAAA-####-AA'],
        letterCase: LetterCase.lower,
        inputType: PatternInputType.serial,
      );

      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(
          text: 'ABCD1234EF',
          selection: TextSelection.collapsed(offset: 10),
        ),
      );

      expect(result.text, equals('abcd-1234-ef'));
      print('Lowercase: ${result.text}');
    });

    test('Serial number any case formatting should work', () {
      final formatter = PatternInputFormatter(
        patterns: ['AAAA-####-AA'],
        letterCase: LetterCase.any,
        inputType: PatternInputType.serial,
      );

      final result = formatter.formatEditUpdate(
        const TextEditingValue(),
        const TextEditingValue(
          text: 'AbCd1234Ef',
          selection: TextSelection.collapsed(offset: 10),
        ),
      );

      expect(result.text, equals('AbCd-1234-Ef'));
      print('Any case: ${result.text}');
    });

    test('Serial number step by step input test', () {
      final formatter = PatternInputFormatter(
        patterns: ['AAAA-####-AA'],
        letterCase: LetterCase.upper,
        inputType: PatternInputType.serial,
      );

      final testInput = 'abcd1234ef';
      String formatted = '';

      for (int i = 0; i < testInput.length; i++) {
        final char = testInput[i];
        final newText =
            formatted.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '') + char;

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
        print('Step ${i + 1}: Input "$char" -> "${formatted}"');
      }

      expect(formatted, equals('ABCD-1234-EF'));
    });
  });
}
