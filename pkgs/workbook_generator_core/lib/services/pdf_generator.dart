import 'dart:io';
import 'dart:isolate';

import 'package:cross_file/cross_file.dart';
import 'package:dev_utils/result.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:workbook_generator_core/domain/meeting_week/meeting_week.dart';
import 'package:workbook_generator_core/presentation/apply_yourself_to_ministry_presenter.dart';
import 'package:workbook_generator_core/presentation/christian_life_presenter.dart';
import 'package:workbook_generator_core/presentation/treasures_presentation.dart';
import 'package:workbook_generator_core/services/icon_provider.dart';
import 'package:workbook_generator_core/services/yaml_parser_service.dart';

Future<void> main(List<String> args) async {
  const yamlParser = YamlParserService();

  final result = await yamlParser.fromString(
    File('../../data/schema.yaml').readAsStringSync(),
  );

  if (result.isErr) {
    throw Exception('Failed to parse YAML: ${result.err}');
  }

  final meetingWeeks = result.ok!;

  final parseResult = [
    for (final map in meetingWeeks) MeetingWeek.fromMap(map),
  ].whereType<Ok<MeetingWeek, FormatException>>().map((e) => e.value).toSet();

  final pdfFile = await generatePdf(parseResult);

  final file = File('output.pdf')
    ..createSync()
    ..writeAsBytesSync(await pdfFile.readAsBytes());
  print('PDF generated: ${file.path}');
}

Future<XFile> generatePdf(Set<MeetingWeek> meetingWeeks) async {
  final fontFile = File(
    '../../assets/fonts/roboto/Roboto-VariableFont_wdth,wght.ttf',
  );
  final fontBytes = await fontFile.readAsBytes();
  final font = pw.Font.ttf(fontBytes.buffer.asByteData());

  final doc = pw.Document(theme: .withFont(base: font));

  for (final meetingWeek in meetingWeeks) {
    final page = await _buildPage(meetingWeek);
    doc.addPage(page);
  }

  final bytes = await Isolate.run(doc.save);

  final file = XFile.fromData(
    bytes,
    name: 'meeting_week.pdf',
    mimeType: 'application/pdf',
    length: bytes.length,
  );

  return file;
}

