import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GuestCounter extends StatelessWidget {
  final int totalGuests;
  final ValueChanged<int> onChanged;

  const GuestCounter({
    super.key,
    required this.totalGuests,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Guests',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (totalGuests > 1) {
                    onChanged(totalGuests - 1);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: totalGuests > 1 ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: totalGuests > 1 ? Colors.white : const Color(0xFF9CA3AF),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                totalGuests.toString(),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  onChanged(totalGuests + 1);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

