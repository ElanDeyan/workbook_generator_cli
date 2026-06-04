import 'dart:io';

final class IconProvider {
  const IconProvider();

  static final Directory iconsDirectory = Directory('../../assets/icons/');

  File get diamondIcon => .new(
    '${iconsDirectory.path}'
    'diamond_24dp_E3E3E3_FILL0_wght400_GRAD0_opsz24.svg',
  );

  File get emojiPeopleIcon => .new(
    '${iconsDirectory.path}'
    'emoji_people_24dp_E3E3E3_FILL0_wght400_GRAD0_opsz24.svg',
  );

  File get musicNoteIcon => .new(
    '${iconsDirectory.path}'
    'music_note_2_24dp_E3E3E3_FILL0_wght400_GRAD0_opsz24.svg',
  );

  File get wheatIcon => .new(
    '${iconsDirectory.path}'
    'wheat_24dp_E3E3E3_FILL0_wght400_GRAD0_opsz24.svg',
  );
}
