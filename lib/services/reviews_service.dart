import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/admin_config.dart';
import '../models/review.dart';

class ReviewsService {
  static const _readHeaders = {
    'apikey': AdminConfig.supabaseAnonKey,
    'Authorization': 'Bearer ${AdminConfig.supabaseAnonKey}',
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

  Future<List<Review>> tutti() async {
    if (overrideForTest != null) return overrideForTest!;
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviews?select=*&order=created_at.desc');
    final response = await http.get(uri, headers: _readHeaders);
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
        '?Name=eq.$encodedUsername&select=*');
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
    required String description,
    required int stars,
  }) async {
    final uri = Uri.parse('${AdminConfig.supabaseRestUrl}/reviews');
    final body = jsonEncode({
      'Name': name,
      'Description': description,
      'stars': stars,
    });
    final response = await http.post(uri, headers: _writeHeaders, body: body);
    if (response.statusCode != 201) {
      throw Exception('Errore nel salvataggio della recensione: ${response.body}');
    }
  }

  Future<void> aggiorna({
    required int id,
    required String description,
    required int stars,
  }) async {
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/reviews?id=eq.$id');
    final body = jsonEncode({
      'Description': description,
      'stars': stars,
    });
    final response = await http.patch(uri, headers: _writeHeaders, body: body);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Errore nella modifica della recensione: ${response.body}');
    }
  }
}
