import 'lib/pattern_input_formatter.dart';
import 'package:flutter/services.dart';

void main() {
  print('Testing PatternInputFormatter...');

  // Test 1: Simple serial number pattern
  final serialFormatter = PatternInputFormatter(
    patterns: ['AA-####-BB'],
    inputType: PatternInputType.serial,
    letterCase: LetterCase.upper,
  );

  print('\n=== Test 1: Serial Number (AA-####-BB) ===');
  testFormatter(serialFormatter, [
    'A',
    'AB',
    'AB1',
    'AB12',
    'AB123',
    'AB1234',
    'AB1234C',
    'AB1234CD',
  ]);

  // Test 2: UK Postcode
  final postcodeFormatter = PatternInputFormatter(
    patterns: PatternInputFormatter.ukPostcodePatterns(),
    inputType: PatternInputType.postal,
    letterCase: LetterCase.upper,
  );

  print('\n=== Test 2: UK Postcode ===');
  testFormatter(postcodeFormatter, [
    'M',
    'M1',
    'M1 ',
    'M1 1',
    'M1 1A',
    'M1 1AA',
  ]);

  // Test 3: Simple letter pattern
  final letterFormatter = PatternInputFormatter(
    patterns: ['AAAA'],
    inputType: PatternInputType.none,
    letterCase: LetterCase.upper,
  );

  print('\n=== Test 3: Simple Letters (AAAA) ===');
  testFormatter(letterFormatter, ['A', 'AB', 'ABC', 'ABCD']);
}

void testFormatter(PatternInputFormatter formatter, List<String> inputs) {
  var currentValue = const TextEditingValue(
    text: '',
    selection: TextSelection.collapsed(offset: 0),
  );

  for (final input in inputs) {
    final newValue = TextEditingValue(
      text: input,
      selection: TextSelection.collapsed(offset: input.length),
    );

    final result = formatter.formatEditUpdate(currentValue, newValue);
    print(
      'Input: "$input" -> Output: "${result.text}" (cursor: ${result.selection.baseOffset})',
    );

    if (result.text == currentValue.text && input != currentValue.text) {
      print('  ❌ REJECTED: Input was rejected!');
      break;
    } else {
      print('  ✅ ACCEPTED');
    }

    currentValue = result;
  }
}
