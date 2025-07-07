import 'package:flutter/services.dart';
import 'lib/pattern_input_formatter_refactored.dart';

void main() {
  print('Testing sequential character input for RH19KAA...\n');
  
  final formatter = PatternInputFormatter(
    patterns: [
      'AA## AAA', // UK postcode like RH19 KAA
      'AA### AAA', // UK postcode like RH195 KAA
      'A## AAA', // UK postcode like R19 KAA
      'A### AAA', // UK postcode like R195 KAA
      '#A# #AA', // Canadian postal code like K1A 0A6
    ],
    inputType: PatternInputType.postal,
  );

  final testInput = 'RH19KAA';
  String currentText = '';
  
  for (int i = 0; i < testInput.length; i++) {
    final char = testInput[i];
    final newText = currentText + char;
    
    final oldValue = TextEditingValue(
      text: currentText,
      selection: TextSelection.collapsed(offset: currentText.length),
    );
    final newValue = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
    
    print('Step ${i + 1}: Adding "$char"');
    print('  Input: "$currentText" -> "$newText"');
    
    final result = formatter.formatEditUpdate(oldValue, newValue);
    
    print('  Output: "${result.text}" (cursor: ${result.selection.baseOffset})');
    
    // Check if the formatter rejected the input
    if (result.text == currentText) {
      print('  ❌ REJECTED: Input was not accepted!');
      break;
    } else {
      print('  ✅ ACCEPTED');
      currentText = result.text;
    }
    print('');
  }
  
  print('Final result: "$currentText"');
  print('Expected: "RH19 KAA"');
  print('Match: ${currentText == "RH19 KAA" ? "✅" : "❌"}');
}
