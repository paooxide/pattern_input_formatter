enum LetterCase {
  /// Convert all alphabetic characters to uppercase.
  upper,

  /// Convert all alphabetic characters to lowercase.
  lower,

  /// Allow any case (no conversion).
  any,
}

enum PatternInputType {
  none,
  date,
  time,
  datetime,
  phone,
  postal,
  serial,
  creditCard,
}

class MaskSlot {
  final String patternChar;
  final bool isPlaceholder;
  final int logicalDigitIndex;

  const MaskSlot({
    required this.patternChar,
    required this.isPlaceholder,
    required this.logicalDigitIndex,
  });
}

class FormattedResult {
  final String text;
  final int cursorPosition;

  const FormattedResult({required this.text, required this.cursorPosition});
}
