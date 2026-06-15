import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/admin_config.dart';

class StorageService {
  static const _writeHeaders = {
    'apikey': AdminConfig.supabaseServiceRoleKey,
    'Authorization': 'Bearer ${AdminConfig.supabaseServiceRoleKey}',
  };

  String _publicUrl(String filename) =>
      '${AdminConfig.supabaseStorageUrl}/object/public/${AdminConfig.articoliBucket}/$filename';

  String? _filenameFromUrl(String url) {
    final prefix =
        '${AdminConfig.supabaseStorageUrl}/object/public/${AdminConfig.articoliBucket}/';
    if (!url.startsWith(prefix)) return null;
    return url.substring(prefix.length);
  }

  Future<String> uploadImmagine(Uint8List bytes, String mime) async {
    final filename =
        '${DateTime.now().millisecondsSinceEpoch}.${mime.split('/').last}';
    final uri = Uri.parse(
        '${AdminConfig.supabaseStorageUrl}/object/${AdminConfig.articoliBucket}/$filename');
    final response = await http.post(
      uri,
      headers: {
        ..._writeHeaders,
        'Content-Type': mime,
      },
      body: bytes,
    );
    if (response.statusCode != 200) {
      throw Exception('Errore nel caricamento immagine: ${response.body}');
    }
    return _publicUrl(filename);
  }

  Future<void> deleteImmagine(String url) async {
    final filename = _filenameFromUrl(url);
    if (filename == null) return;
    final uri = Uri.parse(
        '${AdminConfig.supabaseStorageUrl}/object/${AdminConfig.articoliBucket}/$filename');
    await http.delete(uri, headers: _writeHeaders);
  }
}
