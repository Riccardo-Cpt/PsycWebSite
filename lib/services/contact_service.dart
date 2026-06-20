import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/admin_config.dart';

class ContactService {
  Future<void> invia({
    required String name,
    required String surname,
    required String email,
    required String title,
    required String message,
    required String tesseraBase64,
    required String tesseraFileName,
  }) async {
    final uri = Uri.parse(
        '${AdminConfig.supabaseUrl}/functions/v1/send-contact-request');
    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer ${AdminConfig.supabaseAnonKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'surname': surname,
        'email': email,
        'title': title,
        'message': message,
        'tesseraBase64': tesseraBase64,
        'tesseraFileName': tesseraFileName,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Errore nell\'invio: riprova più tardi.');
    }
  }
}
