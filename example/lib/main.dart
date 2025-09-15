import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pattern_input_formatter/pattern_input_formatter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PatternInputFormatter Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true, 
      ),
      home: const MyHomePage(title: 'PatternInputFormatter Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _dateController1 = TextEditingController();
  final TextEditingController _dateController2 = TextEditingController();
  final TextEditingController _dateController3 = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _creditCardController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _serialUpperController = TextEditingController();
  final TextEditingController _serialLowerController = TextEditingController();
  final TextEditingController _serialAnyController = TextEditingController();

  @override
  void dispose() {
    _dateController1.dispose();
    _dateController2.dispose();
    _dateController3.dispose();
    _timeController.dispose();
    _phoneController.dispose();
    _creditCardController.dispose();
    _postalCodeController.dispose();
    _serialUpperController.dispose();
    _serialLowerController.dispose();
    _serialAnyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            Text(
              'Enter date (dd/MM/yyyy):',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController1,
              decoration: const InputDecoration(
                hintText: 'DD/MM/YYYY',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                PatternInputFormatter(
                  inputType: PatternInputType.date,
                  patterns: ['dd/MM/yyyy'],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Enter date (MM-dd-yy) with placeholder \'_\':',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController2,
              decoration: const InputDecoration(
                hintText: 'MM-DD-YY',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                PatternInputFormatter(
                  patterns: ['MM-dd-yy'],
                  placeholderChar: '_',
                  inputType: PatternInputType.date,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Enter date (yyyy.MM.dd):',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateController3,
              decoration: const InputDecoration(
                hintText: 'YYYY.MM.DD',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                PatternInputFormatter(
                  inputType: PatternInputType.date,
                  patterns: ['yyyy.MM.dd'],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Enter time (HH:mm:ss):',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                hintText: 'HH:MM:SS',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                PatternInputFormatter(
                  patterns: ['HH:mm:ss'],
                  inputType: PatternInputType.time,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Enter US Phone Number:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                hintText: '(###) ###-####',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                PatternInputFormatter(patterns: ['(###) ###-####']),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Enter Credit Card Number:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _creditCardController,
              decoration: const InputDecoration(
                hintText: '#### #### #### ####',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                PatternInputFormatter(patterns: ['#### #### #### ####']),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Enter Canadian Postal Code:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _postalCodeController,
              decoration: const InputDecoration(
                hintText: 'A#A #A#',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              inputFormatters: [
                PatternInputFormatter(
                  patterns: ['A#A #A#'],
                  inputType: PatternInputType.postal,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Enter UK Postal Code:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'AA1 1AA',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              inputFormatters: [
                PatternInputFormatter(
                  patterns: [
                    'AA# #AA',
                    'A# #AA',
                    'A#A #AA',
                    'AA## #AA', // Handles RH15 9AA and similar
                    'AA## AAA', // Handles RH19 KAA and similar
                  ],
                  inputType: PatternInputType.postal,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Enter Serial Number (Uppercase):',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _serialUpperController,
              decoration: const InputDecoration(
                hintText: 'AAAA-####-AA',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              inputFormatters: [
                PatternInputFormatter(
                  patterns: ['AAAA-####-AA'],
                  letterCase: LetterCase.upper,
                  inputType: PatternInputType.serial,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Enter Serial Number (Lowercase):',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _serialLowerController,
              decoration: const InputDecoration(
                hintText: 'aaaa-####-aa',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              inputFormatters: [
                PatternInputFormatter(
                  patterns: ['AAAA-####-AA'],
                  letterCase: LetterCase.lower,
                  inputType: PatternInputType.serial,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Enter Serial Number (Any Case):',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _serialAnyController,
              decoration: const InputDecoration(
                hintText: 'AaAa-####-aA',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              inputFormatters: [
                PatternInputFormatter(
                  patterns: ['AAAA-####-AA'],
                  letterCase: LetterCase.any,
                  inputType: PatternInputType.serial,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
