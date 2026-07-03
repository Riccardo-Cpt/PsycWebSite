import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class StarRating extends StatelessWidget {
  final int stars;
  final double size;

  const StarRating({super.key, required this.stars, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= 5; i++)
          Icon(
            i <= stars ? Icons.star : Icons.star_border,
            color: AppColors.star,
            size: size,
          ),
      ],
    );
  }
}
