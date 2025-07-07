import 'dart:io';
import '../lib/pattern_input_formatter_refactored.dart';
import 'package:flutter/services.dart';

void main() {
  print('=== DEBUGGING RH19KAA ===');

  final formatter = PatternInputFormatter(
    patterns: [
      'AA## #AA', // UK postcode
      'AA### #AA', // UK postcode
      'A## #AA', // UK postcode
      'A### #AA', // UK postcode
      '#A# #AA', // Canadian postal code
      'AAA ###', // Alternative pattern
    ],
    inputType: PatternInputType.postal,
  );

  print('\n--- Testing RH19KAA character by character ---');
  String current = '';
  final input = 'RH19KAA';

  for (int i = 0; i < input.length; i++) {
    final char = input[i];
    current += char;

    final oldValue = TextEditingValue(text: '');
    final newValue = TextEditingValue(
      text: current,
      selection: TextSelection.collapsed(offset: current.length),
    );

    final result = formatter.formatEditUpdate(oldValue, newValue);

    print(
      'Input: "$current" -> Formatted: "${result.text}" (cursor: ${result.selection.baseOffset})',
    );

    // Check pattern selection details
    final cleanInput = current.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    print('  Clean input: "$cleanInput"');

    // Get internal state if possible
    print('  Expected after $i chars: should have pattern pieces');
    print('');
  }

  print('\n--- Expected vs Actual ---');
  print('Expected progression:');
  print('R -> R');
  print('RH -> RH');
  print('RH1 -> RH1');
  print('RH19 -> RH19 '); // Should add space after 4 chars
  print('RH19K -> RH19 K');
  print('RH19KA -> RH19 KA');
  print('RH19KAA -> RH19 KAA');
}
