import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/admin_config.dart';
import '../models/review.dart';
import '../main.dart';

class ReviewsService {
  Future<List<Review>>? overrideForTest;

  Map<String, String> get _publicHeaders => const {
        'Content-Type': 'application/json',
        'apikey': AdminConfig.supabaseAnonKey,
      };

  Map<String, String> get _adminHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${blogAuthService.currentJwt ?? ''}',
      };

  Future<List<Review>> tutti() async {
    if (overrideForTest != null) return overrideForTest!;
    final uri = Uri.parse('${AdminConfig.functionsUrl}/get-approved-reviews');
    final response = await http.get(uri, headers: _publicHeaders);
    if (response.statusCode != 200) throw Exception('Errore nel recupero delle recensioni');
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Review>> tuttiAdmin() async {
    final uri = Uri.parse('${AdminConfig.functionsUrl}/admin-reviews');
    final response = await http.post(uri,
        headers: _adminHeaders,
        body: jsonEncode({'action': 'list'}));
    if (response.statusCode != 200) throw Exception('Errore nel recupero delle recensioni');
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> inserisci({
    required String email,
    required String title,
    required String description,
    required int stars,
  }) async {
    final uri = Uri.parse('${AdminConfig.functionsUrl}/submit-review');
    final response = await http.post(uri,
        headers: _publicHeaders,
        body: jsonEncode({'email': email, 'title': title, 'description': description, 'stars': stars}));
    if (response.statusCode != 200) {
      String? errorCode;
      try {
        errorCode = (jsonDecode(response.body) as Map<String, dynamic>)['error'] as String?;
      } catch (_) {}
      if (errorCode == 'duplicate') {
        throw Exception('Hai già inviato una recensione.');
      }
      throw Exception('Errore: riprova più tardi.');
    }
  }

  Future<void> approva(int id) async {
    final uri = Uri.parse('${AdminConfig.functionsUrl}/admin-reviews');
    final response = await http.post(uri,
        headers: _adminHeaders,
        body: jsonEncode({'action': 'approve', 'id': id}));
    if (response.statusCode != 200) throw Exception('Errore nell\'approvazione');
  }

  Future<void> cancella(int id) async {
    final uri = Uri.parse('${AdminConfig.functionsUrl}/admin-reviews');
    final response = await http.post(uri,
        headers: _adminHeaders,
        body: jsonEncode({'action': 'delete', 'id': id}));
    if (response.statusCode != 200) throw Exception('Errore nell\'eliminazione');
  }
}
