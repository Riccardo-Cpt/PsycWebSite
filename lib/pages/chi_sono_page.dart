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
              _Section(
                icon: Icons.school_outlined,
                title: 'Formazione',
                items: [
                  _SectionItem(
                    year: '1998',
                    text:
                        'Laurea quinquiennale in Psicologia Clinica '
                        ' — Università degli Studi di Padova.',
                  ),
                  _SectionItem(
                    year: '2002',
                    text:
                        'Diploma quadriennale di Specializzazione in Psicoterapia Psicoanalitica Relazionale '
                        '— Istituto di Psicologia Cognitiva, Milano.',
                  ),
                  _SectionItem(
                    year: '2005',
                    text:
                        'Master In psicologia delle Emergenze '
                        ' — Università Cattolica del Sacro Cuore, Milano.',
                  ),
                ],
              ),
              SizedBox(height: 32),
              _Section(
                icon: Icons.psychology_outlined,
                title: 'Specializzazioni',
                items: [
                  _SectionItem(
                    text:
                        'Sessuologia clinica, '
                        'depressione e attacchi di panico.',
                  ),
                  _SectionItem(
                    text:
                        'EMDR (Eye Movement Desensitization and Reprocessing) per '
                        'il trattamento del trauma e del PTSD. Certificazione EMDR Europe.',
                  ),
                  _SectionItem(
                    text:
                        'Mindfulness-Based Cognitive Therapy (MBCT) — prevenzione '
                        'delle ricadute depressive e gestione dello stress.',
                  ),
                  _SectionItem(
                    text:
                        'Psicoterapia di coppia e familiare con approccio sistemico-relazionale.',
                  ),
                ],
              ),
              SizedBox(height: 32),
              _Section(
                icon: Icons.work_outline,
                title: 'Esperienze',
                items: [
                  _SectionItem(
                    year: '2009 – 2014',
                    text:
                        'Psicologa clinica presso il Servizio di Salute Mentale '
                        'dell\'Azienda Socio-Sanitaria Territoriale di Milano Nord. '
                        'Presa in carico di pazienti adulti con disturbi dell\'umore e d\'ansia.',
                  ),
                  _SectionItem(
                    year: '2014 – 2018',
                    text:
                        'Consulente presso il Centro di Psicologia e Psicoterapia '
                        '"Mente & Benessere" — Milano. Attività clinica individuale e di coppia.',
                  ),
                  _SectionItem(
                    year: '2018 – oggi',
                    text:
                        'Studio privato a Somma Lombardo. Psicoterapia individuale, di coppia '
                        'e interventi specialistici.',
                  ),
                ],
              ),
              SizedBox(height: 32),
              _Section(
                icon: Icons.emoji_events_outlined,
                title: 'Riconoscimenti',
                items: [
                  _SectionItem(
                    year: '2015',
                    text:
                        'Premio "Giovane Professionista dell\'Anno" — Ordine degli Psicologi '
                        'della Lombardia, per l\'attività clinica e la ricerca sul benessere psicologico.',
                  ),
                  _SectionItem(
                    year: '2019',
                    text:
                        'Menzione speciale al Congresso Nazionale di Psicoterapia Cognitiva '
                        'per il contributo scientifico sul trattamento integrato del trauma.',
                  ),
                  _SectionItem(
                    year: '2022',
                    text:
                        'Docente invitata presso l\'Università degli Studi di Milano — '
                        'corso di Psicologia Clinica per studenti magistrali.',
                  ),
                ],
              ),
              SizedBox(height: 48),
            ],
          ),
        ),
      ),
          ),
          SiteFooter(),
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
            'assets/images/foto_psicologa.jpg',
            width: 180,
            height: 180,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, _, _) => Container(
              width: 180,
              height: 180,
              color: const Color(0xFFE0F0F3),
              child: const Icon(Icons.person,
                  size: 80, color: Color(0xFF3B7A1D)),
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
              color: Color(0xFF3B7A1D)),
        ),
        const SizedBox(height: 6),
        const Text(
          'Psicologa e Psicoterapeuta',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 18,
              color: Color(0xFF2E8494),
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
            Icon(icon, color: const Color(0xFF3B7A1D), size: 24),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B7A1D)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Divider(color: Color(0xFF3B7A1D), thickness: 1),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }
}

// ── Section item ──────────────────────────────────────────────────────────────

class _SectionItem extends StatelessWidget {
  final String? year;
  final String text;

  const _SectionItem({this.year, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (year != null) ...[
            SizedBox(
              width: 80,
              child: Text(
                year!,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E8494),
                    fontSize: 14),
              ),
            ),
          ] else
            const SizedBox(width: 16),
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
