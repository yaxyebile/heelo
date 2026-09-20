import 'package:flutter/material.dart';
import '../constants/colors.dart';

class HakaboLogoTitle extends StatelessWidget {
  final double logoHeight;
  final bool isWhite;
  const HakaboLogoTitle({super.key, this.logoHeight = 32, this.isWhite = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: logoHeight,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: const Color(0xFFD2F7FF),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo/LOOGO.jpeg',
              height: logoHeight - 4,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.shopping_cart_rounded, color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'EMARA',
          style: TextStyle(
            color: isWhite ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w900,
            fontSize: logoHeight * 0.7,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
