import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/admin_config.dart';

class ReviewAuthService {
  static const _readHeaders = {
    'apikey': AdminConfig.supabaseServiceRoleKey,
    'Authorization': 'Bearer ${AdminConfig.supabaseServiceRoleKey}',
  };

  static const _writeHeaders = {
    'apikey': AdminConfig.supabaseServiceRoleKey,
    'Authorization': 'Bearer ${AdminConfig.supabaseServiceRoleKey}',
    'Content-Type': 'application/json',
    'Prefer': 'return=minimal',
  };

  final ValueNotifier<bool> isLoggedIn = ValueNotifier(false);
  String? currentUsername;
  String? currentName;
  String? currentSurname;
  String? currentEmail;

  // ignore: avoid_public_members_for_test
  Future<void> Function(String, String)? overrideLoginForTest;
  // ignore: avoid_public_members_for_test
  Future<void> Function(String, String)? overrideRegisterForTest;

  static String _hash(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  Future<void> register(String username, String password,
      {required String name,
      required String surname,
      required String email}) async {
    if (overrideRegisterForTest != null) {
      await overrideRegisterForTest!(username, password);
      currentUsername = username;
      currentName = name;
      currentSurname = surname;
      currentEmail = email;
      isLoggedIn.value = true;
      return;
    }
    final uri = Uri.parse('${AdminConfig.supabaseRestUrl}/reviewer_users');
    final body = jsonEncode({
      'username': username,
      'password_hash': _hash(password),
      'name': name,
      'surname': surname,
      'email': email,
    });
    final response = await http.post(uri, headers: _writeHeaders, body: body);
    if (response.statusCode == 409) {
      throw Exception('Username già in uso');
    }
    if (response.statusCode != 201) {
      throw Exception('Errore nella registrazione: ${response.body}');
    }
    currentUsername = username;
    currentName = name;
    currentSurname = surname;
    currentEmail = email;
    isLoggedIn.value = true;
  }

  Future<void> login(String username, String password) async {
    if (overrideLoginForTest != null) {
      await overrideLoginForTest!(username, password);
      currentUsername = username;
      isLoggedIn.value = true;
      return;
    }
    final hash = _hash(password);
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviewer_users'
        '?username=eq.$username&password_hash=eq.$hash&select=id,name,surname,email');
    final response = await http.get(uri, headers: _readHeaders);
    if (response.statusCode != 200) {
      throw Exception('Errore nel login: ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    if (list.isEmpty) throw Exception('Credenziali errate');
    final user = list.first as Map<String, dynamic>;
    currentUsername = username;
    currentName = user['name'] as String?;
    currentSurname = user['surname'] as String?;
    currentEmail = user['email'] as String?;
    isLoggedIn.value = true;
  }

  void logout() {
    currentUsername = null;
    currentName = null;
    currentSurname = null;
    currentEmail = null;
    isLoggedIn.value = false;
  }
}
