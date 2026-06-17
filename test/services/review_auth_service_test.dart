import 'package:flutter_test/flutter_test.dart';
import 'package:psic_app/services/review_auth_service.dart';

void main() {
  late ReviewAuthService service;

  setUp(() => service = ReviewAuthService());

  group('sendMagicLink', () {
    test('does not set isVerified', () async {
      service.overrideSendMagicLinkForTest = (_, __, ___, ____) async {};
      await service.sendMagicLink(
        email: 'a@b.com',
        username: 'user1',
        name: 'Mario',
        surname: 'Rossi',
      );
      expect(service.isVerified.value, isFalse);
    });

    test('throws on error', () async {
      service.overrideSendMagicLinkForTest = (_, __, ___, ____) async {
        throw Exception('network error');
      };
      expect(
        () => service.sendMagicLink(
          email: 'a@b.com',
          username: 'user1',
          name: 'Mario',
          surname: 'Rossi',
        ),
        throwsException,
      );
    });
  });

  group('verifyToken', () {
    test('sets isVerified and stores identity on success', () async {
      service.overrideVerifyTokenForTest = (_) async => {
        'email': 'a@b.com',
        'username': 'user1',
        'name': 'Mario',
      };
      await service.verifyToken('valid-token');
      expect(service.isVerified.value, isTrue);
      expect(service.currentEmail, 'a@b.com');
      expect(service.currentUsername, 'user1');
      expect(service.currentName, 'Mario');
    });

    test('throws and does not set isVerified on error', () async {
      service.overrideVerifyTokenForTest = (_) async =>
          throw Exception('Link non valido o scaduto');
      expect(() => service.verifyToken('bad-token'), throwsException);
      expect(service.isVerified.value, isFalse);
      expect(service.currentEmail, isNull);
    });

    test('reset clears all state', () async {
      service.overrideVerifyTokenForTest = (_) async => {
        'email': 'a@b.com',
        'username': 'user1',
        'name': 'Mario',
      };
      await service.verifyToken('valid-token');
      service.reset();
      expect(service.isVerified.value, isFalse);
      expect(service.currentEmail, isNull);
      expect(service.currentUsername, isNull);
      expect(service.currentName, isNull);
    });
  });
}
