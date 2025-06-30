import 'package:flutter/services.dart';

enum LetterCase {
  /// Convert all alphabetic characters to uppercase.
  upper,

  /// Convert all alphabetic characters to lowercase.
  lower,

  /// Allow any case (no conversion).
  any,
}

enum PatternInputType { none, date, time, datetime }

class _MaskSlot {
  final String patternChar; // Character from the pattern (e.g., 'd', '/', 'Y')
  final bool isPlaceholder; // Is it a digit placeholder?
  final int logicalDigitIndex; // If placeholder, its 0-based index (0 to N-1). -1 otherwise.

  const _MaskSlot({
    required this.patternChar,
    required this.isPlaceholder,
    required this.logicalDigitIndex,
  });
}

class _FormattedResult {
  final String text;
  final int cursorPosition;

  const _FormattedResult({
    required this.text,
    required this.cursorPosition,
  });
}

/// A that formats user input according to a given pattern or a list of patterns.
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
///
/// ```dart
/// import 'package:flutter/material.dart';
/// import 'package:flutter/services.dart';
/// import 'package:input_formatter_pao/input_formatter_pao.dart';
///
/// class MyForm extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Column(
///       children: <Widget>[
///         TextField(
///           decoration: const InputDecoration(
///             hintText: 'AA-####-BB',
///             labelText: 'Serial Number',
///           ),
///           keyboardType: TextInputType.text,
///           inputFormatters: [
///             PatternInputFormatter(
///               patterns: ['aa-####-bb'],
///               letterCase: LetterCase.lower,
///             ),
///           ],
///         ),
///       ],
///     );
///   }
/// }
/// ```
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

  /// Regex matching placeholder tokens in the pattern (alphabetic characters and '#').
  final RegExp _placeholderRegex = RegExp(r'[A-Za-z#]');

  /// A cache to store the mask structure for each pattern to avoid rebuilding.
  final Map<String, List<_MaskSlot>> _patternCache = {};
  final Map<String, int> _placeholderCountCache = {};

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
    // Pre-build and cache the structure for each pattern.
    for (final pattern in patterns) {
      // Ensure each pattern is valid before caching.
      assert(
        RegExp(r'[A-Za-z#]').hasMatch(pattern),
        'Pattern "$pattern" must contain at least one placeholder character (A-Z, a-z, #).',
      );
      _buildAndCacheMaskStructure(pattern);
    }
  }

  /// Builds the internal list (_maskStructure) for a given pattern and caches it.
  void _buildAndCacheMaskStructure(String pattern) {
    final structure = <_MaskSlot>[];
    int count = 0;
    int currentLogicalDigitIndex = 0;
    for (int i = 0; i < pattern.length; i++) {
      final char = pattern[i];
      final isPlaceholder = _placeholderRegex.hasMatch(char);
      int logicalIndex = -1;

      if (isPlaceholder) {
        logicalIndex = currentLogicalDigitIndex++;
        count++;
      }
      structure.add(
        _MaskSlot(
          patternChar: char,
          isPlaceholder: isPlaceholder,
          logicalDigitIndex: logicalIndex,
        ),
      );
    }
    _patternCache[pattern] = List.unmodifiable(structure);
    _placeholderCountCache[pattern] = count;
  }

  /// Checks if a given input can possibly match a given pattern.
  /// For patterns with consecutive placeholders at the start, all must be fillable
  /// by the available input, or the pattern is not a valid match.
  bool _canInputMatchPattern(String alphanumericInput, String pattern) {
    final List<_MaskSlot> mask = _patternCache[pattern]!;
    int inputIndex = 0;

    // Allow partial input: only check up to the length of the input
    for (final slot in mask) {
      if (slot.isPlaceholder) {
        if (inputIndex < alphanumericInput.length) {
          final inputChar = alphanumericInput[inputIndex];
          final patternChar = slot.patternChar;
          final isInputLetter = RegExp(r'[a-zA-Z]').hasMatch(inputChar);
          final isInputDigit = RegExp(r'[0-9]').hasMatch(inputChar);

          // Determine what type of input this placeholder expects
          bool expectsDigit = false;
          bool expectsLetter = false;

          if (patternChar == '#') {
            expectsDigit = true;
          } else if ('dMyHms'.contains(patternChar)) {
            // Date/time placeholders expect digits
            expectsDigit = true;
          } else {
            // Other letter placeholders (A, a, etc.) expect letters
            expectsLetter = true;
          }

          if (expectsDigit && !isInputDigit) return false;
          if (expectsLetter && !isInputLetter) return false;
          inputIndex++;
        } else {
          // No more input available for this placeholder, but that's fine for partial input
          break;
        }
      }
    }
    // Allow partial input, so do not reject if not all placeholders are filled
    return true;
  }

  /// Finds the best-fitting pattern from the list for the current input.
  /// Returns null if input violates pattern constraints.
  String? _findBestMatch(String alphanumericInput) {
    if (patterns.length == 1) {
      final pattern = patterns.first;
      // Check if input violates the pattern constraints
      if (!_canInputMatchPattern(alphanumericInput, pattern)) {
        return null;
      }
      return pattern;
    }

    // Find all patterns that could possibly match the input so far
    final List<String> matchingPatterns = [];
    for (final pattern in patterns) {
      final canMatch = _canInputMatchPattern(alphanumericInput, pattern);
      if (canMatch) {
        matchingPatterns.add(pattern);
      }
    }

    // If none match, reject the input
    if (matchingPatterns.isEmpty) {
      return null;
    }

    // Always prefer longer patterns (more specific) but consider pattern structure
    matchingPatterns.sort((a, b) {
      final countA = _placeholderCountCache[a]!;
      final countB = _placeholderCountCache[b]!;
      
      // For single character input, prefer patterns that start with single letter placeholders
      // over patterns that start with double letter placeholders
      if (alphanumericInput.length == 1) {
        final aStartsWithDoubleLetters = a.length >= 2 && 
                                        RegExp(r'[A-Za-z]').hasMatch(a[0]) && 
                                        RegExp(r'[A-Za-z]').hasMatch(a[1]);
        final bStartsWithDoubleLetters = b.length >= 2 && 
                                        RegExp(r'[A-Za-z]').hasMatch(b[0]) && 
                                        RegExp(r'[A-Za-z]').hasMatch(b[1]);
        
        if (aStartsWithDoubleLetters && !bStartsWithDoubleLetters) return 1; // b wins
        if (!aStartsWithDoubleLetters && bStartsWithDoubleLetters) return -1; // a wins
      }
      
      // Among patterns with similar structure, prefer longer ones
      final countCompare = countB.compareTo(countA); // Descending order (longer first)
      if (countCompare != 0) {
        return countCompare;
      }
      return b.length.compareTo(a.length);
    });

    return matchingPatterns.first;
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
    final String newAlphanumeric = newValue.text.replaceAll(
      RegExp(r'[^a-zA-Z0-9]'),
      '',
    );
    final String oldAlphanumeric = oldValue.text.replaceAll(
      RegExp(r'[^a-zA-Z0-9]'),
      '',
    );

    // Find the best matching pattern
    final String? bestPattern = _findBestMatch(newAlphanumeric);
    if (bestPattern == null) {
      // Input doesn't match any pattern - reject it
      return oldValue;
    }

    final List<_MaskSlot> maskStructure = _patternCache[bestPattern]!;
    final int placeholderCount = _placeholderCountCache[bestPattern]!;

    // Apply date/time validation if required
    if (inputType != PatternInputType.none) {
      if (!_validateInput(
        newAlphanumeric,
        bestPattern,
        maskStructure,
        placeholderCount,
      )) {
        return oldValue;
      }
    }

    // Calculate cursor position in alphanumeric string
    int cursorInAlphanumeric = _calculateCursorInAlphanumeric(
      newValue,
      oldValue,
      newAlphanumeric,
      oldAlphanumeric,
    );

    // Build the formatted string and calculate final cursor position
    final _FormattedResult result = _buildFormattedString(
      newAlphanumeric,
      maskStructure,
      cursorInAlphanumeric,
      placeholderCount,
    );

    return TextEditingValue(
      text: result.text,
      selection: TextSelection.collapsed(offset: result.cursorPosition),
    );
  }

  /// Calculates the cursor position within the alphanumeric string
  int _calculateCursorInAlphanumeric(
    TextEditingValue newValue,
    TextEditingValue oldValue,
    String newAlphanumeric,
    String oldAlphanumeric,
  ) {
    // Check if this is a replacement rather than a deletion
    // Replacement typically occurs when:
    // 1. New text is shorter than old text
    // 2. Cursor is at the end of new text
    // 3. New text doesn't start with the same characters as old text
    final bool isReplacement = newAlphanumeric.length < oldAlphanumeric.length &&
        newValue.selection.baseOffset == newValue.text.length &&
        !oldAlphanumeric.startsWith(newAlphanumeric);

    if (newAlphanumeric.length < oldAlphanumeric.length && !isReplacement) {
      // This is a true deletion - find the cursor position in the old value
      final int oldCursor = oldValue.selection.baseOffset.clamp(0, oldValue.text.length);
      
      // Count alphanumeric characters before the old cursor position
      int alphanumericBeforeOldCursor = 0;
      for (int i = 0; i < oldCursor && i < oldValue.text.length; i++) {
        if (RegExp(r'[a-zA-Z0-9]').hasMatch(oldValue.text[i])) {
          alphanumericBeforeOldCursor++;
        }
      }
      
      // For deletion, the cursor should be positioned at the deletion point
      return (alphanumericBeforeOldCursor - (oldAlphanumeric.length - newAlphanumeric.length))
          .clamp(0, newAlphanumeric.length);
    }

    // For additions or replacements, calculate based on new cursor position
    final int newCursor = newValue.selection.baseOffset.clamp(0, newValue.text.length);
    
    // Count alphanumeric characters before the new cursor position
    int alphanumericBeforeNewCursor = 0;
    for (int i = 0; i < newCursor && i < newValue.text.length; i++) {
      if (RegExp(r'[a-zA-Z0-9]').hasMatch(newValue.text[i])) {
        alphanumericBeforeNewCursor++;
      }
    }

    return alphanumericBeforeNewCursor.clamp(0, newAlphanumeric.length);
  }

  /// Builds the formatted string and calculates cursor position
  _FormattedResult _buildFormattedString(
    String alphanumericInput,
    List<_MaskSlot> maskStructure,
    int cursorInAlphanumeric,
    int placeholderCount,
  ) {
    final buffer = StringBuffer();
    int alphanumericIndex = 0;
    int cursorPosition = 0;
    bool cursorSet = false;

    for (int i = 0; i < maskStructure.length; i++) {
      final slot = maskStructure[i];

      if (slot.isPlaceholder) {
        if (alphanumericIndex < alphanumericInput.length) {
          // We have input for this placeholder
          String char = alphanumericInput[alphanumericIndex];
          
          // Apply case conversion
          if (letterCase == LetterCase.upper) {
            char = char.toUpperCase();
          } else if (letterCase == LetterCase.lower) {
            char = char.toLowerCase();
          }
          
          buffer.write(char);
          alphanumericIndex++;

          // Check if cursor should be positioned after this character
          if (alphanumericIndex == cursorInAlphanumeric && !cursorSet) {
            // Set initial cursor position after this character
            cursorPosition = buffer.length;
            
            // Look ahead to skip over any immediate separators
            for (int j = i + 1; j < maskStructure.length; j++) {
              if (!maskStructure[j].isPlaceholder) {
                // This is a separator that will be added - factor it in
                cursorPosition += maskStructure[j].patternChar.length;
              } else {
                // Hit the next placeholder - stop looking ahead
                break;
              }
            }
            
            cursorSet = true;
          }
        } else {
          // No more input - show placeholder or stop
          if (alphanumericInput.isEmpty) {
            // If no input at all, don't show placeholders
            break;
          }
          
          final placeholder = placeholderChar ??
              (slot.patternChar == '#' ? '#' : slot.patternChar.toUpperCase());
          buffer.write(placeholder);
        }
      } else {
        // This is a separator character
        if (alphanumericInput.isEmpty) {
          // If no input, don't add separators
          break;
        }
        
        buffer.write(slot.patternChar);
        
        // If cursor should be positioned after separators following the last entered character
        if (alphanumericIndex == cursorInAlphanumeric && !cursorSet) {
          cursorPosition = buffer.length;
          cursorSet = true;
        }
      }
    }

    // If cursor wasn't set yet and we have input, place it at the end of actual input
    if (!cursorSet) {
      cursorPosition = buffer.length;
    }

    return _FormattedResult(
      text: buffer.toString(),
      cursorPosition: cursorPosition.clamp(0, buffer.length),
    );
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
    ];
  }

  /// Validates the input string for date/time/datetime types using case-sensitive placeholders.
  /// d: day, M: month, y: year, H: hour (0-23), m: minute, s: second.
  bool _validateInput(
    String input,
    String pattern,
    List<_MaskSlot> maskStructure,
    int placeholderCount,
  ) {
    // 1. Find logical indices and counts of all supported placeholders.
    int dLI = -1, MLI = -1, yLI = -1, HLI = -1, mLI = -1, sLI = -1;
    int dC = 0, MC = 0, yC = 0, HC = 0, mC = 0, sC = 0;

    for (final slot in maskStructure) {
      if (slot.isPlaceholder) {
        final pChar = slot.patternChar; // Case-sensitive
        switch (pChar) {
          case 'd':
            if (dLI == -1) dLI = slot.logicalDigitIndex;
            dC++;
            break;
          case 'M':
            if (MLI == -1) MLI = slot.logicalDigitIndex;
            MC++;
            break;
          case 'y':
            if (yLI == -1) yLI = slot.logicalDigitIndex;
            yC++;
            break;
          case 'H':
            if (HLI == -1) HLI = slot.logicalDigitIndex;
            HC++;
            break;
          case 'm':
            if (mLI == -1) mLI = slot.logicalDigitIndex;
            mC++;
            break;
          case 's':
            if (sLI == -1) sLI = slot.logicalDigitIndex;
            sC++;
            break;
        }
      }
    }

    // --- DATE VALIDATION ---
    final bool hasDate = dLI != -1 && MLI != -1 && yLI != -1;
    if (hasDate &&
        (inputType == PatternInputType.date ||
            inputType == PatternInputType.datetime)) {
      final dayEnd = dLI + dC;
      final monthEnd = MLI + MC;
      final yearEnd = yLI + yC;

      // Validate month as soon as it's filled
      if (input.length >= monthEnd) {
        final monthStr = input.substring(MLI, monthEnd);
        final month = int.tryParse(monthStr);
        if (month == null || month < 1 || month > 12) {
          return false;
        }
      }

      // Validate day as soon as it's filled
      if (input.length >= dayEnd) {
        final dayStr = input.substring(dLI, dayEnd);
        final day = int.tryParse(dayStr);
        if (day == null || day < 1) {
          return false;
        }

        final monthStr = input.length >= monthEnd
            ? input.substring(MLI, monthEnd)
            : '';
        final month = int.tryParse(monthStr);
        final yearIsFullyEntered = input.length >= yearEnd;

        if (month == 2 && !yearIsFullyEntered) {
          if (day > 29)
            return false; // Allow up to 29 for leap year possibility
        } else if (month != null) {
          if (day > 31) return false; // Check against generic max days
        } else {
          if (day > 31) return false; // Month not entered, check generic max
        }
      }

      // Perform strict day/month/year validation only when all fields are filled
      final allDateFieldsPresent =
          input.length >= dayEnd &&
          input.length >= monthEnd &&
          input.length >= yearEnd;
      if (allDateFieldsPresent) {
        final dayStr = input.substring(dLI, dayEnd);
        final monthStr = input.substring(MLI, monthEnd);
        final yearStr = input.substring(yLI, yearEnd);

        final day = int.tryParse(dayStr);
        final month = int.tryParse(monthStr);
        final year = int.tryParse(yearStr);
        if (month! < 1 || month > 12 || day == null || day < 1) {
          return false;
        }

        final daysInMonth = _daysInMonth(year!, month);
        if (day > daysInMonth) return false;
      }
    }

    // --- TIME VALIDATION ---
    final bool hasTime = HLI != -1 && mLI != -1;
    if (hasTime &&
        (inputType == PatternInputType.time ||
            inputType == PatternInputType.datetime)) {
      final hourEnd = HLI + HC;
      final minuteEnd = mLI + mC;

      if (input.length >= hourEnd) {
        final hourStr = input.substring(HLI, hourEnd);
        final hour = int.tryParse(hourStr);
        if (hour == null || hour < 0 || hour > 23) {
          return false;
        }
      }

      if (input.length >= minuteEnd) {
        final minuteStr = input.substring(mLI, minuteEnd);
        final minute = int.tryParse(minuteStr);
        if (minute == null || minute < 0 || minute > 59) {
          return false;
        }
      }

      // Seconds are optional
      if (sLI != -1) {
        final secondEnd = sLI + sC;
        if (input.length >= secondEnd) {
          final secondStr = input.substring(sLI, secondEnd);
          final second = int.tryParse(secondStr);
          if (second == null || second < 0 || second > 59) {
            return false;
          }
        }
      }
    }

    return true;
  }

  int _daysInMonth(int year, int month) {
    if (month == 2) {
      // Leap year check
      if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
        return 29;
      } else {
        return 28;
      }
    }
    const monthDays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return monthDays[month - 1];
  }
}
