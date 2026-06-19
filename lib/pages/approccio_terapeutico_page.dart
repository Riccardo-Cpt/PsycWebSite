import 'package:flutter/material.dart';
import '../widgets/contact_form_dialog.dart';
import '../widgets/nav_bar.dart';
import '../widgets/site_footer.dart';

class ApproccioTerapeuticoPage extends StatelessWidget {
  const ApproccioTerapeuticoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _HeroHeader(),
            _CentralitaPersonaSection(),
            _RelazioneSection(),
            _PercorsoSection(),
            _CambiamentoSection(),
            _EmdrSection(),
            _CtaSection(),
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
                'Approccio terapeutico',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93a996),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Il lavoro terapeutico nasce dall\'incontro con una storia unica. '
                'Non esiste un percorso standard: ogni cammino viene costruito '
                'con rispetto dei tempi, delle risorse e della specificità di ciascuno.',
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

class _CentralitaPersonaSection extends StatelessWidget {
  const _CentralitaPersonaSection();

  @override
  Widget build(BuildContext context) {
    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'La centralità della persona',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF93a996)),
        ),
        const SizedBox(height: 12),
        const Text(
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
          style: TextStyle(fontSize: 18, height: 1.7, color: Color(0xFF2C2C2C)),
        ),
        const SizedBox(height: 16),
      ],
    );

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 400 / 380,
        child: Image.asset(
          'assets/images/NinfeeStagno.jpeg',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [textContent, const SizedBox(height: 32), image],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: textContent),
                  const SizedBox(width: 40),
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

class _RelazioneSection extends StatelessWidget {
  const _RelazioneSection();

  @override
  Widget build(BuildContext context) {
    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'La relazione terapeutica',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF93a996)),
        ),
        const SizedBox(height: 12),
        const Text(
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
          style: TextStyle(fontSize: 18, height: 1.7, color: Color(0xFF2C2C2C)),
        ),
        const SizedBox(height: 16),
      ],
    );
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 400 / 380,
        child: Image.asset(
          'assets/images/TaleaPiantaGrassa.jpeg',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [textContent, const SizedBox(height: 32), image],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: image),
                  const SizedBox(width: 40),
                  Expanded(flex: 3, child: textContent),
                ],
              );
            },
          ),
        ),
      ),
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
        const Text(
          'La centralità della persona',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF93a996)),
        ),
        const SizedBox(height: 12),
        const Text(
            'La psicoterapia non è una risposta standard a un sintomo, ma un percorso '
            'costruito insieme, che tiene conto dei tempi, delle risorse, delle fragilità '
            'e delle possibilità di cambiamento di ciascuno.'
            'I primi incontri sono dedicati alla comprensione della richiesta e alla '
            'valutazione condivisa del percorso più adatto. Non si parte con un programma '
            'già definito, ma con la disponibilità a costruirlo insieme, incontro dopo incontro.'
            'La durata e l\'intensità del lavoro vengono valutate in modo flessibile, '
            'in relazione all\'evoluzione della situazione e agli obiettivi condivisi.',
          style: TextStyle(fontSize: 18, height: 1.7, color: Color(0xFF2C2C2C)),
        ),
        const SizedBox(height: 16),
      ],
    );

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 400 / 380,
        child: Image.asset(
          'assets/images/fallingLeaves.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [textContent, const SizedBox(height: 32), image],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: textContent),
                  const SizedBox(width: 40),
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
      color: const Color(0xFFF0F7F4),
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cambiamento e consapevolezza',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93a996),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'L\'obiettivo del lavoro terapeutico è aiutare la persona ad avvicinarsi a sé stessa '
                'con maggiore chiarezza, a riconoscere ciò che la muove e ciò che la trattiene, '
                'e a trovare una direzione più autentica.',
                style: TextStyle(
                    fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
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
                            color: const Color(0xFF93a996).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item.$1,
                              color: const Color(0xFF93a996), size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              item.$2,
                              style: const TextStyle(
                                  fontSize: 17,
                                  height: 1.6,
                                  color: Color(0xFF2C2C2C)),
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
                      color: const Color(0xFF93a996),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'EMDR',
                      style: TextStyle(
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
              const Text(
                'Eye Movement Desensitization and Reprocessing',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93a996),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tra gli strumenti clinici che utilizzo vi è anche l\'EMDR, un approccio '
                'terapeutico riconosciuto dall\'OMS e utilizzato in particolare per '
                'l\'elaborazione di esperienze traumatiche o emotivamente molto intense.',
                style: TextStyle(
                    fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Può essere utile quando alcuni eventi del passato continuano a produrre '
                'sofferenza nel presente, manifestandosi attraverso:',
                style: TextStyle(
                    fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7F4),
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
                                      color: Color(0xFF93a996)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(s,
                                      style: const TextStyle(
                                          fontSize: 17,
                                          height: 1.6,
                                          color: Color(0xFF2C2C2C))),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'L\'integrazione dell\'EMDR all\'interno del percorso psicoterapeutico viene '
                'valutata in base al bisogno della persona, alla fase del lavoro clinico e agli '
                'obiettivi condivisi. Non si tratta di una tecnica applicata in modo automatico, '
                'ma di uno strumento inserito con attenzione e competenza all\'interno di un '
                'percorso costruito su misura.',
                style: TextStyle(
                    fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CtaSection extends StatelessWidget {
  const _CtaSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF93a996),
      child: Stack(
        children: [
        LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;
              return SizedBox(
                width: double.infinity,
                height: isWide ? 390 : 330,
                child: Image.asset(
                  'assets/images/germinatingPlants.jpg',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              );
            },
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.50),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
            child: Center(
              child: Column(
                children: [
                  const Text(
                    'Hai domande sul percorso?',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Il primo colloquio è uno spazio di ascolto senza impegno, '
                    'per cominciare a orientarsi insieme.',
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.65,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const ContactFormDialog(),
                    ),
                    icon: const Icon(Icons.calendar_today_outlined,
                        color: Colors.white),
                    label: const Text(
                      'Richiedi un primo colloquio',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
