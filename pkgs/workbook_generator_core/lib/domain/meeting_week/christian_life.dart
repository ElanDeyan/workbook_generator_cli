import 'dart:collection';

import 'package:workbook_generator_core/domain/meeting_week/segments/assignment.dart';
import 'package:workbook_generator_core/domain/shared/name.dart';

sealed class ChristianLife {
  final UnmodifiableListView<SinglePersonAssignment> initialParts;

  const ChristianLife({required this.initialParts});
}

final class CongregationStudy {
  final String title;
  final Duration duration;
  final Name conductor;
  final Name reader;

  const CongregationStudy({
    required this.title,
    required this.duration,
    required this.conductor,
    required this.reader,
  });
}

final class OverseerVisitChristianLife extends ChristianLife {
  final SinglePersonAssignment overseerSpeech;

  const OverseerVisitChristianLife({
    required super.initialParts,
    required this.overseerSpeech,
  });
}

final class RegularChristianLife extends ChristianLife {
  final CongregationStudy congregationStudy;

  const RegularChristianLife({
    required super.initialParts,
    required this.congregationStudy,
  });
}
