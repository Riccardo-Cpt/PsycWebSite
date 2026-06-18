import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import '../widgets/site_footer.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _HeroHeader(),
            _PrivacySection(),
            _ConsensoSection(),
            _ConsensoMinoriSection(),
            _ChiusuraSection(),
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
          constraints: const BoxConstraints(maxWidth: 900),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy e consenso informato',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93a996),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'La riservatezza e la chiarezza sono elementi fondamentali della relazione '
                'terapeutica. Prima di iniziare un percorso vengono fornite tutte le '
                'informazioni necessarie per una scelta libera e consapevole.',
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

class _PrivacySection extends StatelessWidget {
  const _PrivacySection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93a996),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'La riservatezza è una parte essenziale della relazione terapeutica.',
                style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
              ),
              SizedBox(height: 16),
              Text(
                'Tutte le informazioni condivise durante i colloqui sono trattate con '
                'attenzione e nel rispetto della normativa vigente in materia di protezione '
                'dei dati personali.',
                style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
              ),
              SizedBox(height: 16),
              Text(
                'Prima dell\'avvio del percorso vengono fornite le informazioni necessarie '
                'sul trattamento dei dati e sulle modalità di conservazione della '
                'documentazione professionale.',
                style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsensoSection extends StatelessWidget {
  const _ConsensoSection();

  static const _voci = [
    'Obiettivi del percorso',
    'Modalità di svolgimento',
    'Tempi previsti',
    'Tutela della riservatezza',
    'Aspetti economici',
    'Possibilità di interrompere il percorso',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF9F9F9),
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Consenso informato',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93a996),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Prima dell\'inizio di un percorso psicologico o psicoterapeutico viene '
                'richiesto il consenso informato, che permette alla persona di ricevere '
                'informazioni chiare riguardo a:',
                style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF93a996).withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  children: _voci.map((v) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 7),
                          child: Icon(Icons.circle, size: 8, color: Color(0xFF93a996)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(v,
                              style: const TextStyle(
                                  fontSize: 17,
                                  height: 1.6,
                                  color: Color(0xFF2C2C2C))),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Questo consente una scelta libera, consapevole e informata.',
                style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsensoMinoriSection extends StatelessWidget {
  const _ConsensoMinoriSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consenso informato per i minori',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93a996),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Nel caso di minori, il consenso informato deve essere firmato da entrambi '
                'i genitori esercenti la responsabilità genitoriale, anche se separati o '
                'divorziati, salvo diversa disposizione dell\'autorità competente.',
                style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
              ),
              SizedBox(height: 16),
              Text(
                'Questo aspetto è particolarmente importante nelle situazioni di separazione '
                'familiare e viene discusso con attenzione prima dell\'avvio del percorso.',
                style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChiusuraSection extends StatelessWidget {
  const _ChiusuraSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F7F4),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: const Text(
            'Privacy e consenso informato rappresentano strumenti fondamentali di tutela, '
            'chiarezza e fiducia all\'interno della relazione professionale.',
            style: TextStyle(
              fontSize: 18,
              height: 1.75,
              fontStyle: FontStyle.italic,
              color: Color(0xFF2C2C2C),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
