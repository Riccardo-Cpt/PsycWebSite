import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/nav_bar.dart';
import '../widgets/site_footer.dart';

class DisturbPage extends StatelessWidget {
  const DisturbPage({super.key});

  static const _disturbi = [
    (Icons.air, 'Ansia'),
    (Icons.flash_on_outlined, 'Attacchi di panico'),
    (Icons.cloud_outlined, 'Disturbi dell\'umore'),
    (Icons.work_outline, 'Stress'),
    (Icons.favorite_border, 'Lutto'),
    (Icons.shield_outlined, 'Esperienze traumatiche'),
    (Icons.people_outline, 'Difficoltà relazionali'),
    (Icons.heart_broken_outlined, 'Problematiche affettive'),
    (Icons.spa_outlined, 'Disturbi della sessualità'),
    (Icons.lock_clock_outlined, 'Dipendenze'),
    (Icons.restaurant_menu_outlined, 'Disturbi alimentari'),
    (Icons.bedtime_outlined, 'Disturbi del sonno'),
    (Icons.psychology_outlined, 'Problematiche della personalità'),
  ];

  static const _situazioni = [
    (Icons.timeline_outlined, 'Crisi del ciclo di vita'),
    (Icons.child_care_outlined, 'Genitorialità'),
    (Icons.school_outlined, 'Fragilità adolescenziali'),
    (Icons.family_restroom_outlined, 'Conflitti di coppia e familiari'),
    (Icons.business_center_outlined, 'Stress lavorativo'),
    (Icons.monitor_heart_outlined, 'Sintomi psicofisici'),
  ];

  @override
  Widget build(BuildContext context) {
    return NavScaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _HeroHeader(),
            _DisturbSection(),
            _SituazioniSection(),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Disturbi trattati',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF93a996),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mi occupo di disagio psicologico nelle sue diverse manifestazioni. '
                'Ogni persona viene incontrata nella sua specificità, senza etichette '
                'riduttive.',
                style: GoogleFonts.lato(
                  fontSize: 19,
                  height: 1.75,
                  color: const Color(0xFF2C2C2C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DisturbSection extends StatelessWidget {
  const _DisturbSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aree di intervento',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF93a996),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lavoro con persone che attraversano:',
                style: GoogleFonts.lato(
                    fontSize: 17, height: 1.7, color: const Color(0xFF4A4A4A)),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: DisturbPage._disturbi
                    .map((d) => _Chip(icon: d.$1, label: d.$2))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SituazioniSection extends StatelessWidget {
  const _SituazioniSection();

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
              Text(
                'Situazioni di vita',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF93a996),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Accolgo inoltre situazioni legate a:',
                style: GoogleFonts.lato(
                    fontSize: 17, height: 1.7, color: const Color(0xFF4A4A4A)),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: DisturbPage._situazioni
                    .map((s) => _Chip(icon: s.$1, label: s.$2))
                    .toList(),
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
          child: Text(
            'Ogni persona viene incontrata nella sua specificità, senza etichette riduttive. '
            'La sofferenza non si riduce a una diagnosi: è sempre l\'espressione di una storia '
            'unica che merita ascolto e rispetto.',
            style: GoogleFonts.lato(
              fontSize: 18,
              height: 1.75,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF2C2C2C),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF93a996).withValues(alpha: 0.45),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF93a996)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 15,
              color: const Color(0xFF2C2C2C),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
