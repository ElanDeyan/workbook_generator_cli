import 'package:test/test.dart';
import 'package:workbook_generator_core/domain/meeting_week/assignments/assignment.dart';
import 'package:workbook_generator_core/domain/meeting_week/ministry.dart';

void main() {
  group('MinistryAssignment.fromMap', () {
    test('parses the nested study point and publication code', () {
      final result = MinistryAssignment.fromMap({
        'title': 'Starting a conversation',
        'duration': '3:00',
        'who': ['Alex'],
        'kind': 'starting_a_conversation',
        'description': 'Offer a Bible study.',
        'is_talk': false,
        'study_point': {'point': 'lesson 3 point 3', 'publication_code': 'lmd'},
      });

      expect(result.isErr, isFalse);
      expect(result.ok!.studyPoint, 'lesson 3 point 3');
      expect(
        result.ok!.schoolPublicationReference,
        SchoolPublicationReference.lovePeople,
      );
    });

    test('accepts a null study point when no publication applies', () {
      final result = MinistryAssignment.fromMap({
        'title': 'What would you say?',
        'duration': '5:00',
        'who': ['Alex'],
        'kind': 'what_would_you_say',
        'description': null,
        'is_talk': false,
        'study_point': null,
      });

      expect(result.isErr, isFalse);
      expect(result.ok!.studyPoint, isNull);
      expect(result.ok!.schoolPublicationReference, isNull);
    });

    test('rejects an unsupported publication code', () {
      final result = MinistryAssignment.fromMap({
        'title': 'Starting a conversation',
        'duration': '3:00',
        'who': ['Alex'],
        'kind': 'starting_a_conversation',
        'description': null,
        'is_talk': false,
        'study_point': {'point': 'lesson 3 point 3', 'publication_code': 'bad'},
      });

      expect(result.isErr, isTrue);
    });
  });

  test('BibleReadingAssignment parses the nested study point', () {
    final result = BibleReadingAssignment.fromMap({
      'title': 'Bible reading',
      'duration': '4:00',
      'reader': 'Alex',
      'study_point': {'point': 'lesson 1', 'publication_code': 'th'},
    });

    expect(result.isErr, isFalse);
    expect(result.ok!.studyPoint, 'lesson 1');
    expect(
      result.ok!.schoolPublicationReference,
      SchoolPublicationReference.teaching,
    );
  });

  test('BibleReadingAssignment accepts a null study point', () {
    final result = BibleReadingAssignment.fromMap({
      'title': 'Bible reading',
      'duration': '4:00',
      'reader': 'Alex',
      'study_point': null,
    });

    expect(result.isErr, isFalse);
    expect(result.ok!.studyPoint, isNull);
    expect(result.ok!.schoolPublicationReference, isNull);
  });
}
