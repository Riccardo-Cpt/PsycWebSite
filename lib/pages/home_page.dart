// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/contatti.dart';
import '../main.dart';
import '../models/articolo.dart';
import '../models/review.dart';
import '../widgets/site_footer.dart';
import '../widgets/contact_chip.dart';
import '../widgets/nav_bar.dart';
import '../widgets/contact_form_dialog.dart';
import '../widgets/section_image.dart';
import '../widgets/star_rating.dart';

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
            _AdditionalIntro(),
            _MazePicture(),
            _AChiMiRivolgoSection(),
            _ComeLavoroSection(),
            _AreeInterventoSection(),
            _PrimoColloquioBox(),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final minHeight = (screenWidth * (1240 / 1860)).clamp(360.0, 520.0);
    return SizedBox(
      width: double.infinity,
      height: minHeight,
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
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
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
            child: Builder(builder: (context) {
              final isMobile = screenWidth < 600;
              return Padding(
              padding: EdgeInsets.symmetric(vertical: isMobile ? 24 : 50, horizontal: isMobile ? 16 : 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isMobile ? 37 : 20,),
                    Text("Dott. Antonella Petrini",
                                        style: GoogleFonts.montserrat(
                                              fontSize: isMobile ? 35 : 60,
                                              color: const Color(0xFFFFFFF0),
                                              fontWeight: FontWeight.w700,
                                              height: 1.0),
                                    ),
                    SizedBox(height: isMobile ? 15 : 25,),
                    Text("Psicologa Psicoterapeuta",
                      style: GoogleFonts.montserrat(
                            fontSize: isMobile ? 22 : 41,
                            color: const Color(0xFFFFFFF0),
                            fontWeight: FontWeight.w500,
                            height: 0.7),
                    ),
                    SizedBox(height: isMobile ? 16 : 22,),
                    Text(
                      'ESPERA IN PSICOLOGIA DELL\'EMERGENZA',
                      style: GoogleFonts.lato(
                          fontSize: isMobile ? 16 : 22,
                          color: const Color(0xFFFFFFF0),
                          height: 1.5,
                          ),
                    ),
                    SizedBox(height: isMobile ? 4 : 8,),
                    Text(
                      'PER ADULTI, ADOLESCENTI, COPPIE, FAMIGLIE E TERZA ETÀ',
                      style: GoogleFonts.lato(
                          fontSize: isMobile ? 16 : 22,
                          color: const Color(0xFFFFFFF0),
                          height: 1.5,
                          ),
                    ),
                    SizedBox(height: isMobile ? 40 : 60),
                    ElevatedButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const ContactFormDialog(),
                      ),
                      icon: Icon(Icons.calendar_today_outlined, size: 24),
                      label: Text('Richiedi un primo colloquio',
                          style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 31 : 36,
                            vertical: isMobile ? 27 : 32),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 3,
                      ),
                    ),
                  ],
                ),
              ),
            );}),
          ),
        ],
      ),
    );
  }
}

// ── Maze Picture ───────────────────────────────────────────────────────────
class _MazePicture extends StatelessWidget {
  const _MazePicture();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 600;
        return Image.asset(
          'assets/images/MazeDescription.webp',
          width: double.infinity,
          height: isDesktop ? null : (constraints.maxWidth * (1240 / 1860)).clamp(360.0, 520.0),
          fit: isDesktop ? BoxFit.fitWidth : BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        );
      },
    );
  }
}
Widget _buildImage(String imageName, double aspectRatio) =>
    buildSectionImage('assets/images/$imageName', aspectRatio);

