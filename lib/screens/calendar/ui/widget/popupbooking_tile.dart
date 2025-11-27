import 'package:flutter/material.dart';
import 'package:checkinn/utils/routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:checkinn/screens/bookings/bookingdetailpage.dart';
import 'package:checkinn/screens/bookings/models/bookingdetails.dart';

// Placeholder for BookingsDetailsUi until the actual implementation is available
class BookingsDetailsUi extends StatelessWidget {
  const BookingsDetailsUi({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
      ),
      body: Center(
        child: Text('Booking Details Screen - Coming Soon'),
      ),
    );
  }
}

class PopupbookingTile extends StatefulWidget {
  final Map<String, dynamic> booking;
  
  const PopupbookingTile({
    super.key,
    required this.booking,
  });

  @override
  State<PopupbookingTile> createState() => _PopupbookingTileState();
}

class _PopupbookingTileState extends State<PopupbookingTile> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    // Extract booking data
    final guestName = (widget.booking['customer_name'] ?? 
        widget.booking['guest_name'] ?? 
        widget.booking['customer']?['name'] ?? 
        'Guest').toString();
    
    final roomName = (widget.booking['room_name'] ?? 
        widget.booking['room']?['name'] ?? 
        'Room').toString();
    
    final status = (widget.booking['status'] ?? '').toString().toLowerCase();
    
    // Get guest count
    int guestCount = 1;
    try {
      guestCount = (widget.booking['total_guests'] ?? 
          widget.booking['guests']?.length ?? 
          1) as int;
    } catch (_) {
      guestCount = int.tryParse((widget.booking['total_guests'] ?? '1').toString()) ?? 1;
    }
    
    // Format time
    String formatTime(dynamic v) {
      if (v == null) return '';
      try {
        final dt = DateTime.tryParse(v.toString());
        if (dt != null) {
          return DateFormat('hh:mm a').format(dt);
        }
        return v.toString();
      } catch (_) {
        return v.toString();
      }
    }
    
    final checkIn = formatTime(widget.booking['check_in_time'] ?? widget.booking['check_in_date']);
    final checkOut = formatTime(widget.booking['check_out_time'] ?? widget.booking['check_out_date']);
    
    // Status color
    Color statusColor;
    if (status.contains('confirmed') || status.contains('upcoming')) {
      statusColor = const Color(0xFF6366F1);
    } else if (status.contains('checked') || status.contains('completed')) {
      statusColor = const Color(0xFF22C55E);
    } else if (status.contains('cancel')) {
      statusColor = const Color(0xFFEF4444);
    } else {
      statusColor = const Color(0xFF8B5CF6);
    }
    
    return GestureDetector(
      onTap: () => _navigateToBookingDetail(),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * .015,
          horizontal: screenWidth * .02,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bed,
                        size: screenWidth * .035,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          roomName,
                          style: GoogleFonts.inter(
                            fontSize: screenWidth * .035,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    guestName,
                    style: GoogleFonts.inter(
                      fontSize: screenWidth * .04,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1F2937),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: screenWidth * .03,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "${checkIn.isEmpty ? '-' : checkIn} - ${checkOut.isEmpty ? '-' : checkOut}",
                          style: GoogleFonts.inter(
                            fontSize: screenWidth * .03,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: screenWidth * .025,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      color: Colors.grey,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      guestCount.toString(),
                      style: GoogleFonts.inter(
                        fontSize: screenWidth * .03,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _navigateToBookingDetail() {
    try {
      // Convert the booking data to Booking model
      final bookingModel = Booking.fromMap(widget.booking);
      
      // Navigate to booking detail page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BookingDetailsPage(booking: bookingModel),
        ),
      );
    } catch (e) {
      // Show error if booking data is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open booking details: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
