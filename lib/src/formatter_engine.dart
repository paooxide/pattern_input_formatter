// String formatting and cursor positioning logic
import 'package:flutter/services.dart';
import 'types.dart';
import 'pattern_detector.dart';

class FormatterEngine {
  /// Builds the formatted string and calculates cursor position
  static FormattedResult buildFormattedString(
    String alphanumericInput,
    List<MaskSlot> maskStructure,
    int cursorInAlphanumeric,
    PatternInputType inputType,
    LetterCase letterCase,
    String? placeholderChar,
  ) {
    final buffer = StringBuffer();
    int alphanumericIndex = 0;
    int cursorPosition = 0;
    bool cursorSet = false;

    // Build current pattern string for auto-detection
    String currentPattern = '';
    for (final slot in maskStructure) {
      currentPattern += slot.patternChar;
    }

    // Debug: Print the input being processed

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
            // Set cursor position after this character
            cursorPosition = buffer.length;
            cursorSet = true;
          }
        } else {
          // No more input - decide whether to show placeholders
          if (alphanumericInput.isEmpty) {
            // If no input at all, don't show placeholders
            break;
          }

          final shouldShow = PatternDetector.shouldShowPlaceholders(
            inputType,
            currentPattern,
          );

          if (shouldShow) {
            if (placeholderChar != null) {
              // If a specific placeholder character was provided, use it
              buffer.write(placeholderChar);
            } else {
              // Show default placeholders
              final placeholder = slot.patternChar == '#'
                  ? '#'
                  : slot.patternChar.toUpperCase();
              buffer.write(placeholder);
            }
          } else {
            // Don't show placeholders - just stop here
            break;
          }
        }
      } else {
        // This is a separator character
        if (alphanumericInput.isEmpty) {
          // If no input, don't add separators
          break;
        }

        final shouldAdd = _shouldAddSeparator(
          maskStructure,
          i,
          alphanumericIndex,
          alphanumericInput,
          inputType,
          currentPattern,
        );

        if (shouldAdd) {
          buffer.write(slot.patternChar);

          // If cursor was just set at the previous position and we're adding a separator,
          // move the cursor to after the separator
          if (cursorSet && cursorPosition == buffer.length - 1) {
            cursorPosition = buffer.length;
          }
        }
      }
    }

    // If cursor wasn't set yet and we have input, place it at the end
    if (!cursorSet) {
      cursorPosition = buffer.length;
    }

    final result = FormattedResult(
      text: buffer.toString(),
      cursorPosition: cursorPosition.clamp(0, buffer.length),
    );

    return result;
  }

  /// Determines if a separator should be added
  static bool _shouldAddSeparator(
    List<MaskSlot> maskStructure,
    int separatorIndex,
    int alphanumericIndex,
    String alphanumericInput,
    PatternInputType inputType,
    String currentPattern,
  ) {
    // Count placeholders before this separator
    int placeholdersBefore = 0;
    for (int j = 0; j < separatorIndex; j++) {
      if (maskStructure[j].isPlaceholder) {
        placeholdersBefore++;
      }
    }

    // For postal/serial types: be more precise about when to add separators
    if (inputType == PatternInputType.postal ||
        inputType == PatternInputType.serial) {
      // Add separator only if we have filled all placeholders before it AND have more input
      if (placeholdersBefore > 0 && alphanumericIndex >= placeholdersBefore) {
        // Check if there are more placeholders after this separator
        bool hasPlaceholdersAfter = false;
        for (int j = separatorIndex + 1; j < maskStructure.length; j++) {
          if (maskStructure[j].isPlaceholder) {
            hasPlaceholdersAfter = true;
            break;
          }
        }
        // Add separator if there are placeholders after it AND we have more input than just the filled placeholders
        return hasPlaceholdersAfter &&
            alphanumericInput.length > placeholdersBefore;
      }
      return false;
    } else {
      // For date/time/phone/credit card: add separators more liberally to show structure
      if (placeholdersBefore > 0 &&
          (alphanumericIndex > 0 || alphanumericInput.isNotEmpty)) {
        return true;
      } else if (placeholdersBefore == 0 && alphanumericInput.isNotEmpty) {
        // Leading separator with input
        return true;
      }
    }

    return false;
  }

  /// Calculates the cursor position within the alphanumeric string
  static int calculateCursorInAlphanumeric(TextEditingValue newValue) {
    final newCursor = newValue.selection.baseOffset;
    int count = 0;
    for (int i = 0; i < newCursor; i++) {
      if (RegExp(r'[a-zA-Z0-9]').hasMatch(newValue.text[i])) {
        count++;
      }
    }
    return count;
  }
}
