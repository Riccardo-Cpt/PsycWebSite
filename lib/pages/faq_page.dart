import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import '../widgets/site_footer.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  static const _faq = [
    (
      'Prima di iniziare',
      [
        (
          'Quando può essere utile rivolgersi a uno psicoterapeuta?',
          'Può essere utile quando si sta attraversando un periodo di sofferenza, difficoltà relazionali, '
          'cambiamenti importanti, momenti di crisi o quando si sente il bisogno di comprendere più '
          'profondamente se stessi e il proprio modo di vivere le esperienze.',
        ),
        (
          'Come funziona il primo colloquio?',
          'Il primo colloquio rappresenta uno spazio di ascolto e conoscenza reciproca. Permette di '
          'comprendere la richiesta portata dalla persona, chiarire eventuali dubbi e valutare insieme '
          'il percorso più adatto.',
        ),
        (
          'È necessario stare molto male per iniziare?',
          'No. Molte persone si rivolgono a uno psicoterapeuta non solo in presenza di un forte disagio, '
          'ma anche per affrontare momenti di cambiamento, prendere decisioni importanti o approfondire '
          'la conoscenza di sé.',
        ),
      ],
    ),
    (
      'Sul percorso terapeutico',
      [
        (
          'Quanto dura un percorso?',
          'La durata varia in base alla situazione, agli obiettivi e ai bisogni della persona. '
          'Ogni percorso viene costruito in modo personalizzato.',
        ),
        (
          'Come si capisce se la psicoterapia è adatta?',
          'Attraverso i primi incontri è possibile valutare insieme la natura della difficoltà e '
          'comprendere quale tipo di intervento possa essere maggiormente utile.',
        ),
        (
          'Quali obiettivi può avere?',
          'Gli obiettivi possono riguardare la riduzione della sofferenza, la comprensione dei propri '
          'vissuti, il miglioramento delle relazioni, lo sviluppo delle risorse personali e una '
          'maggiore consapevolezza di sé.',
        ),
      ],
    ),
    (
      'Dubbi frequenti',
      [
        (
          'Qual è la differenza tra psicologo e psicoterapeuta?',
          'Lo psicoterapeuta è uno psicologo o un medico che ha completato una specifica '
          'specializzazione quadriennale in psicoterapia.',
        ),
        (
          'Posso interrompere il percorso?',
          'Sì. La persona può interrompere il percorso in qualsiasi momento, possibilmente '
          'condividendo la propria decisione all\'interno del lavoro terapeutico.',
        ),
        (
          'La psicoterapia è utile anche senza un disturbo grave?',
          'Sì. La psicoterapia può rappresentare uno spazio di crescita, riflessione e sostegno '
          'anche in assenza di una diagnosi psicopatologica.',
        ),
      ],
    ),
    (
      'Aspetti pratici',
      [
        (
          'Come prenotare?',
          'È possibile richiedere informazioni o concordare un appuntamento attraverso i recapiti '
          'indicati nella pagina Contatti.',
        ),
        (
          'Come si svolgono gli incontri?',
          'Gli incontri si svolgono in uno spazio professionale e riservato, nel rispetto della '
          'privacy e delle esigenze della persona.',
        ),
        (
          'Quali informazioni vengono fornite all\'inizio del percorso?',
          'Prima dell\'avvio vengono illustrati obiettivi, modalità di lavoro, tutela della '
          'riservatezza, aspetti organizzativi ed economici.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return NavScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _HeroHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _faq.map((group) => _FaqGroup(
                      title: group.$1,
                      items: group.$2,
                    )).toList(),
                  ),
                ),
              ),
            ),
            const SiteFooter(),
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
                'Domande frequenti',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93a996),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Alcune delle domande più comuni sulla psicoterapia, sul percorso terapeutico '
                'e sugli aspetti pratici. Se hai altre domande, puoi contattarmi direttamente.',
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

class _FaqGroup extends StatelessWidget {
  final String title;
  final List<(String, String)> items;

  const _FaqGroup({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40, bottom: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF93a996),
            ),
          ),
        ),
        ...items.map((item) => _FaqTile(question: item.$1, answer: item.$2)),
      ],
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF93a996).withValues(alpha: 0.25),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        childrenPadding:
            const EdgeInsets.fromLTRB(20, 0, 20, 20),
        iconColor: const Color(0xFF93a996),
        collapsedIconColor: const Color(0xFF93a996),
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C2C2C),
          ),
        ),
        children: [
          Text(
            answer,
            style: const TextStyle(
              fontSize: 16,
              height: 1.7,
              color: Color(0xFF4A4A4A),
            ),
          ),
        ],
      ),
    );
  }
}
