import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFormStyles {
  static InputDecoration inputDecoration({String? hint, Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      prefixIcon: prefixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1F2937), width: 1.5),
      ),
      helperStyle: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
      errorStyle: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFEF4444)),
    );
  }

  static TextStyle labelStyle() => GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF334155));

  static Widget stepHeader(String title, int current, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: (current + 1) / total,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
              ),
            ),
            const SizedBox(width: 12),
            Text('${current + 1}/$total', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
          ],
        ),
        const SizedBox(height: 8),
        Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
      ],
    );
  }
}


