import 'package:flutter_test/flutter_test.dart';
import 'package:psic_app/models/articolo.dart';

void main() {
  group('Articolo.fromJson', () {
    test('parses all fields', () {
      final json = {
        'id': 1,
        'titolo': 'Test',
        'corpo': 'Corpo',
        'pubblicato_at': '2024-03-15T10:30:00+00:00',
        'immagine_url': 'https://example.com/img.webp',
      };
      final a = Articolo.fromJson(json);
      expect(a.id, 1);
      expect(a.titolo, 'Test');
      expect(a.corpo, 'Corpo');
      expect(a.pubblicatoAt, DateTime.parse('2024-03-15T10:30:00+00:00'));
      expect(a.immagineUrl, 'https://example.com/img.webp');
    });

    test('handles null immagine_url', () {
      final json = {
        'id': 2,
        'titolo': 'No image',
        'corpo': 'Corpo',
        'pubblicato_at': '2024-03-15T10:30:00+00:00',
        'immagine_url': null,
      };
      final a = Articolo.fromJson(json);
      expect(a.immagineUrl, isNull);
    });

    test('handles null pubblicato_at', () {
      final json = {
        'id': 3,
        'titolo': 'No date',
        'corpo': 'Corpo',
        'pubblicato_at': null,
        'immagine_url': null,
      };
      final a = Articolo.fromJson(json);
      expect(a.pubblicatoAt, isNull);
    });
  });
}
