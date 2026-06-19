import 'package:flutter/material.dart';
import '../widgets/nav_bar.dart';
import '../widgets/site_footer.dart';

class ChiSonoPage extends StatelessWidget {
  const ChiSonoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavScaffold(body: _ChiSonoBody());
  }
}

class _ChiSonoBody extends StatelessWidget {
  const _ChiSonoBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const _HeroHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileCard(),
                    SizedBox(height: 40),
                    _PresentazioneSection(),
                    SizedBox(height: 40),
                    _Section(
                      icon: Icons.school_outlined,
                      title: 'Formazione ed esperienza',
                      items: [
                        _SectionItem(text: 'Laurea in Psicologia Clinica e di Comunità'),
                        _SectionItem(text: 'Abilitazione professionale'),
                        _SectionItem(text: 'Master in Psicologia delle Emergenze'),
                        _SectionItem(text: 'Formazione in Sessuologia Clinica'),
                        _SectionItem(
                            text: 'Specializzazione in Psicoterapia Psicoanalitica Relazionale'),
                        _SectionItem(
                            text: 'Approfondimento nella cura dei traumi psicologici con EMDR'),
                      ],
                    ),
                    SizedBox(height: 12),
                    _ExperienceNote(),
                    SizedBox(height: 40),
                    _Section(
                      icon: Icons.work_outline,
                      title: 'Il mio lavoro oggi',
                      items: [
                        _SectionItem(
                          text: 'Lavoro come libera professionista nel mio studio privato, '
                              'continuando ad aggiornarmi attraverso attività formative ed ECM, '
                              'per offrire un intervento clinico competente, attento e fondato '
                              'su una preparazione costante.',
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    _Section(
                      icon: Icons.psychology_outlined,
                      title: 'Il mio orientamento clinico',
                      items: [
                        _SectionItem(
                          text: 'Il mio approccio è umanistico-relazionale, con formazione '
                              'psicoanalitica contemporanea.',
                        ),
                        _SectionItem(
                          text: 'Al centro del lavoro c\'è la persona nella sua storia, '
                              'nei suoi vissuti e nelle sue relazioni significative.',
                        ),
                      ],
                    ),
                    SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
          const SiteFooter(),
        ],
      ),
    );
  }
}

// ── Hero header ───────────────────────────────────────────────────────────────

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
          constraints: const BoxConstraints(maxWidth: 760),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chi sono',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93a996),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Psicologa e Psicoterapeuta con un approccio umanistico-relazionale. '
                'Accolgo adulti, adolescenti, coppie e famiglie che desiderano uno spazio '
                'di ascolto autentico e accompagnamento professionale.',
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

// ── Presentazione ─────────────────────────────────────────────────────────────

class _PresentazioneSection extends StatelessWidget {
  const _PresentazioneSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_outline, color: Color(0xFF93a996), size: 24),
            SizedBox(width: 10),
            Text(
              'Presentazione',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93a996)),
            ),
          ],
        ),
        SizedBox(height: 4),
        Divider(color: Color(0xFF93a996), thickness: 1),
        SizedBox(height: 16),
        Text(
          'Nel mio lavoro accolgo adulti, adolescenti, coppie e famiglie che attraversano '
          'momenti complessi della loro vita e che desiderano uno spazio in cui sentirsi '
          'ascoltati con rispetto, competenza e attenzione alla propria unicità.',
          style: TextStyle(fontSize: 16, height: 1.7, color: Color(0xFF2C2C2C)),
        ),
      ],
    );
  }
}

// ── Experience note ───────────────────────────────────────────────────────────

class _ExperienceNote extends StatelessWidget {
  const _ExperienceNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFF93a996), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Nel corso degli anni ho maturato esperienza in consultori, ospedali, scuole, '
              'comuni, associazioni e altri contesti dell\'area sociale.',
              style: TextStyle(fontSize: 15, height: 1.65, color: Color(0xFF2C2C2C)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile card ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipOval(
          child: Image.asset(
            'assets/images/foto_psicologa.webp',
            width: 180,
            height: 180,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, _, _) => Container(
              width: 180,
              height: 180,
              color: const Color(0xFFE0F0F3),
              child: const Icon(Icons.person, size: 80, color: Color(0xFF93a996)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Dr.ssa Maria Bianchi',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFF93a996)),
        ),
        const SizedBox(height: 6),
        const Text(
          'Psicologa e Psicoterapeuta',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 18,
              color: Color(0xFF93a996),
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        const Text(
          'Iscritta all\'Albo degli Psicologi della Lombardia — n. 14872',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }
}

// ── Section ───────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<_SectionItem> items;

  const _Section({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF93a996), size: 24),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93a996)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Divider(color: Color(0xFF93a996), thickness: 1),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }
}

// ── Section item ──────────────────────────────────────────────────────────────

class _SectionItem extends StatelessWidget {
  final String text;

  const _SectionItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7),
            child: Icon(Icons.circle, size: 7, color: Color(0xFF93a996)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
