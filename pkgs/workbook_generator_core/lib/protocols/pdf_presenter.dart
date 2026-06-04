import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

abstract interface class PdfPresenter {
  PdfColor get iconAccentColor;
  PdfColor get textAccentColor;
  pw.Widget toPdfWidget();
}
