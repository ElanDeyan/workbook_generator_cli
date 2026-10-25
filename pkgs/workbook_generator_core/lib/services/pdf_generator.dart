import 'dart:isolate';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:workbook_generator_core/domain/meeting_week/meeting_week.dart';
import 'package:workbook_generator_core/presentation/apply_yourself_to_ministry_presenter.dart';
import 'package:workbook_generator_core/presentation/christian_life_presenter.dart';
import 'package:workbook_generator_core/presentation/treasures_presentation.dart';
import 'package:workbook_generator_core/protocols/icon_provider.dart';

extension type FontFileBytes(Uint8List bytes) {
  pw.Font toPdfFont() => pw.Font.ttf(bytes.buffer.asByteData());
}

Future<Uint8List> generatePdf({
  required Set<MeetingWeek> meetingWeeks,
  required IconProvider iconProvider,
  FontFileBytes? fontFileBytes,
}) async {
  final font = fontFileBytes?.toPdfFont() ?? pw.Font.helvetica();

  final doc = pw.Document(theme: .withFont(base: font));

  for (final meetingWeek in meetingWeeks) {
    final page = await _buildPage(
      meetingWeek: meetingWeek,
      iconProvider: iconProvider,
      fontFileBytes: fontFileBytes,
    );
    doc.addPage(page);
  }

  final bytes = await Isolate.run(doc.save);

  return bytes;
}

Future<pw.Page> _buildPage({
  required MeetingWeek meetingWeek,
  required IconProvider iconProvider,
  FontFileBytes? fontFileBytes,
}) async {
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
            text: ' (VISITA DO SUPERINTENDENTE)',
            style: .new(fontWeight: .bold),
          ),
      ],
      style: const .new(fontSize: 15),
    ),
  );

  switch (meetingWeek) {
    case SpecialEventWeek(:final reason):
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
              pw.Expanded(
                child: pw.Center(
                  child: pw.Text(
                    reason,
                    textAlign: .center,
                    style: const .new(fontWeight: .bold, fontSize: 28),
                  ),
                ),
              ),
            ],
          );
        },
      );
    case final ProgrammedMeetingWeek meetingWeek:
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
        finalCommentsWidget: finalCommentsRender,
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
              treasuresPresenter.toPdfWidget(
                iconProvider: iconProvider,
                fontFileBytes: fontFileBytes,
              ),
              pw.SizedBox(height: 8),
              applyYourselfToMinistryPresenter.toPdfWidget(
                iconProvider: iconProvider,
                fontFileBytes: fontFileBytes,
              ),
              pw.SizedBox(height: 8),
              christianLifePresenter.toPdfWidget(
                iconProvider: iconProvider,
                fontFileBytes: fontFileBytes,
              ),
              pw.SizedBox(height: 8),
              lastSongAndPrayer,
            ],
          );
        },
      );
  }
}
