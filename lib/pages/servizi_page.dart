import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/contact_form_dialog.dart';
import '../widgets/cta_banner.dart';
import '../widgets/nav_bar.dart';
import '../widgets/section_image.dart';
import '../widgets/site_footer.dart';

class ServiziPage extends StatelessWidget {
  const ServiziPage({super.key});

  static const _aree = [
    (
      'Ansia e gestione dello stress',
      'Supporto nel riconoscere e gestire l\'ansia, gli attacchi di panico e le tensioni croniche legate al lavoro, alle relazioni o ai cambiamenti di vita.',
      'assets/images/individual_therapy.webp',
      true,
    ),
    (
      'Difficoltà relazionali e di coppia',
      'Percorsi per migliorare la comunicazione, affrontare i conflitti e ritrovare equilibrio nelle relazioni affettive e familiari.',
      'assets/images/couple_therapy.webp',
      false,
    ),
    (
      'Adolescenza',
      'Interventi dedicati ai giovani e alle loro famiglie per affrontare le sfide dell\'identità, del rendimento scolastico e delle relazioni tra pari.',
      'assets/images/youth_therapy.webp',
      true,
    ),
    (
      'Autostima e crescita personale',
      'Lavoro su sé stessi per rafforzare la fiducia nelle proprie capacità, superare blocchi emotivi e sviluppare una visione più autentica di sé.',
      'assets/images/personal_growth.webp',
      false,
    ),
    (
      'Momenti di crisi e regolazione emotiva',
      'Supporto nei periodi di forte difficoltà — lutti, separazioni, traumi, burnout — con strumenti concreti per ritrovare stabilità e risorse interiori.',
      'assets/images/self_regulation.webp',
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
            Text(
              'Di cosa mi occupo',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Mi occupo di benessere psicologico in tutte le sue forme. '
              'Attraverso un approccio personalizzato e basato sulla relazione terapeutica, '
              'accompagno le persone in percorsi di cambiamento, comprensione di sé e '
              'recupero dell\'equilibrio emotivo. Di seguito le principali aree in cui lavoro.',
              style: GoogleFonts.lato(fontSize: 16, height: 1.7, color: Colors.black87),
            ),
            const SizedBox(height: 40),
            Text(
              'A chi mi rivolgo',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
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
            const CtaBanner(imagePath: 'assets/images/germinatingPlants.webp'),
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

          final picture = SizedBox(
            width: isWide ? 220 : double.infinity,
            child: buildSectionImage(imagePath, isWide ? 220 / 180 : 16 / 9),
          );

          final textBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(titolo,
                  style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              const SizedBox(height: 10),
              Text(descrizione,
                  style: GoogleFonts.lato(
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
