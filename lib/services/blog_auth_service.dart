import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/admin_config.dart';

class BlogAuthService {
  final ValueNotifier<bool> isAdmin = ValueNotifier(false);

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AdminConfig.supabaseUrl,
      anonKey: '',
    );
    // Restore session on hot reload / page refresh
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      _instance?.isAdmin.value = true;
    }
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _instance?.isAdmin.value = data.session != null;
    });
  }

  static BlogAuthService? _instance;

  BlogAuthService() {
    _instance = this;
  }

  Future<void> signIn({required String email, required String password}) async {
    final response = await Supabase.instance.client.auth
        .signInWithPassword(email: email, password: password);
    if (response.session == null) {
      throw Exception('Credenziali non valide');
    }
    isAdmin.value = true;
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    isAdmin.value = false;
  }

  String? get currentJwt =>
      Supabase.instance.client.auth.currentSession?.accessToken;
}
