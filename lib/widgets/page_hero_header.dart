import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_colors.dart';

class PageHeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double maxWidth;
  final double titleFontSize;

  const PageHeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.maxWidth = 900,
    this.titleFontSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.backgroundLight,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                subtitle,
                style: GoogleFonts.lato(
                  fontSize: 19,
                  height: 1.75,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
