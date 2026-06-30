import 'dart:collection';
import 'dart:io';

import 'package:dev_utils/result.dart';
import 'package:dev_utils/scope.dart';
import 'package:workbook_generator_core/domain/meeting_week/christian_life.dart';
import 'package:workbook_generator_core/domain/meeting_week/meeting_kind.dart';
import 'package:workbook_generator_core/domain/meeting_week/ministry.dart';
import 'package:workbook_generator_core/domain/meeting_week/segments/assignment.dart';
import 'package:workbook_generator_core/domain/meeting_week/treasures.dart';
import 'package:workbook_generator_core/domain/shared/name.dart';
import 'package:workbook_generator_core/protocols/shareable_text.dart';
import 'package:workbook_generator_core/services/yaml_parser_service.dart';
import 'package:workbook_generator_core/utils/rich_text_utils.dart';

part 'overseer_visit_meeting_week.dart';
part 'programmed_meeting_week.dart';
part 'regular_meeting_week.dart';
part 'special_event_week.dart';

void main(List<String> args) async {
  const yamlParser = YamlParserService();

  final result = await yamlParser.fromString(
    File('../../data/schema.yaml').readAsStringSync(),
  );
  if (result.isErr) {
    print('Error parsing YAML: ${result.err}');
  } else {
    final meetingWeek = result.ok!;
    // print('Successfully parsed meeting week: $meetingWeek');

    final parseResult = [
      for (final map in meetingWeek) MeetingWeek.fromMap(map),
    ];

    final file = File('output.txt')..createSync();
    final resultBuffer = StringBuffer();

    for (final meetingWeekResult in parseResult) {
      if (meetingWeekResult.isErr) {
        print('Error parsing meeting week from map: ${meetingWeekResult.err}');
      } else {
        resultBuffer.write(
          '-----\n${meetingWeekResult.unwrap().toShareableText(richTextKind: .whatsApp)}',
        );
      }
    }

    file.writeAsStringSync(resultBuffer.toString());
  }
}

sealed class MeetingWeek implements ShareableText {
  const MeetingWeek({
    required this.link,
    required this.weekRange,
    required this.bibleReading,
  });

  final String weekRange;
  final String bibleReading;
  final Uri link;

  bool get hasMeeting;

  MeetingKind get kind => switch (this) {
    SpecialEventWeek() => .specialEvent,
    final ProgrammedMeetingWeek programmedMeetingWeek =>
      switch (programmedMeetingWeek) {
        RegularMeetingWeek() => .normal,
        OverseerVisitMeetingWeek() => .visit,
      },
  };

  static Result<MeetingWeek, FormatException> fromMap(
    Map<String, Object?> dartMap,
  ) {
    if (dartMap case {'kind': 'normal'}) {
      return RegularMeetingWeek.fromMap(dartMap);
    } else if (dartMap case {'kind': 'visit'}) {
      return OverseerVisitMeetingWeek.fromMap(dartMap);
    } else if (dartMap case {'kind': 'specialEvent'}) {
      return SpecialEventWeek.fromMap(dartMap);
    } else {
      return .err(
        const .new('Map does not contain a valid "kind" key for MeetingWeek.'),
      );
    }
  }
}
