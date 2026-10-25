import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:workbook_generator_core/domain/meeting_week/assignments/assignment.dart';
import 'package:workbook_generator_core/domain/meeting_week/ministry.dart';
import 'package:workbook_generator_core/protocols/icon_provider.dart';
import 'package:workbook_generator_core/protocols/pdf_presenter.dart';
import 'package:workbook_generator_core/services/pdf_generator.dart';

final class const ApplyYourselfToMinistryPresenter({
  required final ApplyYourselfToMinistry _applyYourselfToMinistry,
}) implements PdfPresenter {
  @override
  PdfColor get iconAccentColor => .fromHex('#D69000');

  @override
  PdfColor get textAccentColor => .fromHex('#9B6D17');

  @override
  pw.Widget toPdfWidget({
    required IconProvider iconProvider,
    FontFileBytes? fontFileBytes,
  }) {
    final sectionTitle = pw.Row(
      children: [
        pw.SizedBox.square(
          dimension: 18,
          child: pw.DecoratedBox(
            decoration: pw.BoxDecoration(color: textAccentColor),
            child: pw.SvgImage(svg: iconProvider.wheatIcon.readAsStringSync()),
          ),
        ),
        pw.SizedBox(width: 5),
        pw.Text(
          'FAÇA SEU MELHOR NO MINISTÉRIO',
          style: .new(color: textAccentColor, fontWeight: .bold, fontSize: 20),
          softWrap: true,
        ),
      ],
    );

    return pw.Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        sectionTitle,
        pw.Divider(),
        for (final assignment in _applyYourselfToMinistry.assignments)
          _assignmentBuilder(assignment),
      ],
    );
  }

  pw.Widget _assignmentBuilder(Assignment assignment) {
    return pw.Column(
      mainAxisSize: .min,
      children: [
        pw.RichText(
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
                MinistryAssignment(:final names) => pw.TextSpan(
                  text: names.join(' e '),
                  style: const .new(fontStyle: .italic),
                ),
                BibleReadingAssignment(:final reader) => pw.TextSpan(
                  text: reader.self,
                  style: const .new(fontStyle: .italic),
                ),
                SinglePersonAssignment(:final name) => pw.TextSpan(
                  text: name.self,
                  style: const .new(fontStyle: .italic),
                ),
              },
            ],
            style: const .new(fontSize: 14),
          ),
        ),
        pw.SizedBox(height: 8),
      ],
    );
  }
}
