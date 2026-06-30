part of 'meeting_week.dart';

final class SpecialEventWeek extends MeetingWeek {
  const SpecialEventWeek({
    required super.weekRange,
    required super.bibleReading,
    required super.link,
    required this.reason,
  });

  final String reason;

  @override
  bool get hasMeeting => false;

  @override
  String toShareableText({RichTextKind richTextKind = .none}) {
    final buffer = StringBuffer()
      ..writeln('Semana de $weekRange')
      ..writeln()
      ..writeln(bibleReading)
      ..writeln()
      ..writeln(reason);

    return buffer.toString();
  }

  @override
  String toString() {
    return 'SpecialEventWeek(weekRange: $weekRange, bibleReading: $bibleReading, reason: $reason)';
  }

  static Result<SpecialEventWeek, FormatException> fromMap(
    Map<String, Object?> dartMap,
  ) {
    if (dartMap case {
      'kind': 'specialEvent',
      'week': final String weekRange,
      'bible_reading': final String bibleReading,
      'reason': final String reason,
      'link': final String linkString,
    } when Uri.tryParse(linkString) != null) {
      return .ok(
        SpecialEventWeek(
          weekRange: weekRange,
          bibleReading: bibleReading,
          reason: reason,
          link: .parse(linkString),
        ),
      );
    }

    return .err(
      const .new('Map does not contain required keys for SpecialEventWeek.'),
    );
  }
}
