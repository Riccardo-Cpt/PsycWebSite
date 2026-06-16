import 'package:flutter_test/flutter_test.dart';
import 'package:psic_app/models/review.dart';

void main() {
  group('Review.fromJson', () {
    test('parses all fields', () {
      final r = Review.fromJson({
        'id': 1,
        'Name': 'mario',
        'Description': 'ottimo servizio',
        'created_at': '2026-06-16T10:00:00Z',
        'stars': 4,
      });
      expect(r.id, 1);
      expect(r.name, 'mario');
      expect(r.description, 'ottimo servizio');
      expect(r.createdAt, DateTime.parse('2026-06-16T10:00:00Z'));
      expect(r.stars, 4);
    });

    test('nullable createdAt when null', () {
      final r = Review.fromJson({
        'id': 2,
        'Name': 'lucia',
        'Description': 'buono',
        'created_at': null,
        'stars': 3,
      });
      expect(r.createdAt, isNull);
    });
  });
}
