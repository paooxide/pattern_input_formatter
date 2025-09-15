# PatternInputFormatter Example

This Flutter application demonstrates the usage of the `PatternInputFormatter` from the `pattern_input_formatter` package.

## Overview

The example showcases how to use the `PatternInputFormatter` with various `TextField` widgets to format user input in real-time. It includes demonstrations for:

*   **Date Formatting**:
    *   `dd/MM/yyyy`
    *   `MM-dd-yy` (with a custom placeholder character)
    *   `yyyy.MM.dd`
*   **Phone Number Formatting**:
    *   U.S. Phone Number: `(###) ###-####`
*   **Credit Card Formatting**:
    *   `#### #### #### ####`
*   **Alphanumeric Formatting**:
    *   Canadian Postal Code: `A#A #A#`
    *   Product Serial Number: `AAAA-####-aa`

Each example is configured with the appropriate `keyboardType` and `FilteringTextInputFormatter` for the best user experience.

## How to Run

1.  Navigate to the `example` directory.
2.  Ensure you have Flutter installed.
3.  Run the app:
    ```sh
    flutter run
    ```

This will launch the example application on your connected device or simulator.
