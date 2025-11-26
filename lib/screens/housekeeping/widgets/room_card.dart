import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/room_model.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onTap;

  const RoomCard({
    super.key,
    required this.room,
    required this.onTap,
  });

  String _statusLabel(String status) {
    return RoomStatus.getDisplayLabel(status);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'clean':
        return Colors.green;
      case 'dirty':
        return Colors.red;
      case 'in_progress':
        return Colors.orange;
      case 'out_of_order':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final Color badgeColor = _statusColor(room.status);
    final String statusLabel = _statusLabel(room.status);
    final String lastCleanedText =
        'Last cleaned: ${DateFormat('dd MMM yyyy').format(room.lastCleaned)}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.018,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.black12, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.brown.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bed, color: Colors.brown, size: 22),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Room ${room.roomNo} • ${room.type}',
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.042,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Floor ${room.floor} • ${room.building}',
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.034,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lastCleanedText,
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.032,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: badgeColor.withOpacity(0.7), width: 1),
              ),
              child: Text(
                statusLabel,
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.032,
                  fontWeight: FontWeight.w600,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
