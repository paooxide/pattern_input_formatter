import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pattern_input_formatter/pattern_input_formatter_refactored.dart';

void main() {
  group('Refactored PatternInputFormatter Tests', () {
    test('RH19KAA postal code should work correctly', () {
      final formatter = PatternInputFormatter(
        patterns: PatternInputFormatter.ukPostcodePatterns(),
        inputType: PatternInputType.postal,
        letterCase: LetterCase.upper,
      );

      // Test step by step input
      var result = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        ),
        const TextEditingValue(
          text: 'R',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      expect(result.text, 'R');

      result = formatter.formatEditUpdate(
        result,
        const TextEditingValue(
          text: 'RH',
          selection: TextSelection.collapsed(offset: 2),
        ),
      );
      expect(result.text, 'RH');

      result = formatter.formatEditUpdate(
        result,
        const TextEditingValue(
          text: 'RH1',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      expect(result.text, 'RH1');

      result = formatter.formatEditUpdate(
        result,
        const TextEditingValue(
          text: 'RH19',
          selection: TextSelection.collapsed(offset: 4),
        ),
      );
      expect(result.text, 'RH19 ');

      result = formatter.formatEditUpdate(
        result,
        const TextEditingValue(
          text: 'RH19K',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );
      expect(result.text, 'RH19 K');

      result = formatter.formatEditUpdate(
        result,
        const TextEditingValue(
          text: 'RH19KA',
          selection: TextSelection.collapsed(offset: 6),
        ),
      );
      expect(result.text, 'RH19 KA');

      result = formatter.formatEditUpdate(
        result,
        const TextEditingValue(
          text: 'RH19KAA',
          selection: TextSelection.collapsed(offset: 7),
        ),
      );
      expect(result.text, 'RH19 KAA');
    });

    test('Serial number should work correctly', () {
      final formatter = PatternInputFormatter(
        patterns: ['AAAA-####-aa'],
        inputType: PatternInputType.serial,
        letterCase: LetterCase.upper,
      );

      var result = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        ),
        const TextEditingValue(
          text: 'A',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      expect(result.text, 'A');

      result = formatter.formatEditUpdate(
        result,
        const TextEditingValue(
          text: 'AB',
          selection: TextSelection.collapsed(offset: 2),
        ),
      );
      expect(result.text, 'AB');

      result = formatter.formatEditUpdate(
        result,
        const TextEditingValue(
          text: 'ABCD',
          selection: TextSelection.collapsed(offset: 4),
        ),
      );
      expect(result.text, 'ABCD-');

      result = formatter.formatEditUpdate(
        result,
        const TextEditingValue(
          text: 'ABCD1',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );
      expect(result.text, 'ABCD-1');

      result = formatter.formatEditUpdate(
        result,
        const TextEditingValue(
          text: 'ABCD1234',
          selection: TextSelection.collapsed(offset: 8),
        ),
      );
      expect(result.text, 'ABCD-1234-');

      result = formatter.formatEditUpdate(
        result,
        const TextEditingValue(
          text: 'ABCD1234ef',
          selection: TextSelection.collapsed(offset: 10),
        ),
      );
      expect(result.text, 'ABCD-1234-EF');
    });

    test('Date formatting should still work', () {
      final formatter = PatternInputFormatter(patterns: ['dd/MM/yyyy']);

      var result = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        ),
        const TextEditingValue(
          text: '1',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      expect(result.text, '1D/MM/YYYY');

      result = formatter.formatEditUpdate(
        result,
        const TextEditingValue(
          text: '12',
          selection: TextSelection.collapsed(offset: 2),
        ),
      );
      expect(result.text, '12/MM/YYYY');
    });

    test('Phone formatting should still work', () {
      final formatter = PatternInputFormatter(
        patterns: ['(###) ###-####'],
        inputType: PatternInputType.phone,
      );

      var result = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        ),
        const TextEditingValue(
          text: '1',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      expect(result.text, '(1##) ###-####');

      result = formatter.formatEditUpdate(
        result,
        const TextEditingValue(
          text: '123',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      expect(result.text, '(123) ###-####');
    });
  });
}
