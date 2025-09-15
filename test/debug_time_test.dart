import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:pattern_input_formatter/pattern_input_formatter.dart';

void main() {
  test('Debug time formatting and backspace', () {
    final formatter = PatternInputFormatter(
      patterns: ['##:##'],
      inputType: PatternInputType.time,
    );

    print('=== Testing time formation ===');

    var result = TextEditingValue.empty;
    final digits = '1430';

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

    print('\n=== Testing backspace on separator ===');

    var oldValue = TextEditingValue(
      text: '14:30',
      selection: TextSelection.collapsed(offset: 3), // cursor right after ':'
    );
    var newValue = TextEditingValue(
      text: '1430', // ':' removed
      selection: TextSelection.collapsed(offset: 2), // cursor where ':' was
    );
    result = formatter.formatEditUpdate(oldValue, newValue);
    print('After backspace on ":": "${result.text}"');
    print('Starts with "1": ${result.text.startsWith('1')}');
    print('Contains ":30": ${result.text.contains(':30')}');
  });
}
