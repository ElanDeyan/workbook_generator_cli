import 'package:args/command_runner.dart';
import 'package:workbook_generator_cli/commands/new_runner.dart';

final class MainCommandRunner extends CommandRunner<void> {
  MainCommandRunner()
    : super(
        'jwb',
        "A CLI for generate Jehovah's Witnesses' "
            'meeting workbook from a .yaml source file.',
      ) {
    addCommand(NewCommand());
  }
}
