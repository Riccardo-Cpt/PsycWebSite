// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/contatti.dart';
import '../main.dart';
import '../models/articolo.dart';
import '../models/review.dart';
import '../widgets/site_footer.dart';
import '../widgets/contact_chip.dart';
import '../widgets/nav_bar.dart';
import '../widgets/contact_form_dialog.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavScaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(),
            _IntroSection(),
            _AChiMiRivolgoSection(),
            _PrimoColloquioBox(),
            _AreeInterventoSection(),
            _LabirintiSection(),
            _UltimoArticoloSection(),
            _UltimeRecensioniSection(),
            _CtaSection(),
            _ContactFooter(),
            const SiteFooter(),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatefulWidget {
  const _HeroSection();

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _leftDx;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _leftDx = Tween<double>(begin: -60, end: 0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    // Start after first frame so the initial offset is visible before animating
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/NinfeeStagnoOpache.webp',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          // Soft overlay so text stays readable
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.4)),
          ),
          // Content
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) => Opacity(
              opacity: _fade.value,
              child: Transform.translate(
                offset: Offset(_leftDx.value, 0),
                child: child,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dr.ssa Maria Bianchi',
                      style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF5F5F5)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Psicologa e Psicoterapeuta per adulti, adolescenti, coppie e famiglie',
                      style: TextStyle(
                          fontSize: 26,
                          color: Color(0xFFFFFFF0),
                          fontWeight: FontWeight.w500,
                          height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Uno spazio di ascolto professionale, riservato e accogliente per chi sta attraversando un momento di difficoltà, sofferenza o cambiamento.',
                      style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFFFFFFF0),
                          height: 1.6),
                    ),
                      const SizedBox(height: 50),
                      ElevatedButton.icon(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => const ContactFormDialog(),
                        ),
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: const Text('Richiedi un primo colloquio',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF93a996),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 36, vertical: 28),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 3,
                        ),
                      ),
                    ],
                  ),
                ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Intro section ──────────────────────────────────────────────────────────────

class _IntroSection extends StatelessWidget {
  const _IntroSection();

  @override
  Widget build(BuildContext context) {
    const text = 'Ci sono momenti della vita in cui tutto può sembrare più faticoso: '
        'le relazioni si complicano, l\'ansia prende spazio, il dolore emotivo diventa difficile da sostenere '
        'o ci si sente semplicemente smarriti.\n\n'
        'In questi momenti, chiedere aiuto può rappresentare un passo importante verso una maggiore comprensione '
        'di sé e verso la possibilità di ritrovare equilibrio.\n\n'
        'Nel mio studio offro uno spazio di ascolto professionale, riservato e accogliente, in cui la persona '
        'possa sentirsi riconosciuta nella propria esperienza e accompagnata con rispetto, sensibilità e competenza.\n\n'
        'Il percorso psicologico o psicoterapeutico nasce dall\'incontro con una storia unica e viene costruito '
        'con attenzione ai tempi, ai bisogni e alla specificità di ciascuno.';

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 340 / 420,
        child: Image.asset(
          'assets/images/fotodonna.webp',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
    final textWidget = Text(
      text,
      style: const TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
    );
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [textWidget, const SizedBox(height: 32), image],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: textWidget),
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

// ── A chi mi rivolgo ───────────────────────────────────────────────────────────

class _AChiMiRivolgoSection extends StatelessWidget {
  const _AChiMiRivolgoSection();

  static const _categorie = [
    (Icons.person_outline, 'Adulti',
        'Adulti che attraversano momenti di difficoltà, crisi personali, sofferenza emotiva, problemi relazionali o passaggi delicati del ciclo di vita.'),
    (Icons.school_outlined, 'Adolescenti',
        'Adolescenti che vivono fragilità, difficoltà scolastiche, crisi identitarie, conflitti familiari o ansia durante questa fase della crescita.'),
    (Icons.people_outline, 'Coppie e famiglie',
        'Coppie e famiglie che attraversano conflitti, difficoltà comunicative, crisi affettive o momenti di trasformazione.'),
    (Icons.timeline_outlined, 'Crisi del ciclo di vita',
        'Fasi delicate come adolescenza, maternità, genitorialità, crisi affettive, lutto, traumi, menopausa e stress lavorativo.'),
  ];

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 320 / 400,
        child: Image.asset(
          'assets/images/AlberoVento.webp',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'A chi mi rivolgo',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF93a996),
          ),
        ),
        const SizedBox(height: 24),
        ..._categorie.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(c.$1, color: const Color(0xFF93a996), size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.$2,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Color(0xFF93a996))),
                    const SizedBox(height: 4),
                    Text(c.$3,
                        style: const TextStyle(
                            fontSize: 16,
                            height: 1.55,
                            color: Color(0xFF2C2C2C))),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F7F4),
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [content, const SizedBox(height: 32), image],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: image),
                  const SizedBox(width: 40),
                  Expanded(flex: 3, child: content),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Primo colloquio box ────────────────────────────────────────────────────────

class _PrimoColloquioBox extends StatelessWidget {
  const _PrimoColloquioBox();

