import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:workbook_generator_core/domain/meeting_week/christian_life.dart';
import 'package:workbook_generator_core/domain/meeting_week/segments/assignment.dart';
import 'package:workbook_generator_core/protocols/pdf_presenter.dart';
import 'package:workbook_generator_core/services/icon_provider.dart';

final class ChristianLifePresenter implements PdfPresenter {
  ChristianLifePresenter({
    required this.midMeetingSong,
    required this._christianLife,
  });

  final ChristianLife _christianLife;
  final String midMeetingSong;

  @override
  PdfColor get iconAccentColor => .fromHex('#BF2F14');

  @override
  PdfColor get textAccentColor => .fromHex('#942926');

  @override
  pw.Widget toPdfWidget() {
    const iconProvider = IconProvider();

    final sectionTitle = pw.Row(
      children: [
        pw.SizedBox.square(
          dimension: 18,
          child: pw.DecoratedBox(
            decoration: pw.BoxDecoration(color: textAccentColor),
            child: pw.SvgImage(
              svg: iconProvider.emojiPeopleIcon.readAsStringSync(),
            ),
          ),
        ),
        pw.SizedBox(width: 5),
        pw.Text(
          'NOSSA VIDA CRISTÃ',
          style: .new(color: textAccentColor, fontWeight: .bold, fontSize: 20),
          softWrap: true,
        ),
      ],
    );

    final lastPartRender = switch (_christianLife) {
      OverseerVisitChristianLife(:final overseerSpeech) => _assignmentBuilder(
        overseerSpeech,
      ),
      RegularChristianLife(:final congregationStudy) => pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: congregationStudy.title,
              style: .new(color: textAccentColor, fontWeight: .bold),
            ),
            const pw.TextSpan(text: ' '),
            pw.TextSpan(text: '(${congregationStudy.duration.inMinutes} min)'),
            const pw.TextSpan(text: ' - '),
            pw.TextSpan(
              text: 'Dirigente: ',
              style: .new(fontWeight: .bold),
            ),
            pw.TextSpan(
              text: '${congregationStudy.conductor}',
              style: .new(fontStyle: .italic),
            ),
            pw.TextSpan(
              text: ' | ',
              style: .new(fontWeight: .bold),
            ),
            pw.TextSpan(
              text: 'Leitor: ',
              style: .new(fontWeight: .bold),
            ),
            pw.TextSpan(
              text: '${congregationStudy.reader}',
              style: .new(fontStyle: .italic),
            ),
          ],
          style: const .new(fontSize: 14),
        ),
      ),
    };

    final musicNoteSvgImage = pw.SvgImage(
      svg: iconProvider.musicNoteIcon.readAsStringSync(),
      colorFilter: PdfColors.black,
      width: 12,
      height: 12,
    );

    final midweekSongRender = pw.Row(
      mainAxisSize: .min,
      children: [
        musicNoteSvgImage,
        pw.SizedBox(width: 2),
        pw.Text(midMeetingSong, style: .new(fontWeight: .bold, fontSize: 12)),
      ],
    );

    return pw.Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        sectionTitle,
        pw.Divider(),
        midweekSongRender,
        for (final assignment in _christianLife.initialParts)
          _assignmentBuilder(assignment),
        lastPartRender,
      ],
    );
  }

  pw.Widget _assignmentBuilder(Assignment assignment) {
    return pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: assignment.title,
            style: .new(color: textAccentColor, fontWeight: .bold),
          ),
          const pw.TextSpan(text: ' '),
          pw.TextSpan(text: '(${assignment.duration.inMinutes} min)'),
          const pw.TextSpan(text: ' - '),
          switch (assignment) {
            MultiPersonAssignment(:final names) => pw.TextSpan(
              text: names.join(' e '),
              style: .new(fontStyle: .italic),
            ),
            SinglePersonAssignment(:final name) => pw.TextSpan(
              text: name.self,
              style: .new(fontStyle: .italic),
            ),
          },
        ],
        style: const .new(fontSize: 14),
      ),
    );
  }
}
