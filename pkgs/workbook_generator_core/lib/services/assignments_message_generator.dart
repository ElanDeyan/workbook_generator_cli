import 'package:workbook_generator_core/domain/meeting_week/assignments/assignment.dart';
import 'package:workbook_generator_core/protocols/shareable_text.dart';
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

final class const AssignmentMessage({required final Assignment _assignment})
    implements ShareableText {
  @override
  String toShareableText({RichTextKind richTextKind = .none}) {
    final buffer = StringBuffer();

    buffer.writeln('Olá, querida(o)');

    return buffer.toString();
  }
}

String generateAssignmentsMessage({
  required List<Assignment> assignments,
  RichTextKind richTextKind = .none,
}) {
  final buffer = StringBuffer();

  for (final assignment in assignments) {
    buffer
      ..writeln(
        AssignmentMessage(assignment: assignment)
            .toShareableText(richTextKind: richTextKind),
      )
      ..writeln('=' * 20);
  }

  return buffer.toString();
}
