extension RichTextUtils on String {
  String wrapWith(String wrapper) {
    return '$wrapper$this$wrapper';
  }

  String toBold() => wrapWith('**');
  String toItalic() => wrapWith('*');

  String toWhatsAppBold() => wrapWith('*');
  String toWhatsAppItalic() => wrapWith('_');
}
