import 'package:flutter/material.dart';
import '../config/contatti.dart';
import '../widgets/contact_chip.dart';
import '../widgets/nav_bar.dart';

class ServiziPage extends StatelessWidget {
  const ServiziPage({super.key});

  static const _servizi = [
    (
      'Terapia Individuale',
      'Percorso psicologico personalizzato per affrontare difficoltà emotive, ansia, depressione e crescita personale.',
      'assets/images/individual_therapy.png',
      true,  // imageOnLeft
    ),
    (
      'Terapia di Coppia',
      'Supporto alla relazione per migliorare la comunicazione, gestire i conflitti e ritrovare l\'equilibrio di coppia.',
      'assets/images/couple_therapy.jpeg',
      false, // imageOnRight
    ),
    (
      'Terapia Speciale',
      'Interventi mirati per situazioni specifiche: elaborazione del lutto, trauma, fobia, supporto oncologico.',
      'assets/images/special_terapy.jpg',
      true,  // imageOnLeft
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return NavScaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text('Servizi Offerti',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E6370))),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  runSpacing: 13,
                  children: _servizi
                      .map((s) => SizedBox(
                            width: constraints.maxWidth,
                            child: _ServizioCard(
                              titolo: s.$1,
                              descrizione: s.$2,
                              imagePath: s.$3,
                              imageOnLeft: s.$4,
                            ),
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            const _ContattiSection(),
          ],
        ),
      ),
    );
  }
}

class _ContattiSection extends StatelessWidget {
  const _ContattiSection();

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Contattami',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E6370)),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF1E6370),
                    child: Icon(Icons.phone, color: Colors.white),
                  ),
                  title: const Text('Chiama',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text(Contatti.telefono,
                      textAlign: TextAlign.center),
                  onTap: () {
                    Navigator.pop(context);
                    chiamaTelefono(Contatti.telefono);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF1E6370),
                    child: Icon(Icons.email_outlined, color: Colors.white),
                  ),
                  title: const Text('Scrivi un\'email',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text(Contatti.email,
                      textAlign: TextAlign.center),
                  onTap: () {
                    Navigator.pop(context);
                    inviaEmail(Contatti.email);
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Chiudi',
                      style: TextStyle(color: Color(0xFF1E6370))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IntrinsicWidth(
        child: ElevatedButton.icon(
          onPressed: () => _showPopup(context),
          icon: const Icon(Icons.contact_phone_outlined),
          label: const Text(
            'Contattami',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E6370),
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 3,
          ),
        ),
      ),
    );
  }
}

class _ServizioCard extends StatelessWidget {
  final String titolo;
  final String descrizione;
  final String imagePath;
  final bool imageOnLeft;

  const _ServizioCard({
    required this.titolo,
    required this.descrizione,
    required this.imagePath,
    required this.imageOnLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;

          final picture = ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imagePath,
              width: isWide ? 220 : double.infinity,
              height: isWide ? 180 : 200,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          );

          final textBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(titolo,
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E6370))),
              const SizedBox(height: 10),
              Text(descrizione,
                  style: const TextStyle(
                      fontSize: 17, color: Colors.black54, height: 1.5)),
            ],
          );

          if (!isWide) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  picture,
                  const SizedBox(height: 16),
                  textBlock,
                ],
              ),
            );
          }

          final children = imageOnLeft
              ? [picture, const SizedBox(width: 20), Expanded(child: textBlock)]
              : [Expanded(child: textBlock), const SizedBox(width: 20), picture];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            ),
          );
        },
      ),
    );
  }
}
