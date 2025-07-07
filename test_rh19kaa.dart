import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pattern_input_formatter/pattern_input_formatter.dart';

void main() {
  group('RH19KAA Postal Code Test', () {
    test('should handle RH19KAA postal code pattern correctly', () {
      // Test with UK postcode patterns including the one for RH19KAA
      final formatter = PatternInputFormatter(
        patterns: PatternInputFormatter.ukPostcodePatterns(),
        inputType: PatternInputType.postal,
        letterCase: LetterCase.upper,
      );

      // Test typing R
      const oldValue = TextEditingValue.empty;
      const newValue1 = TextEditingValue(
        text: 'R',
        selection: TextSelection.collapsed(offset: 1),
      );
      final result1 = formatter.formatEditUpdate(oldValue, newValue1);
      print('Input: R -> Output: "${result1.text}"');
      expect(result1.text, 'R');

      // Test typing RH
      final newValue2 = const TextEditingValue(
        text: 'RH',
        selection: TextSelection.collapsed(offset: 2),
      );
      final result2 = formatter.formatEditUpdate(result1, newValue2);
      print('Input: RH -> Output: "${result2.text}"');
      expect(result2.text, 'RH');

      // Test typing RH1
      final newValue3 = const TextEditingValue(
        text: 'RH1',
        selection: TextSelection.collapsed(offset: 3),
      );
      final result3 = formatter.formatEditUpdate(result2, newValue3);
      print('Input: RH1 -> Output: "${result3.text}"');
      expect(result3.text, 'RH1');

      // Test typing RH19
      final newValue4 = const TextEditingValue(
        text: 'RH19',
        selection: TextSelection.collapsed(offset: 4),
      );
      final result4 = formatter.formatEditUpdate(result3, newValue4);
      print('Input: RH19 -> Output: "${result4.text}"');
      expect(result4.text, 'RH19 ');

      // Test typing RH19K
      final newValue5 = const TextEditingValue(
        text: 'RH19K',
        selection: TextSelection.collapsed(offset: 5),
      );
      final result5 = formatter.formatEditUpdate(result4, newValue5);
      print('Input: RH19K -> Output: "${result5.text}"');
      expect(result5.text, 'RH19 K');

      // Test typing RH19KA
      final newValue6 = const TextEditingValue(
        text: 'RH19KA',
        selection: TextSelection.collapsed(offset: 6),
      );
      final result6 = formatter.formatEditUpdate(result5, newValue6);
      print('Input: RH19KA -> Output: "${result6.text}"');
      expect(result6.text, 'RH19 KA');

      // Test typing RH19KAA
      final newValue7 = const TextEditingValue(
        text: 'RH19KAA',
        selection: TextSelection.collapsed(offset: 7),
      );
      final result7 = formatter.formatEditUpdate(result6, newValue7);
      print('Input: RH19KAA -> Output: "${result7.text}"');
      expect(result7.text, 'RH19 KAA');
    });
  });
}
