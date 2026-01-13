import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/bookingdetails.dart';
import 'booking_card.dart';
import '../../../widgets/list_item_animation.dart';

class BookingList extends StatelessWidget {
  final List<Booking> bookings;
  final String searchQuery;

  const BookingList({
    super.key,
    required this.bookings,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No bookings found',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    // Sort bookings by check-in date so headers appear in order
    final sorted = [...bookings]
      ..sort((a, b) => a.checkInDate.compareTo(b.checkInDate));

    return ListView.separated(
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
      ),
      itemBuilder: (context, index) {
        final booking = sorted[index];

        // Determine if we need to show a date header above this card
        final currentDate = DateTime(
          booking.checkInDate.year,
          booking.checkInDate.month,
          booking.checkInDate.day,
        );

        DateTime? previousDate;
        if (index > 0) {
          final prev = sorted[index - 1].checkInDate;
          previousDate = DateTime(prev.year, prev.month, prev.day);
        }

        final bool showHeader = previousDate == null || previousDate.isBefore(currentDate) || previousDate.isAfter(currentDate);
        final String headerLabel = DateFormat('EEEE, dd MMM yyyy').format(currentDate);

        return ListItemAnimation(
          delay: ListItemAnimationConfig.getDelayForIndex(index),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    headerLabel,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
              BookingCard(booking: booking),
            ],
          ),
        );
      },
    );
  }
}
