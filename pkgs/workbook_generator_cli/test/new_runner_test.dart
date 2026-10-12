import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:test/test.dart';
import 'package:workbook_generator_cli/commands/new_runner.dart';

void main() {
  group('NewCommand', () {
    test('creates a .yml file with the schema header at the top', () async {
      final tempDir = await Directory.systemTemp.createTemp('jwb_new_');
      addTearDown(() => tempDir.delete(recursive: true));

      final targetPath = '${tempDir.path}/workbook.yml';
      final runner = CommandRunner<void>('jwb', 'desc')
        ..addCommand(NewCommand());

      await expectLater(runner.run(['new', '--path', targetPath]), completes);
      expect(File(targetPath).existsSync(), isTrue);

      final fileContent = await File(targetPath).readAsString();
      expect(fileContent, startsWith(_defaultFileData));
    });

    test(
      'creates missing parent directories and appends yaml extension',
      () async {
        final tempDir = await Directory.systemTemp.createTemp('jwb_new_');
        addTearDown(() => tempDir.delete(recursive: true));
        final targetPath = '${tempDir.path}/nested/workbook';

        await _runNew(targetPath, command: NewCommand());

        final generatedFile = File('$targetPath.yaml');
        expect(generatedFile.existsSync(), isTrue);
        expect(
          await generatedFile.readAsString(),
          startsWith(_defaultFileData),
        );
      },
    );

    test('keeps an existing file when overwrite is declined', () async {
      final tempDir = await Directory.systemTemp.createTemp('jwb_new_');
      addTearDown(() => tempDir.delete(recursive: true));
      final target = File('${tempDir.path}/workbook.yaml');
      await target.writeAsString('existing content');

      await _runNew(
        target.path,
        command: NewCommand(confirmOverwrite: (_) => false),
      );

      expect(await target.readAsString(), 'existing content');
    });

    test('replaces existing files with the schema header at the top', () async {
      final tempDir = await Directory.systemTemp.createTemp('jwb_new_');
      addTearDown(() => tempDir.delete(recursive: true));
      final target = File('${tempDir.path}/workbook.yaml');
      await target.writeAsString('existing content');

      await _runNew(
        target.path,
        command: NewCommand(confirmOverwrite: (_) => true),
      );

      expect(await target.readAsString(), startsWith(_defaultFileData));
      expect(
        tempDir.listSync().whereType<Directory>().where(
          (directory) => directory.path.contains('.jwb-new-'),
        ),
        isEmpty,
      );
    });

    test('rejects a directory path rather than appending yaml', () async {
      final tempDir = await Directory.systemTemp.createTemp('jwb_new_');
      addTearDown(() => tempDir.delete(recursive: true));
      exitCode = 0;

      await _runNew(tempDir.path, command: NewCommand());

      expect(File('${tempDir.path}.yaml').existsSync(), isFalse);
      expect(exitCode, isNonZero);
      exitCode = 0;
    });

    test(
      'uses the injected clock and falls back for unsupported locales',
      () async {
        final tempDir = await Directory.systemTemp.createTemp('jwb_new_');
        addTearDown(() => tempDir.delete(recursive: true));
        final currentDirectory = Directory.current;
        Directory.current = tempDir.path;
        addTearDown(() => Directory.current = currentDirectory);

        await _runNew(
          null,
          command: NewCommand(clock: () => DateTime(2024, 1, 2)),
          extraArguments: ['--locale', 'en_US'],
        );

        expect(File('January_2024.yaml').existsSync(), isTrue);
        await File('January_2024.yaml').delete();

        await _runNew(
          null,
          command: NewCommand(clock: () => DateTime(2024, 1, 2)),
          extraArguments: ['--locale', 'unsupported_LOCALE'],
        );

        expect(File('January_2024.yaml').existsSync(), isTrue);
      },
    );
  });
}

const _defaultFileData =
    '# yaml-language-server: '
    r'$schema=https://raw.githubusercontent.com/ElanDeyan'
    '/workbook_generator_cli/main/data/workbook_schema.json'
    '\n';

Future<void> _runNew(
  String? path, {
  required NewCommand command,
  List<String> extraArguments = const [],
}) async {
  final runner = CommandRunner<void>('jwb', 'desc')..addCommand(command);
  await runner.run([
    'new',
    if (path != null) ...['--path', path],
    ...extraArguments,
  ]);
}
