import 'package:flutter/material.dart';

class ColorfulHello extends StatelessWidget {
  final double fontSize;
  final bool isWhite;
  const ColorfulHello({super.key, this.fontSize = 28, this.isWhite = false});

  @override
  Widget build(BuildContext context) {
    final size = fontSize * 2.2;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFD2F7FF),
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset(
          'assets/images/logo/LOOGO.jpeg',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Text(
              "EMARA",
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: isWhite ? Colors.white : const Color(0xFF00AA5B),
                letterSpacing: -1,
              ),
            );
          },
        ),
      ),
    );
  }
}
