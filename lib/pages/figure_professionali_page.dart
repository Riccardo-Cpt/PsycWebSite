import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/nav_bar.dart';
import '../widgets/page_hero_header.dart';
import '../widgets/section_image.dart';
import '../widgets/site_footer.dart';
import '../widgets/text_image_section.dart';

class FigureProfessionaliPage extends StatelessWidget {
  const FigureProfessionaliPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeroHeader(
              title: 'Psicologo, psicoterapeuta e psichiatra',
              subtitle: 'Tre figure professionali distinte che spesso vengono confuse. '
                  'Conoscere le differenze aiuta a orientarsi nella scelta del professionista '
                  'più adatto al proprio bisogno.',
              maxWidth: 1100,
            ),
            const _PsicologoSection(),
            const _PsicoterapeutaSection(),
            const _PsichiatraSection(),
            const _CollaborazioneSection(),
            const SiteFooter(),
          ],
        ),
      ),
    );
  }
}

class _PsicologoSection extends StatelessWidget {
  const _PsicologoSection();

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Psicologo',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Lo psicologo è un professionista laureato in Psicologia e abilitato all\'esercizio '
          'della professione attraverso l\'esame di Stato e l\'iscrizione all\'Albo.',
          style: GoogleFonts.lato(fontSize: 18, height: 1.75, color: AppColors.textDark),
        ),
        const SizedBox(height: 16),
        Text(
          'Si occupa di consulenza psicologica, sostegno, valutazione e prevenzione. '
          'Può effettuare colloqui clinici, somministrare test psicologici e accompagnare '
          'le persone in momenti di difficoltà o cambiamento.',
          style: GoogleFonts.lato(fontSize: 18, height: 1.75, color: AppColors.textDark),
        ),
        const SizedBox(height: 16),
        Text(
          'Lo psicologo non ha la formazione specifica per condurre percorsi di psicoterapia, '
          'a meno che non abbia conseguito anche la specializzazione in psicoterapia.',
          style: GoogleFonts.lato(fontSize: 18, height: 1.75, color: AppColors.textDark),
        ),
      ],
    );
    return TextImageSection(
      content: content,
      imagePath: 'assets/images/NinfeeSottAcqua.webp',
      aspectRatio: 340 / 420,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
    );
  }
}

class _PsicoterapeutaSection extends StatelessWidget {
  const _PsicoterapeutaSection();

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Psicoterapeuta',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Lo psicoterapeuta è uno psicologo o un medico che, dopo la laurea, ha completato '
          'una specializzazione quadriennale riconosciuta in psicoterapia.',
          style: GoogleFonts.lato(fontSize: 18, height: 1.75, color: AppColors.textDark),
        ),
        const SizedBox(height: 16),
        Text(
          'È formato per trattare il disagio psicologico e i disturbi emotivi attraverso '
          'strumenti clinici specifici, fondati sul colloquio e sulla relazione terapeutica. '
          'Può lavorare con individui, coppie e famiglie.',
          style: GoogleFonts.lato(fontSize: 18, height: 1.75, color: AppColors.textDark),
        ),
        const SizedBox(height: 16),
        Text(
          'La psicoterapia non prevede la prescrizione di farmaci. Il suo strumento principale '
          'è la relazione terapeutica, costruita nel tempo attraverso ascolto, parola '
          'e presenza clinica.',
          style: GoogleFonts.lato(fontSize: 18, height: 1.75, color: AppColors.textDark),
        ),
      ],
    );
    return TextImageSection(
      content: content,
      imagePath: 'assets/images/TaleaPiantaGrassa.webp',
      aspectRatio: 320 / 400,
      imageOnLeft: true,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
    );
  }
}

class _PsichiatraSection extends StatelessWidget {
  const _PsichiatraSection();

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Psichiatra',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Lo psichiatra è un medico specializzato in psichiatria. In quanto medico, '
          'può formulare diagnosi di natura medica e prescrivere farmaci.',
          style: GoogleFonts.lato(fontSize: 18, height: 1.75, color: AppColors.textDark),
        ),
        const SizedBox(height: 16),
        Text(
          'Si occupa in particolare di disturbi psichici che richiedono una valutazione '
          'biologica e farmacologica, come disturbi dell\'umore gravi, psicosi, disturbi '
          'd\'ansia severi o condizioni che beneficiano di un trattamento integrato.',
          style: GoogleFonts.lato(fontSize: 18, height: 1.75, color: AppColors.textDark),
        ),
        const SizedBox(height: 16),
        Text(
          'Alcuni psichiatri svolgono anche psicoterapia se hanno conseguito la relativa '
          'specializzazione, ma non è la regola.',
          style: GoogleFonts.lato(fontSize: 18, height: 1.75, color: AppColors.textDark),
        ),
      ],
    );
    return TextImageSection(
      content: content,
      imagePath: 'assets/images/fallingLeaves.webp',
      aspectRatio: 340 / 420,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
    );
  }
}

class _CollaborazioneSection extends StatelessWidget {
  const _CollaborazioneSection();

  static const _figure = [
    (
      Icons.person_outline,
      'Psicologo',
      'Consulenza, sostegno psicologico, valutazione e prevenzione. Non conduce psicoterapia senza specializzazione specifica.',
    ),
    (
      Icons.psychology_outlined,
      'Psicoterapeuta',
      'Psicologo o medico con specializzazione quadriennale. Conduce percorsi di psicoterapia individuali, di coppia o familiari.',
    ),
    (
      Icons.medical_services_outlined,
      'Psichiatra',
      'Medico specializzato. Può prescrivere farmaci e formulare diagnosi mediche. Può integrare il trattamento con psicoterapia.',
    ),
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
                'Quando lavorano insieme',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'A seconda del bisogno della persona, queste figure possono collaborare tra loro '
                'offrendo un intervento integrato e adeguato alla complessità della situazione. '
                'Non si escludono: spesso la combinazione di psicoterapia e supporto psichiatrico '
                'rappresenta la risposta più efficace.',
                style: GoogleFonts.lato(
                    fontSize: 18, height: 1.75, color: AppColors.textDark),
              ),
              const SizedBox(height: 40),
              ..._figure.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 20),
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
                          child: Icon(f.$1,
                              color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.$2,
                                style: GoogleFonts.lato(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                f.$3,
                                style: GoogleFonts.lato(
                                    fontSize: 16,
                                    height: 1.6,
                                    color: AppColors.textDark),
                              ),
                            ],
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
