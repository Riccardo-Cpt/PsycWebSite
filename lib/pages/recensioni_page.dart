import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/review.dart';
import '../widgets/nav_bar.dart';
import '../widgets/site_footer.dart';
import '../widgets/star_rating.dart';

class RecensioniPage extends StatelessWidget {
  final String? pendingToken;
  const RecensioniPage({super.key, this.pendingToken});

  @override
  Widget build(BuildContext context) {
    return NavScaffold(body: _RecensioniBody(pendingToken: pendingToken));
  }
}

// ── Body ───────────────────────────────────────────────────────────────────────

class _RecensioniBody extends StatefulWidget {
  final String? pendingToken;
  const _RecensioniBody({this.pendingToken});

  @override
  State<_RecensioniBody> createState() => _RecensioniBodyState();
}

class _RecensioniBodyState extends State<_RecensioniBody> {
  late Future<List<Review>> _futureReviews;

  @override
  void initState() {
    super.initState();
    _futureReviews = reviewsService.tutti();
    if (widget.pendingToken != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _handlePendingToken(widget.pendingToken!));
    }
  }

  Future<void> _handlePendingToken(String token) async {
    try {
      await reviewAuthService.verifyToken(token);
      if (mounted) _openForm();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _refresh() {
    setState(() {
      _futureReviews = reviewsService.tutti();
    });
  }

  void _openForm() {
    final isWide = MediaQuery.of(context).size.width >= 720;
    if (isWide) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => _ReviewFlowPage(onSaved: _refresh),
      ));
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => _ReviewFlowSheet(onSaved: _refresh),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Recensioni',
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
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
                            style: GoogleFonts.lato(color: Colors.red)),
                      );
                    }
                    final reviews = snapshot.data ?? [];
                    if (reviews.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text('Nessuna recensione ancora.',
                              style: GoogleFonts.lato(
                                  fontSize: 18, color: Colors.black54)),
                        ),
                      );
                    }
                    return Column(
                      children: reviews
                          .map((r) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child:
                                    _ReviewCard(review: r, onDeleted: _refresh),
                              ))
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _openForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Lascia una recensione',
                    style: GoogleFonts.lato(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          const SiteFooter(),
        ],
      ),
    );
  }
}

// ── Review card ────────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback? onDeleted;
  const _ReviewCard({required this.review, this.onDeleted});

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Elimina recensione'),
        content: Text(
            'Eliminare la recensione di "${review.username}"? L\'azione è irreversibile.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annulla')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Elimina',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      try {
        await reviewsService.cancella(review.id);
        onDeleted?.call();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore durante l\'eliminazione: $e')),
          );
        }
      }
    }
  }

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
                Text(review.username,
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                if (review.createdAt != null)
                  Text(
                    DateFormat('yyyy-MM-dd').format(review.createdAt!),
                    style: GoogleFonts.lato(color: Colors.black54, fontSize: 13),
                  ),
                ValueListenableBuilder<bool>(
                  valueListenable: blogAuthService.isAdmin,
                  builder: (context, isAdmin, _) => isAdmin
                      ? IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red, size: 20),
                          tooltip: 'Elimina recensione',
                          onPressed: () => _confirmDelete(context),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            StarRating(stars: review.stars, size: 20),
            const SizedBox(height: 6),
            Text(review.title,
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 6),
            Text(review.description,
                style: GoogleFonts.lato(
                    fontSize: 15, height: 1.5, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}

// ── Flow: step 1 = identity form, step 2 = review form ────────────────────────

class _ReviewFlow extends StatefulWidget {
  final VoidCallback onSaved;
  const _ReviewFlow({required this.onSaved});

  @override
  State<_ReviewFlow> createState() => _ReviewFlowState();
}

class _ReviewFlowState extends State<_ReviewFlow> {
  // Step 1 controllers
  final _emailCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _nomeCtrl = TextEditingController();
  final _cognomeCtrl = TextEditingController();

  // Step 2 controllers
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int _stars = 5;

  bool _loading = false;
  bool _submitted = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _usernameCtrl.dispose();
    _nomeCtrl.dispose();
    _cognomeCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendLink() async {
    final email = _emailCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    final name = _nomeCtrl.text.trim();
    final surname = _cognomeCtrl.text.trim();
    if (email.isEmpty || username.isEmpty || name.isEmpty || surname.isEmpty) {
      setState(() => _error = 'Compila tutti i campi');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await reviewAuthService.sendMagicLink(
        email: email,
        username: username,
        name: name,
        surname: surname,
      );
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Link inviato! Controlla la tua email e clicca il link per continuare.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  Future<void> _submitReview() async {
    if (_titleCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Inserisci titolo e descrizione');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await reviewsService.inserisci(
        email: reviewAuthService.currentEmail!,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        stars: _stars,
      );
      reviewAuthService.reset();
      if (mounted) {
        setState(() => _submitted = true);
        widget.onSaved();
      }
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
    if (_submitted) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 64),
            const SizedBox(height: 16),
            Text(
              'Recensione rilasciata.',
              style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Deve essere approvata da un admin prima di essere pubblicata e visibile nel sito.',
              style: GoogleFonts.lato(fontSize: 15, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ValueListenableBuilder<bool>(
      valueListenable: reviewAuthService.isVerified,
      builder: (context, isVerified, _) {
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
              if (!isVerified) ..._buildStep1() else ..._buildStep2(),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: GoogleFonts.lato(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: isVerified ? _submitReview : _sendLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        isVerified ? 'Invia recensione' : 'Invia link di conferma',
                        style: GoogleFonts.lato(fontSize: 16),
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildStep1() => [
        Text('Lascia una recensione',
            style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          'Inserisci i tuoi dati. Riceverai un link via email per confermare e inviare la tua recensione.',
          style: GoogleFonts.lato(color: Colors.black54),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailCtrl,
          decoration: const InputDecoration(labelText: 'Email *'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _usernameCtrl,
          decoration: const InputDecoration(labelText: 'Username *'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nomeCtrl,
          decoration: const InputDecoration(labelText: 'Nome *'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cognomeCtrl,
          decoration: const InputDecoration(labelText: 'Cognome *'),
        ),
      ];

  List<Widget> _buildStep2() => [
        Text('La tua recensione',
            style: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            for (int i = 1; i <= 5; i++)
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(
                  i <= _stars ? Icons.star : Icons.star_border,
                  color: AppColors.primary,
                  size: 32,
                ),
                onPressed: () => setState(() => _stars = i),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(labelText: 'Titolo *'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descCtrl,
          decoration: const InputDecoration(labelText: 'Descrizione *'),
          minLines: 4,
          maxLines: null,
          keyboardType: TextInputType.multiline,
        ),
      ];
}

// ── Wide: full page ────────────────────────────────────────────────────────────

class _ReviewFlowPage extends StatelessWidget {
  final VoidCallback onSaved;
  const _ReviewFlowPage({required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        foregroundColor: AppColors.primary,
        title: const Text('Lascia una recensione'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: _ReviewFlow(
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

class _ReviewFlowSheet extends StatelessWidget {
  final VoidCallback onSaved;
  const _ReviewFlowSheet({required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      expand: false,
      builder: (_, _) => _ReviewFlow(
        onSaved: () {
          onSaved();
          Navigator.pop(context);
        },
      ),
    );
  }
}
