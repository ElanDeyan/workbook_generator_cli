import 'dart:io';
import 'dart:isolate';

import 'package:args/command_runner.dart';
import 'package:dey_dev_utils/result.dart';
import 'package:dey_dev_utils/scope.dart';
import 'package:shared_assets/shared_assets.dart';
import 'package:workbook_generator_core/domain/meeting_week/meeting_week.dart';
import 'package:workbook_generator_core/services/pdf_generator.dart';
import 'package:workbook_generator_core/services/yaml_parser_service.dart';

enum _GenerateFormat {
  pdf,
  md,
  whatsapp;

  static _GenerateFormat? fromString(String? value) {
    if (value == null) return null;

    switch (value.toLowerCase()) {
      case 'pdf':
        return .pdf;
      case 'md':
        return .md;
      case 'whatsapp':
        return .whatsapp;
      default:
        return null;
    }
  }

  String get extension {
    switch (this) {
      case .pdf:
        return 'pdf';
      case .md:
        return 'md';
      case .whatsapp:
        return 'txt';
    }
  }
}

enum _OutputPlace { file, stdout }

final class GenerateCommand() extends Command<void> {
  this {
    argParser
      ..addOption(
        'format',
        abbr: 'f',
        help: 'Output format (e.g. pdf, md)',
        allowed: ['pdf', 'md', 'whatsapp'],
        mandatory: true,
      )
      ..addOption(
        'output',
        abbr: 'o',
        help: 'Path to the output file',
        valueHelp: 'path',
      );
  }

  @override
  String get description =>
      "Generate Jehovah's Witnesses' meeting workbook "
      'from a .yaml source file.';

  @override
  String get name => 'generate';

  @override
  List<String> get aliases => ['gen', 'g'];

  @override
  bool get takesArguments => true;

  @override
  Future<void> run() async {
    final result = await generateWorkbook();

    if (result.isErr) {
      stderr.writeln('Error: ${result.err}');
      exit(1);
    }
  }

  Future<Result<void, Exception>> generateWorkbook() async {
    // Ensure file exists
    final inputFilePath = argResults?.arguments.firstOrNull?.trim().let(
      File.new,
    );

    if (inputFilePath == null || !inputFilePath.existsSync()) {
      return .err(.new('Input file does not exist: $inputFilePath'));
    }

    final formatOption = argResults
        ?.option('format')
        ?.trim()
        .let(_GenerateFormat.fromString);

    if (formatOption == null) {
      return .err(.new('Invalid format option provided.'));
    }

    final outputOption = argResults?.option('output')?.trim().let(File.new);

    final outputPlace = switch ((outputOption, formatOption)) {
      (_, .pdf) => _OutputPlace.file,
      (null, .md) => _OutputPlace.stdout,
      (final _?, .md) => _OutputPlace.file,
      (null, .whatsapp) => _OutputPlace.stdout,
      (final _?, .whatsapp) => _OutputPlace.stdout,
    };

    const yamlParserService = YamlParserService();
    final parsedWorkbookResult = await Isolate.run(
      () => yamlParserService.fromString(inputFilePath.readAsStringSync()),
    );

    if (parsedWorkbookResult.isErr) {
      return .err(parsedWorkbookResult.err!);
    }

    final workbook = parsedWorkbookResult.ok!;

    final meetingWeekResults = await Isolate.run(
      () => [for (final map in workbook) MeetingWeek.fromMap(map)],
    );

    if (meetingWeekResults.any((result) => result.isErr)) {
      final errors = meetingWeekResults
          .where((result) => result.isErr)
          .map((result) => result.err)
          .join('\n');

      return .err(.new('Error parsing meeting weeks:\n$errors'));
    }

    final meetingWeeks = meetingWeekResults
        .map((result) => result.ok!)
        .toList();

    if (meetingWeeks.isEmpty) {
      return .err(.new('No valid meeting weeks found in the input file.'));
    }

    assert(
      !(outputPlace == .stdout && formatOption == .pdf),
      'PDF output cannot be sent to stdout.',
    );

    switch (outputPlace) {
      case .file:
        final outputFilePath =
            outputOption ??
            inputFilePath.parent.path
                .let((path) => File('$path/output.${formatOption.extension}'))
                .takeIfLazy((value) => value.existsSync());

        if (outputFilePath == null) {
          return .err(.new('Output file path is not specified.'));
        }

        switch (formatOption) {
          case .pdf:
            final sharedAssets = await SharedAssets.load();
            final bytes = await generatePdf(
              meetingWeeks: meetingWeeks.toSet(),
              iconProvider: sharedAssets,
              fontFileBytes: sharedAssets.fontFileBytes,
            );

            await outputFilePath.writeAsBytes(bytes);

            return const .ok(null);
          case .md || .whatsapp:
            final content = meetingWeeks
                .map(
                  (week) => week.toShareableText(
                    richTextKind: formatOption == .md ? .markdown : .whatsApp,
                  ),
                )
                .join('\n\n');

            await outputFilePath.writeAsString(content);

            return const .ok(null);
        }
      case .stdout:
        if (formatOption == .pdf) {
          return .err(.new('PDF output cannot be sent to stdout.'));
        }

        final content = meetingWeeks
            .map(
              (week) => week.toShareableText(
                richTextKind: formatOption == .md ? .markdown : .whatsApp,
              ),
            )
            .join('\n\n');

        stdout.writeln(content);

        return const .ok(null);
    }
  }
}
