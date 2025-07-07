import 'package:flutter/services.dart';
import 'package:pattern_input_formatter/pattern_input_formatter.dart';

void main() {
  print('Testing PatternInputFormatter fixes...\n');

  // Test 1: Postal code (should not show placeholders)
  print('=== POSTAL CODE TEST ===');
  final postalFormatter = PatternInputFormatter(
    patterns: ['AA#A #AA', 'A# #AA', 'A## #AA', 'AA# #AA'],
    inputType: PatternInputType.postal,
  );

  // Simulate typing 'S'
  var result1 = postalFormatter.formatEditUpdate(
    TextEditingValue.empty,
    const TextEditingValue(
      text: 'S',
      selection: TextSelection.collapsed(offset: 1),
    ),
  );
  print('Input: "S" -> Output: "${result1.text}" (should be "S")');

  // Simulate typing 'SW'
  var result2 = postalFormatter.formatEditUpdate(
    result1,
    const TextEditingValue(
      text: 'SW',
      selection: TextSelection.collapsed(offset: 2),
    ),
  );
  print('Input: "SW" -> Output: "${result2.text}" (should be "SW")');

  // Simulate typing 'SW1A1AA'
  var result3 = postalFormatter.formatEditUpdate(
    TextEditingValue.empty,
    const TextEditingValue(
      text: 'SW1A1AA',
      selection: TextSelection.collapsed(offset: 7),
    ),
  );
  print('Input: "SW1A1AA" -> Output: "${result3.text}" (should be "SW1A 1AA")');

  print('\n=== PHONE NUMBER TEST ===');
  final phoneFormatter = PatternInputFormatter(patterns: ['(###) ###-####']);

  // Simulate typing '1'
  var phoneResult1 = phoneFormatter.formatEditUpdate(
    TextEditingValue.empty,
    const TextEditingValue(
      text: '1',
      selection: TextSelection.collapsed(offset: 1),
    ),
  );
  print(
    'Input: "1" -> Output: "${phoneResult1.text}" (should be "(1##) ###-####")',
  );

  // Simulate typing '123'
  var phoneResult2 = phoneFormatter.formatEditUpdate(
    TextEditingValue.empty,
    const TextEditingValue(
      text: '123',
      selection: TextSelection.collapsed(offset: 3),
    ),
  );
  print(
    'Input: "123" -> Output: "${phoneResult2.text}" (should be "(123) ###-####")',
  );

  print('\n=== SERIAL NUMBER TEST ===');
  final serialFormatter = PatternInputFormatter(
    patterns: ['AAAA-####-aa'],
    inputType: PatternInputType.serial,
    letterCase: LetterCase.any,
  );

  // Simulate typing 'ABCD'
  var serialResult1 = serialFormatter.formatEditUpdate(
    TextEditingValue.empty,
    const TextEditingValue(
      text: 'ABCD',
      selection: TextSelection.collapsed(offset: 4),
    ),
  );
  print('Input: "ABCD" -> Output: "${serialResult1.text}" (should be "ABCD")');

  // Simulate typing 'ABCD1234ef'
  var serialResult2 = serialFormatter.formatEditUpdate(
    TextEditingValue.empty,
    const TextEditingValue(
      text: 'ABCD1234ef',
      selection: TextSelection.collapsed(offset: 10),
    ),
  );
  print(
    'Input: "ABCD1234ef" -> Output: "${serialResult2.text}" (should be "ABCD-1234-ef")',
  );

  print('\nAll tests completed!');
}
