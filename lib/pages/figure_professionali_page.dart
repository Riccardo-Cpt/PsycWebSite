import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import '../widgets/site_footer.dart';

class FigureProfessionaliPage extends StatelessWidget {
  const FigureProfessionaliPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _HeroHeader(),
            _PsicologoSection(),
            _PsicoterapeutaSection(),
            _PsichiatraSection(),
            _CollaborazioneSection(),
            SiteFooter(),
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F7F4),
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Psicologo, psicoterapeuta e psichiatra',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93a996),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Tre figure professionali distinte che spesso vengono confuse. '
                'Conoscere le differenze aiuta a orientarsi nella scelta del professionista '
                'più adatto al proprio bisogno.',
                style: TextStyle(
                  fontSize: 19,
                  height: 1.75,
                  color: Color(0xFF2C2C2C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PsicologoSection extends StatelessWidget {
  const _PsicologoSection();

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 340 / 420,
        child: Image.asset(
          'assets/images/NinfeeSottAcqua.jpeg',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
    const content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Psicologo',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF93a996),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Lo psicologo è un professionista laureato in Psicologia e abilitato all\'esercizio '
          'della professione attraverso l\'esame di Stato e l\'iscrizione all\'Albo.',
          style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
        ),
        SizedBox(height: 16),
        Text(
          'Si occupa di consulenza psicologica, sostegno, valutazione e prevenzione. '
          'Può effettuare colloqui clinici, somministrare test psicologici e accompagnare '
          'le persone in momenti di difficoltà o cambiamento.',
          style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
        ),
        SizedBox(height: 16),
        Text(
          'Lo psicologo non ha la formazione specifica per condurre percorsi di psicoterapia, '
          'a meno che non abbia conseguito anche la specializzazione in psicoterapia.',
          style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
        ),
      ],
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [content, SizedBox(height: 32)],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 3, child: content),
                  const SizedBox(width: 48),
                  Expanded(flex: 2, child: image),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PsicoterapeutaSection extends StatelessWidget {
  const _PsicoterapeutaSection();

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 320 / 400,
        child: Image.asset(
          'assets/images/TaleaPiantaGrassa.jpeg',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
    const content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Psicoterapeuta',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF93a996),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Lo psicoterapeuta è uno psicologo o un medico che, dopo la laurea, ha completato '
          'una specializzazione quadriennale riconosciuta in psicoterapia.',
          style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
        ),
        SizedBox(height: 16),
        Text(
          'È formato per trattare il disagio psicologico e i disturbi emotivi attraverso '
          'strumenti clinici specifici, fondati sul colloquio e sulla relazione terapeutica. '
          'Può lavorare con individui, coppie e famiglie.',
          style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
        ),
        SizedBox(height: 16),
        Text(
          'La psicoterapia non prevede la prescrizione di farmaci. Il suo strumento principale '
          'è la relazione terapeutica, costruita nel tempo attraverso ascolto, parola '
          'e presenza clinica.',
          style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
        ),
      ],
    );
    return Container(
      width: double.infinity,
      color: const Color(0xFFF9F9F9),
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [content, SizedBox(height: 32)],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: image),
                  const SizedBox(width: 48),
                  const Expanded(flex: 3, child: content),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PsichiatraSection extends StatelessWidget {
  const _PsichiatraSection();

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 340 / 420,
        child: Image.asset(
          'assets/images/fallingLeaves.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
    const content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Psichiatra',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF93a996),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Lo psichiatra è un medico specializzato in psichiatria. In quanto medico, '
          'può formulare diagnosi di natura medica e prescrivere farmaci.',
          style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
        ),
        SizedBox(height: 16),
        Text(
          'Si occupa in particolare di disturbi psichici che richiedono una valutazione '
          'biologica e farmacologica, come disturbi dell\'umore gravi, psicosi, disturbi '
          'd\'ansia severi o condizioni che beneficiano di un trattamento integrato.',
          style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
        ),
        SizedBox(height: 16),
        Text(
          'Alcuni psichiatri svolgono anche psicoterapia se hanno conseguito la relativa '
          'specializzazione, ma non è la regola.',
          style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
        ),
      ],
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [content, SizedBox(height: 32)],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(flex: 3, child: content),
                  const SizedBox(width: 48),
                  Expanded(flex: 2, child: image),
                ],
              );
            },
          ),
        ),
      ),
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
      color: const Color(0xFFF0F7F4),
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quando lavorano insieme',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93a996),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'A seconda del bisogno della persona, queste figure possono collaborare tra loro '
                'offrendo un intervento integrato e adeguato alla complessità della situazione. '
                'Non si escludono: spesso la combinazione di psicoterapia e supporto psichiatrico '
                'rappresenta la risposta più efficace.',
                style: TextStyle(
                    fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
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
                            color: const Color(0xFF93a996).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(f.$1,
                              color: const Color(0xFF93a996), size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.$2,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF93a996),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                f.$3,
                                style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.6,
                                    color: Color(0xFF2C2C2C)),
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
