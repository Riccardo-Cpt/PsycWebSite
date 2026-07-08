import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/admin_config.dart';

class ReviewAuthService {
  final ValueNotifier<bool> isVerified = ValueNotifier(false);
  String? currentEmail;
  String? currentUsername;
  String? currentName;

  // ignore: avoid_public_members_for_test
  Future<void> Function(String, String, String, String)?
      overrideSendMagicLinkForTest;
  // ignore: avoid_public_members_for_test
  Future<Map<String, dynamic>> Function(String)? overrideVerifyTokenForTest;

  Future<void> sendMagicLink({
    required String email,
    required String username,
    required String name,
    required String surname,
  }) async {
    if (overrideSendMagicLinkForTest != null) {
      return overrideSendMagicLinkForTest!(email, username, name, surname);
    }
    final uri = Uri.parse(
        '${AdminConfig.functionsUrl}/send-review-magic-link');
    final response = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json',
        'apikey': AdminConfig.supabaseAnonKey,
      },
      body: jsonEncode({
        'email': email,
        'username': username,
        'name': name,
        'surname': surname,
      }),
    );
    if (response.statusCode == 409) {
      throw Exception('Hai già inviato una recensione. Puoi contattarci per modificarla.');
    }
    if (response.statusCode != 200) {
      throw Exception('Errore: riprova più tardi.');
    }
  }

  Future<void> verifyToken(String token) async {
    final Map<String, dynamic> data;
    if (overrideVerifyTokenForTest != null) {
      data = await overrideVerifyTokenForTest!(token);
    } else {
      final uri = Uri.parse(
          '${AdminConfig.functionsUrl}/verify-review-token');
      final response = await http.post(
        uri,
        headers: const {
          'Content-Type': 'application/json',
          'apikey': AdminConfig.supabaseAnonKey,
        },
        body: jsonEncode({'token': token}),
      );
      if (response.statusCode != 200) {
        throw Exception('Link non valido o scaduto. Richiedi un nuovo link.');
      }
      late final Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        throw Exception('Link non valido o scaduto. Richiedi un nuovo link.');
      }
      if (decoded['error'] != null) {
        throw Exception('Link non valido o scaduto. Richiedi un nuovo link.');
      }
      if (decoded['email'] == null || decoded['username'] == null) {
        throw Exception('Link non valido o scaduto. Richiedi un nuovo link.');
      }
      data = decoded;
    }
    currentEmail = data['email'] as String;
    currentUsername = data['username'] as String;
    currentName = data['name'] as String?;
    isVerified.value = true;
  }

  void reset() {
    currentEmail = null;
    currentUsername = null;
    currentName = null;
    isVerified.value = false;
  }
}
