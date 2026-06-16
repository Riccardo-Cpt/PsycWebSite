// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/contatti.dart';
import '../main.dart';
import '../models/articolo.dart';
import '../models/review.dart';
import '../widgets/contact_chip.dart';
import '../widgets/nav_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavScaffold(
      backgroundColor: Colors.transparent,
      body: const SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(),
            _CitazioneSofaSection(),
            _ValoriSection(),
            _UltimoArticoloSection(),
            _UltimeRecensioniSection(),
            _CitazioneSection(),
            _CtaSection(),
            _ContactFooter(),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 420),
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;

          final textContent = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dr.ssa Maria Bianchi',
                style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E6370)),
              ),
              const Text(
                'Psicologa e Psicoterapeuta',
                style: TextStyle(
                    fontSize: 30,
                    color: Color(0xFF2E8494),
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 35),
              Text(
                'Offro un percorso terapeutico personalizzato in un ambiente '
                'sicuro e accogliente. Mi occupo di terapia individuale, di coppia '
                'e di interventi specialistici per situazioni specifiche.',
                style: TextStyle(
                    fontSize: 24,
                    color: const Color(0xFF134456).withValues(alpha: 0.85),
                    height: 1.6),
              ),
            ],
          );

          if (!isWide) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 72, horizontal: 32),
              child: textContent,
            );
          }

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 72, horizontal: 32),
                    child: textContent,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: SizedBox(
                    width: 330,
                    height: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/foto_psicologa.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CitazioneSofaSection extends StatelessWidget {
  const _CitazioneSofaSection();

  static const _brown = Color(0xFF922B05);
  // Image dimensions (centred, straddles transparent/brown boundary)
  static const _imgW = 440.0;
  static const _imgH = 500.0;
  // splitH = 0.25 * totalH; imgTop = splitH - imgH/2 must be >= 0
  // → totalH >= 2*imgH = 1000. Use 860 with splitH bumped to keep imgTop >= 0.
  // Split at 30% gives: splitH=258, imgTop=258-250=8 ✓; quote ends ~8+500+32+~130=670 ✓
  static const _totalH = 860.0;
  static const _splitH = _totalH * 0.30; // = 258

  @override
  Widget build(BuildContext context) {
    // imgTop = splitH - imgH/2 = 230 - 210 = 20 (small transparent gap above)
    const imgTop = _splitH - _imgH / 2;

    return SizedBox(
      width: double.infinity,
      height: _totalH,
      child: Stack(
        children: [
          // Background: hard stop at 25% — transparent above, solid below
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.30, 0.30, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    _brown,
                    _brown,
                  ],
                ),
              ),
            ),
          ),
          // Image — centred, straddles the boundary
          Positioned(
            top: imgTop,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/images/PychologistSatOnSofa.jpg',
                  width: _imgW,
                  height: _imgH,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (_, _, _) =>
                      Container(width: _imgW, height: _imgH, color: _brown),
                ),
              ),
            ),
          ),
          // Quote — centred, fully below the image, inside the brown band
          Positioned(
            top: imgTop + _imgH + 32,
            left: 0,
            right: 0,
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.format_quote, color: Color(0xFFEAC4B0), size: 56),
                  SizedBox(height: 14),
                  Text(
                    'Il tuo benessere\nè la mia aspirazione\ndi vita',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontStyle: FontStyle.italic,
                      height: 1.7,
                      fontWeight: FontWeight.w600,
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

class _ValoriSection extends StatelessWidget {
  const _ValoriSection();

  static const _valori = [
    (Icons.favorite, 'Empatia e ascolto',
        'Ogni persona è ascoltata senza giudizio in un ambiente sicuro e accogliente.'),
    (Icons.lock, 'Riservatezza assoluta',
        'Il segreto professionale è un pilastro fondamentale del rapporto terapeutico.'),
    (Icons.science, 'Approccio basato sull\'evidenza',
        'Tecniche validate scientificamente adattate alle esigenze del singolo.'),
    (Icons.spa, 'Spazio sicuro',
        'Un luogo fisico e mentale dove esprimersi liberamente senza timore.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
          alignment: Alignment.center,
          color: Colors.transparent,
          child: const Text(
            'I miei valori',
            style: TextStyle(
              fontSize: 45,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E6370),
            ),
          ),
        ),
        ...List.generate(_valori.length, (i) {
          final v = _valori[i];
          return _ValoreRow(
            icon: v.$1,
            titolo: v.$2,
            descrizione: v.$3,
            tinted: i.isOdd,
            iconOnLeft: i.isEven,
          );
        }),
      ],
    );
  }
}

class _ValoreRow extends StatelessWidget {
  static const _tintBg = Color(0x1F1E6370); // ~12% opacity of 0xFF1E6370

  final IconData icon;
  final String titolo;
  final String descrizione;
  final bool tinted;
  final bool iconOnLeft;

