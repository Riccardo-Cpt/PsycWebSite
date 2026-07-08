import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/admin_config.dart';
import '../models/articolo.dart';
import '../main.dart';

class ArticoliService {
  Future<List<Articolo>>? overrideForTest;

  Map<String, String> get _publicHeaders => const {
        'Content-Type': 'application/json',
        'apikey': AdminConfig.supabaseAnonKey,
      };

  Map<String, String> get _adminHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${blogAuthService.currentJwt ?? ''}',
      };

  Future<List<Articolo>> tutti() async {
    if (overrideForTest != null) return overrideForTest!;
    final uri = Uri.parse('${AdminConfig.functionsUrl}/get-articles');
    final response = await http.get(uri, headers: _publicHeaders);
    if (response.statusCode != 200) {
      throw Exception('Errore nel recupero degli articoli');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Articolo.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Articolo> inserisci({
    required String titolo,
    required String corpo,
    Uint8List? imageBytes,
    String? imageMime,
  }) async {
    String? immagineUrl;
    if (imageBytes != null && imageMime != null) {
      immagineUrl = await _uploadImage(imageBytes, imageMime);
    }
    final uri = Uri.parse('${AdminConfig.functionsUrl}/admin-articles');
    final response = await http.post(uri,
        headers: _adminHeaders,
        body: jsonEncode({
          'action': 'create',
          'titolo': titolo,
          'corpo': corpo,
          if (immagineUrl != null) 'immagine_url': immagineUrl,
        }));
    if (response.statusCode != 200) {
      throw Exception('Errore nel salvataggio');
    }
    return Articolo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> aggiorna({
    required int id,
    required String titolo,
    required String corpo,
    Uint8List? newImageBytes,
    String? newImageMime,
    String? existingImageUrl,
    bool removeImage = false,
  }) async {
    String? immagineUrl = removeImage ? null : existingImageUrl;
    if (newImageBytes != null && newImageMime != null) {
      if (existingImageUrl != null) await _deleteImage(existingImageUrl);
      immagineUrl = await _uploadImage(newImageBytes, newImageMime);
    } else if (removeImage && existingImageUrl != null) {
      await _deleteImage(existingImageUrl);
    }
    final uri = Uri.parse('${AdminConfig.functionsUrl}/admin-articles');
    final response = await http.post(uri,
        headers: _adminHeaders,
        body: jsonEncode({
          'action': 'update',
          'id': id,
          'titolo': titolo,
          'corpo': corpo,
          'immagine_url': immagineUrl,
        }));
    if (response.statusCode != 200) {
      throw Exception('Errore nella modifica');
    }
  }

  Future<void> cancella(int id, {String? immagineUrl}) async {
    if (immagineUrl != null) await _deleteImage(immagineUrl);
    final uri = Uri.parse('${AdminConfig.functionsUrl}/admin-articles');
    final response = await http.post(uri,
        headers: _adminHeaders,
        body: jsonEncode({'action': 'delete', 'id': id}));
    if (response.statusCode != 200) {
      throw Exception('Errore nell\'eliminazione');
    }
  }

  Future<String> _uploadImage(Uint8List bytes, String mime) async {
    final uri = Uri.parse('${AdminConfig.functionsUrl}/admin-articles');
    final response = await http.post(uri,
        headers: _adminHeaders,
        body: jsonEncode({
          'action': 'upload-image',
          'imageBase64': base64Encode(bytes),
          'mimeType': mime,
        }));
    if (response.statusCode != 200) throw Exception('Errore nel caricamento immagine');
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return body['url'] as String;
  }

  Future<void> _deleteImage(String url) async {
    final uri = Uri.parse('${AdminConfig.functionsUrl}/admin-articles');
    final response = await http.post(uri,
        headers: _adminHeaders,
        body: jsonEncode({'action': 'delete-image', 'url': url}));
    if (response.statusCode != 200) {
      // Log but don't throw — image orphan is recoverable
      debugPrint('Warning: image delete failed for $url: ${response.statusCode}');
    }
  }
}
