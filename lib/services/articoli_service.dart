import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/admin_config.dart';
import '../models/articolo.dart';

class ArticoliService {
  static const _headers = {
    'apikey': AdminConfig.supabaseAnonKey,
    'Authorization': 'Bearer ${AdminConfig.supabaseAnonKey}',
    'Content-Type': 'application/json',
  };

  static const _writeHeaders = {
    'apikey': AdminConfig.supabaseServiceRoleKey,
    'Authorization': 'Bearer ${AdminConfig.supabaseServiceRoleKey}',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };

  // ignore: avoid_public_members_for_test
  Future<List<Articolo>>? overrideForTest;

  Future<List<Articolo>> tutti() async {
    if (overrideForTest != null) return overrideForTest!;
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/articoli?select=*&order=pubblicato_at.desc');
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Errore nel recupero degli articoli: ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => Articolo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Articolo> inserisci({
    required String titolo,
    required String corpo,
    String? immagineUrl,
  }) async {
    final uri =
        Uri.parse('${AdminConfig.supabaseRestUrl}/articoli');
    final body = jsonEncode({
      'titolo': titolo,
      'corpo': corpo,
      'pubblicato_at': DateTime.now().toUtc().toIso8601String(),
      if (immagineUrl != null) 'immagine_url': immagineUrl,
    });
    final response = await http.post(uri, headers: _writeHeaders, body: body);
    if (response.statusCode != 201) {
      throw Exception('Errore nel salvataggio: ${response.body}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    if (list.isEmpty) throw Exception('Nessun dato restituito dal server');
    return Articolo.fromJson(list.first as Map<String, dynamic>);
  }

  Future<void> aggiorna({
    required int id,
    required String titolo,
    required String corpo,
    String? immagineUrl,
  }) async {
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/articoli?id=eq.$id');
    final body = jsonEncode({
      'titolo': titolo,
      'corpo': corpo,
      'immagine_url': immagineUrl,
    });
    final response =
        await http.patch(uri, headers: _writeHeaders, body: body);
    if (response.statusCode != 200) {
      throw Exception('Errore nella modifica: ${response.body}');
    }
  }

  Future<void> cancella(int id) async {
    final uri = Uri.parse(
        '${AdminConfig.supabaseRestUrl}/articoli?id=eq.$id');
    final response = await http.delete(uri, headers: _writeHeaders);
    if (response.statusCode != 204) {
      throw Exception('Errore nell\'eliminazione: ${response.body}');
    }
  }
}
