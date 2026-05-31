enum RichTextKind { whatsApp, markdown, none }

extension RichTextUtils on String {
  String applyBoldBy(RichTextKind kind) => switch (kind) {
    .whatsApp => toWhatsAppBold(),
    .markdown => toMarkdownBold(),
    .none => this,
  };

  String applyItalicBy(RichTextKind kind) => switch (kind) {
    .whatsApp => toWhatsAppItalic(),
    .markdown => toMarkdownItalic(),
    .none => this,
  };

  String toMarkdownBold() => wrapWith('**');
  String toMarkdownItalic() => wrapWith('*');

  String toWhatsAppBold() => wrapWith('*');

  String toWhatsAppItalic() => wrapWith('_');

  String wrapWith(String wrapper) => '$wrapper$this$wrapper';
}
