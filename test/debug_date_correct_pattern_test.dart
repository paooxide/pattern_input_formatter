import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:pattern_input_formatter/pattern_input_formatter.dart';

void main() {
  test('Test correct date pattern', () {
    // Use the correct pattern for dates with digits
    final formatter = PatternInputFormatter(
      patterns: ['##/##/####'], // Use # for digits
      inputType: PatternInputType.date,
    );

    print('=== Testing correct date pattern ===');

    var result = TextEditingValue.empty;
    final digits = '12252024';

    for (int i = 0; i < digits.length; i++) {
      final oldValue = result;
      final newValue = TextEditingValue(
        text: oldValue.text + digits[i],
        selection: TextSelection.collapsed(offset: oldValue.text.length + 1),
      );
      result = formatter.formatEditUpdate(oldValue, newValue);
      print(
        'After "${digits.substring(0, i + 1)}": "${result.text}", cursor: ${result.selection.baseOffset}',
      );
    }
  });
}
