// Date and time validation logic
import 'types.dart';

class DateTimeValidator {
  /// Validates date/time input according to the pattern
  static bool validateInput(
    String input,
    String pattern,
    List<MaskSlot> maskStructure,
    PatternInputType inputType,
  ) {
    // Only validate for date/time types
    if (inputType == PatternInputType.none) return true;

    // Find logical indices and counts of all supported placeholders
    // ignore: non_constant_identifier_names
    int dLI = -1, MLI = -1, yLI = -1, HLI = -1, mLI = -1, sLI = -1;
    // ignore: non_constant_identifier_names
    int dC = 0, MC = 0, yC = 0, HC = 0, mC = 0, sC = 0;

    for (final slot in maskStructure) {
      if (slot.isPlaceholder) {
        final pChar = slot.patternChar;
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

    // Validate date components
    if (_hasDateComponents(dLI, MLI, yLI) && _isDateInputType(inputType)) {
      if (!_validateDateComponents(input, dLI, dC, MLI, MC, yLI, yC)) {
        return false;
      }
    }

    // Validate time components
    if (_hasTimeComponents(HLI, mLI) && _isTimeInputType(inputType)) {
      if (!_validateTimeComponents(input, HLI, HC, mLI, mC, sLI, sC)) {
        return false;
      }
    }

    return true;
  }

  // ignore: non_constant_identifier_names
  static bool _hasDateComponents(int dLI, int MLI, int yLI) {
    return dLI != -1 && MLI != -1 && yLI != -1;
  }

  // ignore: non_constant_identifier_names
  static bool _hasTimeComponents(int HLI, int mLI) {
    return HLI != -1 && mLI != -1;
  }

  static bool _isDateInputType(PatternInputType inputType) {
    return inputType == PatternInputType.date ||
        inputType == PatternInputType.datetime;
  }

  static bool _isTimeInputType(PatternInputType inputType) {
    return inputType == PatternInputType.time ||
        inputType == PatternInputType.datetime;
  }

  // ignore: non_constant_identifier_names
  static bool _validateDateComponents(
    String input,
    int dLI,
    int dC,
    int MLI,
    int MC,
    int yLI,
    int yC,
  ) {
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

      // Basic day validation
      final monthStr = input.length >= monthEnd
          ? input.substring(MLI, monthEnd)
          : '';
      final month = int.tryParse(monthStr);
      final yearIsFullyEntered = input.length >= yearEnd;

      if (month == 2 && !yearIsFullyEntered) {
        if (day > 29) return false; // Allow up to 29 for leap year possibility
      } else if (month != null) {
        if (day > 31) return false; // Check against generic max days
      } else {
        if (day > 31) return false; // Month not entered, check generic max
      }
    }

    // Strict validation when all date fields are complete
    if (input.length >= dayEnd &&
        input.length >= monthEnd &&
        input.length >= yearEnd) {
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

    return true;
  }

  // ignore: non_constant_identifier_names
  static bool _validateTimeComponents(
    String input,
    int HLI,
    int HC,
    int mLI,
    int mC,
    int sLI,
    int sC,
  ) {
    final hourEnd = HLI + HC;
    final minuteEnd = mLI + mC;

    // Validate hours
    if (input.length >= hourEnd) {
      final hourStr = input.substring(HLI, hourEnd);
      final hour = int.tryParse(hourStr);
      if (hour == null || hour < 0 || hour > 23) {
        return false;
      }
    }

    // Validate minutes
    if (input.length >= minuteEnd) {
      final minuteStr = input.substring(mLI, minuteEnd);
      final minute = int.tryParse(minuteStr);
      if (minute == null || minute < 0 || minute > 59) {
        return false;
      }
    }

    // Validate seconds (optional)
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

    return true;
  }

  static int _daysInMonth(int year, int month) {
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
