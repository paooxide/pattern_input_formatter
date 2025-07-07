// Simple test script for pattern input formatter
import '../lib/src/types.dart';
import '../lib/src/pattern_matcher.dart';
import '../lib/src/formatter_engine.dart';

void main() {
  print('=== Testing Pattern Input Formatter Core Logic ===');

  // Test patterns for UK postcode
  final patterns = [
    'AA## #AA', // UK postcode like RH19 KAA
    'AA### #AA', // UK postcode
    'A## #AA', // UK postcode
    'A### #AA', // UK postcode
    '#A# #AA', // Canadian postal code
  ];

  final matcher = PatternMatcher();

  // Build and cache patterns
  for (final pattern in patterns) {
    matcher.buildAndCacheMaskStructure(pattern);
    print('Cached pattern: $pattern');
  }

  print('\n--- Testing RH19KAA step by step ---');

  final testInput = 'RH19KAA';
  for (int i = 1; i <= testInput.length; i++) {
    final input = testInput.substring(0, i);
    final cleanInput = input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    // Find best pattern
    final bestPattern = matcher.findBestMatch(
      patterns,
      cleanInput,
      PatternInputType.postal,
    );

    if (bestPattern != null) {
      final maskStructure = matcher.getMaskStructure(bestPattern);
      final result = FormatterEngine.buildFormattedString(
        cleanInput,
        maskStructure,
        cleanInput.length,
        PatternInputType.postal,
        LetterCase.upper,
        null,
      );

      print(
        'Input: "$cleanInput" -> Pattern: "$bestPattern" -> Formatted: "${result.text}" (cursor: ${result.cursorPosition})',
      );
    } else {
      print('Input: "$cleanInput" -> No matching pattern');
    }
  }

  print('\n--- Expected vs Actual ---');
  print('Expected: R -> RH -> RH1 -> RH19 -> RH19 K -> RH19 KA -> RH19 KAA');

  print('\n--- Testing other patterns ---');

  // Test date pattern
  final datePatterns = ['##/##/####', '##-##-####'];
  for (final pattern in datePatterns) {
    matcher.buildAndCacheMaskStructure(pattern);
  }

  final dateInput = '12252024';
  final datePattern = matcher.findBestMatch(
    datePatterns,
    dateInput,
    PatternInputType.date,
  );
  if (datePattern != null) {
    final maskStructure = matcher.getMaskStructure(datePattern);
    final result = FormatterEngine.buildFormattedString(
      dateInput,
      maskStructure,
      dateInput.length,
      PatternInputType.date,
      LetterCase.none,
      null,
    );
    print(
      'Date input: "$dateInput" -> Pattern: "$datePattern" -> Formatted: "${result.text}"',
    );
  }
}
