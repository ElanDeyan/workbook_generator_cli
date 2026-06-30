import 'dart:isolate';

import 'package:dev_utils/result.dart';
import 'package:dev_utils/trampoline.dart';
import 'package:workbook_generator_core/services/i_parser_service.dart';
import 'package:yaml/yaml.dart';

void main(List<String> args) async {
  const parser = YamlParserService();

  final object = await parser.fromString(_sample);
  print(object.unwrap());
}

const _sample = '''
---
- kind: normal
  week: 4-10 de maio
  bible_reading: ISAÍAS 58-59
  songs:
    - Cântico 21
    - Cântico 100
    - Cântico 42
  prayers:
    - Person 1
    - Person 2
  chairman: Person 1
  initial_comments:
    who: Person 1
    duration: 1 min
  treasures:
    speech:
      who: Person 3
      title: Receba muitas bençãos de Jeová
      duration: 10 min
    jewels:
      who: Person 4
      duration: 10 min
    bible_reading:
      who: Person 5
      duration: 4 min
  ministry:
    - title: "4. Iniciando conversas"
      duration: 3 min
      who:
        - Person 6
        - Person 7
    - title: "5. Iniciando conversas"
      duration: 4 min
      who:
        - Person 8
        - Person 9
  christian_life:
    parts:
      - title: "Sempre mostrem hospitalidade"
        duration: 15 min
        who: Person 10
    congregation_study:
      title: Estudo bíblico de congregação
      duration: 30 min
      conductor: Person 11
      reader: Person 12
  final_comments:
    who: Person 1
    duration: 3 min
---
- kind: normal
  week: 4-10 de maio
  bible_reading: ISAÍAS 58-59
  songs:
    - Cântico 21
    - Cântico 100
    - Cântico 42
  prayers:
    - Person 1
    - Person 2
  chairman: Person 1
  initial_comments:
    who: Person 1
    duration: 1 min
  treasures:
    speech:
      who: Person 3
      title: Receba muitas bençãos de Jeová
      duration: 10 min
    jewels:
      who: Person 4
      duration: 10 min
    bible_reading:
      who: Person 5
      duration: 4 min
  ministry:
    - title: "4. Iniciando conversas"
      duration: 3 min
      who:
        - Person 6
        - Person 7
    - title: "5. Iniciando conversas"
      duration: 4 min
      who:
        - Person 8
        - Person 9
  christian_life:
    parts:
      - title: "Sempre mostrem hospitalidade"
        duration: 15 min
        who: Person 10
    congregation_study:
      title: Estudo bíblico de congregação
      duration: 30 min
      conductor: Person 11
      reader: Person 12
  final_comments:
    who: Person 1
    duration: 3 min
''';

final class YamlParserService implements ParserService {
  const YamlParserService();
  @override
  FutureResult<List<Map<String, Object?>>, FormatException> fromString(
    String yamlString,
  ) async {
    final yamlStream = await Isolate.run(
      () => loadYamlStream(yamlString)
          .map<Result<List<Map<String, Object?>>, FormatException>>((doc) {
            final value = _toPlain(doc);
            if (value is! Iterable<Object?>) {
              return .err(const FormatException('expected list'));
            }
            if (value.any((e) => e is! Map<String, Object?>)) {
              return .err(const FormatException('expected list of maps'));
            }

            return .ok(value.cast<Map<String, Object?>>().toList());
          }),
    );

    final result = <Map<String, Object?>>[];
    for (final data in yamlStream) {
      switch (data) {
        case Err(:final error, :final stackTrace):
          return .err(error, stackTrace);
        case Ok(:final value):
          result.addAll(value);
      }
    }

    return .ok(result);
  }

  Object? _toPlain(Object? node) => trampoline(switch (node) {
    final YamlList yamlList => _toPlainList(yamlList),
    final YamlMap yamlMap => _toPlainMap(yamlMap),
    _ => Done(node),
  });

  Bounce<List<Object?>> _toPlainList(YamlList list) =>
      Done(list.map(_toPlain).toList());

  Bounce<Map<String, Object?>> _toPlainMap(YamlMap map) =>
      Done(map.map((k, v) => MapEntry(k.toString(), _toPlain(v))));
}
