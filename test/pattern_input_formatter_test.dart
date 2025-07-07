import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/pattern_input_formatter_refactored.dart';

void main() {
  group('PatternInputFormatter', () {
    group('Date Patterns', () {
      test('should format initial input correctly for dd/MM/yyyy', () {
        final formatter = PatternInputFormatter(patterns: ['dd/MM/yyyy']);
        const oldValue = TextEditingValue.empty;
        const newValue = TextEditingValue(
          text: '1',
          selection: TextSelection.collapsed(offset: 1),
        );
        final result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, '1D/MM/YYYY');
        expect(result.selection.baseOffset, 1);
      });

      test('should format second digit correctly for dd/MM/yyyy', () {
        final formatter = PatternInputFormatter(patterns: ['dd/MM/yyyy']);
        // Simulate state after '1' was typed
        TextEditingValue oldValue = const TextEditingValue(
          text: '1', // This is what the user sees as raw input from digitsOnly
          selection: TextSelection.collapsed(offset: 1),
        );
        // User types '2'
        TextEditingValue newValue = const TextEditingValue(
          text: '12',
          selection: TextSelection.collapsed(offset: 2),
        );
        final result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, '12/MM/YYYY');
        // Cursor should be after '12/', which is index 3
        expect(result.selection.baseOffset, 3);
      });

      test('should format full date correctly for dd/MM/yyyy', () {
        final formatter = PatternInputFormatter(patterns: ['dd/MM/yyyy']);
        TextEditingValue oldValue = const TextEditingValue(
          text: '3009202', // User has typed up to this point
          selection: TextSelection.collapsed(offset: 7),
        );
        // User types '3'
        TextEditingValue newValue = const TextEditingValue(
          text: '30092023',
          selection: TextSelection.collapsed(offset: 8),
        );
        final result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, '30/09/2023');
        // Cursor should be at the end
        expect(result.selection.baseOffset, 10);
      });

      test('should format full date with placeholderChar for MM-dd-yy', () {
        final formatter = PatternInputFormatter(
          patterns: ['MM-dd-yy'],
          placeholderChar: '_',
        );
        TextEditingValue oldValue = const TextEditingValue(
          text: '12312', // User has typed up to this point
          selection: TextSelection.collapsed(offset: 5),
        );
        // User types '3'
        TextEditingValue newValue = const TextEditingValue(
          text: '123123',
          selection: TextSelection.collapsed(offset: 6),
        );
        final result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, '12-31-23');
        expect(result.selection.baseOffset, 8);
      });

      test('should handle backspace correctly', () {
        final formatter = PatternInputFormatter(patterns: ['dd/MM/yyyy']);
        // Simulate state: '12/MM/YYYY' with cursor after '/'
        // Raw digits entered so far: "12"
        TextEditingValue oldValue = const TextEditingValue(
          text: '12', // Raw digits before backspace
          selection: TextSelection.collapsed(
            offset: 2,
          ), // Cursor was at the end of "12"
        );
        // User presses backspace, removing '2'
        TextEditingValue newValue = const TextEditingValue(
          text: '1', // Raw digits after backspace
          selection: TextSelection.collapsed(offset: 1), // Cursor is after '1'
        );
        final result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, '1D/MM/YYYY');
        expect(result.selection.baseOffset, 1);
      });

      test('should handle pasting a valid full date string', () {
        final formatter = PatternInputFormatter(patterns: ['dd/MM/yyyy']);
        const oldValue = TextEditingValue.empty;
        // User pastes '25122023'
        const newValue = TextEditingValue(
          text: '25122023',
          selection: TextSelection.collapsed(
            offset: 8,
          ), // Cursor at the end of pasted content
        );
        final result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, '25/12/2023');
        expect(result.selection.baseOffset, 10);
      });

      test('should handle pasting a string with non-digits', () {
        final formatter = PatternInputFormatter(patterns: ['dd/MM/yyyy']);
        const oldValue = TextEditingValue.empty;
        // User pastes 'abc25def12ghi2023jkl'
        // Assuming FilteringTextInputFormatter.digitsOnly runs first, newValue.text would be '25122023'
        const newValue = TextEditingValue(
          text:
              '25122023', // This is what DateInputFormatter receives after digitsOnly
          selection: TextSelection.collapsed(offset: 8),
        );
        final result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, '25/12/2023');
        expect(result.selection.baseOffset, 10);
      });

      test(
        'should correctly place cursor when typing into middle of MM-dd-yyyy',
        () {
          final formatter = PatternInputFormatter(patterns: ['MM-dd-yyyy']);
          // Initial state: 1M-DD-YYYY, user typed "1"
          TextEditingValue oldValue = const TextEditingValue(
            text: "1",
            selection: TextSelection.collapsed(offset: 1),
          );
          // User types "2"
          TextEditingValue newValue = const TextEditingValue(
            text: "12",
            selection: TextSelection.collapsed(offset: 2),
          );
          var result = formatter.formatEditUpdate(oldValue, newValue);
          expect(result.text, "12-DD-YYYY");
          expect(result.selection.baseOffset, 3); // Cursor after "12-"

          // Simulate state: 12-DD-YYYY, user typed "12"
          oldValue = newValue; // The new value from previous step is now old
          // User types "3"
          newValue = const TextEditingValue(
            text: "123",
            selection: TextSelection.collapsed(offset: 3),
          );
          result = formatter.formatEditUpdate(oldValue, newValue);
          expect(result.text, "12-3D-YYYY");
          expect(result.selection.baseOffset, 4); // Cursor after "12-3"
        },
      );
    });

    group('Phone Number Patterns', () {
      test('should format phone number (###) ###-#### correctly', () {
        final formatter = PatternInputFormatter(patterns: ['(###) ###-####']);

        // Typing '1'
        var oldValue = TextEditingValue.empty;
        var newValue = const TextEditingValue(
          text: '1',
          selection: TextSelection.collapsed(offset: 1),
        );
        var result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, '(1##) ###-####');
        expect(result.selection.baseOffset, 2);

        // Typing '123'
        oldValue = result;
        newValue = const TextEditingValue(
          text: '123',
          selection: TextSelection.collapsed(offset: 3),
        );
        result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, '(123) ###-####');
        expect(result.selection.baseOffset, 6);

        // Typing '123456'
        oldValue = result;
        newValue = const TextEditingValue(
          text: '123456',
          selection: TextSelection.collapsed(offset: 6),
        );
        result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, '(123) 456-####');
        expect(result.selection.baseOffset, 10);

        // Typing '1234567890' (full)
        oldValue = result;
        newValue = const TextEditingValue(
          text: '1234567890',
          selection: TextSelection.collapsed(offset: 10),
        );
        result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, '(123) 456-7890');
        expect(result.selection.baseOffset, 14);

        // Deleting '0'
        oldValue = result;
        newValue = const TextEditingValue(
          text: '123456789',
          selection: TextSelection.collapsed(offset: 9),
        );
        result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, '(123) 456-789#');
        expect(result.selection.baseOffset, 13);
      });
    });

    group('Credit Card Patterns', () {
      test('should format credit card #### #### #### #### correctly', () {
        final formatter = PatternInputFormatter(
          patterns: ['#### #### #### ####'],
        );

        // Typing '1234'
        var oldValue = TextEditingValue.empty;
        var newValue = const TextEditingValue(
          text: '1234',
          selection: TextSelection.collapsed(offset: 4),
        );
        var result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, '1234 #### #### ####');
        expect(result.selection.baseOffset, 5);

        // Typing '12345678'
        oldValue = result;
        newValue = const TextEditingValue(
          text: '12345678',
          selection: TextSelection.collapsed(offset: 8),
        );
        result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, '1234 5678 #### ####');
        expect(result.selection.baseOffset, 10);

        // Typing '123456781234'
        oldValue = result;
        newValue = const TextEditingValue(
          text: '123456781234',
          selection: TextSelection.collapsed(offset: 12),
        );
        result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, '1234 5678 1234 ####');
        expect(result.selection.baseOffset, 15);

        // Typing '1234567812345678' (full)
        oldValue = result;
        newValue = const TextEditingValue(
          text: '1234567812345678',
          selection: TextSelection.collapsed(offset: 16),
        );
        result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, '1234 5678 1234 5678');
        expect(result.selection.baseOffset, 19);
      });
    });

    group('Alphanumeric Patterns', () {
      test('should format postal code A#A #A# correctly', () {
        final formatter = PatternInputFormatter(patterns: ['A#A #A#']);

        // Typing 'A'
        var oldValue = TextEditingValue.empty;
        var newValue = const TextEditingValue(
          text: 'A',
          selection: TextSelection.collapsed(offset: 1),
        );
        var result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, 'A#A #A#');
        expect(result.selection.baseOffset, 1);

        // Typing 'A1B'
        oldValue = result;
        newValue = const TextEditingValue(
          text: 'A1B',
          selection: TextSelection.collapsed(offset: 3),
        );
        result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, 'A1B #A#');
        expect(result.selection.baseOffset, 4);

        // Typing 'A1B2C3' (full)
        oldValue = result;
        newValue = const TextEditingValue(
          text: 'A1B2C3',
          selection: TextSelection.collapsed(offset: 6),
        );
        result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, 'A1B 2C3');
        expect(result.selection.baseOffset, 7);
      });

      test('should format serial number AAAA-####-aa correctly', () {
        final formatter = PatternInputFormatter(patterns: ['AAAA-####-aa']);

        // Typing 'P'
        var oldValue = TextEditingValue.empty;
        var newValue = const TextEditingValue(
          text: 'P',
          selection: TextSelection.collapsed(offset: 1),
        );
        var result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, 'PAAA-####-AA');
        expect(result.selection.baseOffset, 1);

        // Typing 'PROD'
        oldValue = result;
        newValue = const TextEditingValue(
          text: 'PROD',
          selection: TextSelection.collapsed(offset: 4),
        );
        result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, 'PROD-####-AA');
        expect(result.selection.baseOffset, 5);

        // Typing 'PROD1234'
        oldValue = result;
        newValue = const TextEditingValue(
          text: 'PROD1234',
          selection: TextSelection.collapsed(offset: 8),
        );
        result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, 'PROD-1234-AA');
        expect(result.selection.baseOffset, 10);

        // Typing 'PROD1234ab' (full)
        oldValue = result;
        newValue = const TextEditingValue(
          text: 'PROD1234ab',
          selection: TextSelection.collapsed(offset: 10),
        );
        result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, 'PROD-1234-AB');
        expect(result.selection.baseOffset, 12);
      });
    });

    group('Variable-Length Patterns', () {
      test(
        'should format UK postcode by always preferring the longest possible pattern',
        () {
          final formatter = PatternInputFormatter(
            patterns: [
              'A# #AA', // 5 placeholders, e.g., M1 1AE
              'A## #AA', // 6 placeholders, e.g., B33 8TH
              'AA# #AA', // 6 placeholders, e.g., CR2 6XH
              'AA## #AA', // 7 placeholders, e.g., DN55 1PT
              'A#A #AA', // 6 placeholders, e.g., W1A 1HQ
              'AA#A #AA', // 7 placeholders, e.g., EC1A 1BB
            ],
            letterCase: LetterCase.upper,
          );

          // --- Test Case 1: Input 'M' ---
          // Should match the longest patterns starting with 'A': A## #AA (6) or A#A #AA (6).
          // The implementation prefers patterns with more placeholders.
          var oldValue = TextEditingValue.empty;
          var newValue = const TextEditingValue(
            text: 'M',
            selection: TextSelection.collapsed(offset: 1),
          );
          var result = formatter.formatEditUpdate(oldValue, newValue);
          expect(result.text, 'M## #AA');
          expect(result.selection.baseOffset, 1);

          // --- Test Case 2: Input 'M1' ---
          // Still matches A## #AA.
          oldValue = result;
          newValue = const TextEditingValue(
            text: 'M1',
            selection: TextSelection.collapsed(offset: 2),
          );
          result = formatter.formatEditUpdate(oldValue, newValue);
          expect(result.text, 'M1# #AA');
          expect(result.selection.baseOffset, 2);

          // --- Test Case 3: Input 'M11' ---
          // Still matches A## #AA as it allows for more characters.
          oldValue = result;
          newValue = const TextEditingValue(
            text: 'M11',
            selection: TextSelection.collapsed(offset: 3),
          );
          result = formatter.formatEditUpdate(oldValue, newValue);
          expect(result.text, 'M11 #AA');
          expect(result.selection.baseOffset, 4);

          // --- Test Case 4: Input 'M11AE' (full postcode for a shorter pattern) ---
          // The input 'M11AE' (L-D-D-L-L) is no longer valid for A## #AA (A-D-D-D-A-A).
          // The formatter should dynamically switch to the only valid pattern: A# #AA.
          oldValue = result;
          newValue = const TextEditingValue(
            text: 'M11AE',
            selection: TextSelection.collapsed(offset: 5),
          );
          result = formatter.formatEditUpdate(oldValue, newValue);
          expect(result.text, 'M1 1AE');
          expect(result.selection.baseOffset, 6);

          // --- Test Case 5: Input 'DN' ---
          // Should match longest patterns starting with 'AA': AA## #AA (7) or AA#A #AA (7).
          oldValue = TextEditingValue.empty;
          newValue = const TextEditingValue(
            text: 'DN',
            selection: TextSelection.collapsed(offset: 2),
          );
          result = formatter.formatEditUpdate(oldValue, newValue);
          expect(result.text, 'DN## #AA');
          expect(result.selection.baseOffset, 2);

          // --- Test Case 6: Input 'DN55' ---
          // Still matches AA## #AA.
          oldValue = result;
          newValue = const TextEditingValue(
            text: 'DN55',
            selection: TextSelection.collapsed(offset: 4),
          );
          result = formatter.formatEditUpdate(oldValue, newValue);
          expect(result.text, 'DN55 #AA');
          expect(result.selection.baseOffset, 5);

          // --- Test Case 7: Input 'DN551PT' (full) ---
          oldValue = result;
          newValue = const TextEditingValue(
            text: 'DN551PT',
            selection: TextSelection.collapsed(offset: 7),
          );
          result = formatter.formatEditUpdate(oldValue, newValue);
          expect(result.text, 'DN55 1PT');
          expect(result.selection.baseOffset, 8);
        },
      );
    });

    group('Rejection Behavior', () {
      test('should reject input longer than any available pattern', () {
        final formatter = PatternInputFormatter(
          patterns: [
            'A# #AA', // 5 placeholders
            'AA## #AA', // 7 placeholders
          ],
          letterCase: LetterCase.upper,
        );

        // Establish a state with a full, valid postcode for the longest pattern.
        final oldValue = formatter.formatEditUpdate(
          TextEditingValue.empty,
          const TextEditingValue(text: 'DN551PT'),
        );
        expect(oldValue.text, 'DN55 1PT');

        // Now, the user tries to type one more character, 'X'.
        final newValue = TextEditingValue(
          text: '${oldValue.text}X',
          selection: TextSelection.collapsed(offset: oldValue.text.length + 1),
        );

        // The formatter will extract 'DN551PTX' (8 chars), which is too long.
        // It should reject this change and return the `oldValue`.
        final result = formatter.formatEditUpdate(oldValue, newValue);

        expect(result.text, oldValue.text);
        expect(result.selection, oldValue.selection);
      });

      test('should reject input that violates pattern character type', () {
        final formatter = PatternInputFormatter(
          patterns: ['A# #AA'], // Expects a letter first.
          letterCase: LetterCase.upper,
        );

        const oldValue = TextEditingValue.empty;
        // User types '1', but the pattern expects a letter ('A').
        const newValue = TextEditingValue(
          text: '1',
          selection: TextSelection.collapsed(offset: 1),
        );

        // _findBestMatch('1') should return null.
        final result = formatter.formatEditUpdate(oldValue, newValue);

        // The change should be rejected, returning the empty old value.
        expect(result, oldValue);
      });
    });

    group('Assertions', () {
      test('should throw assertion error if patterns list is empty', () {
        expect(
          () => PatternInputFormatter(patterns: []),
          throwsA(isA<AssertionError>()),
        );
      });

      test(
        'should throw assertion error if a pattern contains no placeholders',
        () {
          expect(
            () => PatternInputFormatter(patterns: ['123-456']),
            throwsA(isA<AssertionError>()),
          );
        },
      );

      test(
        'should throw assertion error if placeholderChar is longer than 1',
        () {
          expect(
            () => PatternInputFormatter(patterns: ['#'], placeholderChar: '__'),
            throwsA(isA<AssertionError>()),
          );
        },
      );
    });

    group('Postal Code Patterns', () {
      test('should allow typing first character of UK postcode', () {
        final formatter = PatternInputFormatter(
          patterns: ['AA## #AA', 'A# #AA', 'A## #AA', 'AA# #AA'],
          inputType: PatternInputType.postal,
        );
        const oldValue = TextEditingValue.empty;
        const newValue = TextEditingValue(
          text: 'S',
          selection: TextSelection.collapsed(offset: 1),
        );
        final result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, 'S');
        expect(result.selection.baseOffset, 1);
      });

      test('should allow typing second character of UK postcode', () {
        final formatter = PatternInputFormatter(
          patterns: ['AA## #AA', 'A# #AA', 'A## #AA', 'AA# #AA'],
          inputType: PatternInputType.postal,
        );
        const oldValue = TextEditingValue(
          text: 'S',
          selection: TextSelection.collapsed(offset: 1),
        );
        const newValue = TextEditingValue(
          text: 'SW',
          selection: TextSelection.collapsed(offset: 2),
        );
        final result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, 'SW');
        expect(result.selection.baseOffset, 2);
      });
      test('should continue formatting full UK postcode SW1A 1AA', () {
        final formatter = PatternInputFormatter(
          patterns: ['AA#A #AA', 'A# #AA', 'A## #AA', 'AA# #AA'],
          inputType: PatternInputType.postal,
        );
        const oldValue = TextEditingValue(
          text: 'SW1A1A',
          selection: TextSelection.collapsed(offset: 6),
        );
        const newValue = TextEditingValue(
          text: 'SW1A1AA',
          selection: TextSelection.collapsed(offset: 7),
        );
        final result = formatter.formatEditUpdate(oldValue, newValue);
        expect(result.text, 'SW1A 1AA');
        expect(result.selection.baseOffset, 8);
      });
    });
  });
}
