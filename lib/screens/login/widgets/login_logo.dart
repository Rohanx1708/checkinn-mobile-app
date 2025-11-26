import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:checkinn/widgets/checkinn_logo.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // CheckInn Logo
        const CheckInnLogo(
          iconSize: 80,
          fontSize: 36,
          alignment: MainAxisAlignment.center,
        ),

        const SizedBox(height: 30),

        Text(
          "Welcome Back!",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF1F2937),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          "Sign in to your account",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
