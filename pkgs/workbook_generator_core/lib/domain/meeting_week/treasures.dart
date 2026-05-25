import 'package:dev_utils/result.dart';
import 'package:workbook_generator_core/domain/meeting_week/segments/assignment.dart';

final class TreasuresFromGodsWord {
  const TreasuresFromGodsWord({
    required this.speech,
    required this.spiritualGems,
    required this.bibleReading,
  });

  final SinglePersonAssignment speech;
  final SinglePersonAssignment spiritualGems;
  final SinglePersonAssignment bibleReading;

  @override
  String toString() {
    return 'TreasuresFromGodsWord(speech: $speech, spiritualGems: $spiritualGems, bibleReading: $bibleReading)';
  }

  static Result<TreasuresFromGodsWord, FormatException> fromMap(
    Map<String, Object?> dartMap,
  ) {
    if (dartMap case {
      'speech': final Map<String, Object?> speechMap,
      'spiritual_gems': final Map<String, Object?> spiritualGemsMap,
      'bible_reading': final Map<String, Object?> bibleReadingMap,
    }) {
      final speechResult = SinglePersonAssignment.fromMap(speechMap);
      final spiritualGemsResult = SinglePersonAssignment.fromMap(
        spiritualGemsMap,
      );
      final bibleReadingResult = SinglePersonAssignment.fromMap(
        bibleReadingMap,
      );

      if (speechResult.isErr) {
        return .err(
          FormatException(
            'Error parsing speech assignment: ${speechResult.err}',
          ),
        );
      }
      if (spiritualGemsResult.isErr) {
        return .err(
          FormatException(
            'Error parsing spiritual gems assignment: ${spiritualGemsResult.err}',
          ),
        );
      }
      if (bibleReadingResult.isErr) {
        return .err(
          FormatException(
            'Error parsing Bible reading assignment: ${bibleReadingResult.err}',
          ),
        );
      }

      return .ok(
        TreasuresFromGodsWord(
          speech: speechResult.ok!,
          spiritualGems: spiritualGemsResult.ok!,
          bibleReading: bibleReadingResult.ok!,
        ),
      );
    }

    return .err(
      const .new(
        'Map does not contain required keys for TreasuresFromGodsWord.',
      ),
    );
  }
}