Future<pw.Page> _buildPage(MeetingWeek meetingWeek) async {
  const iconProvider = IconProvider();
  late final musicNoteSvgImage = pw.SvgImage(
    svg: iconProvider.musicNoteIcon.readAsStringSync(),
    colorFilter: PdfColors.black,
    width: 12,
    height: 12,
  );

  final pageHeader = pw.Row(
    children: [
      pw.Text('IMBUÍ', style: const .new(fontWeight: .bold)),
      pw.Spacer(),
      pw.Text(
        'PROGRAMAÇÃO DA REUNIÃO',
        style: const .new(fontWeight: .bold, fontSize: 18),
        maxLines: 2,
        softWrap: true,
        overflow: .clip,
      ),
    ],
  );

  final meetingWeekHeader = pw.RichText(
    text: pw.TextSpan(
      children: [
        pw.TextSpan(
          text: meetingWeek.weekRange.toUpperCase(),
          annotation: pw.AnnotationUrl(meetingWeek.link.toString()),
          style: const .new(decoration: .underline),
        ),
        const pw.TextSpan(text: ' | '),
        pw.TextSpan(
          text: meetingWeek.bibleReading.toUpperCase(),
          style: const .new(fontWeight: .bold),
        ),
        if (meetingWeek is OverseerVisitMeetingWeek)
          const pw.TextSpan(
            text: '(SEMANA DA VISITA)',
            style: .new(fontWeight: .bold),
          ),
      ],
      style: const .new(fontSize: 15),
    ),
  );

  if (meetingWeek is SpecialEventWeek) {
    return pw.Page(
      orientation: .portrait,
      pageFormat: .a4,
      build: (context) {
        return pw.Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            pageHeader,
            pw.Divider(thickness: 2),
            meetingWeekHeader,
            pw.SizedBox(height: 8),
            pw.Center(child: pw.Text(meetingWeek.reason)),
          ],
        );
      },
    );
  }

  final ProgrammedMeetingWeek programmedMeetingWeek = meetingWeek;

  final firstSongAndPrayer = pw.Row(
    mainAxisSize: .min,
    children: [
      musicNoteSvgImage,
      pw.SizedBox(width: 2),
      pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(text: meetingWeek.songs.first),
            const pw.TextSpan(text: ' e '),
            const pw.TextSpan(text: 'oração inicial: '),
            pw.TextSpan(text: meetingWeek.prayers.first.self),
          ],
          style: const .new(fontSize: 12, fontWeight: .bold),
        ),
      ),
    ],
  );

  final chairmanAndInitialCommentsRender = pw.RichText(
    text: pw.TextSpan(
      children: [
        pw.TextSpan(
          text:
              'Presidente e '
              '${meetingWeek.initialComments.title} '
              '(${meetingWeek.initialComments.duration.inMinutes} min)',
          style: const .new(fontWeight: .bold),
        ),
        const pw.TextSpan(text: ' - '),
        pw.TextSpan(
          text: meetingWeek.initialComments.name.self,
          style: const .new(fontStyle: .italic),
        ),
      ],
      style: const .new(fontSize: 12),
    ),
  );

  final finalCommentsRender = pw.RichText(
    text: pw.TextSpan(
      style: const .new(fontSize: 12),
      children: [
        pw.TextSpan(
          text: meetingWeek.finalComments.title,
          style: const .new(fontWeight: .bold),
        ),
        pw.TextSpan(
          text: ' (${meetingWeek.finalComments.duration.inMinutes} min) ',
          style: const .new(fontWeight: .bold),
        ),
        const pw.TextSpan(text: ' - '),
        pw.TextSpan(
          text: meetingWeek.finalComments.name.self,
          style: const .new(fontStyle: .italic),
        ),
      ],
    ),
  );

  final lastSongAndPrayer = pw.Row(
    mainAxisSize: .min,
    children: [
      musicNoteSvgImage,
      pw.SizedBox(width: 2),
      pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: meetingWeek.songs.last,
              style: const .new(fontWeight: .bold),
            ),
            const pw.TextSpan(
              text: ' e oração final: ',
              style: .new(fontWeight: .bold),
            ),
            pw.TextSpan(
              text: meetingWeek.prayers.last.self,
              style: const .new(fontStyle: .italic),
            ),
          ],
          style: const .new(fontSize: 12),
        ),
      ),
    ],
  );

  final treasuresPresenter = TreasuresFromGodsWordPresenter(
    treasures: meetingWeek.treasuresFromGodsWord,
  );

  final applyYourselfToMinistryPresenter = ApplyYourselfToMinistryPresenter(
    applyYourselfToMinistry: meetingWeek.applyYourselfToMinistry,
  );

  final christianLifePresenter = ChristianLifePresenter(
    christianLife: meetingWeek.christianLife,
    midMeetingSong: meetingWeek.songs[1],
  );

  return pw.Page(
    orientation: .portrait,
    pageFormat: .a4,
    build: (context) {
      return pw.Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          pageHeader,
          pw.Divider(thickness: 2),
          meetingWeekHeader,
          pw.SizedBox(height: 8),
          firstSongAndPrayer,
          pw.SizedBox(height: 8),
          chairmanAndInitialCommentsRender,
          pw.SizedBox(height: 8),
          treasuresPresenter.toPdfWidget(),
          pw.SizedBox(height: 8),
          applyYourselfToMinistryPresenter.toPdfWidget(),
          pw.SizedBox(height: 8),
          christianLifePresenter.toPdfWidget(),
          pw.SizedBox(height: 8),
          finalCommentsRender,
          pw.SizedBox(height: 8),
          lastSongAndPrayer,
        ],
      );
    },
  );
}
