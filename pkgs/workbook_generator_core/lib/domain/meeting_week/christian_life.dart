import 'dart:collection';

import 'package:dev_utils/result.dart';
import 'package:workbook_generator_core/domain/meeting_week/segments/assignment.dart';
import 'package:workbook_generator_core/domain/shared/name.dart';

sealed class ChristianLife {
  const ChristianLife({required this.initialParts});

  final UnmodifiableListView<SinglePersonAssignment> initialParts;

  static Result<ChristianLife, FormatException> fromMap(
    Map<String, Object?> dartMap,
  ) {
    if (dartMap.containsKey('overseer_speech')) {
      return OverseerVisitChristianLife.fromMap(dartMap);
    } else if (dartMap.containsKey('congregation_study')) {
      return RegularChristianLife.fromMap(dartMap);
    } else {
      return .err(
        const .new(
          'Map does not contain required keys for any Christian Life type.',
        ),
      );
    }
  }
}

final class CongregationStudy {
  const CongregationStudy({
    required this.title,
    required this.duration,
    required this.conductor,
    required this.reader,
  });

  final String title;
  final Duration duration;
  final Name conductor;
  final Name reader;

  @override
  String toString() {
    return 'CongregationStudy(title: $title, duration: $duration, conductor: $conductor, reader: $reader)';
  }

  static Result<CongregationStudy, FormatException> fromMap(
    Map<String, Object?> dartMap,
  ) {
    if (dartMap case {
      'title': final String title,
      'duration': final String durationString,
      'conductor': final String conductorName,
      'reader': final String readerName,
    }) {
      final durationParts = durationString.split(':');
      if (durationParts.length != 2) {
        return .err(const .new('Duration must be in the format "mm:ss".'));
      }

      final minutes = int.tryParse(durationParts[0]);
      final seconds = int.tryParse(durationParts[1]);
      if (minutes == null || seconds == null) {
        return .err(const .new('Duration must contain valid integers.'));
      }

      final duration = Duration(minutes: minutes, seconds: seconds);
      final conductor = Name(conductorName);
      final reader = Name(readerName);

      return .ok(
        .new(
          title: title,
          duration: duration,
          conductor: conductor,
          reader: reader,
        ),
      );
    } else {
      return .err(
        const .new(
          'Map does not contain required keys for a CongregationStudy.',
        ),
      );
    }
  }
}

final class OverseerVisitChristianLife extends ChristianLife {
  const OverseerVisitChristianLife({
    required super.initialParts,
    required this.overseerSpeech,
  });

  final SinglePersonAssignment overseerSpeech;

  @override
  String toString() {
    return 'OverseerVisitChristianLife(initialParts: $initialParts, overseerSpeech: $overseerSpeech)';
  }

  static Result<OverseerVisitChristianLife, FormatException> fromMap(
    Map<String, Object?> dartMap,
  ) {
    if (dartMap case {
      'parts': final List<Object?> initialPartsList,
      'overseer_speech': final Map<String, Object?> overseerSpeechMap,
    }) {
      final initialPartsResult = initialPartsList
          .whereType<Map<String, Object?>>()
          .map(SinglePersonAssignment.fromMap)
          .toList()
          .fold<Result<List<SinglePersonAssignment>, FormatException>>(
            const .ok([]),
            (acc, result) => acc.isErr
                ? acc
                : result.isErr
                ? .err(result.err!)
                : .ok([...acc.ok!, result.ok!]),
          );

      if (initialPartsResult.isErr) {
        return .err(initialPartsResult.err!);
      }

      final overseerSpeechResult = SinglePersonAssignment.fromMap(
        overseerSpeechMap,
      );
      if (overseerSpeechResult.isErr) {
        return .err(overseerSpeechResult.err!);
      }

      return .ok(
        .new(
          initialParts: UnmodifiableListView(initialPartsResult.ok!),
          overseerSpeech: overseerSpeechResult.ok!,
        ),
      );
    }

    return .err(
      const .new(
        'Map does not contain required keys for an OverseerVisitChristianLife.',
      ),
    );
  }
}

final class RegularChristianLife extends ChristianLife {
  const RegularChristianLife({
    required super.initialParts,
    required this.congregationStudy,
  });

  final CongregationStudy congregationStudy;

  @override
  String toString() {
    return 'RegularChristianLife(initialParts: $initialParts, congregationStudy: $congregationStudy)';
  }

  static Result<RegularChristianLife, FormatException> fromMap(
    Map<String, Object?> dartMap,
  ) {
    if (dartMap case {
      'parts': final List<Object?> initialPartsList,
      'congregation_study': final Map<String, Object?> congregationStudyMap,
    }) {
      final initialPartsResult = initialPartsList
          .whereType<Map<String, Object?>>()
          .map(SinglePersonAssignment.fromMap);
      if (initialPartsResult.any((result) => result.isErr)) {
        return .err(
          FormatException(
            'Error parsing initial parts: ${initialPartsResult.firstWhere((result) => result.isErr).err}',
          ),
        );
      }
      final initialParts = initialPartsResult
          .whereType<Ok<SinglePersonAssignment, FormatException>>()
          .map((e) => e.value);

      final congregationStudyResult = CongregationStudy.fromMap(
        congregationStudyMap,
      );
      if (congregationStudyResult.isErr) {
        return .err(congregationStudyResult.err!);
      }

      return .ok(
        .new(
          initialParts: UnmodifiableListView(initialParts),
          congregationStudy: congregationStudyResult.ok!,
        ),
      );
    } else if (dartMap case {
      'parts': final List<Map<String, Object?>> initialPartsList,
    }) {
      final initialPartsResult = initialPartsList
          .map(SinglePersonAssignment.fromMap)
          .toList()
          .fold<Result<List<SinglePersonAssignment>, FormatException>>(
            const .ok([]),
            (acc, result) => acc.isErr
                ? acc
                : result.isErr
                ? .err(result.err!)
                : .ok([...acc.ok!, result.ok!]),
          );

      if (initialPartsResult.isErr) {
        return .err(initialPartsResult.err!);
      }

      return .ok(
        .new(
          initialParts: UnmodifiableListView(initialPartsResult.ok!),
          congregationStudy: CongregationStudy(
            title: 'N/A',
            duration: Duration.zero,
            conductor: Name('N/A'),
            reader: Name('N/A'),
          ),
        ),
      );
    }

    return .err(
      const .new(
        'Map does not contain required keys for a RegularChristianLife.',
      ),
    );
  }
}
