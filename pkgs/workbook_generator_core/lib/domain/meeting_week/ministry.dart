import 'dart:collection';

import 'package:dey_dev_utils/result.dart';
import 'package:workbook_generator_core/domain/meeting_week/assignments/assignment.dart';

enum MinistryAssignmentKind({required final String jsonValue}) {
  startingAConversation(jsonValue: 'starting_a_conversation'),
  followingUp(jsonValue: 'following_up'),
  whatWouldYouSay(jsonValue: 'what_would_you_say'),
  makingDisciples(jsonValue: 'making_disciples'),
  explainingYourBeliefs(jsonValue: 'explaining_your_beliefs'),
  talk(jsonValue: 'talk');

  static Result<MinistryAssignmentKind, FormatException> fromJsonValue(
    String jsonValue,
  ) {
    for (final kind in MinistryAssignmentKind.values) {
      if (kind.jsonValue == jsonValue) {
        return .ok(kind);
      }
    }
    return .err(FormatException('Invalid MinistryAssignmentKind: $jsonValue'));
  }
}

enum SchoolPublicationReference({required final String publicationCode}) {
  teaching(publicationCode: 'th'),
  lovePeople(publicationCode: 'lmd');

  static Result<SchoolPublicationReference, FormatException>
  fromPublicationCode(String publicationCode) {
    for (final reference in SchoolPublicationReference.values) {
      if (reference.publicationCode == publicationCode) {
        return .ok(reference);
      }
    }
    return .err(
      FormatException('Invalid SchoolPublicationReference: $publicationCode'),
    );
  }
}

final class const ApplyYourselfToMinistry({
  required final UnmodifiableListView<MinistryAssignment> assignments,
}) {
  @override
  String toString() {
    return 'ApplyYourselfToMinistry(assignments: $assignments)';
  }

  static Result<ApplyYourselfToMinistry, FormatException> fromMap(
    List<Map<String, Object?>> dartListOfMaps,
  ) {
    final assignments = <MinistryAssignment>[];
    for (final item in dartListOfMaps) {
      final result = MinistryAssignment.fromMap(item);
      if (result.isErr) {
        return .err(FormatException('Error parsing assignment: ${result.err}'));
      }
      assignments.add(result.ok!);
    }

    return .ok(.new(assignments: .new(assignments)));
  }
}
