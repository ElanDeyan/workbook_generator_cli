part of 'meeting_week.dart';

sealed class const ProgrammedMeetingWeek<C extends ChristianLife>({
  required super.weekRange,
  required super.bibleReading,
  required super.link,
  required final UnmodifiableListView<String> songs,
  required final UnmodifiableListView<Name> prayers,
  required final Name chairman,
  required final SinglePersonAssignment initialComments,
  required final TreasuresFromGodsWord treasuresFromGodsWord,
  required final ApplyYourselfToMinistry applyYourselfToMinistry,
  required final C christianLife,
  required final SinglePersonAssignment finalComments,
}) extends MeetingWeek;
