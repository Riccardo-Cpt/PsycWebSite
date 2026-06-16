import 'package:flutter_test/flutter_test.dart';
import 'package:psic_app/services/review_auth_service.dart';

void main() {
  late ReviewAuthService service;

  setUp(() {
    service = ReviewAuthService();
  });

  group('login', () {
    test('sets isLoggedIn and currentUsername on success', () async {
      service.overrideLoginForTest = (u, p) async {};
      await service.login('mario', 'pass123');
      expect(service.isLoggedIn.value, isTrue);
      expect(service.currentUsername, 'mario');
    });

    test('throws and does not set state on wrong password', () async {
      service.overrideLoginForTest = (u, p) async {
        throw Exception('Credenziali errate');
      };
      expect(
        () => service.login('mario', 'wrong'),
        throwsException,
      );
      expect(service.isLoggedIn.value, isFalse);
      expect(service.currentUsername, isNull);
    });
  });

  group('register', () {
    test('sets isLoggedIn and currentUsername on success', () async {
      service.overrideRegisterForTest = (u, p) async {};
      await service.register('newuser', 'pass123');
      expect(service.isLoggedIn.value, isTrue);
      expect(service.currentUsername, 'newuser');
    });

    test('throws on duplicate username without setting state', () async {
      service.overrideRegisterForTest = (u, p) async {
        throw Exception('Username già in uso');
      };
      expect(
        () => service.register('existing', 'pass123'),
        throwsException,
      );
      expect(service.isLoggedIn.value, isFalse);
    });
  });

  group('logout', () {
    test('clears isLoggedIn and currentUsername', () async {
      service.overrideLoginForTest = (u, p) async {};
      await service.login('mario', 'pass');
      service.logout();
      expect(service.isLoggedIn.value, isFalse);
      expect(service.currentUsername, isNull);
    });
  });
}
