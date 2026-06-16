import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/review.dart';
import '../widgets/nav_bar.dart';

class RecensioniPage extends StatelessWidget {
  const RecensioniPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavScaffold(body: _RecensioniBody());
  }
}

// ── Body ───────────────────────────────────────────────────────────────────────

class _RecensioniBody extends StatefulWidget {
  const _RecensioniBody();

  @override
  State<_RecensioniBody> createState() => _RecensioniBodyState();
}

class _RecensioniBodyState extends State<_RecensioniBody> {
  late Future<List<Review>> _futureReviews;
  Review? _myReview;
  bool _loadingMyReview = false;

  @override
  void initState() {
    super.initState();
    _futureReviews = reviewsService.tutti();
  }

  void _refresh() {
    setState(() {
      _futureReviews = reviewsService.tutti();
      _myReview = null;
    });
  }

  Future<void> _onButtonTap() async {
    if (!reviewAuthService.isLoggedIn.value) {
      final loggedIn = await showDialog<bool>(
        context: context,
        builder: (_) => const _AuthDialog(),
      );
      if (loggedIn != true || !mounted) return;
    }
    if (!mounted) return;
    setState(() => _loadingMyReview = true);
    final username = reviewAuthService.currentUsername!;
    final existing = await reviewsService.mia(username);
    if (!mounted) return;
    setState(() {
      _myReview = existing;
      _loadingMyReview = false;
    });
    _openForm(existing);
  }

  void _openForm(Review? existing) {
    final isWide = MediaQuery.of(context).size.width >= 720;
    if (isWide) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => _ReviewFormPage(existing: existing, onSaved: _refresh),
      ));
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => _ReviewFormSheet(existing: existing, onSaved: _refresh),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Recensioni',
            style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E6370)),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Review>>(
            future: _futureReviews,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Errore: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red)),
                );
              }
              final reviews = snapshot.data ?? [];
              if (reviews.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Text('Nessuna recensione ancora.',
                        style: TextStyle(fontSize: 18, color: Colors.black54)),
                  ),
                );
              }
              return Column(
                children: reviews
                    .map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ReviewCard(review: r),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          ValueListenableBuilder<bool>(
            valueListenable: reviewAuthService.isLoggedIn,
            builder: (context, isLoggedIn, _) {
              return _loadingMyReview
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _onButtonTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E6370),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        isLoggedIn && _myReview != null
                            ? 'Modifica la tua recensione'
                            : 'Lascia una recensione',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
            },
          ),
          if (reviewAuthService.isLoggedIn.value) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => reviewAuthService.logout(),
                child: const Text('Esci',
                    style: TextStyle(color: Color(0xFF1E6370))),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Review card ────────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (int i = 1; i <= 5; i++)
                  Icon(
                    i <= review.stars ? Icons.star : Icons.star_border,
                    color: const Color(0xFF1E6370),
                    size: 20,
                  ),
                const SizedBox(width: 12),
                Text(review.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (review.createdAt != null)
                  Text(
                    DateFormat('yyyy-MM-dd').format(review.createdAt!),
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.description,
                style: const TextStyle(fontSize: 15, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

// ── Auth dialog ────────────────────────────────────────────────────────────────

class _AuthDialog extends StatefulWidget {
  const _AuthDialog();

  @override
  State<_AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<_AuthDialog> {
  bool _isLogin = true;
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Inserisci username e password');
      return;
    }
    if (!_isLogin && password != _confirmCtrl.text) {
      setState(() => _error = 'Le password non coincidono');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      if (_isLogin) {
        await reviewAuthService.login(username, password);
      } else {
        await reviewAuthService.register(username, password);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isLogin ? 'Accedi' : 'Registrati'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              onSubmitted: _isLogin ? (_) => _submit() : null,
            ),
            if (!_isLogin) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Conferma password'),
                onSubmitted: (_) => _submit(),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() {
            _isLogin = !_isLogin;
            _error = null;
          }),
          child: Text(
            _isLogin
                ? 'Non hai un account? Registrati'
                : 'Hai già un account? Accedi',
            style: const TextStyle(color: Color(0xFF1E6370)),
          ),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(8),
            child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E6370),
              foregroundColor: Colors.white,
            ),
            child: Text(_isLogin ? 'Accedi' : 'Registrati'),
          ),
      ],
    );
  }
}

// ── Review form (shared logic) ─────────────────────────────────────────────────

class _ReviewForm extends StatefulWidget {
  final Review? existing;
  final VoidCallback onSaved;
  const _ReviewForm({this.existing, required this.onSaved});

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  late final TextEditingController _descCtrl;
  late int _stars;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.existing?.description ?? '');
    _stars = widget.existing?.stars ?? 5;
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci una descrizione')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      if (widget.existing == null) {
        await reviewsService.inserisci(
          name: reviewAuthService.currentUsername!,
          description: _descCtrl.text.trim(),
          stars: _stars,
        );
      } else {
        await reviewsService.aggiorna(
          id: widget.existing!.id,
          description: _descCtrl.text.trim(),
          stars: _stars,
        );
      }
      if (mounted) widget.onSaved();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante il salvataggio: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existing == null ? 'Lascia una recensione' : 'Modifica la tua recensione',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (int i = 1; i <= 5; i++)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    i <= _stars ? Icons.star : Icons.star_border,
                    color: const Color(0xFF1E6370),
                    size: 32,
                  ),
                  onPressed: () => setState(() => _stars = i),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Descrizione *'),
            minLines: 4,
            maxLines: null,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 20),
          _saving
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E6370),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Salva', style: TextStyle(fontSize: 16)),
                ),
        ],
      ),
    );
  }
}

// ── Wide: full page ────────────────────────────────────────────────────────────

class _ReviewFormPage extends StatelessWidget {
  final Review? existing;
  final VoidCallback onSaved;
  const _ReviewFormPage({this.existing, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        foregroundColor: const Color(0xFF1E6370),
        title: Text(
            existing == null ? 'Lascia una recensione' : 'Modifica la tua recensione'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: _ReviewForm(
            existing: existing,
            onSaved: () {
              onSaved();
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}

// ── Narrow: bottom sheet ───────────────────────────────────────────────────────

class _ReviewFormSheet extends StatelessWidget {
  final Review? existing;
  final VoidCallback onSaved;
  const _ReviewFormSheet({this.existing, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      expand: false,
      builder: (_, _) => _ReviewForm(
        existing: existing,
        onSaved: () {
          onSaved();
          Navigator.pop(context);
        },
      ),
    );
  }
}
