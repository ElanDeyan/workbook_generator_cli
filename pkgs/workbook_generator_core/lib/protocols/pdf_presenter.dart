import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:workbook_generator_core/protocols/icon_provider.dart';
import 'package:workbook_generator_core/services/pdf_generator.dart';

abstract interface class PdfPresenter {
  PdfColor get iconAccentColor;
  PdfColor get textAccentColor;
  pw.Widget toPdfWidget({
    required IconProvider iconProvider,
    FontFileBytes? fontFileBytes,
  });
}
