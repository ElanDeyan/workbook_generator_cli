import 'dart:io';

import 'package:intl/date_symbol_data_local.dart';
import 'package:workbook_generator_cli/commands/main_runner.dart';

Future<void> main(List<String> arguments) async {
  final locale =
      Platform.localeName.split('.').firstOrNull ?? Platform.localeName;

  await initializeDateFormatting(locale);

  await MainCommandRunner().run(arguments);
}
