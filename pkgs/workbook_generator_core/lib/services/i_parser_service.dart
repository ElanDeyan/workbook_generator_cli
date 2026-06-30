import 'package:dev_utils/result.dart';

abstract interface class ParserService {
  const ParserService();

  FutureResult<List<Map<String, Object?>>, FormatException> fromString(
    String rawString,
  );
}
