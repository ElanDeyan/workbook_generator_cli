import 'dart:collection';

import 'package:dev_utils/result.dart';
import 'package:workbook_generator_core/domain/meeting_week/segments/assignment.dart';

final class ApplyYourselfToMinistry {
  const ApplyYourselfToMinistry({required this.assignments});

  final UnmodifiableListView<MultiPersonAssignment> assignments;

  @override
  String toString() {
    return 'ApplyYourselfToMinistry(assignments: $assignments)';
  }

  static Result<ApplyYourselfToMinistry, FormatException> fromMap(
    List<Map<String, Object?>> dartListOfMaps,
  ) {
    final assignments = <MultiPersonAssignment>[];
    for (final item in dartListOfMaps) {
      final result = MultiPersonAssignment.fromMap(item);
      if (result.isErr) {
        return .err(FormatException('Error parsing assignment: ${result.err}'));
      }
      assignments.add(result.ok!);
    }

    return .ok(.new(assignments: .new(assignments)));
  }
}
