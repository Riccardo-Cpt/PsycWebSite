import 'package:flutter/material.dart';
import '../widgets/contact_form_dialog.dart';
import '../widgets/nav_bar.dart';
import '../widgets/site_footer.dart';

class ServiziPage extends StatelessWidget {
  const ServiziPage({super.key});

  static const _aree = [
    (
      'Ansia e gestione dello stress',
      'Supporto nel riconoscere e gestire l\'ansia, gli attacchi di panico e le tensioni croniche legate al lavoro, alle relazioni o ai cambiamenti di vita.',
      'assets/images/individual_therapy.png',
      true,
    ),
    (
      'Difficoltà relazionali e di coppia',
      'Percorsi per migliorare la comunicazione, affrontare i conflitti e ritrovare equilibrio nelle relazioni affettive e familiari.',
      'assets/images/couple_therapy.jpeg',
      false,
    ),
    (
      'Adolescenza',
      'Interventi dedicati ai giovani e alle loro famiglie per affrontare le sfide dell\'identità, del rendimento scolastico e delle relazioni tra pari.',
      'assets/images/youth_therapy.jpg',
      true,
    ),
    (
      'Autostima e crescita personale',
      'Lavoro su sé stessi per rafforzare la fiducia nelle proprie capacità, superare blocchi emotivi e sviluppare una visione più autentica di sé.',
      'assets/images/personal_growth.jpg',
      false,
    ),
    (
      'Momenti di crisi e regolazione emotiva',
      'Supporto nei periodi di forte difficoltà — lutti, separazioni, traumi, burnout — con strumenti concreti per ritrovare stabilità e risorse interiori.',
      'assets/images/self_regulation.jpg',
      true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return NavScaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            const Text(
              'Di cosa mi occupo',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93a996)),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mi occupo di benessere psicologico in tutte le sue forme. '
              'Attraverso un approccio personalizzato e basato sulla relazione terapeutica, '
              'accompagno le persone in percorsi di cambiamento, comprensione di sé e '
              'recupero dell\'equilibrio emotivo. Di seguito le principali aree in cui lavoro.',
              style: TextStyle(fontSize: 16, height: 1.7, color: Colors.black87),
            ),
            const SizedBox(height: 40),
            const Text(
              'Aree di intervento',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93a996)),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  runSpacing: 13,
                  children: _aree
                      .map((s) => SizedBox(
                            width: constraints.maxWidth,
                            child: _AreaCard(
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
            const SizedBox(height: 24),
                ],
              ),
            ),
            const SiteFooter(),
          ],
        ),
      ),
    );
  }
}

class _ContattiSection extends StatelessWidget {
  const _ContattiSection();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IntrinsicWidth(
        child: ElevatedButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const ContactFormDialog(),
          ),
          icon: const Icon(Icons.calendar_today_outlined),
          label: const Text(
            'Richiedi un primo colloquio',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF93a996),
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 3,
          ),
        ),
      ),
    );
  }
}

class _AreaCard extends StatelessWidget {
  final String titolo;
  final String descrizione;
  final String imagePath;
  final bool imageOnLeft;

  const _AreaCard({
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
                      color: Color(0xFF93a996))),
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
