import 'package:flutter/material.dart';

class ColorfulHello extends StatelessWidget {
  final double fontSize;
  final bool isWhite;
  const ColorfulHello({super.key, this.fontSize = 28, this.isWhite = false});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: fontSize * 2.5,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Text(
          "HELO",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: isWhite ? Colors.white : const Color(0xFF00AA5B),
            letterSpacing: -1,
          ),
        );
      },
    );
  }
}
