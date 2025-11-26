import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckInnLogo extends StatelessWidget {
  final double? iconSize;
  final double? fontSize;
  final bool showText;
  final Color? textColor;
  final MainAxisAlignment alignment;

  const CheckInnLogo({
    super.key,
    this.iconSize,
    this.fontSize,
    this.showText = true,
    this.textColor,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    // Dark charcoal/navy color for the icon background
    const Color iconBackgroundColor = Color(0xFF1F2937); // Dark charcoal grey
    // Light grey for the text
    final Color logoTextColor = textColor ?? const Color(0xFF6B7280);
    
    final double iconSizeValue = iconSize ?? 48.0;
    final double fontSizeValue = fontSize ?? 24.0;

    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dark square with rounded corners (squircle) containing white "c"
        Container(
          width: iconSizeValue,
          height: iconSizeValue,
          decoration: BoxDecoration(
            color: iconBackgroundColor,
            borderRadius: BorderRadius.circular(iconSizeValue * 0.25), // Rounded corners (squircle effect)
          ),
          child: Center(
            child: Text(
              'c',
              style: GoogleFonts.inter(
                fontSize: iconSizeValue * 0.5,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        if (showText) ...[
          SizedBox(width: iconSizeValue * 0.1),
          
          // "checkinn" text in lowercase, thin, modern sans-serif
          Text(
            'checkinn',
            style: GoogleFonts.inter(
              fontSize: fontSizeValue,
              fontWeight: FontWeight.w300,
              color: logoTextColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}

