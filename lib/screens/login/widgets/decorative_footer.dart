import 'package:flutter/material.dart';

class DecorativeFooter extends StatelessWidget {
  const DecorativeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1),
            const Color(0xFF8B5CF6),
          ],
        ),
      ),
    );
  }
}
