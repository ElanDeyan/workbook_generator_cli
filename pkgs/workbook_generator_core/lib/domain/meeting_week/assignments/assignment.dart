import 'dart:collection';

import 'package:dey_dev_utils/result.dart';
import 'package:workbook_generator_core/domain/meeting_week/ministry.dart';
import 'package:workbook_generator_core/domain/shared/name.dart';
import 'package:workbook_generator_core/protocols/school_assignable.dart';

typedef _StudyPointData = ({
  String point,
  SchoolPublicationReference? publicationReference,
});

Result<_StudyPointData?, FormatException> _parseStudyPoint(Object? value) {
  if (value == null) {
    return const .ok(null);
  }
  if (value is! Map<String, Object?> || value.length != 2) {
    return .err(const .new('Invalid study_point object.'));
  }

  final point = value['point'];
  final publicationCode = value['publication_code'];
  if (point is! String || point.trim().isEmpty) {
    return .err(
      const FormatException('Study point must be a non-empty string.'),
    );
  }
  if (publicationCode == null) {
    return .ok((point: point, publicationReference: null));
  }
  if (publicationCode is! String) {
    return .err(const .new('Invalid study point publication code.'));
  }

  final publicationReference = SchoolPublicationReference.fromPublicationCode(
    publicationCode,
  );
  if (publicationReference.isErr) {
    return .err(publicationReference.err!);
  }

  return .ok((point: point, publicationReference: publicationReference.ok));
}

sealed class const Assignment({
  required final String title,
  required final Duration duration,
}) {
  static Result<Assignment, FormatException> fromMap(
    Map<String, Object?> dartMap,
  ) {
    if (dartMap.containsKey('names')) {
      return MinistryAssignment.fromMap(dartMap);
    } else if (dartMap.containsKey('name')) {
      return SinglePersonAssignment.fromMap(dartMap);
    } else {
      return .err(
        const .new(
          'Map does not contain required keys for any assignment type.',
        ),
      );
    }
  }
}

final class const MinistryAssignment({
  required super.title,
  required super.duration,
  required final UnmodifiableListView<Name> names,
  required final MinistryAssignmentKind kind,
  required final String? description,
  required final bool isTalk,
  @override
  required final SchoolPublicationReference? schoolPublicationReference,
  final String? studyPoint,
}) extends Assignment implements SchoolAssignable {
  @override
  String toString() =>
      'MultiPersonAssignment(title: $title, duration: $duration, '
      'names: $names , kind: $kind, '
      'description: $description, '
      'isTalk: $isTalk, schoolPublicationReference: $schoolPublicationReference'
      ')';

  static Result<MinistryAssignment, FormatException> fromMap(
    Map<String, Object?> dartMap,
  ) {
    if (dartMap case {
      'title': final String title,
      'duration': final String durationString,
      'who': final List<Object?> namesList,
      'kind': final String kindString,
      'description': final String? description,
      'is_talk': final bool isTalk,
      'study_point': final Object? studyPointValue,
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
      final names = UnmodifiableListView(
        namesList.whereType<String>().map(Name.new),
      );

      final kind = MinistryAssignmentKind.fromJsonValue(kindString);
      if (kind.isErr) {
        return .err(
          FormatException('Invalid MinistryAssignmentKind: $kindString'),
        );
      }

      final studyPointResult = _parseStudyPoint(studyPointValue);
      if (studyPointResult.isErr) {
        return .err(studyPointResult.err!);
      }
      final studyPoint = studyPointResult.unwrapOrNull();
      final publicationReference = studyPoint?.publicationReference;

      if (kind
          case Ok<MinistryAssignmentKind, FormatException>(value: final kind)
          when kind != .whatWouldYouSay && publicationReference == null) {
        return .err(
          FormatException(
            'Publication code is required for assignment kind: $kindString',
          ),
        );
      }

      return .ok(
        .new(
          title: title,
          duration: duration,
          names: names,
          isTalk: isTalk,
          kind: kind.unwrap(),
          description: description,
          studyPoint: studyPoint?.point,
          schoolPublicationReference: publicationReference,
        ),
      );
    } else {
      return .err(
        const .new('Map does not contain required keys or has invalid types.'),
      );
    }
  }
}

final class const BibleReadingAssignment({
  required super.title,
  required super.duration,
  required final Name reader,
  @override
  required final SchoolPublicationReference? schoolPublicationReference,
  final String? studyPoint,
}) extends Assignment implements SchoolAssignable {
  @override
  String toString() {
    return 'BibleReadingAssignment(title: $title, duration: $duration, '
        'reader: $reader, '
        'schoolPublicationReference: $schoolPublicationReference)';
  }

  static Result<BibleReadingAssignment, FormatException> fromMap(
    Map<String, Object?> dartMap,
  ) {
    if (dartMap case {
      'title': final String title,
      'duration': final String durationString,
      'reader': final String readerName,
      'study_point': final Object? studyPointValue,
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
      final reader = Name(readerName);

      final studyPointResult = _parseStudyPoint(studyPointValue);
      if (studyPointResult.isErr) {
        return .err(studyPointResult.err!);
      }
      final studyPoint = studyPointResult.unwrapOrNull();

      return .ok(
        .new(
          title: title,
          duration: duration,
          reader: reader,
          studyPoint: studyPoint?.point,
          schoolPublicationReference: studyPoint?.publicationReference,
        ),
      );
    }

    return .err(
      const .new(
        'Map does not contain required keys for a BibleReadingAssignment.',
      ),
    );
  }
}

final class const SinglePersonAssignment({
  required super.title,
  required super.duration,
  required final Name name,
}) extends Assignment {
  factory spiritualGems({required Name name, required Duration duration}) =>
      .new(duration: duration, name: name, title: 'Joias espirituais');

  @override
  String toString() {
    return 'SinglePersonAssignment(name: $name, title: $title, '
        'duration: $duration)';
  }

  static Result<SinglePersonAssignment, FormatException> fromMap(
    Map<String, Object?> dartMap,
  ) {
    if (dartMap case {
      'who': final String nameString,
      'title': final String title,
      'duration': final String durationString,
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
      final name = Name(nameString);

      return .ok(.new(name: name, title: title, duration: duration));
    } else {
      return .err(
        const .new('Map does not contain required keys or has invalid types.'),
      );
    }
  }
}