// ── Breve intro ───────────────────────────────────────────────────────────
class _AdditionalIntro extends StatelessWidget {
  const _AdditionalIntro();

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chiedere aiuto può rappresentare un passo importante verso una maggiore '
          'comprensione di sé e verso la possibilità di ritrovare equilibrio. '
          'La sofferenza psicologica, quando viene accolta in uno spazio professionale, '
          'può diventare l\'inizio di un lavoro di consapevolezza, trasformazione e cura.',
          style: GoogleFonts.montserrat(
            fontSize: 22,
            height: 1.85,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Nel mio lavoro accolgo persone che attraversano momenti complessi della loro '
          'vita e che sentono il bisogno di essere ascoltate con rispetto, attenzione e '
          'competenza. Ogni percorso nasce dall\'incontro con una storia unica e viene '
          'costruito tenendo conto dei tempi, dei bisogni e delle risorse di ciascuno.',
          style: GoogleFonts.montserrat(
            fontSize: 22,
            height: 1.85,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
    return Container(
      width: double.infinity,
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    content,
                    const SizedBox(height: 32),
                    _buildImage('foto_donna_seduta.webp', 360 / 220),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: content),
                  const SizedBox(width: 40),
                  Expanded(flex: 2, child: _buildImage('foto_donna_seduta.webp', 360 / 280)),
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
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'A chi mi rivolgo',
          style: GoogleFonts.playfairDisplay(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        ..._categorie.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(c.$1, color: AppColors.primary, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.$2,
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text(c.$3,
                        style: GoogleFonts.montserrat(
                            fontSize: 20,
                            height: 1.55,
                            color: AppColors.textDark)),
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
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    content,
                    const SizedBox(height: 32),
                    _buildImage('AlberoVento.webp', 320 / 280),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildImage('AlberoVento.webp', 320 / 300)),
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
        Text(
          'Il primo colloquio',
          style: GoogleFonts.playfairDisplay(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Text(
          'Il primo incontro è uno spazio dedicato all\'ascolto della domanda di aiuto e alla comprensione del bisogno portato.'
          'È un momento utile per iniziare a orientarsi, chiarire eventuali dubbi e valutare insieme il percorso più adatto.',
          style: GoogleFonts.montserrat(fontSize: 22, height: 1.85, color: AppColors.textDark),
        ),
        const SizedBox(height: 10),
        Text(
          'Ogni contatto ed ogni colloquio avvengono in un contesto professionale e riservato, nel rispetto della privacy e della persona.',
          style: GoogleFonts.montserrat(fontSize: 22, height: 1.85, color: AppColors.textDark),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const ContactFormDialog(),
          ),
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text('Richiedi un primo colloquio',
              style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E8494),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 3,
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textContent,
                    const SizedBox(height: 32),
                    _buildImage('flowers_on_table.webp', 210 / 190),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: textContent),
                  const SizedBox(width: 40),
                  Expanded(flex: 2, child: _buildImage('flowers_on_table.webp', 275 / 240)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Come lavoro ────────────────────────────────────────────────────────────────

class _ComeLavoroSection extends StatelessWidget {
  const _ComeLavoroSection();

  static const _pillars = [
    (
      Icons.psychology_outlined,
      'Approccio',
      'Umanistico-relazionale con formazione psicoanalitica contemporanea, centrato sulla persona nella sua unicità.',
    ),
    (
      Icons.handshake_outlined,
      'Relazione terapeutica',
      'Uno spazio fondamentale di ascolto, fiducia e continuità, orientato a costruire un percorso condiviso.',
    ),
    (
      Icons.remove_red_eye_outlined,
      'EMDR',
      'Uno strumento clinico che può essere integrato nel percorso psicoterapeutico per elaborare esperienze traumatiche o emotivamente intense.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Come lavoro',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary),
              ),
              const SizedBox(height: 36),
              LayoutBuilder(
                builder: (context, constraints) {
                  final tiles = _pillars
                      .map((p) => _PillarTile(icon: p.$1, title: p.$2, body: p.$3))
                      .toList();
                  if (constraints.maxWidth < 600) {
                    return Column(
                      children: [
                        for (int i = 0; i < tiles.length; i++) ...[
                          if (i > 0) const SizedBox(height: 16),
                          tiles[i],
                        ],
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < tiles.length; i++) ...[
                        if (i > 0) const SizedBox(width: 20),
                        Expanded(child: tiles[i]),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PillarTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _PillarTile({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(height: 12),
          Text(title,
              style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
          Divider(color: AppColors.primary.withValues(alpha: 0.3), height: 24),
          Text(body,
              style: GoogleFonts.lato(
                  fontSize: 15, height: 1.65, color: AppColors.textDark)),
        ],
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
    (Icons.bedtime_outlined, 'Disturbi del sonno'),
    (Icons.monitor_heart_outlined, 'Sintomi psicofisici'),
    (Icons.work_history_outlined, 'Difficoltà legate al lavoro'),
    (Icons.psychology_outlined, 'Problematiche della personalità'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aree di intervento',
                style: GoogleFonts.playfairDisplay(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Mi occupo del disagio psicologico nelle sue diverse manifestazioni:',
                style: GoogleFonts.montserrat(
                    fontSize: 18,
                    color: AppColors.textDark,
                    ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _aree
                    .map((a) => _AreaChip(icon: a.$1, label: a.$2))
                    .toList(),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      width: 1),
                ),
                child: Text(
                  'Il lavoro clinico può integrare strumenti differenti, scelti in base al bisogno della persona, al momento del percorso e agli obbiettivi condivisi, compreso l\'utilizzo dell\'EMDR quando indicato per l\'elaborazione di esperienze traumatiche o emotivamente stressanti.',
                  style: GoogleFonts.montserrat(
                      fontSize: 15,
                      height: 1.65,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textDark),
                ),
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
            color: AppColors.primary.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 7),
          Text(label,
              style: GoogleFonts.lato(
                  fontSize: 14,
                  color: AppColors.textDark,
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
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Labirinti',
          style: GoogleFonts.playfairDisplay(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.primary),
        ),
        const SizedBox(height: 20),
        Text(
          'In alcuni momenti della vita ci si può sentire smarriti, confusi o intrappolati in passaggi difficili e ripetitivi, come se fosse impossibile trovare una direzione chiara.'
          'Il labirinto rappresenta la metafora di questo percorso interiore: un cammino complesso, a volte faticoso, nel quale il disagio può assumere la forma di qualcosa che si ripete e che sembra non trovare uscita.',
          style: GoogleFonts.montserrat(fontSize: 22, height: 1.75, color: AppColors.textDark),
        ),
        const SizedBox(height: 16),
        Text(
          'La psicoterapia può offrire uno spazio in cui attraversare questo labirinto con maggiore consapevolezza. Non propone scorciatoie, ma aiuta a dare senso ai vissuti, a riconoscere ciò che fa soffrire e a individuare nuove possibilità di cambiamento.',
          style: GoogleFonts.montserrat(fontSize: 22, height: 1.75, color: AppColors.textDark),
        ),
      ],
    );
    return Container(
      width: double.infinity,
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    content,
                    const SizedBox(height: 32),
                    _buildImage('Maze.webp', 360 / 240),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: content),
                  const SizedBox(width: 40, height: 20),
                  Expanded(flex: 2, child: _buildImage('Maze.webp', 380 / 300)),
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
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ultimo articolo pubblicato',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
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
                        color: AppColors.primary),
                    label: const Text(
                      'Leggi tutti i post del blog',
                      style: TextStyle(
                          color: AppColors.primary,
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
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF134456))),
                  const SizedBox(height: 6),
                  Text(corpo,
                      style: GoogleFonts.lato(
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
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Le ultime 3 recensioni',
                    style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        color: AppColors.primary),
                    label: const Text(
                      'Leggi tutte le recensioni',
                      style: TextStyle(
                          color: AppColors.primary,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              review.username,
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            StarRating(stars: review.stars, size: 18),
            const SizedBox(height: 8),
            Text(
              review.title,
              style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.w600,
                  fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              _truncateWords(review.description, 50),
              style: GoogleFonts.lato(
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
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      color: Colors.transparent,
      child: Column(
        children: [
          Text(
            'Inizia il tuo percorso',
            style: GoogleFonts.playfairDisplay(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: AppColors.primary),
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
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                onPressed: () => context.go('/servizi'),
              ),
              _CtaButton(
                icon: Icons.calendar_today_outlined,
                label: 'Contattami',
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const ContactFormDialog(),
                ),
              ),
              _CtaButton(
                icon: Icons.person_3_rounded ,
                label: 'Lo psicoterapeuta',
                backgroundColor: AppColors.primary,
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
            style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
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
          Text('Contatti',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
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
                  color: AppColors.primary,
                  hoverColor: const Color(0xFF134456),
                  onTap: () => chiamaTelefono(Contatti.telefono),
                ),
                ContactChip(
                  icon: Icons.location_on,
                  text: Contatti.indirizzo,
                  color: AppColors.primary,
                  hoverColor: const Color(0xFF134456),
                  onTap: () => apriMappa(Contatti.indirizzo),
                ),
                ContactChip(
                  icon: Icons.email,
                  text: Contatti.email,
                  color: AppColors.primary,
                  hoverColor: const Color(0xFF134456),
                  onTap: () => inviaEmail(Contatti.email),
                ),
                ContactChip(
                  icon: Icons.facebook,
                  text: 'Facebook',
                  color: AppColors.primary,
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