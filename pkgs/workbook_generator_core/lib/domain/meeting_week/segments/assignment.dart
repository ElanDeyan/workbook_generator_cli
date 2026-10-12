import 'dart:collection';

import 'package:dey_dev_utils/result.dart';
import 'package:workbook_generator_core/domain/shared/name.dart';

sealed class const Assignment({
  required final String title,
  required final Duration duration,
}) {
  static Result<Assignment, FormatException> fromMap(
    Map<String, Object?> dartMap,
  ) {
    if (dartMap.containsKey('names')) {
      return MultiPersonAssignment.fromMap(dartMap);
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

final class const MultiPersonAssignment({
  required super.title,
  required super.duration,
  required final UnmodifiableListView<Name> names,
}) extends Assignment {
  @override
  String toString() {
    return 'MultiPersonAssignment(title: $title, duration: $duration, names: $names)';
  }

  static Result<MultiPersonAssignment, FormatException> fromMap(
    Map<String, Object?> dartMap,
  ) {
    if (dartMap case {
      'title': final String title,
      'duration': final String durationString,
      'who': final List<Object?> namesList,
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

      return .ok(.new(title: title, duration: duration, names: names));
    } else {
      return .err(
        const .new('Map does not contain required keys or has invalid types.'),
      );
    }
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
    return 'SinglePersonAssignment(name: $name, title: $title, duration: $duration)';
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
