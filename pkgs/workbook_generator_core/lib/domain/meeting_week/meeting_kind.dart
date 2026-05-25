import 'package:dev_utils/result.dart';

enum MeetingKind {
  normal,
  visit,
  specialEvent;

  @override
  String toString() {
    switch (this) {
      case MeetingKind.normal:
        return 'normal';
      case MeetingKind.visit:
        return 'visit';
      case MeetingKind.specialEvent:
        return 'specialEvent';
    }
  }

  static Result<MeetingKind, FormatException> fromString(String value) {
    switch (value) {
      case 'normal':
        return const .ok(MeetingKind.normal);
      case 'visit':
        return const .ok(MeetingKind.visit);
      case 'specialEvent':
        return const .ok(MeetingKind.specialEvent);
      default:
        return .err(
          FormatException(
            'Invalid meeting kind: $value. Expected "normal", "visit", or "specialEvent".',
          ),
        );
    }
  }
}
