import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:pattern_input_formatter/pattern_input_formatter.dart';

void main() {
  test('Simple phone number formatting test', () {
    final formatter = PatternInputFormatter(
      patterns: ['(###) ###-####'],
      inputType: PatternInputType.none,
    );

    print('=== Testing basic phone number formatting ===');

    var result = TextEditingValue.empty;

    var oldValue = result;
    var newValue = TextEditingValue(
      text: '1',
      selection: TextSelection.collapsed(offset: 1),
    );
    result = formatter.formatEditUpdate(oldValue, newValue);
    print(
      'After "1": "${result.text}", cursor: ${result.selection.baseOffset}',
    );

    final digits = '234567890';
    for (int i = 0; i < digits.length; i++) {
      oldValue = result;
      final newText =
          result.text.substring(0, result.selection.baseOffset) +
          digits[i] +
          result.text.substring(result.selection.baseOffset);
      newValue = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: result.selection.baseOffset + 1,
        ),
      );
      result = formatter.formatEditUpdate(oldValue, newValue);
      print(
        'After typing "${digits[i]}": "${result.text}", cursor: ${result.selection.baseOffset}',
      );
    }

    expect(result.text, '(123) 456-7890');
  });
}
