import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AmenityTypeToggle extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;

  const AmenityTypeToggle({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged("Room"),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: selectedType == "Room"
                      ? LinearGradient(
                          colors: [
                            const Color(0xFF6366F1),
                            const Color(0xFF8B5CF6),
                          ],
                        )
                      : null,
                  color: selectedType == "Room" ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selectedType == "Room"
                      ? [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hotel,
                      color: selectedType == "Room" ? Colors.white : const Color(0xFF6366F1),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Room",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: selectedType == "Room" ? Colors.white : const Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged("Property"),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: selectedType == "Property"
                      ? LinearGradient(
                          colors: [
                            const Color(0xFF6366F1),
                            const Color(0xFF8B5CF6),
                          ],
                        )
                      : null,
                  color: selectedType == "Property" ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selectedType == "Property"
                      ? [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.business,
                      color: selectedType == "Property" ? Colors.white : const Color(0xFF6366F1),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Property",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: selectedType == "Property" ? Colors.white : const Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
