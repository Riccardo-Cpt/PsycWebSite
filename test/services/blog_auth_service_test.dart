import 'package:flutter_test/flutter_test.dart';
import 'package:psic_app/services/blog_auth_service.dart';

void main() {
  group('BlogAuthService', () {
    late BlogAuthService auth;

    setUp(() => auth = BlogAuthService());

    test('isAdmin starts false', () {
      expect(auth.isAdmin.value, isFalse);
    });

    test('login with correct password sets isAdmin true', () {
      auth.login('admin123');
      expect(auth.isAdmin.value, isTrue);
    });

    test('login with wrong password keeps isAdmin false', () {
      auth.login('sbagliata');
      expect(auth.isAdmin.value, isFalse);
    });

    test('logout resets isAdmin to false', () {
      auth.login('admin123');
      auth.logout();
      expect(auth.isAdmin.value, isFalse);
    });
  });
}
