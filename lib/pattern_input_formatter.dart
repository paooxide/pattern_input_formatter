import 'package:flutter/services.dart';

import 'src/types.dart';
import 'src/pattern_matcher.dart';
import 'src/formatter_engine.dart';
import 'src/datetime_validator.dart';

export 'src/types.dart' show LetterCase, PatternInputType;

/// A TextInputFormatter that formats user input according to a given pattern or a list of patterns.
///
/// This formatter is useful for formatting user input into a specific format,
/// such as a phone number, date, or other patterned text. For variable-length
/// inputs like UK postcodes, a list of all possible patterns can be provided.
///
/// It works by defining a pattern with placeholder characters (e.g., '#', 'd', 'M', 'y')
/// that are replaced by the user's input.
///
/// This formatter automatically filters for alphanumeric characters (letters and
/// digits). For patterns that require other characters, like a leading `+` for
/// international phone numbers, include them directly in the pattern.
///
/// For fields that should only accept digits (like phone numbers or dates), it is
/// recommended to use `FilteringTextInputFormatter.digitsOnly` in addition to this
/// formatter to restrict the keyboard and input.
class PatternInputFormatter extends TextInputFormatter {
  /// A list of possible patterns for the mask. The formatter will dynamically choose the best fit.
  final List<String> patterns;

  /// Optional character to use for unfilled placeholders.
  /// If null, the uppercase version of the pattern character (e.g., 'D', 'M', 'Y') is used.
  final String? placeholderChar;

  /// Determines the case of alphabetic characters.
  final LetterCase letterCase;

  /// Optional input type for validation (date, time, datetime, or none).
  final PatternInputType inputType;

  /// Internal pattern matcher for handling pattern selection and validation
  final PatternMatcher _patternMatcher = PatternMatcher();

  /// Constructs a [PatternInputFormatter].
  /// For variable-length patterns (like UK postcodes), provide a list of all possible patterns.
  /// For fixed-length patterns, provide a single pattern in the list.
  PatternInputFormatter({
    required this.patterns,
    this.placeholderChar,
    this.letterCase = LetterCase.upper,
    this.inputType = PatternInputType.none,
  }) : assert(patterns.isNotEmpty, 'At least one pattern must be provided.'),
       assert(
         placeholderChar == null || placeholderChar.length == 1,
         'Placeholder character must be a single character.',
       ) {
    // Pre-build and cache the structure for each pattern
    for (final pattern in patterns) {
      // Ensure each pattern is valid before caching
      assert(
        RegExp(r'[A-Za-z#]').hasMatch(pattern),
        'Pattern "$pattern" must contain at least one placeholder character (A-Z, a-z, #).',
      );
      _patternMatcher.buildAndCacheMaskStructure(pattern);
    }
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Handle empty input - clear everything
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Extract alphanumeric characters only
    String newAlphanumeric = newValue.text.replaceAll(
      RegExp(r'[^a-zA-Z0-9]'),
      '',
    );

    // Check if a separator was deleted and apply intuitive backspace behavior
    final alphaIndexToRemove = _checkSeparatorDeletion(oldValue, newValue);
    if (alphaIndexToRemove >= 0) {
      // Remove the alphanumeric character that preceded the deleted separator
      if (alphaIndexToRemove < newAlphanumeric.length) {
        newAlphanumeric =
            newAlphanumeric.substring(0, alphaIndexToRemove) +
            newAlphanumeric.substring(alphaIndexToRemove + 1);
      }
    }

    // Find the best matching pattern
    final String? bestPattern = _patternMatcher.findBestMatch(
      patterns,
      newAlphanumeric,
      inputType,
    );

    if (bestPattern == null) {
      // Input doesn't match any pattern - reject it
      return oldValue;
    }

    final maskStructure = _patternMatcher.getMaskStructure(bestPattern);

    final cursorInAlphanumeric = FormatterEngine.calculateCursorInAlphanumeric(
      newValue,
    );

    // Apply date/time validation if required
    if (inputType != PatternInputType.none) {
      if (!DateTimeValidator.validateInput(
        newAlphanumeric,
        bestPattern,
        maskStructure,
        inputType,
      )) {
        return oldValue;
      }
    }

    // Build the formatted string and calculate final cursor position
    final result = FormatterEngine.buildFormattedString(
      newAlphanumeric,
      maskStructure,
      cursorInAlphanumeric,
      inputType,
      letterCase,
      placeholderChar,
    );

    return TextEditingValue(
      text: result.text,
      selection: TextSelection.collapsed(offset: result.cursorPosition),
    );
  }

  /// Checks if a separator was deleted and returns the index of the alphanumeric character to remove
  /// Returns -1 if no separator was deleted, or the index of the character to remove
  int _checkSeparatorDeletion(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final isPostalOrSerial =
        inputType == PatternInputType.postal ||
        inputType == PatternInputType.serial;

    if (isPostalOrSerial) {
      return -1;
    }

    final isDeletion = oldValue.text.length > newValue.text.length;

    if (isDeletion) {
      final oldCursor = oldValue.selection.baseOffset;
      final newCursor = newValue.selection.baseOffset;

      if (oldValue.text.length == newValue.text.length + 1 &&
          oldCursor == newCursor + 1 &&
          newCursor >= 0 &&
          newCursor < oldValue.text.length) {
        final deletedChar = oldValue.text[newCursor];

        if (!RegExp(r'[a-zA-Z0-9]').hasMatch(deletedChar)) {
          int alphaCount = 0;
          for (int i = 0; i < newCursor; i++) {
            if (RegExp(r'[a-zA-Z0-9]').hasMatch(oldValue.text[i])) {
              alphaCount++;
            }
          }
          return alphaCount > 0 ? alphaCount - 1 : -1;
        }
      }
    }

    return -1;
  }

  /// Returns a list of patterns covering all valid UK postcode formats.
  ///
  /// Usage:
  ///   PatternInputFormatter(
  ///     patterns: PatternInputFormatter.ukPostcodePatterns(),
  ///     letterCase: LetterCase.upper,
  ///   )
  static List<String> ukPostcodePatterns() {
    // A = letter, # = digit
    // Common UK postcode formats:
    return [
      'A# #AA', // e.g. M1 1AA
      'A## #AA', // e.g. W12 3AB
      'AA# #AA', // e.g. CR2 6XH
      'AA## #AA', // e.g. EC1A 1BB
      'A#A #AA', // e.g. E1A 1BB
      'AA#A #AA', // e.g. SW1A 1AA
      'AA## AAA', // e.g. RH95 BAA
    ];
  }
}