  @override
  Widget build(BuildContext context) {
    final textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Il primo colloquio',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF93a996)),
        ),
        const SizedBox(height: 12),
        const Text(
          'Il primo incontro è uno spazio dedicato all\'ascolto della domanda di aiuto e alla comprensione del bisogno portato.',
          style: TextStyle(fontSize: 18, height: 1.7, color: Color(0xFF2C2C2C)),
        ),
        const SizedBox(height: 10),
        const Text(
          'È un momento utile per iniziare a orientarsi, chiarire eventuali dubbi e valutare insieme il percorso più adatto.',
          style: TextStyle(fontSize: 18, height: 1.7, color: Color(0xFF2C2C2C)),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const ContactFormDialog(),
          ),
          icon: const Icon(Icons.calendar_today_outlined),
          label: const Text('Richiedi un primo colloquio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E8494),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 3,
          ),
        ),
      ],
    );

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 400 / 380,
        child: Image.asset(
          'assets/images/SassoParticolare.webp',
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

// ── Aree di intervento ─────────────────────────────────────────────────────────

class _AreeInterventoSection extends StatelessWidget {
  const _AreeInterventoSection();

  static const _aree = [
    (Icons.air, 'Ansia'),
    (Icons.flash_on_outlined, 'Attacchi di panico'),
    (Icons.work_outline, 'Stress'),
    (Icons.cloud_outlined, 'Vissuti depressivi'),
    (Icons.favorite_border, 'Lutto'),
    (Icons.shield_outlined, 'Traumi'),
    (Icons.people_outline, 'Difficoltà relazionali e affettive'),
    (Icons.family_restroom_outlined, 'Conflitti di coppia e familiari'),
    (Icons.school_outlined, 'Fragilità adolescenziali'),
    (Icons.lock_clock_outlined, 'Dipendenze'),
    (Icons.spa_outlined, 'Problematiche della sessualità'),
    (Icons.restaurant_menu_outlined, 'Disturbi alimentari'),
    (Icons.timeline_outlined, 'Crisi del ciclo di vita'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F7F4),
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aree di lavoro',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF93a996)),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _aree
                    .map((a) => _AreaChip(icon: a.$1, label: a.$2))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AreaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _AreaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: const Color(0xFF93a996).withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF93a996)),
          const SizedBox(width: 7),
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2C2C2C),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Labirinti section ──────────────────────────────────────────────────────────

class _LabirintiSection extends StatelessWidget {
  const _LabirintiSection();

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 360 / 420,
        child: Image.asset(
          'assets/images/Maze.png',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
    const content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Labirinti',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF93a996)),
        ),
        SizedBox(height: 20),
        Text(
          'In alcuni momenti della vita ci si può sentire smarriti. La psicoterapia può offrire uno spazio in cui attraversare questo labirinto con maggiore consapevolezza.',
          style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
        ),
        SizedBox(height: 16),
        Text(
          'Il disagio psicologico può assumere la forma di un cammino complesso, faticoso, a tratti senza uscita apparente. Non si tratta di debolezza, ma di un segnale che qualcosa chiede attenzione e cura.',
          style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
        ),
        SizedBox(height: 16),
        Text(
          'La psicoterapia non propone scorciatoie, ma aiuta a dare senso ai propri vissuti, a riconoscere ciò che si ripete e ciò che fa soffrire, e a ritrovare una direzione più autentica. Anche nei momenti di maggiore smarrimento può aprirsi la possibilità di un incontro più profondo con se stessi.',
          style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
        ),
      ],
    );
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F7F4),
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
                  const SizedBox(width: 40),
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

class _UltimoArticoloSection extends StatefulWidget {
  const _UltimoArticoloSection();

  @override
  State<_UltimoArticoloSection> createState() => _UltimoArticoloSectionState();
}

class _UltimoArticoloSectionState extends State<_UltimoArticoloSection> {
  late final Future<List<Articolo>> _futureArticoli;

  static String _truncate(String text) {
    final words = text.split(RegExp(r'\s+'));
    if (words.length <= 50) return text;
    return '${words.take(50).join(' ')}…';
  }

