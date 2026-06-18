import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Standalone panel — rendered inside the custom animated overlay in NavScaffold.
/// Requires [onClose] to dismiss the overlay.
class NavDrawer extends StatelessWidget {
  final VoidCallback onClose;
  const NavDrawer({super.key, required this.onClose});

  void _go(BuildContext context, String path) {
    onClose();
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        boxShadow: [
          BoxShadow(
              color: Colors.black26, blurRadius: 16, offset: Offset(-4, 0)),
        ],
      ),
      child: SafeArea(
        child: Material(
          color: const Color(0xFFFAFAFA),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                color: const Color(0xFFEEEEEE),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr.ssa Maria Bianchi',
                      style: TextStyle(
                          color: Color(0xFF93a996),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Psicologa e Psicoterapeuta',
                      style: TextStyle(color: Color(0xFF93a996), fontSize: 13),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading:
                    const Icon(Icons.home_outlined, color: Color(0xFF93a996)),
                title: const Text('Home',
                    style: TextStyle(color: Color(0xFF93a996))),
                onTap: () => _go(context, '/'),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline,
                    color: Color(0xFF93a996)),
                title: const Text('Chi sono',
                    style: TextStyle(color: Color(0xFF93a996))),
                onTap: () => _go(context, '/chi-sono'),
              ),
              ListTile(
                leading: const Icon(Icons.psychology_outlined,
                    color: Color(0xFF93a996)),
                title: const Text('A chi mi rivolgo',
                    style: TextStyle(color: Color(0xFF93a996))),
                onTap: () => _go(context, '/servizi'),
              ),
              ListTile(
                leading: const Icon(Icons.self_improvement_outlined,
                    color: Color(0xFF93a996)),
                title: const Text('Approccio terapeutico',
                    style: TextStyle(color: Color(0xFF93a996))),
                onTap: () => _go(context, '/approccio-terapeutico'),
              ),
              ListTile(
                leading: const Icon(Icons.volunteer_activism_outlined,
                    color: Color(0xFF93a996)),
                title: const Text('Psicoterapia',
                    style: TextStyle(color: Color(0xFF93a996))),
                onTap: () => _go(context, '/psicoterapia'),
              ),
              ListTile(
                leading: const Icon(Icons.medical_information_outlined,
                    color: Color(0xFF93a996)),
                title: const Text('Disturbi trattati',
                    style: TextStyle(color: Color(0xFF93a996))),
                onTap: () => _go(context, '/disturbi'),
              ),
              ListTile(
                leading: const Icon(Icons.groups_outlined,
                    color: Color(0xFF93a996)),
                title: const Text('Figure professionali',
                    style: TextStyle(color: Color(0xFF93a996))),
                onTap: () => _go(context, '/figure-professionali'),
              ),
              ListTile(
                leading: const Icon(Icons.lock_outline,
                    color: Color(0xFF93a996)),
                title: const Text('Privacy e consenso',
                    style: TextStyle(color: Color(0xFF93a996))),
                onTap: () => _go(context, '/privacy'),
              ),
              ListTile(
                leading: const Icon(Icons.help_outline,
                    color: Color(0xFF93a996)),
                title: const Text('FAQ',
                    style: TextStyle(color: Color(0xFF93a996))),
                onTap: () => _go(context, '/faq'),
              ),
              ListTile(
                leading: const Icon(Icons.article_outlined,
                    color: Color(0xFF93a996)),
                title: const Text('Il mio blog',
                    style: TextStyle(color: Color(0xFF93a996))),
                onTap: () => _go(context, '/articoli'),
              ),
              ListTile(
                leading: const Icon(Icons.star_outline,
                    color: Color(0xFF93a996)),
                title: const Text('Recensioni',
                    style: TextStyle(color: Color(0xFF93a996))),
                onTap: () => _go(context, '/recensioni'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
