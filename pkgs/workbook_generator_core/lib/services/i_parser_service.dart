import 'package:dey_dev_utils/result.dart';

abstract interface class const ParserService() {
  FutureResult<List<Map<String, Object?>>, FormatException> fromString(
    String rawString,
  );
}
