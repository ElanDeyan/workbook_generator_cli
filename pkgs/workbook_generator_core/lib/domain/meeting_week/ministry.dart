import 'dart:collection';

import 'package:workbook_generator_core/domain/meeting_week/segments/assignment.dart';

final class ApplyYourselfToMinistry {
  final UnmodifiableListView<Assignment> assignments;

  const ApplyYourselfToMinistry({required this.assignments});
}
