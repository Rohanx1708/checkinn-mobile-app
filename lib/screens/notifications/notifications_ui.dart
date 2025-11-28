import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/common_app_bar.dart';

class NotificationsUi extends StatelessWidget {
  const NotificationsUi({super.key});

  List<Map<String, String>> get _notifications => const [
        {
          'title': 'Room 101 booked',
          'subtitle': 'John Doe • 12 Aug 2025',
        },
        {
          'title': 'Room 203 booked',
          'subtitle': 'Alice Smith • 12 Aug 2025',
        },
        {
          'title': 'Room 305 booked',
          'subtitle': 'Michael Lee • 11 Aug 2025',
        },
        {
          'title': 'Room 112 booked',
          'subtitle': 'Priya Patel • 11 Aug 2025',
        },
        {
          'title': 'Room 407 booked',
          'subtitle': 'Daniel Kim • 10 Aug 2025',
        },
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar.withBackButton(
        title: 'Notifications',
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _notifications[index];
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.06),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF1F2937),
                child: Icon(Icons.book_online, color: Colors.white),
              ),
              title: Text(
                item['title']!,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              subtitle: Text(
                item['subtitle']!,
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Color(0xFF6B7280)),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}


