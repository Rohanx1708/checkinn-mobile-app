import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: screenWidth * 0.055,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = _notifications[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF9E8C6D),
                child: Icon(Icons.book_online, color: Colors.white),
              ),
              title: Text(
                item['title']!,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(item['subtitle']!),
              trailing: const Icon(Icons.chevron_right, color: Colors.black38),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}


