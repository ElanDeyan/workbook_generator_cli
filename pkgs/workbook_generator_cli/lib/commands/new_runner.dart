import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dey_dev_utils/result.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:workbook_generator_cli/utils/prompt_yes_or_no.dart';

final class NewCommand extends Command<void> {
  new({this._confirmOverwrite, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    argParser
      ..addOption(
        _fileOptionName,
        abbr: 'p',
        valueHelp: 'path',
        help: 'Path where the file will be created or replaced',
      )
      ..addOption(
        _localeOptionName,
        abbr: 'l',
        help: 'Locale in language_COUNTRY format (e.g. en_US, pt_BR, fr_FR)',
      );
  }

  final bool Function(String prompt)? _confirmOverwrite;
  final DateTime Function() _clock;

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
  List<String> get aliases => ['create'];

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

  String _resolveLocale() {
    final explicitLocale = argResults?.option(_localeOptionName);
    final candidate = explicitLocale?.trim().isNotEmpty == true
        ? explicitLocale
        : _defaultLocaleValue;

    if (candidate == null || candidate.trim().isEmpty) {
      return Platform.localeName.split('.').firstOrNull ?? 'en_US';
    }

    return candidate.trim();
  }

  Future<String> _resolveDefaultFilePath() async {
    final requestedLocale = _resolveLocale();
    await initializeDateFormatting(requestedLocale);
    final locale = DateFormat.localeExists(requestedLocale)
        ? requestedLocale
        : 'en_US';
    final monthYear = DateFormat('MMMM_yyyy', locale).format(_clock());
    return './$monthYear.yaml';
  }

  File _resolveFilePath(String requestedPath) {
    final rawPath = requestedPath.trim();
    if (rawPath.isEmpty) {
      throw const FileSystemException('The target path cannot be empty');
    }
    if (rawPath.endsWith('/') || rawPath.endsWith(r'\')) {
      throw FileSystemException(
        'The target path must name a file, not a directory: $rawPath',
        rawPath,
      );
    }
    if (Directory(rawPath).existsSync()) {
      throw FileSystemException(
        'The target path is a directory; expected a file: $rawPath',
        rawPath,
      );
    }

    final normalized =
        rawPath.toLowerCase().endsWith('.yaml') ||
            rawPath.toLowerCase().endsWith('.yml')
        ? rawPath
        : '$rawPath.yaml';

    return File(normalized);
  }

  Future<Result<File, FileSystemException>> _createFile(File file) async {
    var created = false;
    try {
      await file.parent.create(recursive: true);
      await file.create(exclusive: true);
      created = true;
      await file.writeAsString(_defaultFileData, flush: true);
      return Ok(file);
    } on FileSystemException catch (error) {
      if (created) {
        await file.delete();
      }
      return Err(error);
    }
  }

  Future<Result<File, FileSystemException>> _replaceFile(File file) async {
    Directory? temporaryDirectory;
    try {
      await file.parent.create(recursive: true);
      temporaryDirectory = await file.parent.createTemp('.jwb-new-');
      final temporaryFile = File('${temporaryDirectory.path}/workbook.yaml');
      await temporaryFile.writeAsString(_defaultFileData, flush: true);

      // Keep the existing target in place until the completed file is ready.
      final replacedFile = await temporaryFile.rename(file.path);
      return Ok(replacedFile);
    } on FileSystemException catch (error) {
      return Err(error);
    } finally {
      if (temporaryDirectory != null && temporaryDirectory.existsSync()) {
        await temporaryDirectory.delete(recursive: true);
      }
    }
  }

  bool _askToReplace(File file) {
    if (!stdin.hasTerminal && _confirmOverwrite == null) {
      stderr.writeln(
        'The target file already exists; refusing to overwrite in '
        'non-interactive mode: '
        '${file.path}',
      );
      return false;
    }

    return (_confirmOverwrite ?? _promptForOverwrite)(
      'The provided path already exists, do you want to replace?',
    );
  }

  Future<Result<NewCommandOkResult, FileSystemException>> _replaceIfConfirmed(
    File file,
  ) async {
    if (!_askToReplace(file)) {
      stdout.writeln('File kept as it stands.');
      return const .ok(.untouched);
    }

    stdout.writeln('Trying to replace file...');
    final replaceResult = await _replaceFile(file);
    return switch (replaceResult) {
      Ok(:final value) => _success(
        'File replaced successfully at ${value.path}',
        .replaced,
      ),
      Err(:final error) => _failure(
        'Something went wrong when replacing file...',
        error,
      ),
    };
  }

  Result<NewCommandOkResult, FileSystemException> _success(
    String message,
    NewCommandOkResult result,
  ) {
    stdout.writeln(message);
    return .ok(result);
  }

  Result<NewCommandOkResult, FileSystemException> _failure(
    String message,
    FileSystemException error,
  ) {
    stderr
      ..writeln(message)
      ..writeln(error);
    exitCode = 1;
    return .err(error);
  }

  @override
  Future<Result<NewCommandOkResult, FileSystemException>> run() async {
    try {
      final filePath =
          argResults?.option(_fileOptionName) ??
          await _resolveDefaultFilePath();
      final file = _resolveFilePath(filePath);
      final fileType = FileSystemEntity.typeSync(file.path, followLinks: false);

      if (fileType != FileSystemEntityType.notFound) {
        if (fileType != FileSystemEntityType.file) {
          throw FileSystemException(
            'The target path is not a regular file: ${file.path}',
            file.path,
          );
        }

        return await _replaceIfConfirmed(file);
      }

      final createFileResult = await _createFile(file);

      switch (createFileResult) {
        case Ok(:final value):
          return _success(
            'File successfully created at ${value.path}',
            .created,
          );
        case Err(:final error):
          final fileType = FileSystemEntity.typeSync(
            file.path,
            followLinks: false,
          );
          if (fileType == FileSystemEntityType.file) {
            return await _replaceIfConfirmed(file);
          }
          return _failure('Something went wrong...', error);
      }
    } on FileSystemException catch (error) {
      return _failure('Something went wrong...', error);
    }
  }
}

bool _promptForOverwrite(String prompt) => promptYesNo(prompt) ?? false;

enum NewCommandOkResult { untouched, created, replaced }
