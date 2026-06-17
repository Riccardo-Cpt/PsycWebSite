import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/admin_config.dart';
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

  /// Public: only approved reviews.
  Future<List<Review>> tutti() async {
    if (overrideForTest != null) return overrideForTest!;
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviews?select=*&approved=eq.true&order=created_at.desc');
    final response = await http.get(uri, headers: _readHeaders);
    if (response.statusCode != 200) {
      throw Exception('Errore nel recupero delle recensioni: ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Admin: all reviews regardless of approval status.
  Future<List<Review>> tuttiAdmin() async {
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviews'
        '?select=*'
        '&order=created_at.desc');
    final response = await http.get(uri, headers: _adminReadHeaders);
    if (response.statusCode != 200) {
      throw Exception('Errore nel recupero delle recensioni: ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> inserisci({
    required String email,
    required String title,
    required String description,
    required int stars,
  }) async {
    final uri = Uri.parse(
        '${AdminConfig.supabaseUrl}/functions/v1/submit-review');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer ${AdminConfig.supabaseAnonKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'title': title,
        'description': description,
        'stars': stars,
      }),
    );
    if (response.statusCode != 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['error'] == 'duplicate') {
        throw Exception(
            'Hai già inviato una recensione. Puoi contattarci per modificarla.');
      }
      throw Exception('Errore: riprova più tardi.');
    }
  }

  Future<void> approva(int id) async {
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviews?id=eq.$id');
    final body = jsonEncode({'approved': true});
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
}
