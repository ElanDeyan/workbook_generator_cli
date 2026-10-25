import 'dart:io';

import 'package:shared_assets/shared_assets.dart';
import 'package:test/test.dart';

void main() {
  test(
    'loads bundled PDF assets independently of the current directory',
    () async {
      final originalDirectory = Directory.current;
      final temporaryDirectory = await Directory.systemTemp.createTemp();

      try {
        Directory.current = temporaryDirectory.path;

        final assets = await SharedAssets.load();

        expect(assets.fontFileBytes.bytes, isNotEmpty);
        expect(assets.diamondIcon.existsSync(), isTrue);
        expect(assets.emojiPeopleIcon.existsSync(), isTrue);
        expect(assets.musicNoteIcon.existsSync(), isTrue);
        expect(assets.wheatIcon.existsSync(), isTrue);
      } finally {
        Directory.current = originalDirectory.path;
        await temporaryDirectory.delete(recursive: true);
      }
    },
  );
}
