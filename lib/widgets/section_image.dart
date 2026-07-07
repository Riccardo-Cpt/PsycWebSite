import 'package:flutter/material.dart';

Widget buildSectionImage(String imagePath, double aspectRatio) => ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Image.asset(
          imagePath,
          fit: BoxFit.fill,
          width: double.infinity,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      ),
    );
