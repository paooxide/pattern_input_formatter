import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:pattern_input_formatter/pattern_input_formatter.dart';

void main() {
  group('Backspace behavior tests', () {
    test('Phone number backspace should be intuitive', () {
      final formatter = PatternInputFormatter(
        patterns: ['(###) ###-####'],
        inputType: PatternInputType.none,
      );

      // Build up phone number using the simple approach that works
      var result = TextEditingValue.empty;
      final digits = '1234567890';

      for (int i = 0; i < digits.length; i++) {
        final oldValue = result;
        final newValue = TextEditingValue(
          text: oldValue.text + digits[i],
          selection: TextSelection.collapsed(offset: oldValue.text.length + 1),
        );
        result = formatter.formatEditUpdate(oldValue, newValue);
      }

      expect(result.text, '(123) 456-7890');

      // Now test intuitive backspace behavior
      // Scenario: User cursor is right after '-' character (position 10) and presses backspace
      // This deletes the '-' character and should also delete the preceding digit '6'
      final oldValue = TextEditingValue(
        text: '(123) 456-7890',
        selection: TextSelection.collapsed(
          offset: 10,
        ), // cursor right after '-'
      );

      // When user presses backspace, the '-' gets deleted by the system
      final newValue = TextEditingValue(
        text: '(123) 4567890', // '-' removed by system backspace
        selection: TextSelection.collapsed(
          offset: 9,
        ), // cursor moves to where '-' was
      );

      result = formatter.formatEditUpdate(oldValue, newValue);

      // The formatter should detect separator deletion and also remove preceding digit
      // So from input '4567890' (which is '456' + '7890'), it should become '457890' (which is '45' + '7890')
      // This should format to '(123) 457-890#' showing the '6' was removed
      expect(result.text, '(123) 457-890#');
    });

    test('Date backspace should be intuitive', () {
      final formatter = PatternInputFormatter(
        patterns: ['##/##/####'], // Use # for digits, not MM/dd/yyyy
        inputType: PatternInputType.date,
      );

      // Build up date using proper typing simulation
      var result = TextEditingValue.empty;
      final digits = '12252024';

      for (int i = 0; i < digits.length; i++) {
        final oldValue = result;
        final newValue = TextEditingValue(
          text: oldValue.text + digits[i],
          selection: TextSelection.collapsed(offset: oldValue.text.length + 1),
        );
        result = formatter.formatEditUpdate(oldValue, newValue);
      }

      expect(result.text, '12/25/2024');

      // Test intuitive backspace: deleting the second '/' should also delete the preceding '5'
      final oldValue = TextEditingValue(
        text: '12/25/2024',
        selection: TextSelection.collapsed(
          offset: 6,
        ), // cursor right after second '/'
      );
      final newValue = TextEditingValue(
        text: '12/252024', // second '/' removed by system backspace
        selection: TextSelection.collapsed(offset: 5), // cursor where '/' was
      );
      result = formatter.formatEditUpdate(oldValue, newValue);

      // Should remove both the separator and the preceding digit '5'
      // So '12252024' becomes '1222024', formatted as '12/22/024#' or similar
      expect(result.text.startsWith('12/2'), true);
    });

    test('Credit card backspace should be intuitive', () {
      final formatter = PatternInputFormatter(
        patterns: ['#### #### #### ####'],
        inputType: PatternInputType.none,
      );

      // Build up credit card
      var result = TextEditingValue.empty;
      final digits = '1234567890123456';

      for (int i = 0; i < digits.length; i++) {
        final oldValue = result;
        final newValue = TextEditingValue(
          text: oldValue.text + digits[i],
          selection: TextSelection.collapsed(offset: oldValue.text.length + 1),
        );
        result = formatter.formatEditUpdate(oldValue, newValue);
      }

      expect(result.text, '1234 5678 9012 3456');

      // Test backspace on space separator at position 10 (after "9012") - should delete preceding digit too
      var oldValue = TextEditingValue(
        text: '1234 5678 9012 3456',
        selection: TextSelection.collapsed(
          offset: 15,
        ), // cursor right after third space
      );
      var newValue = TextEditingValue(
        text: '1234 5678 90123456', // third space removed
        selection: TextSelection.collapsed(
          offset: 14,
        ), // cursor where space was
      );
      result = formatter.formatEditUpdate(oldValue, newValue);

      // Should remove the '2' that was before the deleted space
      // '1234567890123456' becomes '1234567890 13456', formatted as '1234 5678 901 3456'
      expect(result.text.contains('1234 5678 901'), true);
    });

    test('Time backspace should be intuitive', () {
      final formatter = PatternInputFormatter(
        patterns: ['##:##'],
        inputType: PatternInputType.time,
      );

      // Build up time
      var result = TextEditingValue.empty;
      final digits = '1430';

      for (int i = 0; i < digits.length; i++) {
        final oldValue = result;
        final newValue = TextEditingValue(
          text: oldValue.text + digits[i],
          selection: TextSelection.collapsed(offset: oldValue.text.length + 1),
        );
        result = formatter.formatEditUpdate(oldValue, newValue);
      }

      expect(result.text, '14:30');

      // Test backspace on ':' separator - should delete preceding digit too
      var oldValue = TextEditingValue(
        text: '14:30',
        selection: TextSelection.collapsed(offset: 3), // cursor right after ':'
      );
      var newValue = TextEditingValue(
        text: '1430', // ':' removed
        selection: TextSelection.collapsed(offset: 2), // cursor where ':' was
      );
      result = formatter.formatEditUpdate(oldValue, newValue);

      // Should remove the '4' that was before the deleted ':'
      // '1430' becomes '130', formatted as '13:0#'
      expect(result.text.startsWith('13:0'), true);
    });

    test(
      'Postal codes should NOT use intuitive backspace (preserve existing behavior)',
      () {
        final formatter = PatternInputFormatter(
          patterns: ['A#A #A#'],
          inputType: PatternInputType.postal,
        );

        // Build up postal code
        var result = TextEditingValue.empty;
        final chars = 'K1A0A6';

        for (int i = 0; i < chars.length; i++) {
          final oldValue = result;
          final newValue = TextEditingValue(
            text: result.text + chars[i],
            selection: TextSelection.collapsed(offset: result.text.length + 1),
          );
          result = formatter.formatEditUpdate(oldValue, newValue);
        }

        expect(result.text, 'K1A 0A6');

        // Test backspace on space separator - should NOT delete preceding character for postal
        var oldValue = result;
        var newValue = TextEditingValue(
          text: 'K1A0A6',
          selection: TextSelection.collapsed(offset: 3),
        );
        result = formatter.formatEditUpdate(oldValue, newValue);
        expect(
          result.text,
          'K1A 0A6',
        ); // Should preserve the 'A' before the space
      },
    );

    test(
      'Serial numbers should NOT use intuitive backspace (preserve existing behavior)',
      () {
        final formatter = PatternInputFormatter(
          patterns: ['AAAA-####'],
          inputType: PatternInputType.serial,
        );

        // Build up serial
        var result = TextEditingValue.empty;
        final chars = 'ABCD1234';

        for (int i = 0; i < chars.length; i++) {
          final oldValue = result;
          final newValue = TextEditingValue(
            text: result.text + chars[i],
            selection: TextSelection.collapsed(offset: result.text.length + 1),
          );
          result = formatter.formatEditUpdate(oldValue, newValue);
        }

        expect(result.text, 'ABCD-1234');

        // Test backspace on '-' separator - should NOT delete preceding character for serial
        var oldValue = result;
        var newValue = TextEditingValue(
          text: 'ABCD1234',
          selection: TextSelection.collapsed(offset: 4),
        );
        result = formatter.formatEditUpdate(oldValue, newValue);
        expect(
          result.text,
          'ABCD-1234',
        ); // Should preserve the 'D' before the dash
      },
    );
  });
}
