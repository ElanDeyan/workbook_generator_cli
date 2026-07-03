part of 'meeting_week.dart';

sealed class ProgrammedMeetingWeek<C extends ChristianLife> extends MeetingWeek {
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
    required this.christianLife,
    required this.finalComments,
  });

  final UnmodifiableListView<String> songs;
  final UnmodifiableListView<Name> prayers;
  final Name chairman;
  final SinglePersonAssignment initialComments;
  final TreasuresFromGodsWord treasuresFromGodsWord;
  final ApplyYourselfToMinistry applyYourselfToMinistry;
  final C christianLife;
  final SinglePersonAssignment finalComments;
}
