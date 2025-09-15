import 'types.dart';

class PatternDetector {
  /// Determines if a pattern contains date/time placeholders and separators
  static bool isDateTimePattern(String pattern) {
    return pattern.contains(RegExp(r'[/\-:]')) &&
        pattern.contains(RegExp(r'[dMyHms]'));
  }

  /// Determines what kind of input a pattern character expects
  static bool expectsDigit(
    String patternChar,
    String fullPattern,
    PatternInputType inputType,
  ) {
    if (patternChar == '#') {
      return true;
    }

    if ('dMyHms'.contains(patternChar)) {
      // Date/time placeholders: expect digits when inputType is date/time related
      // OR when inputType is none but pattern looks like a date/time pattern
      bool isDateTimePattern =
          inputType == PatternInputType.date ||
          inputType == PatternInputType.time ||
          inputType == PatternInputType.datetime;

      // Auto-detect date/time patterns when inputType is none
      if (!isDateTimePattern && inputType == PatternInputType.none) {
        isDateTimePattern = PatternDetector.isDateTimePattern(fullPattern);
      }

      return isDateTimePattern;
    }

    return false; // Letter placeholders expect letters
  }

  /// Determines if placeholders should be shown for the given input type and pattern
  static bool shouldShowPlaceholders(
    PatternInputType inputType,
    String pattern,
  ) {
    // For postal codes, serial numbers, etc., don't show placeholders
    if (inputType == PatternInputType.postal ||
        inputType == PatternInputType.serial) {
      return false;
    }

    return true; // Show placeholders for phone, credit card, date/time, etc.
  }
}