  static String _formatDate(DateTime? d) {
    if (d == null) return '';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  @override
  void initState() {
    super.initState();
    _futureArticoli = articoliService.tutti();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Articolo>>(
      future: _futureArticoli,
      builder: (context, snapshot) {
        final articoli = (snapshot.data ?? []).take(3).toList();
        if (articoli.isEmpty) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ultimo articolo pubblicato',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF93a996)),
                  ),
                  const SizedBox(height: 24),
                  ...articoli.map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _ArticoloCard(
                          articolo: a,
                          dataTesto: _formatDate(a.pubblicatoAt),
                          corpo: _truncate(a.corpo),
                        ),
                      )),
                  const SizedBox(height: 4),
                  TextButton.icon(
                    onPressed: () => context.go('/articoli'),
                    icon: const Icon(Icons.arrow_forward,
                        color: Color(0xFF93a996)),
                    label: const Text(
                      'Leggi tutti i post del blog',
                      style: TextStyle(
                          color: Color(0xFF93a996),
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ArticoloCard extends StatelessWidget {
  final Articolo articolo;
  final String dataTesto;
  final String corpo;
  const _ArticoloCard(
      {required this.articolo,
      required this.dataTesto,
      required this.corpo});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (articolo.immagineUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  articolo.immagineUrl!,
                  width: 100,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dataTesto.isNotEmpty)
                    Text(dataTesto,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black45)),
                  const SizedBox(height: 4),
                  Text(articolo.titolo,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF134456))),
                  const SizedBox(height: 6),
                  Text(corpo,
                      style: const TextStyle(
                          fontSize: 14, height: 1.6, color: Colors.black87)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UltimeRecensioniSection extends StatefulWidget {
  const _UltimeRecensioniSection();

  @override
  State<_UltimeRecensioniSection> createState() =>
      _UltimeRecensioniSectionState();
}

class _UltimeRecensioniSectionState extends State<_UltimeRecensioniSection> {
  late final Future<List<Review>> _futureReviews;

  @override
  void initState() {
    super.initState();
    _futureReviews = reviewsService.tutti();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: _futureReviews,
      builder: (context, snapshot) {
        final reviews = (snapshot.data ?? []).take(3).toList();
        if (snapshot.connectionState == ConnectionState.waiting ||
            reviews.isEmpty) {
          return const SizedBox.shrink();
        }
        return Container(
          width: double.infinity,
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Le ultime 3 recensioni',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF93a996)),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 600;
                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < reviews.length; i++) ...[
                              if (i > 0) const SizedBox(width: 16),
                              Expanded(child: _ReviewPreviewCard(reviews[i])),
                            ],
                          ],
                        );
                      }
                      return Column(
                        children: reviews
                            .map((r) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _ReviewPreviewCard(r),
                                ))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () => context.go('/recensioni'),
                    icon: const Icon(Icons.arrow_forward,
                        color: Color(0xFF93a996)),
                    label: const Text(
                      'Leggi tutte le recensioni',
                      style: TextStyle(
                          color: Color(0xFF93a996),
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

String _truncateWords(String text, int maxWords) {
  final words = text.split(RegExp(r'\s+'));
  if (words.length <= maxWords) return text;
  return '${words.take(maxWords).join(' ')}…';
}

class _ReviewPreviewCard extends StatelessWidget {
  final Review review;
  const _ReviewPreviewCard(this.review);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              review.username,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                for (int i = 1; i <= 5; i++)
                  Icon(
                    i <= review.stars ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFC107),
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              review.title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              _truncateWords(review.description, 50),
              style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                  color: Colors.black87),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 60),
      color: Colors.transparent,
      child: Column(
        children: [
          const Text(
            'Inizia il tuo percorso',
            style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: Color(0xFF93a996)),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _CtaButton(
                icon: Icons.psychology,
                label: 'Di cosa mi occupo',
                backgroundColor: const Color(0xFF93a996),
                foregroundColor: Colors.white,
                onPressed: () => context.go('/servizi'),
              ),
              _CtaButton(
                icon: Icons.calendar_today_outlined,
                label: 'Contattami',
                backgroundColor: const Color(0xFF93a996),
                foregroundColor: Colors.white,
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const ContactFormDialog(),
                ),
              ),
              _CtaButton(
                icon: Icons.person_3_rounded ,
                label: 'Lo psicoterapeuta',
                backgroundColor: const Color(0xFF93a996),
                foregroundColor: Colors.white,
                onPressed: () => context.go('/figure-professionali'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  const _CtaButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 70,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 28),
        label: Text(label,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5)),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 4,
          shadowColor: Colors.black38,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        ),
      ),
    );
  }
}

// ── Contact footer ─────────────────────────────────────────────────────────────

class _ContactFooter extends StatelessWidget {
  const _ContactFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      color: Colors.transparent,
      child: Column(
        children: [
          const Text('Contatti',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93a996))),
          const SizedBox(height: 24),
          SelectionArea(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 32,
              runSpacing: 16,
              children: [
                ContactChip(
                  icon: Icons.phone,
                  text: Contatti.telefono,
                  color: const Color(0xFF93a996),
                  hoverColor: const Color(0xFF134456),
                  onTap: () => chiamaTelefono(Contatti.telefono),
                ),
                ContactChip(
                  icon: Icons.location_on,
                  text: Contatti.indirizzo,
                  color: const Color(0xFF93a996),
                  hoverColor: const Color(0xFF134456),
                  onTap: () => apriMappa(Contatti.indirizzo),
                ),
                ContactChip(
                  icon: Icons.email,
                  text: Contatti.email,
                  color: const Color(0xFF93a996),
                  hoverColor: const Color(0xFF134456),
                  onTap: () => inviaEmail(Contatti.email),
                ),
                ContactChip(
                  icon: Icons.facebook,
                  text: 'Facebook',
                  color: const Color(0xFF93a996),
                  hoverColor: const Color(0xFF134456),
                  onTap: () => launchUrl(Uri.parse(Contatti.facebook),
                      webOnlyWindowName: '_blank'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}