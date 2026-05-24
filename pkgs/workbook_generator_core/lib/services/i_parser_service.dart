import 'package:dev_utils/result.dart';

abstract interface class IParserService {
  const IParserService();

  FutureResult<List<Map<String, Object?>>, FormatException> fromString(
    String rawString,
  );
}
