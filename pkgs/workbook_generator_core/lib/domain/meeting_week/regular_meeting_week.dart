part of 'meeting_week.dart';

final class RegularMeetingWeek extends ProgrammedMeetingWeek {
  const RegularMeetingWeek({
    required super.link,
    required super.weekRange,
    required super.bibleReading,
    required super.songs,
    required super.prayers,
    required super.chairman,
    required super.initialComments,
    required super.treasuresFromGodsWord,
    required super.applyYourselfToMinistry,
    required super.finalComments,
    required this.christianLife,
  });

  final ChristianLife christianLife;

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
          initialComments: initialCommentsResult.unwrap(),
          treasuresFromGodsWord: treasuresResult.unwrap(),
          applyYourselfToMinistry: ministryResult.unwrap(),
          christianLife: christianLifeResult.unwrap(),
          finalComments: finalCommentsResult.unwrap(),
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
