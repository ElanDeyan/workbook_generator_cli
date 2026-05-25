import 'dart:collection';

import 'package:dev_utils/result.dart';
import 'package:workbook_generator_core/domain/meeting_week/christian_life.dart';
import 'package:workbook_generator_core/domain/meeting_week/meeting_kind.dart';
import 'package:workbook_generator_core/domain/meeting_week/ministry.dart';
import 'package:workbook_generator_core/domain/meeting_week/segments/assignment.dart';
import 'package:workbook_generator_core/domain/meeting_week/treasures.dart';
import 'package:workbook_generator_core/domain/shared/name.dart';
import 'package:workbook_generator_core/services/yaml_parser_service.dart';

void main(List<String> args) async {
  const sample = '''

# # ============================================================================
# # WORKBOOK SCHEMA - Multiple Document Format
# # ============================================================================
# # This YAML file contains multiple documents separated by ---
# # Each document represents a different week in the workbook.
# # Three types of weeks are supported:
# #
# # 1. Normal Meeting Week - regular weekly meetings with full programming
# # 2. Special Event Week - no meeting (e.g., convention, assembly, special event)
# # 3. Visit Week - visiting speaker replaces the congregation study
# # ============================================================================
---
- kind: normal
  week: 4-10 de maio
  bible_reading: ISAÍAS 58-59
  songs:
    - Cântico 21
    - Cântico 100
    - Cântico 42
  prayers:
    - Person 1
    - Person 2
  chairman: Person 1
  initial_comments:
    title: "Comentários iniciais"
    who: Person 1
    duration: 1:00
  treasures:
    speech:
      who: Person 3
      title: 1. Receba muitas bençãos de Jeová
      duration: 10:00
    spiritual_gems:
      title: "2. Joias espirituais"
      who: Person 4
      duration: 10:00
    bible_reading:
      title: "3. Leitura da Bíblia"
      who: Person 5
      duration: 4:00
  ministry:
    - title: "4. Iniciando conversas"
      duration: 3:00
      who:
        - Person 6
        - Person 7
    - title: "5. Iniciando conversas"
      duration: 4:00
      who:
        - Person 8
        - Person 9
  christian_life:
    parts:
      - title: "Sempre mostrem hospitalidade"
        duration: 15:00
        who: Person 10
    congregation_study:
      title: Estudo bíblico de congregação
      duration: 30:00
      conductor: Person 11
      reader: Person 12
  final_comments:
    title: "Comentários finais"
    who: Person 1
    duration: 3:00
---
- kind: specialEvent
  bible_reading: ISAÍAS 60-62
  week: 11-17 de maio
  reason: "Convenção Regional"
  no_meeting: true
---
- kind: visit
  bible_reading: ISAÍAS 60-62
  week: 11-17 de maio
  prayers:
    - Person 10
    - Person 11
  songs:
    - Cântico 3
    - Cântico 45
    - Cântico 67
  chairman: Person 1
  initial_comments:
    title: "Comentários iniciais"
    who: Person 1
    duration: 1:00
  treasures:
    speech:
      who: Person 3
      title: 1. Receba muitas bençãos de Jeová
      duration: 10:00
    spiritual_gems:
      title: "2. Joias espirituais"
      who: Person 4
      duration: 10:00
    bible_reading:
      title: "3. Leitura da Bíblia"
      who: Person 5
      duration: 4:00
  ministry:
    - title: "4. Iniciando conversas"
      duration: 3:00
      who:
        - Person 6
        - Person 7
    - title: "5. Iniciando conversas"
      duration: 4:00
      who:
        - Person 8
  christian_life:
    parts:
      - duration: 15:00
        title: Part 1
        who: Person 9
    overseer_speech:
      duration: 30:00
      title: Theme
      who: Overseer
  final_comments:
    duration: 3:00
    title: Comentários finais
    who: Chairman
''';
  const yamlParser = YamlParserService();

  final result = await yamlParser.fromString(sample);
  if (result.isErr) {
    print('Error parsing YAML: ${result.err}');
  } else {
    final meetingWeek = result.ok!;
    print('Successfully parsed meeting week: $meetingWeek');

    final parseResult = [
      for (final map in meetingWeek) MeetingWeek.fromMap(map),
    ];
    print('Parsed meeting weeks: $parseResult');
  }
}

sealed class MeetingWeek {
  const MeetingWeek();

  bool get hasMeeting;
  MeetingKind get kind => switch (this) {
    RegularMeetingWeek() => .normal,
    VisitMeetingWeek() => .visit,
    SpecialEventWeek() => .specialEvent,
  };

