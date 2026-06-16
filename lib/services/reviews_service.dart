import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/admin_config.dart';
import '../config/contatti.dart';
import '../models/review.dart';

class ReviewsService {
  static const _readHeaders = {
    'apikey': AdminConfig.supabaseAnonKey,
    'Authorization': 'Bearer ${AdminConfig.supabaseAnonKey}',
  };

  static const _adminReadHeaders = {
    'apikey': AdminConfig.supabaseServiceRoleKey,
    'Authorization': 'Bearer ${AdminConfig.supabaseServiceRoleKey}',
  };

  static const _writeHeaders = {
    'apikey': AdminConfig.supabaseServiceRoleKey,
    'Authorization': 'Bearer ${AdminConfig.supabaseServiceRoleKey}',
    'Content-Type': 'application/json',
    'Prefer': 'return=minimal',
  };

  // ignore: avoid_public_members_for_test
  Future<List<Review>>? overrideForTest;
  // ignore: avoid_public_members_for_test
  Future<Review?> Function(String)? overrideMiaForTest;

  /// Public: only approved reviews.
  Future<List<Review>> tutti() async {
    if (overrideForTest != null) return overrideForTest!;
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviews?select=*&approved=eq.1&order=created_at.desc');
    final response = await http.get(uri, headers: _readHeaders);
    if (response.statusCode != 200) {
      throw Exception('Errore nel recupero delle recensioni: ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Admin: all reviews regardless of approval status, with user details joined.
  Future<List<Review>> tuttiAdmin() async {
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviews'
        '?select=*,reviewer_users(nome,cognome,email)'
        '&order=created_at.desc');
    final response = await http.get(uri, headers: _adminReadHeaders);
    if (response.statusCode != 200) {
      throw Exception('Errore nel recupero delle recensioni: ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Review?> mia(String username) async {
    if (overrideMiaForTest != null) return overrideMiaForTest!(username);
    final encodedUsername = Uri.encodeQueryComponent(username);
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviews'
        '?username=eq.$encodedUsername&select=*');
    final response = await http.get(uri, headers: _readHeaders);
    if (response.statusCode != 200) {
      throw Exception('Errore nel recupero della recensione: ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    if (list.isEmpty) return null;
    return Review.fromJson(list.first as Map<String, dynamic>);
  }

  Future<void> inserisci({
    required String name,
    required String title,
    required String description,
    required int stars,
    String? name,
    String? surname,
    String? email,
  }) async {
    final uri = Uri.parse('${AdminConfig.supabaseRestUrl}/reviews');
    final body = jsonEncode({
      'username': name,
      'title': title,
      'Description': description,
      'stars': stars,
      'approved': 0,
    });
    final response = await http.post(uri, headers: _writeHeaders, body: body);
    if (response.statusCode != 201) {
      throw Exception('Errore nel salvataggio della recensione: ${response.body}');
    }
    _notificaAdmin(name, title, name: name, surname: surname, email: email);
  }

  Future<void> aggiorna({
    required int id,
    required String title,
    required String description,
    required int stars,
  }) async {
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviews?id=eq.$id');
    final body = jsonEncode({
      'title': title,
      'Description': description,
      'stars': stars,
      'approved': 0,
    });
    final response = await http.patch(uri, headers: _writeHeaders, body: body);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Errore nella modifica della recensione: ${response.body}');
    }
    _notificaAdmin('(modifica)', title);
  }

  Future<void> approva(int id) async {
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviews?id=eq.$id');
    final body = jsonEncode({'approved': 1});
    final response = await http.patch(uri, headers: _writeHeaders, body: body);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Errore nell\'approvazione della recensione: ${response.body}');
    }
  }

  Future<void> cancella(int id) async {
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviews?id=eq.$id');
    final response = await http.delete(uri, headers: _writeHeaders);
    if (response.statusCode != 204) {
      throw Exception('Errore nell\'eliminazione della recensione: ${response.body}');
    }
  }

  void _notificaAdmin(String username, String title,
      {String? name, String? surname, String? email}) {
    final nomeCompleto = (name != null && surname != null)
        ? '$name $surname'
        : username;
    final emailInfo = email != null ? '\nEmail: $email' : '';
    final subject = Uri.encodeComponent('Nuova recensione in attesa di approvazione');
    final bodyText = Uri.encodeComponent(
      'L\'utente "$username" ($nomeCompleto$emailInfo) ha lasciato una nuova recensione intitolata "$title".\n\n'
      'Accedi al pannello admin per approvarla o rifiutarla.',
    );
    launchUrl(
      Uri.parse('mailto:${Contatti.email}?subject=$subject&body=$bodyText'),
    );
  }
}
