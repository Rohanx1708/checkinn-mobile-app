import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

    return ListView.separated(
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
      ),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return ListItemAnimation(
          delay: ListItemAnimationConfig.getDelayForIndex(index),
          child: BookingCard(booking: booking),
        );
      },
    );
  }
}