  static Result<MeetingWeek, FormatException> fromMap(
    Map<String, Object?> dartMap,
  ) {
    if (dartMap case {'kind': 'normal'}) {
      return RegularMeetingWeek.fromMap(dartMap);
    } else if (dartMap case {'kind': 'visit'}) {
      return VisitMeetingWeek.fromMap(dartMap);
    } else if (dartMap case {'kind': 'specialEvent'}) {
      return SpecialEventWeek.fromMap(dartMap);
    } else {
      return .err(
        const .new('Map does not contain a valid "kind" key for MeetingWeek.'),
      );
    }
  }
}

final class RegularMeetingWeek extends MeetingWeek {
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

  @override
  bool get hasMeeting => true;

  @override
  String toString() {
    return 'RegularMeetingWeek(weekRange: $weekRange, bibleReading: $bibleReading, songs: $songs, prayers: $prayers, chairman: $chairman, initialComments: $initialComments, treasuresFromGodsWord: $treasuresFromGodsWord, applyYourselfToMinistry: $applyYourselfToMinistry, christianLife: $christianLife, finalComments: $finalComments)';
  }

  static Result<RegularMeetingWeek, FormatException> fromMap(
    Map<String, Object?> dartMap,
  ) {
    if (dartMap case {
      'kind': 'normal',
      'week': final String weekRange,
      'bible_reading': final String bibleReading,
      'songs': final List<Object?> songsList,
      'prayers': final List<Object?> prayersList,
      'chairman': final String chairmanName,
      'initial_comments': final Map<String, Object?> initialCommentsMap,
      'treasures': final Map<String, Object?> treasuresMap,
      'ministry': final List<Object?> ministryMap,
      'christian_life': final Map<String, Object?> christianLifeMap,
      'final_comments': final Map<String, Object?> finalCommentsMap,
    }) {
      final chairman = Name(chairmanName);

      final initialCommentsResult = SinglePersonAssignment.fromMap(
        initialCommentsMap,
      );
      if (initialCommentsResult.isErr) {
        return .err(
          FormatException(
            'Error parsing initial comments assignment: ${initialCommentsResult.err}',
          ),
        );
      }

      final treasuresResult = TreasuresFromGodsWord.fromMap(treasuresMap);
      if (treasuresResult.isErr) {
        return .err(
          FormatException(
            "Error parsing treasures from God's Word: ${treasuresResult.err}",
          ),
        );
      }

      final ministryResult = ApplyYourselfToMinistry.fromMap(
        ministryMap.whereType<Map<String, Object?>>().toList(),
      );
      if (ministryResult.isErr) {
        return .err(
          FormatException(
            'Error parsing apply yourself to ministry: ${ministryResult.err}',
          ),
        );
      }

      final christianLifeResult = ChristianLife.fromMap(christianLifeMap);
      if (christianLifeResult.isErr) {
        return .err(
          FormatException(
            'Error parsing Christian life segment: ${christianLifeResult.err}',
          ),
        );
      }

      final finalCommentsResult = SinglePersonAssignment.fromMap(
        finalCommentsMap,
      );
      if (finalCommentsResult.isErr) {
        return .err(
          FormatException(
            'Error parsing final comments assignment: ${finalCommentsResult.err}',
          ),
        );
      }

      return .ok(
        RegularMeetingWeek(
          weekRange: weekRange,
          bibleReading: bibleReading,
          songs: UnmodifiableListView(songsList.whereType<String>().toList()),
          prayers: UnmodifiableListView(
            prayersList.whereType<String>().toList().map(Name.new),
          ),
          chairman: chairman,
          initialComments: initialCommentsResult.ok!,
          treasuresFromGodsWord: treasuresResult.ok!,
          applyYourselfToMinistry: ministryResult.ok!,
          christianLife: christianLifeResult.ok!,
          finalComments: finalCommentsResult.ok!,
        ),
      );
    }

    return .err(
      const .new(
        'Map does not contain required keys for '
        'RegularMeetingWeek or has invalid types.',
      ),
    );
  }
}

final class SpecialEventWeek extends MeetingWeek {
  const SpecialEventWeek({
    required this.weekRange,
    required this.bibleReading,
    required this.reason,
  });

  final String weekRange;
  final String bibleReading;
  final String reason;

