import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';
import 'contact_form_dialog.dart';

class CtaBanner extends StatelessWidget {
  final String imagePath;

  const CtaBanner({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        return Container(
          width: double.infinity,
          color: AppColors.primary,
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 330,
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0.50)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 40),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Hai domande sul percorso?',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: isWide ? 36 : 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Il primo colloquio è uno spazio di ascolto '
                        'per cominciare a orientarsi insieme.',
                        style: GoogleFonts.lato(
                          fontSize: isWide ? 26 : 18,
                          height: 1.55,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      OutlinedButton.icon(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => const ContactFormDialog(),
                        ),
                        icon: const Icon(Icons.calendar_today_outlined, color: Colors.white),
                        label: Text(
                          'Richiedi un primo colloquio',
                          style: GoogleFonts.lato(
                            fontSize: isWide ? 20 : 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 23),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
