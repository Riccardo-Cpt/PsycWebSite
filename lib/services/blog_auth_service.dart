import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/admin_config.dart';

class BlogAuthService {
  final ValueNotifier<bool> isAdmin = ValueNotifier(false);

  BlogAuthService() {
    // Wire auth state listener — fires on session restore and login/logout
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      isAdmin.value = data.session != null;
    });
    // Check for already-restored session (synchronous after initialize())
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) isAdmin.value = true;
  }

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AdminConfig.supabaseUrl,
      anonKey: AdminConfig.supabaseAnonKey,
    );
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
