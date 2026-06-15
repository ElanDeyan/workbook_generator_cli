import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_utils/result.dart';
import 'package:intl/intl.dart';
import 'package:workbook_generator_cli/utils/prompt_yes_or_no.dart';

final class NewCommand extends Command<void> {
  NewCommand() {
    argParser
      ..addOption(
        _fileOptionName,
        abbr: 'p',
        valueHelp: 'path',
        help: 'Path where the file that will be created/replaced',
      )
      ..addOption(
        _localeOptionName,
        abbr: 'l',
        defaultsTo: _defaultLocaleValue,
        help: 'Locale in language_COUNTRY format (e.g. en_US, pt_BR, fr_FR)',
      );
  }

  static const _fileOptionName = 'path';
  static const _localeOptionName = 'locale';

  static String? get _defaultLocaleValue =>
      Platform.environment['JWB_LOCALE']?.toString() ??
      Platform.localeName.split('.').firstOrNull;

  @override
  String get description =>
      'Creates a new workbook yaml file at the provided path.';

  @override
  String get name => 'new';

  @override
  bool get takesArguments => false;

  String get _defaultFileData {
    final buffer = StringBuffer()
      ..writeln(
        '# yaml-language-server: '
        r'$schema=https://raw.githubusercontent.com/ElanDeyan'
        '/workbook_generator_cli/main/data/workbook_schema.json',
      );

    return buffer.toString();
  }

  @override
  Future<Result<NewCommandOkResult, FileSystemException>> run() async {
    final isWindows = Platform.isWindows;

    final locale = argResults?['locale']?.toString() ?? _defaultLocaleValue;

    late final monthYear = DateFormat('MMMM_yyyy', locale).format(.now());

    final filePath = argResults?.option(_fileOptionName) ?? './$monthYear.yaml';

    final fileUri = Uri.file(filePath, windows: isWindows);

    var uriAsFilePath = fileUri.toFilePath(windows: isWindows);

    if (!uriAsFilePath.endsWith('.yaml')) {
      uriAsFilePath = Uri.parse(
        '$uriAsFilePath.yaml',
      ).toFilePath(windows: isWindows);
    }

    final file = File(uriAsFilePath);

    final createFileResult =
        await Result.guardExceptionAsync<File, FileSystemException>(
          () => file
              .create(recursive: true, exclusive: true)
              .then(_writeInitialFileData),
        );

    if (createFileResult case Ok(:final value)) {
      stdout.writeln('File successfully created at ${value.path}');

      return const .ok(.created);
    }

    final err = createFileResult.expectErr(
      'Expected an error when creating file',
    );

    if (err is PathExistsException) {
      final userWantsToReplace =
          promptYesNo(
            'The provided path already exists, do you want to replace?',
          ) ??
          false;

      if (userWantsToReplace) {
        stdout.writeln('Trying to replace file...');

        final replaceFileResult =
            await Result.guardExceptionAsync<File, FileSystemException>(
              () async {
                final deletedFile = await file.delete(recursive: true);

                if (deletedFile is! File) {
                  throw FileSystemException(
                    'Expected a file, not a directory',
                    filePath,
                  );
                }

                //! Will not be wrapped in Result
                //! It's a panic!
                if (deletedFile.existsSync()) {
                  throw StateError('Failed to delete file at $filePath');
                }

                return file.create(recursive: true).then(_writeInitialFileData);
              },
            );

        switch (replaceFileResult) {
          case Ok(:final value):
            stdout.writeln('File replaced successfully at ${value.path}');

            return const .ok(.replaced);
          case Err(:final error):
            stdout.writeln('Something went wrong when replacing file...');
            stderr.writeln(error);

            return .err(error);
        }
      }

      stdout.writeln('File kept as it stands.');
      return const .ok(.untouched);
    }

    stdout.writeln('Something went wrong...');
    stderr.writeln(err);

    return .err(err);
  }

  Future<File> _writeInitialFileData(File file) async =>
      file.writeAsString(_defaultFileData);
}

enum NewCommandOkResult { untouched, created, replaced }
