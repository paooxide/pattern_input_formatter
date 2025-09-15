import 'types.dart';
import 'pattern_detector.dart';

class PatternMatcher {
  final Map<String, List<MaskSlot>> _patternCache = {};
  final Map<String, int> _placeholderCountCache = {};
  final RegExp _placeholderRegex = RegExp(r'[A-Za-z#]');

  /// Builds and caches the mask structure for a pattern
  void buildAndCacheMaskStructure(String pattern) {
    final structure = <MaskSlot>[];
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

      final slot = MaskSlot(
        patternChar: char,
        isPlaceholder: isPlaceholder,
        logicalDigitIndex: logicalIndex,
      );

      structure.add(slot);
    }

    _patternCache[pattern] = List.unmodifiable(structure);
    _placeholderCountCache[pattern] = count;
  }

  /// Gets cached mask structure for a pattern
  List<MaskSlot> getMaskStructure(String pattern) {
    return _patternCache[pattern]!;
  }

  /// Gets cached placeholder count for a pattern
  int getPlaceholderCount(String pattern) {
    return _placeholderCountCache[pattern]!;
  }

  /// Checks if input can match a pattern
  bool canInputMatchPattern(
    String alphanumericInput,
    String pattern,
    PatternInputType inputType,
  ) {
    final List<MaskSlot> mask = _patternCache[pattern]!;
    int inputIndex = 0;

    // Allow partial input: only check up to the length of the input
    for (int slotIndex = 0; slotIndex < mask.length; slotIndex++) {
      final slot = mask[slotIndex];

      if (slot.isPlaceholder) {
        if (inputIndex < alphanumericInput.length) {
          final inputChar = alphanumericInput[inputIndex];
          final patternChar = slot.patternChar;
          final isInputLetter = RegExp(r'[a-zA-Z]').hasMatch(inputChar);
          final isInputDigit = RegExp(r'[0-9]').hasMatch(inputChar);

          final expectsDigit = PatternDetector.expectsDigit(
            patternChar,
            pattern,
            inputType,
          );
          final expectsLetter = !expectsDigit;

          if (expectsDigit && !isInputDigit) {
            return false;
          }
          if (expectsLetter && !isInputLetter) {
            return false;
          }
          inputIndex++;
        } else {
          // No more input available for this placeholder, but that's fine for partial input
          break;
        }
      }
      // Separators don't consume input - just skip them
    }

    return true;
  }

  /// Finds the best matching pattern for the input
  String? findBestMatch(
    List<String> patterns,
    String alphanumericInput,
    PatternInputType inputType,
  ) {
    if (patterns.length == 1) {
      final pattern = patterns.first;
      if (!canInputMatchPattern(alphanumericInput, pattern, inputType)) {
        return null;
      }
      return pattern;
    }

    // Find all patterns that could possibly match the input so far
    final List<String> matchingPatterns = [];
    for (final pattern in patterns) {
      final canMatch = canInputMatchPattern(
        alphanumericInput,
        pattern,
        inputType,
      );
      if (canMatch) {
        matchingPatterns.add(pattern);
      }
    }

    // If none match, reject the input
    if (matchingPatterns.isEmpty) {
      return null;
    }

    // If only one pattern matches, it's the best one.
    if (matchingPatterns.length == 1) {
      return matchingPatterns.first;
    }

    // Sort by best match - prefer patterns that exactly match input structure
    matchingPatterns.sort((a, b) {
      final countA = _placeholderCountCache[a]!;
      final countB = _placeholderCountCache[b]!;

      // Calculate how well each pattern fits the current input
      final scoreA = _calculatePatternScore(alphanumericInput, a, inputType);
      final scoreB = _calculatePatternScore(alphanumericInput, b, inputType);

      // Prefer higher scores (better fit)
      if (scoreA != scoreB) {
        return scoreB.compareTo(scoreA);
      }

      // For single character input, prefer patterns that don't start with double letters
      if (alphanumericInput.length == 1) {
        final aStartsWithDoubleLetters =
            a.length >= 2 &&
            RegExp(r'[A-Za-z]').hasMatch(a[0]) &&
            RegExp(r'[A-Za-z]').hasMatch(a[1]);
        final bStartsWithDoubleLetters =
            b.length >= 2 &&
            RegExp(r'[A-Za-z]').hasMatch(b[0]) &&
            RegExp(r'[A-Za-z]').hasMatch(b[1]);

        if (aStartsWithDoubleLetters && !bStartsWithDoubleLetters) {
          return 1; // b wins
        }
        if (!aStartsWithDoubleLetters && bStartsWithDoubleLetters) {
          return -1; // a wins
        }
      }

      // Among patterns with similar scores, prefer longer ones (more placeholders)
      final countCompare = countB.compareTo(
        countA,
      ); // Descending order (longer first)
      if (countCompare != 0) {
        return countCompare;
      }

      // If same number of placeholders, prefer longer pattern string
      return b.length.compareTo(a.length);
    });

    final selectedPattern = matchingPatterns.first;
    return selectedPattern;
  }

  /// Calculate how well a pattern fits the current input
  /// Higher score means better fit
  int _calculatePatternScore(
    String alphanumericInput,
    String pattern,
    PatternInputType inputType,
  ) {
    final List<MaskSlot> mask = _patternCache[pattern]!;
    int inputIndex = 0;
    int score = 0;
    bool foundSeparator = false;
    int placeholdersBeforeSeparator = 0;
    int placeholdersAfterSeparator = 0;

    // Count placeholders before and after first separator
    for (final slot in mask) {
      if (slot.isPlaceholder) {
        if (!foundSeparator) {
          placeholdersBeforeSeparator++;
        } else {
          placeholdersAfterSeparator++;
        }
      } else if (!foundSeparator) {
        foundSeparator = true;
      }
    }

    // Check how well the input matches the pattern structure
    for (final slot in mask) {
      if (slot.isPlaceholder) {
        if (inputIndex < alphanumericInput.length) {
          final inputChar = alphanumericInput[inputIndex];
          final patternChar = slot.patternChar;
          final isInputLetter = RegExp(r'[a-zA-Z]').hasMatch(inputChar);
          final isInputDigit = RegExp(r'[0-9]').hasMatch(inputChar);

          final expectsDigit = PatternDetector.expectsDigit(
            patternChar,
            pattern,
            inputType,
          );
          final expectsLetter = !expectsDigit;

          // Check if this placeholder can actually accept this input
          if ((expectsDigit && isInputDigit) ||
              (expectsLetter && isInputLetter)) {
            score += 10; // Base score for matching placeholder
            inputIndex++;
          } else {
            // Input doesn't match this placeholder type, heavily penalize
            score -= 100;
            break;
          }
        } else {
          break; // No more input
        }
      }
      // Separators don't consume input - just skip them
    }

    // Bonus scoring for patterns that better match input structure
    if (inputType == PatternInputType.postal ||
        inputType == PatternInputType.serial) {
      // For postal/serial, prefer patterns where the input length makes sense
      // relative to the separator position
      if (alphanumericInput.length > placeholdersBeforeSeparator) {
        // We have input beyond the first segment
        final inputAfterSeparator =
            alphanumericInput.length - placeholdersBeforeSeparator;
        if (inputAfterSeparator <= placeholdersAfterSeparator) {
          // The remaining input fits well in the second segment
          score += 20;
        }

        // Special bonus for exact fit patterns
        if (alphanumericInput.length ==
            placeholdersBeforeSeparator + placeholdersAfterSeparator) {
          score += 30;
        }
      }
    }

    return score;
  }
}
