import 'package:flutter/material.dart';
import '../widgets/contact_form_dialog.dart';
import '../widgets/nav_bar.dart';
import '../widgets/site_footer.dart';

class PsicoterapiaPage extends StatelessWidget {
  const PsicoterapiaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _HeroHeader(),
            _CosESection(),
            _QuandoSection(),
            _ComeSiSvolgeSection(),
            _ObiettiviSection(),
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
                'Psicoterapia',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93a996),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'La psicoterapia è un percorso di cura e conoscenza di sé che aiuta a '
                'comprendere il significato del disagio psicologico, dei sintomi e delle '
                'difficoltà relazionali.',
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

class _CosESection extends StatelessWidget {
  const _CosESection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Che cos\'è la psicoterapia',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF93a996),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'La psicoterapia è un percorso di cura che si sviluppa attraverso la '
                      'relazione tra terapeuta e persona, nel tempo e nello spazio del colloquio.',
                      style: TextStyle(
                          fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Non si tratta di ricevere consigli o soluzioni preconfezionate, ma di '
                      'costruire insieme una comprensione più profonda di ciò che si vive, '
                      'di come ci si muove nelle relazioni e di ciò che alimenta la sofferenza.',
                      style: TextStyle(
                          fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'È un lavoro che richiede tempo, fiducia e disponibilità ad osservare '
                      'se stessi con onestà e curiosità. Il cambiamento che ne può nascere '
                      'è autentico, radicato nella propria storia e nelle proprie risorse.',
                      style: TextStyle(
                          fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 340 / 420,
                    child: Image.asset(
                      'assets/images/Arcobaleno.jpeg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
    return Container(
      width: double.infinity,
      color: const Color(0xFFF9F9F9),
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 320 / 400,
                    child: Image.asset(
                      'assets/images/fallingLeaves.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quando può essere utile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF93a996),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'La psicoterapia può essere utile in presenza di:',
                      style: TextStyle(
                          fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
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
                                    size: 8, color: Color(0xFF93a996)),
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
                        )),
                    const SizedBox(height: 8),
                    const Text(
                      'Non è necessario stare molto male per iniziare: molte persone '
                      'si rivolgono alla psicoterapia anche per affrontare momenti di '
                      'cambiamento, prendere decisioni importanti o approfondire la '
                      'conoscenza di sé.',
                      style: TextStyle(
                          fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComeSiSvolgeSection extends StatelessWidget {
  const _ComeSiSvolgeSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Come si svolge il percorso',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF93a996),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Ogni percorso viene costruito in modo personalizzato, nel rispetto '
                      'della storia, dei tempi e delle caratteristiche della persona.',
                      style: TextStyle(
                          fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'I primi incontri sono dedicati alla conoscenza reciproca, alla '
                      'comprensione della richiesta e alla valutazione condivisa del '
                      'percorso più adatto. Non si parte con un programma già definito, '
                      'ma con la disponibilità ad ascoltare e a costruire insieme.',
                      style: TextStyle(
                          fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'La relazione terapeutica diventa uno spazio in cui comprendere, '
                      'elaborare e trasformare il disagio. La durata e l\'intensità del '
                      'lavoro vengono valutate in modo flessibile, in relazione '
                      'all\'evoluzione della situazione e agli obiettivi condivisi.',
                      style: TextStyle(
                          fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48),
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 340 / 420,
                    child: Image.asset(
                      'assets/images/lilium.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
      color: const Color(0xFFF0F7F4),
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Obiettivi del lavoro terapeutico',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93a996),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'L\'obiettivo non è soltanto ridurre la sofferenza, ma favorire una '
                'trasformazione più profonda e duratura.',
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
                            color: const Color(0xFF93a996)
                                .withValues(alpha: 0.15),
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
                height: 380,
                child: isWide
                    ? Center(
                        child: SizedBox(
                          width: 800,
                          height: 380,
                          child: Image.asset(
                            'assets/images/NinfeeStagno2.jpeg',
                            fit: BoxFit.fill,
                            errorBuilder: (_, _, _) => const SizedBox.shrink(),
                          ),
                        ),
                      )
                    : Image.asset(
                        'assets/images/NinfeeStagno2.jpeg',
                        width: double.infinity,
                        height: 380,
                        fit: BoxFit.fill,
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
            padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
            child: Center(
              child: Column(
                children: [
                  const Text(
                    'Vuoi sapere se la psicoterapia fa per te?',
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
