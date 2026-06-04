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
  const MeetingWeek();

  bool get hasMeeting;
  MeetingKind get kind => switch (this) {
    RegularMeetingWeek() => .normal,
    OverseerVisitMeetingWeek() => .visit,
    SpecialEventWeek() => .specialEvent,
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

final class OverseerVisitMeetingWeek extends MeetingWeek {
  OverseerVisitMeetingWeek({
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
    required this.link,
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
  final Uri link;
  @override
  bool get hasMeeting => true;

  @override
  String toShareableText({RichTextKind richTextKind = .none}) {
    // TODO: implement toShareableText
    throw UnimplementedError();
  }

  @override
  String toString() {
    return 'VisitMeetingWeek(weekRange: $weekRange, bibleReading: $bibleReading, songs: $songs, prayers: $prayers, chairman: $chairman, initialComments: $initialComments, treasuresFromGodsWord: $treasuresFromGodsWord, applyYourselfToMinistry: $applyYourselfToMinistry, overseerVisitChristianLife: $overseerVisitChristianLife, finalComments: $finalComments, link: $link)';
  }

  static Result<OverseerVisitMeetingWeek, FormatException> fromMap(
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
      'link': final String link,
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

      final uriResult = Uri.tryParse(link);
      if (uriResult == null) {
        return .err(
          FormatException(
            'Error parsing link: Invalid URI format for link: $link',
          ),
        );
      }

      return .ok(
        OverseerVisitMeetingWeek(
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
          link: uriResult,
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

final class RegularMeetingWeek extends MeetingWeek {
  const RegularMeetingWeek({
    required this.link,
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
  final Uri link;

  @override
  bool get hasMeeting => true;

  @override
  String toShareableText({RichTextKind richTextKind = .none}) {
    final buffer = StringBuffer()
      ..writeln('Semana de $weekRange'.applyBoldBy(richTextKind))
      ..writeln()
      ..writeln(bibleReading.applyBoldBy(richTextKind))
      ..writeln()
      ..writeln(songs.first.applyBoldBy(richTextKind))
      ..writeln();
    final chairmanTitle =
        'Presidente e ${initialComments.title} '
                '(${initialComments.duration.inMinutes} min)'
            .applyBoldBy(richTextKind);
    final chairmanNames = '${initialComments.name}'.applyItalicBy(richTextKind);

    buffer
      ..writeln('$chairmanTitle - $chairmanNames')
      ..writeln()
      ..writeln('TESOUROS DA PALAVRA DE DEUS'.applyBoldBy(richTextKind))
      ..writeln();

    final treasuresSpeechTitle =
        '${treasuresFromGodsWord.speech.title} '
                '(${treasuresFromGodsWord.speech.duration.inMinutes} min)'
            .applyBoldBy(richTextKind);
    final treasuresSpeechName = '${treasuresFromGodsWord.speech.name}'
        .applyItalicBy(richTextKind);

    buffer
      ..writeln('$treasuresSpeechTitle - $treasuresSpeechName')
      ..writeln();

    final spiritualGemsTitle =
        '${treasuresFromGodsWord.spiritualGems.title} '
                '(${treasuresFromGodsWord.spiritualGems.duration.inMinutes} min)'
            .applyBoldBy(richTextKind);
    final spiritualGemsName = '${treasuresFromGodsWord.spiritualGems.name}'
        .applyItalicBy(richTextKind);

    buffer
      ..writeln('$spiritualGemsTitle - $spiritualGemsName')
      ..writeln();

    final bibleReadingTitle =
        '${treasuresFromGodsWord.bibleReading.title} '
                '(${treasuresFromGodsWord.bibleReading.duration.inMinutes} min)'
            .applyBoldBy(richTextKind);

    final bibleReadingName = '${treasuresFromGodsWord.bibleReading.name}'
        .applyItalicBy(richTextKind);

    buffer
      ..writeln('$bibleReadingTitle - $bibleReadingName')
      ..writeln()
      ..writeln('FAÇA SEU MELHOR NO MINISTÉRIO'.applyBoldBy(richTextKind))
      ..writeln()
      ..writeAll([
        for (final assignment in applyYourselfToMinistry.assignments)
          run(() {
            final title =
                '${assignment.title} '
                        '(${assignment.duration.inMinutes} min)'
                    .applyBoldBy(richTextKind);
            final names = assignment.names
                .map((name) => name.toString())
                .join(' e ')
                .applyItalicBy(richTextKind);

            return '$title - $names';
          }),
      ], '\n\n')
      ..writeln()
      ..writeln()
      ..writeln('NOSSA VIDA CRISTÃ'.applyBoldBy(richTextKind))
      ..writeln()
      ..writeln(songs[1].applyBoldBy(richTextKind))
      ..writeln()
      ..writeAll([
        for (final part in christianLife.initialParts)
          run(() {
            final title =
                '${part.title} '
                        '(${part.duration.inMinutes} min)'
                    .applyBoldBy(richTextKind);
            final name = part.name.self.applyItalicBy(richTextKind);

            return '$title - $name';
          }),
      ], '\n\n')
      ..writeln()
      ..writeln()
      ..writeln(switch (christianLife) {
        final OverseerVisitChristianLife overseerVisitChristianLife => run(() {
          final title =
              '${overseerVisitChristianLife.overseerSpeech.title} '
                      '(${overseerVisitChristianLife.overseerSpeech.duration.inMinutes} min)'
                  .applyBoldBy(richTextKind);
          final name = overseerVisitChristianLife.overseerSpeech.name.self
              .applyItalicBy(richTextKind);

          return '$title - $name';
        }),

        final RegularChristianLife regularChristianLife => run(() {
          final title =
              '${regularChristianLife.congregationStudy.title} '
                      '(${regularChristianLife.congregationStudy.duration.inMinutes} min)'
                  .applyBoldBy(richTextKind);
          final conductor = regularChristianLife
              .congregationStudy
              .conductor
              .self
              .applyItalicBy(richTextKind);

          final reader = regularChristianLife.congregationStudy.reader.self
              .applyItalicBy(richTextKind);

          return '$title - Dirigente: $conductor | Leitor: $reader';
        }),
      })
      ..writeln();

    final finalCommentsTitle =
        '${finalComments.title} '
                '(${finalComments.duration.inMinutes} min)'
            .applyBoldBy(richTextKind);
    final finalCommentsName = '${finalComments.name}'.applyItalicBy(
      richTextKind,
    );

    buffer
      ..writeln('$finalCommentsTitle - $finalCommentsName')
      ..writeln()
      ..writeln(songs[2].applyBoldBy(richTextKind))
      ..writeln();

    final lastPrayerTitle = 'Oração final'.applyBoldBy(richTextKind);

    final lastPrayerName = '${prayers.last}'.applyItalicBy(richTextKind);

    buffer
      ..writeln('$lastPrayerTitle - $lastPrayerName')
      ..writeln()
      ..writeln('$link');

    return buffer.toString();
  }

  @override
  String toString() {
    return 'RegularMeetingWeek(weekRange: $weekRange, '
        'bibleReading: $bibleReading, songs: $songs, '
        'prayers: $prayers, chairman: $chairman, '
        'initialComments: $initialComments, '
        'treasuresFromGodsWord: $treasuresFromGodsWord, '
        'applyYourselfToMinistry: $applyYourselfToMinistry, '
        'christianLife: $christianLife, finalComments: $finalComments)';
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
      'link': final String link,
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

      final uriResult = Uri.tryParse(link);
      if (uriResult == null) {
        return .err(
          FormatException(
            'Error parsing link: Invalid URI format for link: $link',
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
          link: uriResult,
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
  String toShareableText({RichTextKind richTextKind = .none}) {
    // TODO: implement toShareableText
    throw UnimplementedError();
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
