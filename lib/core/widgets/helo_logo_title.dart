import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'colorful_hello.dart';

class HeloLogoTitle extends StatelessWidget {
  final double logoHeight;
  const HeloLogoTitle({super.key, this.logoHeight = 28});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColorfulHello(fontSize: logoHeight * 0.45),
        const SizedBox(width: 4),
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Helo ',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'Market',
                style: TextStyle(
                  color: AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
