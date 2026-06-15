import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../widgets/nav_bar.dart';
import '../main.dart';
import '../models/articolo.dart';

class ArticoliAdminPage extends StatelessWidget {
  const ArticoliAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavScaffold(
      body: ValueListenableBuilder<bool>(
        valueListenable: blogAuthService.isAdmin,
        builder: (context, isAdmin, _) =>
            isAdmin ? const _AdminPanel() : const _PasswordGate(),
      ),
    );
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
    if (!blogAuthService.isAdmin.value && mounted) {
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

// ── Admin panel ───────────────────────────────────────────────────────────────

class _AdminPanel extends StatefulWidget {
  const _AdminPanel();

  @override
  State<_AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<_AdminPanel> {
  late Future<List<Articolo>> _futureArticoli;

  @override
  void initState() {
    super.initState();
    _futureArticoli = articoliService.tutti();
  }

  void _refresh() {
    setState(() {
      _futureArticoli = articoliService.tutti();
    });
  }

  Future<void> _confirmDelete(BuildContext context, Articolo articolo) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Elimina articolo'),
        content: Text(
            'Eliminare "${articolo.titolo}"? L\'azione è irreversibile.'),
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
      if (articolo.immagineUrl != null) {
        await storageService.deleteImmagine(articolo.immagineUrl!);
      }
      await articoliService.cancella(articolo.id);
      _refresh();
    }
  }

  void _openForm(BuildContext context, {Articolo? articolo}) {
    final isWide = MediaQuery.of(context).size.width >= 720;
    if (isWide) {
      Navigator.of(context)
          .push(MaterialPageRoute(
            builder: (_) => _ArticoloFormPage(
                articolo: articolo, onSaved: _refresh),
          ))
          .then((_) => _refresh());
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) =>
            _ArticoloFormSheet(articolo: articolo, onSaved: _refresh),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text('Pannello Admin — I miei articoli',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton.icon(
                onPressed: () => _openForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Nuovo articolo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E6370),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Articolo>>(
              future: _futureArticoli,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Errore: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red)));
                }
                final articoli = snapshot.data ?? [];
                if (articoli.isEmpty) {
                  return const Center(
                      child: Text('Nessun articolo. Creane uno!',
                          style: TextStyle(color: Colors.black54)));
                }
                return ListView.separated(
                  itemCount: articoli.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final a = articoli[i];
                    return ListTile(
                      title: Text(a.titolo,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        a.pubblicatoAt != null
                            ? DateFormat('yyyy-MM-dd')
                                .format(a.pubblicatoAt!)
                            : '',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Color(0xFF1E6370)),
                            tooltip: 'Modifica',
                            onPressed: () =>
                                _openForm(context, articolo: a),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            tooltip: 'Elimina',
                            onPressed: () =>
                                _confirmDelete(context, a),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared form logic ──────────────────────────────────────────────────────────

class _ArticoloForm extends StatefulWidget {
  final Articolo? articolo;
  final VoidCallback onSaved;
  const _ArticoloForm({this.articolo, required this.onSaved});

  @override
  State<_ArticoloForm> createState() => _ArticoloFormState();
}

class _ArticoloFormState extends State<_ArticoloForm> {
  late final TextEditingController _titoloCtrl;
  late final TextEditingController _corpoCtrl;
  Uint8List? _newImageBytes;
  String? _newImageMime;
  bool _removeImage = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.articolo;
    _titoloCtrl = TextEditingController(text: a?.titolo ?? '');
    _corpoCtrl = TextEditingController(text: a?.corpo ?? '');
  }

  @override
  void dispose() {
    _titoloCtrl.dispose();
    _corpoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _newImageBytes = bytes;
      _newImageMime = file.mimeType ?? 'image/jpeg';
      _removeImage = false;
    });
  }

  String? get _currentImageUrl =>
      _removeImage ? null : widget.articolo?.immagineUrl;

  Future<void> _save() async {
    if (_titoloCtrl.text.trim().isEmpty || _corpoCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Titolo e corpo sono obbligatori')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      String? immagineUrl = _currentImageUrl;

      if (_newImageBytes != null) {
        if (widget.articolo?.immagineUrl != null) {
          await storageService
              .deleteImmagine(widget.articolo!.immagineUrl!);
        }
        immagineUrl = await storageService.uploadImmagine(
            _newImageBytes!, _newImageMime!);
      } else if (_removeImage && widget.articolo?.immagineUrl != null) {
        await storageService
            .deleteImmagine(widget.articolo!.immagineUrl!);
        immagineUrl = null;
      }

      if (widget.articolo == null) {
        await articoliService.inserisci(
          titolo: _titoloCtrl.text.trim(),
          corpo: _corpoCtrl.text.trim(),
          immagineUrl: immagineUrl,
        );
      } else {
        await articoliService.aggiorna(
          id: widget.articolo!.id,
          titolo: _titoloCtrl.text.trim(),
          corpo: _corpoCtrl.text.trim(),
          immagineUrl: immagineUrl,
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
            widget.articolo == null ? 'Nuovo articolo' : 'Modifica articolo',
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titoloCtrl,
            decoration: const InputDecoration(labelText: 'Titolo *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _corpoCtrl,
            decoration: const InputDecoration(labelText: 'Corpo *'),
            minLines: 5,
            maxLines: null,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 12),
          if (_newImageBytes != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(_newImageBytes!,
                  height: 160, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => setState(() {
                _newImageBytes = null;
                _newImageMime = null;
              }),
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text('Rimuovi immagine',
                  style: TextStyle(color: Colors.red)),
            ),
          ] else if (_currentImageUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(_currentImageUrl!,
                  height: 160, fit: BoxFit.cover),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Cambia immagine'),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _removeImage = true),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Rimuovi immagine',
                      style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ] else
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image_outlined),
              label:
                  const Text('Seleziona immagine (facoltativa)'),
            ),
          const SizedBox(height: 20),
          _saving
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E6370),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Salva',
                      style: TextStyle(fontSize: 16)),
                ),
        ],
      ),
    );
  }
}

// ── Wide: full page ────────────────────────────────────────────────────────────

class _ArticoloFormPage extends StatelessWidget {
  final Articolo? articolo;
  final VoidCallback onSaved;
  const _ArticoloFormPage({this.articolo, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        foregroundColor: const Color(0xFF1E6370),
        title: Text(
            articolo == null ? 'Nuovo articolo' : 'Modifica articolo'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: _ArticoloForm(
            articolo: articolo,
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

class _ArticoloFormSheet extends StatelessWidget {
  final Articolo? articolo;
  final VoidCallback onSaved;
  const _ArticoloFormSheet({this.articolo, required this.onSaved});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      expand: false,
      builder: (_, _) => _ArticoloForm(
        articolo: articolo,
        onSaved: () {
          onSaved();
          Navigator.pop(context);
        },
      ),
    );
  }
}
