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

class ApproccioTerapeuticoPage extends StatelessWidget {
  const ApproccioTerapeuticoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeroHeader(
              title: 'Approccio terapeutico',
              subtitle: 'Il lavoro terapeutico nasce dall\'incontro con una storia unica. '
                  'Non esiste un percorso standard: ogni cammino viene costruito '
                  'con rispetto dei tempi, delle risorse e della specificità di ciascuno.',
              maxWidth: 1100,
              titleFontSize: 38,
            ),
            const _CentralitaPersonaSection(),
            const _RelazioneSection(),
            const _PercorsoSection(),
            const _CambiamentoSection(),
            const _EmdrSection(),
            const CtaBanner(imagePath: 'assets/images/NinfeeStagno2.webp'),
            const SiteFooter(),
          ],
        ),
      ),
    );
  }
}


class _CentralitaPersonaSection extends StatelessWidget {
  const _CentralitaPersonaSection();

  @override
  Widget build(BuildContext context) {
    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'La centralità della persona',
          style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Text(
            'Al centro del lavoro terapeutico c\'è la persona nella sua unicità, '
            'con la sua storia, i suoi vissuti e il significato che la sofferenza '
            'assume nella sua esperienza.'
            'Ogni persona porta con sé una storia diversa, fatta di legami, '
            'perdite, risorse e ferite. Il punto di partenza non è una diagnosi, '
            'ma un ascolto autentico di ciò che quella persona vive, sente e porta '
            'nel momento in cui chiede aiuto.'
            'Questo orientamento richiede tempo, presenza e disponibilità a stare '
            'vicino all\'esperienza dell\'altro senza fretta di interpretarla o '
            'di ricondurla a schemi prestabiliti.',
          style: GoogleFonts.lato(fontSize: 18, height: 1.7, color: AppColors.textDark),
        ),
        const SizedBox(height: 16),
      ],
    );

    return TextImageSection(
      content: textContent,
      imagePath: 'assets/images/NinfeeStagno.webp',
      aspectRatio: 400 / 380,
    );
  }
}

class _RelazioneSection extends StatelessWidget {
  const _RelazioneSection();

  @override
  Widget build(BuildContext context) {
    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'La relazione terapeutica',
          style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Text(
              'L\'ascolto e la relazione terapeutica sono strumenti fondamentali del '
              'lavoro clinico.'
              'Attraverso una relazione fondata su fiducia, rispetto e continuità, '
              'la persona può sentirsi accolta e compresa. Non si tratta di un rapporto '
              'neutro o distante, ma di una presenza autentica che accompagna con attenzione '
              'e sensibilità.'
              'La relazione diventa essa stessa uno strumento di cura: nel modo in cui '
              'viene vissuta e attraversata, offre la possibilità di riconoscere schemi '
              'relazionali profondi e di sperimentare nuove forme di connessione con sé '
              'stessi e con l\'altro.',
          style: GoogleFonts.lato(fontSize: 18, height: 1.7, color: AppColors.textDark),
        ),
        const SizedBox(height: 16),
      ],
    );
    return TextImageSection(
      content: textContent,
      imagePath: 'assets/images/TaleaPiantaGrassa.webp',
      aspectRatio: 400 / 380,
      imageOnLeft: true,
    );
  }
}

class _PercorsoSection extends StatelessWidget {
  const _PercorsoSection();

  @override
  Widget build(BuildContext context) {
    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'La centralità della persona',
          style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Text(
            'La psicoterapia non è una risposta standard a un sintomo, ma un percorso '
            'costruito insieme, che tiene conto dei tempi, delle risorse, delle fragilità '
            'e delle possibilità di cambiamento di ciascuno.'
            'I primi incontri sono dedicati alla comprensione della richiesta e alla '
            'valutazione condivisa del percorso più adatto. Non si parte con un programma '
            'già definito, ma con la disponibilità a costruirlo insieme, incontro dopo incontro.'
            'La durata e l\'intensità del lavoro vengono valutate in modo flessibile, '
            'in relazione all\'evoluzione della situazione e agli obiettivi condivisi.',
          style: GoogleFonts.lato(fontSize: 18, height: 1.7, color: AppColors.textDark),
        ),
        const SizedBox(height: 16),
      ],
    );

    return TextImageSection(
      content: textContent,
      imagePath: 'assets/images/fallingLeaves.webp',
      aspectRatio: 400 / 380,
    );
  }
}


class _CambiamentoSection extends StatelessWidget {
  const _CambiamentoSection();

  static const _obiettivi = [
    (Icons.visibility_outlined, 'Dare senso a ciò che si vive'),
    (Icons.loop_outlined, 'Riconoscere i propri modelli relazionali'),
    (Icons.spa_outlined, 'Entrare in contatto con le proprie risorse'),
    (Icons.auto_awesome_outlined, 'Sviluppare un cambiamento più autentico e duraturo'),
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
                'Cambiamento e consapevolezza',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'L\'obiettivo del lavoro terapeutico è aiutare la persona ad avvicinarsi a sé stessa '
                'con maggiore chiarezza, a riconoscere ciò che la muove e ciò che la trattiene, '
                'e a trovare una direzione più autentica.',
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
                            color: AppColors.primary.withValues(alpha: 0.15),
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

class _EmdrSection extends StatelessWidget {
  const _EmdrSection();

  static const _symptoms = [
    'Ansia persistente',
    'Immagini intrusive',
    'Blocchi emotivi',
    'Iperattivazione',
    'Altre difficoltà psicologiche legate a esperienze passate',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'EMDR',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Eye Movement Desensitization and Reprocessing',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tra gli strumenti clinici che utilizzo vi è anche l\'EMDR, un approccio '
                'terapeutico riconosciuto dall\'OMS e utilizzato in particolare per '
                'l\'elaborazione di esperienze traumatiche o emotivamente molto intense.',
                style: GoogleFonts.lato(
                    fontSize: 18, height: 1.75, color: AppColors.textDark),
              ),
              const SizedBox(height: 16),
              Text(
                'Può essere utile quando alcuni eventi del passato continuano a produrre '
                'sofferenza nel presente, manifestandosi attraverso:',
                style: GoogleFonts.lato(
                    fontSize: 18, height: 1.75, color: AppColors.textDark),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: _symptoms
                      .map((s) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 7),
                                  child: Icon(Icons.circle,
                                      size: 8,
                                      color: AppColors.primary),
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
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'L\'integrazione dell\'EMDR all\'interno del percorso psicoterapeutico viene '
                'valutata in base al bisogno della persona, alla fase del lavoro clinico e agli '
                'obiettivi condivisi. Non si tratta di una tecnica applicata in modo automatico, '
                'ma di uno strumento inserito con attenzione e competenza all\'interno di un '
                'percorso costruito su misura.',
                style: GoogleFonts.lato(
                    fontSize: 18, height: 1.75, color: AppColors.textDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

