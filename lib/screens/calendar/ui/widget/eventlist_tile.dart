import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:checkinn/screens/calendar/ui/widget/popupbooking_tile.dart';
import 'package:flutter/cupertino.dart';

class BookingListTile extends StatefulWidget {
  final String roomName;
  final String checkInDate;
  final String checkOutDate;
  final String guestName;
  final String guestsCount;
  final Color tileColor;
  final Map<String, dynamic>? bookingData;

  const BookingListTile({
    super.key,
    required this.roomName,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guestName,
    required this.guestsCount,
    required this.tileColor,
    this.bookingData,
  });

  @override
  State<BookingListTile> createState() => _BookingListTileState();
}

class _BookingListTileState extends State<BookingListTile> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    int deriveGuestsCount() {
      final data = widget.bookingData;
      if (data == null) {
        return int.tryParse(widget.guestsCount) ?? 1;
      }
      dynamic v = data['total_guests'] ??
          data['guests_count'] ??
          data['guest_count'] ??
          data['no_of_guests'] ??
          data['num_guests'];
      if (v == null && data['guests'] is List) {
        v = (data['guests'] as List).length;
      }
      if (v == null) {
        final adults = int.tryParse((data['adults'] ?? '0').toString()) ?? 0;
        final children = int.tryParse((data['children'] ?? '0').toString()) ?? 0;
        v = adults + children;
      }
      return int.tryParse(v.toString()) ?? 1;
    }

    final int guestsCountValue = deriveGuestsCount();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * .02,
        vertical: screenHeight * .0035,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * .028,
        vertical: screenHeight * .016,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Top row with guest name heading and booking status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.guestName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: screenWidth * .04,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Booked",
                    style: GoogleFonts.inter(
                      fontSize: screenWidth * .026,
                      fontWeight: FontWeight.w500,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Guests count
            Row(
              children: [
                Icon(Icons.people_outline, size: 14, color: Colors.grey.shade700),
                const SizedBox(width: 4),
                Text(
                  "$guestsCountValue Guests",
                  style: GoogleFonts.inter(
                    fontSize: screenWidth * .03,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Check-in date
            Row(
              children: [
                Icon(Icons.login, size: 14, color: Colors.grey.shade700),
                const SizedBox(width: 4),
                Text(
                  "Check-in: ${widget.checkInDate}",
                  style: GoogleFonts.inter(
                    fontSize: screenWidth * .03,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Check-out date
            Row(
              children: [
                Icon(Icons.logout, size: 14, color: Colors.grey.shade700),
                const SizedBox(width: 4),
                Text(
                  "Check-out: ${widget.checkOutDate}",
                  style: GoogleFonts.inter(
                    fontSize: screenWidth * .03,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  }
}
