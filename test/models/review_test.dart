import 'package:flutter_test/flutter_test.dart';
import 'package:psic_app/models/review.dart';

void main() {
  group('Review.fromJson', () {
    test('parses all fields from flat row', () {
      final r = Review.fromJson({
        'id': 1,
        'username': 'mario_r',
        'email': 'mario@example.com',
        'title': 'Ottimo',
        'description': 'ottimo servizio',
        'created_at': '2026-06-16T10:00:00Z',
        'stars': 4,
        'approved': true,
      });
      expect(r.id, 1);
      expect(r.username, 'mario_r');
      expect(r.email, 'mario@example.com');
      expect(r.title, 'Ottimo');
      expect(r.description, 'ottimo servizio');
      expect(r.createdAt, DateTime.parse('2026-06-16T10:00:00Z'));
      expect(r.stars, 4);
      expect(r.approved, isTrue);
    });

    test('nullable createdAt when null', () {
      final r = Review.fromJson({
        'id': 2,
        'username': 'lucia',
        'email': 'lucia@example.com',
        'title': 'Buono',
        'description': 'buono',
        'created_at': null,
        'stars': 3,
        'approved': false,
      });
      expect(r.createdAt, isNull);
      expect(r.approved, isFalse);
    });
  });
}
