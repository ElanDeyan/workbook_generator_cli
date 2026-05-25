import 'dart:collection';

import 'package:dev_utils/result.dart';
import 'package:workbook_generator_core/domain/shared/name.dart';

sealed class Assignment {
  const Assignment();

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

final class MultiPersonAssignment extends Assignment {
  const MultiPersonAssignment({
    required this.title,
    required this.duration,
    required this.names,
  });

  final String title;
  final Duration duration;
  final UnmodifiableListView<Name> names;

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

final class SinglePersonAssignment extends Assignment {
  const SinglePersonAssignment({
    required this.name,
    required this.title,
    required this.duration,
  });

  factory SinglePersonAssignment.spiritualGems({
    required Name name,
    required Duration duration,
  }) => .new(duration: duration, name: name, title: 'Joias espirituais');

  final Name name;
  final String title;
  final Duration duration;

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
