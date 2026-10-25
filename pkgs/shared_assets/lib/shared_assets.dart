import 'dart:io';
import 'dart:isolate';

import 'package:workbook_generator_core/protocols/icon_provider.dart';
import 'package:workbook_generator_core/services/pdf_generator.dart';

final class SharedAssets._(
  final FontFileBytes fontFileBytes,
  final Uri _iconsDirectoryUri,
) implements IconProvider {
  /// Loads the font and icons bundled with this package.
  ///
  /// Asset paths are resolved from the package location, not the current
  /// working directory.
  static Future<SharedAssets> load() async {
    final packageLibraryUri = await Isolate.resolvePackageUri(
      .parse('package:shared_assets/shared_assets.dart'),
    );
    if (packageLibraryUri == null) {
      throw StateError('Unable to resolve the shared_assets package URI.');
    }

    final packageRootUri = File.fromUri(packageLibraryUri).parent.parent.uri;
    final fontFile = File.fromUri(
      packageRootUri.resolve('assets/fonts/Roboto/static/Roboto-Regular.ttf'),
    );
    final fontFileBytes = FontFileBytes(await fontFile.readAsBytes());

    return ._(fontFileBytes, packageRootUri.resolve('assets/icons/'));
  }

  @override
  File get diamondIcon => File.fromUri(
    _iconsDirectoryUri.resolve(
      'diamond_24dp_E3E3E3_FILL0_wght400_GRAD0_opsz24.svg',
    ),
  );

  @override
  File get emojiPeopleIcon => File.fromUri(
    _iconsDirectoryUri.resolve(
      'emoji_people_24dp_E3E3E3_FILL0_wght400_GRAD0_opsz24.svg',
    ),
  );

  @override
  File get musicNoteIcon => File.fromUri(
    _iconsDirectoryUri.resolve(
      'music_note_2_24dp_E3E3E3_FILL0_wght400_GRAD0_opsz24.svg',
    ),
  );

  @override
  File get wheatIcon => File.fromUri(
    _iconsDirectoryUri.resolve(
      'wheat_24dp_E3E3E3_FILL0_wght400_GRAD0_opsz24.svg',
    ),
  );
}
