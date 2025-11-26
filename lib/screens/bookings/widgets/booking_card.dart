import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/bookingdetails.dart';
import '../bookingdetailpage.dart';
import '../ui/bookings_ui.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    Color statusColor;
    IconData statusIcon;

    final String normalizedStatus = booking.status
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');

    switch (normalizedStatus) {
      case 'upcoming':
      case 'pending':
        statusColor = const Color(0xFFF59E0B); // amber
        statusIcon = Icons.schedule;
        break;
      case 'confirmed':
        statusColor = const Color(0xFF3B82F6); // blue
        statusIcon = Icons.check_circle_outline;
        break;
      case 'checked_in':
      case 'in_house':
        statusColor = const Color(0xFF14B8A6); // teal
        statusIcon = Icons.meeting_room;
        break;
      case 'checked_out':
      case 'completed':
        statusColor = const Color(0xFF22C55E); // green
        statusIcon = Icons.check_circle;
        break;
      case 'cancelled':
      case 'no_show':
        statusColor = const Color(0xFFEF4444); // red
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = const Color(0xFF6B7280); // gray
        statusIcon = Icons.info;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingDetailsPage(
                  booking: booking,
                  onBookingUpdated: () {
                    // This callback will be passed down to refresh the booking list
                    // We need to get the parent widget to refresh
                    if (context.mounted) {
                      // Find the parent BookingsUi and call its refresh method
                      final bookingsUi = context.findAncestorStateOfType<BookingsUiState>();
                      bookingsUi?.loadBookings();
                    }
                  },
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Title and Company
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.companyName,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                     // Status Badge
                     Container(
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                       decoration: BoxDecoration(
                         color: statusColor.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(20),
                         border: Border.all(
                           color: statusColor.withOpacity(0.3),
                           width: 1,
                         ),
                       ),
                       child: Text(
                         booking.status
                             .replaceAll('_', ' ')
                             .split(' ')
                             .map((word) {
                               if (word.isEmpty) return word;
                               return word[0].toUpperCase() + word.substring(1).toLowerCase();
                             })
                             .join(' '),
                         style: GoogleFonts.poppins(
                           fontSize: 12,
                           fontWeight: FontWeight.w600,
                           color: statusColor,
                         ),
                       ),
                     ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Customer Info
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${booking.customer.name} • ${booking.totalGuests} guest${booking.totalGuests > 1 ? 's' : ''}",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Check-in/Check-out Info
                Row(
                  children: [
                    Text(
                      "Check-in: ${DateFormat('dd MMM').format(booking.checkInDate)}",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "Check-out: ${DateFormat('dd MMM').format(booking.checkOutDate)}",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
