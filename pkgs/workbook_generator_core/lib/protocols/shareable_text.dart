import 'package:workbook_generator_core/utils/rich_text_utils.dart';

abstract interface class ShareableText {
  String toShareableText({RichTextKind richTextKind = .none});
}
