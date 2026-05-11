import 'dart:collection';

import 'package:workbook_generator_core/domain/shared/name.dart';

sealed class Assignment {
  const Assignment();
}

final class MultiPersonAssignment extends Assignment {
  final String title;
  final Duration duration;
  final UnmodifiableListView<Name> names;

  const MultiPersonAssignment({
    required this.title,
    required this.duration,
    required this.names,
  });
}

final class SinglePersonAssignment extends Assignment {
  final Name name;
  final String title;
  final Duration duration;

  const SinglePersonAssignment({
    required this.name,
    required this.title,
    required this.duration,
  });

  factory SinglePersonAssignment.spiritualGems({
    required Name name,
    required Duration duration,
  }) => .new(duration: duration, name: name, title: 'Joias espirituais');
}
