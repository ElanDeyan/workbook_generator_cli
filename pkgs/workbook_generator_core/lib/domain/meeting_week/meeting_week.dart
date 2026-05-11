import 'dart:collection';

import 'package:workbook_generator_core/domain/meeting_week/christian_life.dart';
import 'package:workbook_generator_core/domain/meeting_week/ministry.dart';
import 'package:workbook_generator_core/domain/meeting_week/segments/assignment.dart';
import 'package:workbook_generator_core/domain/meeting_week/treasures.dart';
import 'package:workbook_generator_core/domain/shared/name.dart';

sealed class MeetingWeek {
  const MeetingWeek();

  bool get hasMeeting;
}

final class NoMeetingWeek extends MeetingWeek {
  final String weekRange;
  final String bibleReading;
  final String reason;

  const NoMeetingWeek({
    required this.weekRange,
    required this.bibleReading,
    required this.reason,
  });

  @override
  bool get hasMeeting => false;
}

final class RegularMeetingWeek extends MeetingWeek {
  final String weekRange;
  final String bibleReading;
  final UnmodifiableListView<String> songs;
  final UnmodifiableListView<Name> prayers;
  final Name chairman;
  final SinglePersonAssignment initialComments;
  final TreasuresFromGodsWord treasuresFromGodsWord;
  final ApplyYourselfToMinistry applyYourselfToMinistry;
  final ChristianLife christianLife;
  final SinglePersonAssignment finalComments;

  const RegularMeetingWeek({
    required this.weekRange,
    required this.bibleReading,
    required this.songs,
    required this.prayers,
    required this.chairman,
    required this.initialComments,
    required this.treasuresFromGodsWord,
    required this.applyYourselfToMinistry,
    required this.christianLife,
    required this.finalComments,
  });

  @override
  bool get hasMeeting => true;
}
