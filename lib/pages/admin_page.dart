import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../widgets/nav_bar.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavScaffold(body: _PasswordGate());
  }
}

// ── Password gate ─────────────────────────────────────────────────────────────

class _PasswordGate extends StatefulWidget {
  const _PasswordGate();

  @override
  State<_PasswordGate> createState() => _PasswordGateState();
}

class _PasswordGateState extends State<_PasswordGate> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _login() {
    blogAuthService.login(_controller.text);
    if (blogAuthService.isAdmin.value) {
      if (mounted) context.go('/');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password errata')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Accesso Admin',
                    style: TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextField(
                  controller: _controller,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Password'),
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E6370),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Accedi',
                      style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
