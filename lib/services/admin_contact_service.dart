import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/admin_config.dart';
import '../main.dart';

class AdminContactService {
  Map<String, String> get _adminHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${blogAuthService.currentJwt ?? ''}',
      };

  Future<List<Map<String, dynamic>>> lista() async {
    final uri = Uri.parse('${AdminConfig.functionsUrl}/admin-contact-requests');
    final response = await http.post(uri,
        headers: _adminHeaders,
        body: jsonEncode({'action': 'list'}));
    if (response.statusCode != 200) throw Exception('Errore nel recupero');
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }
}
