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
              'assets/images/NinfeeStagnoOpache.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          // Soft overlay so text stays readable
          Positioned.fill(
            child: Container(color: Colors.white.withValues(alpha: 0.10)),
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
                          color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Psicologa e Psicoterapeuta per adulti, adolescenti, coppie e famiglie',
                      style: TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Uno spazio di ascolto professionale, riservato e accogliente per chi sta attraversando un momento di difficoltà, sofferenza o cambiamento.',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
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
                                fontSize: 16, fontWeight: FontWeight.bold)),
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

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;
              final imageWidget = ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/NinfeeStagno.jpeg',
                  width: 340,
                  height: 420,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              );
              final textWidget = Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.75,
                  color: Color(0xFF2C2C2C),
                ),
              );

              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    imageWidget,
                    const SizedBox(height: 32),
                    textWidget,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: textWidget),
                  const SizedBox(width: 48),
                  imageWidget,
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
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F7F4),
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;
              final imageWidget = ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/AlberoVento.jpeg',
                  width: 320,
                  height: 400,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              );
              final contentWidget = Column(
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

              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    contentWidget,
                    const SizedBox(height: 36),
                    Center(child: imageWidget),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imageWidget,
                  const SizedBox(width: 48),
                  Expanded(child: contentWidget),
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
    const textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Il primo colloquio',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF93a996)),
        ),
        SizedBox(height: 20),
        Text(
          'Il primo incontro è uno spazio dedicato all\'ascolto della domanda di aiuto e alla comprensione del bisogno portato.',
          style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
        ),
        SizedBox(height: 16),
        Text(
          'È un momento utile per iniziare a orientarsi, chiarire eventuali dubbi e valutare insieme il percorso più adatto.',
          style: TextStyle(fontSize: 18, height: 1.75, color: Color(0xFF2C2C2C)),
        ),
      ],
    );

    final imageWidget = ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(
        'assets/images/SassoParticolare.jpeg',
        width: 320,
        height: 380,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
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
              final isWide = constraints.maxWidth >= 720;
              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textContent,
                    const SizedBox(height: 32),
                    Center(child: imageWidget),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: textContent),
                  const SizedBox(width: 48),
                  imageWidget,
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
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 19),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Aree di intervento',
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
                    'Dal blog',
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
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 32),
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
                label: 'Richiedi un primo colloquio',
                backgroundColor: const Color(0xFF93a996),
                foregroundColor: Colors.white,
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const ContactFormDialog(),
                ),
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
