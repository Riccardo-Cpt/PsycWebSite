import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../main.dart';

class ContactFormDialog extends StatefulWidget {
  const ContactFormDialog({super.key});

  @override
  State<ContactFormDialog> createState() => _ContactFormDialogState();
}

class _ContactFormDialogState extends State<ContactFormDialog> {
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  PlatformFile? _tessera;
  bool _loading = false;
  bool _submitted = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _emailCtrl.dispose();
    _titleCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTessera() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _tessera = result.files.first);
    }
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final surname = _surnameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final title = _titleCtrl.text.trim();
    final message = _messageCtrl.text.trim();
    if (name.isEmpty || surname.isEmpty || email.isEmpty || title.isEmpty || message.isEmpty) {
      setState(() => _error = 'Compila tutti i campi');
      return;
    }
    if (_tessera == null) {
      setState(() => _error = 'Allega la tessera sanitaria');
      return;
    }
    setState(() { _error = null; _loading = true; });
    try {
      final tesseraBase64 = base64Encode(_tessera!.bytes!);
      await contactService.invia(
        name: name,
        surname: surname,
        email: email,
        title: title,
        message: message,
        tesseraBase64: tesseraBase64,
        tesseraFileName: _tessera!.name,
      );
      if (mounted) setState(() => _submitted = true);
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: _submitted ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 64),
        const SizedBox(height: 16),
        const Text(
          'Richiesta inviata!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Ti contatterò il prima possibile per fissare un appuntamento.',
          style: TextStyle(fontSize: 15, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Chiudi'),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Richiedi un primo colloquio',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Compila il modulo e ti ricontatterò per fissare un appuntamento.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nome *'),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _surnameCtrl,
                  decoration: const InputDecoration(labelText: 'Cognome *'),
                  textCapitalization: TextCapitalization.words,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Email *'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Oggetto *'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageCtrl,
            decoration: const InputDecoration(labelText: 'Messaggio *'),
            minLines: 4,
            maxLines: null,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickTessera,
            icon: Icon(
              _tessera != null ? Icons.check_circle_outline : Icons.attach_file,
              color: _tessera != null ? AppColors.primary : null,
            ),
            label: Text(
              _tessera != null ? _tessera!.name : 'Allega tessera sanitaria *',
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: _tessera != null ? AppColors.primary : Colors.grey,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 20),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Invia richiesta', style: TextStyle(fontSize: 16)),
                ),
        ],
      ),
    );
  }
}
