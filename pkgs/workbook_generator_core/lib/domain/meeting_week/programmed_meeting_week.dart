part of 'meeting_week.dart';

sealed class ProgrammedMeetingWeek extends MeetingWeek {
  const ProgrammedMeetingWeek({
    required super.weekRange,
    required super.bibleReading,
    required super.link,
    required this.songs,
    required this.prayers,
    required this.chairman,
    required this.initialComments,
    required this.treasuresFromGodsWord,
    required this.applyYourselfToMinistry,
    required this.finalComments,
  });

  final UnmodifiableListView<String> songs;
  final UnmodifiableListView<Name> prayers;
  final Name chairman;
  final SinglePersonAssignment initialComments;
  final TreasuresFromGodsWord treasuresFromGodsWord;
  final ApplyYourselfToMinistry applyYourselfToMinistry;
  final SinglePersonAssignment finalComments;
}
