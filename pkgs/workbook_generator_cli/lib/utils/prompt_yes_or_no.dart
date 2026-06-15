import 'dart:io';

bool? promptYesNo(String prompt, {bool defaultToNo = true}) {
  while (true) {
    final defaultDisplay = defaultToNo ? '[y/N]' : '[Y/n]';
    stdout.write('$prompt $defaultDisplay ');

    final input = stdin.readLineSync()?.trim().toLowerCase();

    if (input == null || input.isEmpty) {
      return !defaultToNo; // Return the default
    }

    if (input == 'y' || input == 'yes') return true;
    if (input == 'n' || input == 'no') return false;

    stdout.writeln('Please enter y or n.');
  }
}