  @override
  bool get hasMeeting => false;

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
    }) {
      return .ok(
        SpecialEventWeek(
          weekRange: weekRange,
          bibleReading: bibleReading,
          reason: reason,
        ),
      );
    }

    return .err(
      const .new('Map does not contain required keys for SpecialEventWeek.'),
    );
  }
}

final class VisitMeetingWeek extends MeetingWeek {
  VisitMeetingWeek({
    required this.weekRange,
    required this.bibleReading,
    required this.songs,
    required this.prayers,
    required this.chairman,
    required this.initialComments,
    required this.treasuresFromGodsWord,
    required this.applyYourselfToMinistry,
    required this.overseerVisitChristianLife,
    required this.finalComments,
  });

  final String weekRange;
  final String bibleReading;
  final UnmodifiableListView<String> songs;
  final UnmodifiableListView<Name> prayers;
  final Name chairman;
  final SinglePersonAssignment initialComments;
  final TreasuresFromGodsWord treasuresFromGodsWord;
  final ApplyYourselfToMinistry applyYourselfToMinistry;
  final OverseerVisitChristianLife overseerVisitChristianLife;
  final SinglePersonAssignment finalComments;

  @override
  bool get hasMeeting => true;

  @override
  String toString() {
    return 'VisitMeetingWeek(weekRange: $weekRange, bibleReading: $bibleReading, songs: $songs, prayers: $prayers, chairman: $chairman, initialComments: $initialComments, treasuresFromGodsWord: $treasuresFromGodsWord, applyYourselfToMinistry: $applyYourselfToMinistry, overseerVisitChristianLife: $overseerVisitChristianLife, finalComments: $finalComments)';
  }

  static Result<VisitMeetingWeek, FormatException> fromMap(
    Map<String, Object?> dartMap,
  ) {
    if (dartMap case {
      'kind': 'visit',
      'week': final String weekRange,
      'bible_reading': final String bibleReading,
      'songs': final List<Object?> songsList,
      'prayers': final List<Object?> prayersList,
      'chairman': final String chairmanName,
      'initial_comments': final Map<String, Object?> initialCommentsMap,
      'treasures': final Map<String, Object?> treasuresMap,
      'ministry': final List<Object?> ministryMap,
      'christian_life': final Map<String, Object?> christianLifeMap,
      'final_comments': final Map<String, Object?> finalCommentsMap,
    }) {
      final chairman = Name(chairmanName);

      final initialCommentsResult = SinglePersonAssignment.fromMap(
        initialCommentsMap,
      );
      if (initialCommentsResult.isErr) {
        return .err(
          FormatException(
            'Error parsing initial comments assignment: ${initialCommentsResult.err}',
          ),
        );
      }

      final treasuresResult = TreasuresFromGodsWord.fromMap(treasuresMap);
      if (treasuresResult.isErr) {
        return .err(
          FormatException(
            "Error parsing treasures from God's Word: ${treasuresResult.err}",
          ),
        );
      }

      final ministryResult = ApplyYourselfToMinistry.fromMap(
        ministryMap.whereType<Map<String, Object?>>().toList(),
      );
      if (ministryResult.isErr) {
        return .err(
          FormatException(
            'Error parsing apply yourself to ministry: ${ministryResult.err}',
          ),
        );
      }

      final christianLifeResult = OverseerVisitChristianLife.fromMap(
        christianLifeMap,
      );
      if (christianLifeResult.isErr) {
        return .err(
          FormatException(
            'Error parsing Overseer visit Christian life segment: ${christianLifeResult.err}',
          ),
        );
      }

      final finalCommentsResult = SinglePersonAssignment.fromMap(
        finalCommentsMap,
      );
      if (finalCommentsResult.isErr) {
        return .err(
          FormatException(
            'Error parsing final comments assignment: ${finalCommentsResult.err}',
          ),
        );
      }

      return .ok(
        VisitMeetingWeek(
          weekRange: weekRange,
          bibleReading: bibleReading,
          songs: UnmodifiableListView(songsList.whereType<String>().toList()),
          prayers: UnmodifiableListView(
            prayersList.whereType<String>().toList().map(Name.new),
          ),
          chairman: chairman,
          initialComments: initialCommentsResult.ok!,
          treasuresFromGodsWord: treasuresResult.ok!,
          applyYourselfToMinistry: ministryResult.ok!,
          overseerVisitChristianLife: christianLifeResult.ok!,
          finalComments: finalCommentsResult.ok!,
        ),
      );
    }

    return .err(
      const .new(
        'Map does not contain required keys for VisitMeetingWeek or has invalid types.',
      ),
    );
  }
}