  const _ValoreRow({
    required this.icon,
    required this.titolo,
    required this.descrizione,
    required this.tinted,
    required this.iconOnLeft,
  });

  @override
  Widget build(BuildContext context) {
    final bg = tinted ? _tintBg : Colors.transparent;
    const brown = Color(0xFF922B05);
    final titleColor =
        tinted ? brown : const Color(0xFF1E6370);
    final descColor =
        tinted ? const Color(0xFF6B2004) : Colors.black87;
    final iconColor =
        tinted ? brown : const Color(0xFF1E6370);

    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              final iconWidget =
                  Icon(icon, size: 68, color: iconColor);

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    iconWidget,
                    const SizedBox(height: 16),
                    Text(
                      titolo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: titleColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      descrizione,
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.5,
                        color: descColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }

              final textWidget = Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titolo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      descrizione,
                      style: TextStyle(
                        fontSize: 17,
                        height: 1.5,
                        color: descColor,
                      ),
                    ),
                  ],
                ),
              );

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: iconOnLeft
                    ? [iconWidget, const SizedBox(width: 24), textWidget]
                    : [textWidget, const SizedBox(width: 24), iconWidget],
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
    if (words.length <= 100) return text;
    return '${words.take(100).join(' ')}…';
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
        final articoli = snapshot.data ?? [];
        if (articoli.isEmpty) return const SizedBox.shrink();
        final a = articoli.first;
        final dataTesto = a.pubblicatoAt != null
            ? '${a.pubblicatoAt!.day.toString().padLeft(2, '0')}/'
              '${a.pubblicatoAt!.month.toString().padLeft(2, '0')}/'
              '${a.pubblicatoAt!.year}'
            : '';
        return Container(
          width: double.infinity,
          color: Colors.transparent,
          padding:
              const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
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
                        color: Color(0xFF1E6370)),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 600;

                      final textBlock = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dataTesto,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black45),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            a.titolo,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF134456)),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _truncate(a.corpo),
                            style: const TextStyle(
                                fontSize: 16,
                                height: 1.7,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 20),
                          TextButton.icon(
                            onPressed: () => context.go('/articoli'),
                            icon: const Icon(Icons.arrow_forward,
                                color: Color(0xFF1E6370)),
                            label: const Text(
                              'Leggi tutti i post del blog',
                              style: TextStyle(
                                  color: Color(0xFF1E6370),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      );

                      if (a.immagineUrl == null) return textBlock;

                      final imageWidget = ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          a.immagineUrl!,
                          width: isWide ? 240 : double.infinity,
                          height: isWide ? 200 : 220,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      );

                      if (!isWide) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            imageWidget,
                            const SizedBox(height: 16),
                            textBlock,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          imageWidget,
                          const SizedBox(width: 24),
                          Expanded(child: textBlock),
                        ],
                      );
                    },
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
          padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
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
                        color: Color(0xFF1E6370)),
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
                        color: Color(0xFF1E6370)),
                    label: const Text(
                      'Leggi tutte le recensioni',
                      style: TextStyle(
                          color: Color(0xFF1E6370),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              review.name,
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

class _CitazioneSection extends StatelessWidget {
  const _CitazioneSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1E6370),
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
      child: const Center(
        child: Text(
          'Solo tramite la terapia\nl\'uomo ascende a nuova forma\ndiventando musica',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 56,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            height: 1.4,
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
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      color: Colors.transparent,
      child: Column(
        children: [
          const Text(
            'Inizia il tuo percorso',
            style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E6370)),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _CtaButton(
                icon: Icons.psychology,
                label: 'I miei servizi',
                backgroundColor: const Color(0xFF1E6370),
                foregroundColor: Colors.white,
                onPressed: () => context.go('/servizi'),
              ),
              _CtaButton(
                icon: Icons.email_outlined,
                label: 'Scrivimi una email',
                backgroundColor: const Color(0xFF1E6370),
                foregroundColor: Colors.white,
                onPressed: () => inviaEmail(Contatti.email),
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
                  color: Color(0xFF1E6370))),
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
                  color: const Color(0xFF1E6370),
                  hoverColor: const Color(0xFF134456),
                  onTap: () => chiamaTelefono(Contatti.telefono),
                ),
                ContactChip(
                  icon: Icons.location_on,
                  text: Contatti.indirizzo,
                  color: const Color(0xFF1E6370),
                  hoverColor: const Color(0xFF134456),
                  onTap: () => apriMappa(Contatti.indirizzo),
                ),
                ContactChip(
                  icon: Icons.email,
                  text: Contatti.email,
                  color: const Color(0xFF1E6370),
                  hoverColor: const Color(0xFF134456),
                  onTap: () => inviaEmail(Contatti.email),
                ),
                ContactChip(
                  icon: Icons.facebook,
                  text: 'Facebook',
                  color: const Color(0xFF1E6370),
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
