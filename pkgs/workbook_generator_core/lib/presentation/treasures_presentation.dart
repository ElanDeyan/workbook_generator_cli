import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:workbook_generator_core/domain/meeting_week/treasures.dart';
import 'package:workbook_generator_core/protocols/pdf_presenter.dart';
import 'package:workbook_generator_core/services/icon_provider.dart';

final class TreasuresFromGodsWordPresenter implements PdfPresenter {
  const TreasuresFromGodsWordPresenter({required this._treasures});

  final TreasuresFromGodsWord _treasures;

  @override
  PdfColor get iconAccentColor => .fromHex('#3C7F8B');

  @override
  PdfColor get textAccentColor => .fromHex('#2A6B77');

  @override
  pw.Widget toPdfWidget() {
    const iconProvider = IconProvider();

    final sectionTitle = pw.Row(
      children: [
        pw.SizedBox.square(
          dimension: 18,
          child: pw.DecoratedBox(
            decoration: pw.BoxDecoration(color: iconAccentColor),
            child: pw.SvgImage(
              svg: iconProvider.diamondIcon.readAsStringSync(),
            ),
          ),
        ),
        pw.SizedBox(width: 5),
        pw.Text(
          'TESOUROS DA PALAVRA DE DEUS',
          style: .new(color: textAccentColor, fontWeight: .bold, fontSize: 20),
          softWrap: true,
        ),
      ],
    );

    final speech = _treasures.speech;
    final speechRender = pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: speech.title,
            style: .new(color: textAccentColor, fontWeight: .bold),
          ),
          const pw.TextSpan(text: ' '),
          pw.TextSpan(text: '(${speech.duration.inMinutes} min)'),
          const pw.TextSpan(text: ' - '),
          pw.TextSpan(
            text: '${speech.name}',
            style: .new(fontStyle: .italic),
          ),
        ],
        style: const .new(fontSize: 14),
      ),
    );

    final spiritualGems = _treasures.spiritualGems;
    final spiritualGemsRender = pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: spiritualGems.title,
            style: .new(color: textAccentColor, fontWeight: .bold),
          ),
          const pw.TextSpan(text: ' '),
          pw.TextSpan(text: '(${spiritualGems.duration.inMinutes} min)'),
          const pw.TextSpan(text: ' - '),
          pw.TextSpan(
            text: '${spiritualGems.name}',
            style: .new(fontStyle: .italic),
          ),
        ],
        style: const .new(fontSize: 14),
      ),
    );

    final bibleReading = _treasures.bibleReading;
    final bibleReadingRender = pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: bibleReading.title,
            style: .new(color: textAccentColor, fontWeight: .bold),
          ),
          const pw.TextSpan(text: ' '),
          pw.TextSpan(text: '(${bibleReading.duration.inMinutes} min)'),
          const pw.TextSpan(text: ' - '),
          pw.TextSpan(
            text: '${bibleReading.name}',
            style: .new(fontStyle: .italic),
          ),
        ],
        style: const .new(fontSize: 14),
      ),
    );

    return pw.Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        sectionTitle,
        pw.Divider(),
        speechRender,
        pw.SizedBox(height: 8),
        spiritualGemsRender,
        pw.SizedBox(height: 8),
        bibleReadingRender,
        pw.SizedBox(height: 8),
      ],
    );
  }
}
