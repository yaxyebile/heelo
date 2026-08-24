import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'colorful_hello.dart';

class HakaboLogoTitle extends StatelessWidget {
  final double logoHeight;
  const HakaboLogoTitle({super.key, this.logoHeight = 28});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo/LOOGO.jpeg',
          height: logoHeight,
          errorBuilder: (_, __, ___) => const Icon(Icons.shopping_bag_rounded, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Text(
          'EMARA',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            fontSize: logoHeight * 0.7,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
