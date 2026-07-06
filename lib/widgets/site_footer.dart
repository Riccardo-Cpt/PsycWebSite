import 'package:flutter/material.dart';

class SiteFooter extends StatelessWidget {
  const SiteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF134456),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: const Text(
        '© 2026 Antonella Petrini — Tutti i diritti riservati',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 13),
      ),
    );
  }
}
