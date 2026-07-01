import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/contact_form_dialog.dart';
import '../widgets/cta_banner.dart';
import '../widgets/nav_bar.dart';
import '../widgets/page_hero_header.dart';
import '../widgets/section_image.dart';
import '../widgets/site_footer.dart';
import '../widgets/text_image_section.dart';

class PsicoterapiaPage extends StatelessWidget {
  const PsicoterapiaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeroHeader(
              title: 'Psicoterapia',
              subtitle: 'La psicoterapia è un percorso di cura e conoscenza di sé che aiuta a '
                  'comprendere il significato del disagio psicologico, dei sintomi e delle '
                  'difficoltà relazionali.',
              maxWidth: 1100,
              titleFontSize: 38,
            ),
            const _CosESection(),
            const _QuandoSection(),
            const _ComeSiSvolgeSection(),
            const _ObiettiviSection(),
            const CtaBanner(imagePath: 'assets/images/forestTrees.webp'),
            const SiteFooter(),
          ],
        ),
      ),
    );
  }
}

class _CosESection extends StatelessWidget {
  const _CosESection();

  @override
  Widget build(BuildContext context) {
    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Che cos\'è la psicoterapia',
          style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Text(
            'La psicoterapia è un percorso di cura che si sviluppa attraverso la '
            'relazione tra terapeuta e persona, nel tempo e nello spazio del colloquio.'
            'Non si tratta di ricevere consigli o soluzioni preconfezionate, ma di '
            'costruire insieme una comprensione più profonda di ciò che si vive, '
            'di come ci si muove nelle relazioni e di ciò che alimenta la sofferenza.'
            'È un lavoro che richiede tempo, fiducia e disponibilità ad osservare '
            'se stessi con onestà e curiosità. Il cambiamento che ne può nascere '
            'è autentico, radicato nella propria storia e nelle proprie risorse.',
          style: GoogleFonts.lato(fontSize: 18, height: 1.7, color: AppColors.textDark),
        ),
        const SizedBox(height: 16),
      ],
    );
    return TextImageSection(
      content: textContent,
      imagePath: 'assets/images/Arcobaleno.webp',
      aspectRatio: 400 / 380,
    );
  }
}

class _QuandoSection extends StatelessWidget {
  const _QuandoSection();

  static const _situazioni = [
    'Ansia e attacchi di panico',
    'Vissuti depressivi',
    'Lutto e perdita',
    'Esperienze traumatiche',
    'Stress prolungato',
    'Difficoltà affettive e relazionali',
    'Problematiche familiari o di coppia',
    'Altri momenti di sofferenza emotiva',
  ];

  @override
  Widget build(BuildContext context) {
    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quando può essere utile',
          style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Text(
          'La psicoterapia può essere utile in presenza di:',
          style: GoogleFonts.lato(
              fontSize: 18, height: 1.75, color: AppColors.textDark),
        ),
        const SizedBox(height: 16),
        ..._situazioni.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: Icon(Icons.circle,
                        size: 8, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(s,
                        style: GoogleFonts.lato(
                            fontSize: 17,
                            height: 1.6,
                            color: AppColors.textDark)),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 8),
        Text(
          'Non è necessario stare molto male per iniziare: molte persone '
          'si rivolgono alla psicoterapia anche per affrontare momenti di '
          'cambiamento, prendere decisioni importanti o approfondire la '
          'conoscenza di sé.',
          style: GoogleFonts.lato(
              fontSize: 18, height: 1.75, color: AppColors.textDark),
        ),
        const SizedBox(height: 16),
      ],
    );
    return TextImageSection(
      content: textContent,
      imagePath: 'assets/images/fallingLeaves.webp',
      aspectRatio: 400 / 380,
      imageOnLeft: true,
    );
  }
}

class _ComeSiSvolgeSection extends StatelessWidget {
  const _ComeSiSvolgeSection();

  @override
  Widget build(BuildContext context) {
    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Come si svolge il percorso',
          style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Text(
              'Ogni percorso viene costruito in modo personalizzato, nel rispetto '
              'della storia, dei tempi e delle caratteristiche della persona.'
              'I primi incontri sono dedicati alla conoscenza reciproca, alla '
              'comprensione della richiesta e alla valutazione condivisa del '
              'percorso più adatto. Non si parte con un programma già definito, '
              'ma con la disponibilità ad ascoltare e a costruire insieme.'
              'La relazione terapeutica diventa uno spazio in cui comprendere, '
              'elaborare e trasformare il disagio. La durata e l\'intensità del '
              'lavoro vengono valutate in modo flessibile, in relazione '
              'all\'evoluzione della situazione e agli obiettivi condivisi.',
          style: GoogleFonts.lato(fontSize: 18, height: 1.7, color: AppColors.textDark),
        ),
        const SizedBox(height: 16),
      ],
    );
    return TextImageSection(
      content: textContent,
      imagePath: 'assets/images/lilium.webp',
      aspectRatio: 400 / 380,
    );
  }
}

class _ObiettiviSection extends StatelessWidget {
  const _ObiettiviSection();

  static const _obiettivi = [
    (Icons.self_improvement_outlined, 'Maggiore consapevolezza di sé'),
    (Icons.favorite_border_outlined, 'Riconoscimento dei propri bisogni'),
    (Icons.spa_outlined, 'Valorizzazione delle risorse personali'),
    (Icons.auto_awesome_outlined, 'Cambiamento autentico e duraturo'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Come si svolge il percorso',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'L\'obiettivo non è soltanto ridurre la sofferenza, ma favorire una '
                'trasformazione più profonda e duratura.',
                style: GoogleFonts.lato(
                    fontSize: 18, height: 1.75, color: AppColors.textDark),
              ),
              const SizedBox(height: 32),
              ..._obiettivi.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item.$1,
                              color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              item.$2,
                              style: GoogleFonts.lato(
                                  fontSize: 17,
                                  height: 1.6,
                                  color: AppColors.textDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

