import 'package:workbook_generator_core/domain/meeting_week/assignments/assignment.dart';
import 'package:workbook_generator_core/utils/rich_text_utils.dart';

// A sample of a message:
// Olá, querida(o) irmã(o),

// Espero que esteja perseverando com a ajuda de Jeová!

// 🏅 _Você recebeu uma nova designação._

// 🗣️ _Sugestão_ : Converse com seu/sua colaborador(a) pessoalmente, por telefone, durante a pregação ou ao dirigir estudos bíblicos.

// 🗓️ _Semana_ : 30 de novembro - 6 de dezembro

// 👤 _Designado_ : <name>

// 📌 _Designação_ : 6. Discurso (4 min) lmd apêndice A ponto 22 — Tema: O Reino de Deus vai substituir os governos humanos. (th lição 6)

// 💡 _Para cumprir bem sua designação:_
// 1. Ore.
// 2. Consulte a apostila para ver sua designação.
// 3. Estude a lição indicada na brochura _Ame as pessoas_ (código _lmd_ ) ou na brochura _Melhore sua leitura e seu ensino_ (código _th_ ), conforme aplicável.
// 4. Verifique o documento S-38 (parágrafo 12) para orientações sobre o conteúdo e como executar sua parte: https://www.jw.org/finder?srcid=jwlshare&wtlocale=T&prefer=lang&docid=1201038&par=45

// Em caso de dúvida, entre em contato.

// ✅ _Por favor, confirme o recebimento._

// Estude a lição, treine e _deixe Jeová completar o seu treinamento_ — 1 Pedro 5:10.

// Um forte abraço a todos!

final class const AssignmentMessage({
  required final Assignment _assignment,
  required final String _period,
  final RichTextKind _richTextKind = .whatsApp,
}) {
  @override
  String toString() {
    final buffer = StringBuffer()
      ..writeln(_greeting)
      ..writeln()
      ..writeln(_messageTitle)
      ..writeln()
      ..writeln(_periodText);

    return buffer.toString();
  }

  bool get isSinglePersonAssignment => switch (_assignment) {
    MinistryAssignment() => false,
    BibleReadingAssignment() || SinglePersonAssignment() => true,
  };

  String get _greeting {
    switch (_assignment) {
      case MinistryAssignment(:final names):
        final joinedNames = names
            .join(', ')
            .applyBoldBy(_richTextKind)
            .applyItalicBy(_richTextKind);

        return 'Olá, queridos(as) $joinedNames!';
      case BibleReadingAssignment(reader: final name) ||
          SinglePersonAssignment(:final name):
        final formattedName = name
            .toString()
            .applyBoldBy(_richTextKind)
            .applyItalicBy(_richTextKind);

        return 'Olá, querido irmão $formattedName!';
    }
  }

  String get _messageTitle {
    final buffer = StringBuffer()
      ..writeAll([
        if (isSinglePersonAssignment) 'Você tem' else 'Vocês têm',
        'uma designação na reunião Vida e Ministério:',
      ], ' ');

    return buffer.toString();
  }

  static const _calendarEmoji = '\u{1F5D3}';

  String get _periodText {
    return '$_calendarEmoji ${_period.applyBoldBy(_richTextKind)}';
  }

  String get _assignmentText {
    final buffer = StringBuffer('$_pushPinEmoji ');
    switch (_assignment) {
      case final MinistryAssignment ministryAssignment:
        buffer
          ..write(ministryAssignment.title.applyBoldBy(_richTextKind))
          ..write(' ')
          ..write('(${ministryAssignment.duration.inMinutes} min)')
          ..write(' ');

        if (ministryAssignment.description case final description?) {
          buffer.write(description);
        }

        buffer
          ..writeln()
          ..writeAll([
            _openBookEmoji,
            '${'Estudem'.applyBoldBy(_richTextKind)}:',
            ?ministryAssignment.studyPoint ??
                ministryAssignment.schoolPublicationReference?.publicationCode,
          ], ' ');

        if (isSinglePersonAssignment) {
          buffer
            ..writeln()
            ..writeAll([
              _bustInSilhouetteEmoji,
              '${'Designado'.applyBoldBy(_richTextKind)}:',
              ?ministryAssignment.names.firstOrNull,
            ]);
        } else {
          buffer
            ..writeln()
            ..writeAll([
              _twoPersonsInSilhouetteEmoji,
              '${'Designados'.applyBoldBy(_richTextKind)}:',
              ministryAssignment.names.join(' e '),
            ]);
        }
      case BibleReadingAssignment():
        // TODO: Handle this case.
        throw UnimplementedError();
      case SinglePersonAssignment():
        throw StateError(
          'Unavailable support for this assignment: $_assignment',
        );
    }

    return buffer.toString();
  }

  static const _openBookEmoji = '\u{1F4D6}';
  static const _pushPinEmoji = '\u{1F4CC}';
  static const _bustInSilhouetteEmoji = '\u{1F464}';
  static const _twoPersonsInSilhouetteEmoji = '\u{1F465}';
}

String generateAssignmentsMessage({
  required List<Assignment> assignments,
  required String periodText,
  RichTextKind richTextKind = .none,
}) {
  final buffer = StringBuffer();

  for (final assignment in assignments) {
    buffer
      ..writeln(
        AssignmentMessage(
          assignment: assignment,
          period: periodText,
          richTextKind: richTextKind,
        ).toString(),
      )
      ..writeln('=' * 20);
  }

  return buffer.toString();
}
