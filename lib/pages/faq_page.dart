import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/nav_bar.dart';
import '../widgets/page_hero_header.dart';
import '../widgets/site_footer.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  static const _faq = [
    (
      'Prima di iniziare',
      Icons.help_outline,
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
      Icons.timeline_outlined,
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
      Icons.psychology_outlined,
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
      Icons.calendar_today_outlined,
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
            const PageHeroHeader(
              title: 'Domande frequenti',
              subtitle: 'Alcune delle domande più comuni sulla psicoterapia, sul percorso terapeutico '
                  'e sugli aspetti pratici. Se hai altre domande, puoi contattarmi direttamente.',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _faq.map((group) => _FaqGroup(
                      title: group.$1,
                      icon: group.$2,
                      items: group.$3,
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

class _FaqGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<(String, String)> items;

  const _FaqGroup({required this.title, required this.icon, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => _FaqTile(question: item.$1, answer: item.$2)),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: _expanded ? 3 : 1,
      shadowColor: AppColors.primary.withValues(alpha: 0.15),
      color: _expanded ? const Color(0xFFCFA090) : const Color(0xFFDEB8AC),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        onExpansionChanged: (v) => setState(() => _expanded = v),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        childrenPadding: EdgeInsets.zero,
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          widget.question,
          style: GoogleFonts.lato(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: AppColors.primary),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    child: Text(
                      widget.answer,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        height: 1.75,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
