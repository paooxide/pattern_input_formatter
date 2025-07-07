import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/pattern_input_formatter_refactored.dart';

void main() {
  test('debug specific UK postcode issue', () {
    final formatter = PatternInputFormatter(
      patterns: [
        'A# #AA', // 5 placeholders, e.g., M1 1AE
        'A## #AA', // 6 placeholders, e.g., B33 8TH
        'AA# #AA', // 6 placeholders, e.g., CR2 6XH
        'AA## #AA', // 7 placeholders, e.g., DN55 1PT
        'A#A #AA', // 6 placeholders, e.g., W1A 1HQ
        'AA#A #AA', // 7 placeholders, e.g., EC1A 1BB
      ],
      letterCase: LetterCase.upper,
    );

    // Test Case 1: Input 'M'
    var result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(
        text: 'M',
        selection: TextSelection.collapsed(offset: 1),
      ),
    );
    print(
      'Input "M": text="${result.text}", cursor=${result.selection.baseOffset}',
    );

    // Test Case 2: Input 'M1'
    result = formatter.formatEditUpdate(
      result,
      const TextEditingValue(
        text: 'M1',
        selection: TextSelection.collapsed(offset: 2),
      ),
    );
    print(
      'Input "M1": text="${result.text}", cursor=${result.selection.baseOffset}',
    );

    // Test Case 3: Input 'M11'
    result = formatter.formatEditUpdate(
      result,
      const TextEditingValue(
        text: 'M11',
        selection: TextSelection.collapsed(offset: 3),
      ),
    );
    print(
      'Input "M11": text="${result.text}", cursor=${result.selection.baseOffset}',
    );

    // Expected: 'M11 #AA' with cursor at 4
    expect(result.text, 'M11 #AA');
    expect(result.selection.baseOffset, 4);
  });
}
