import 'package:flutter/material.dart';
import 'package:checkinn/screens/calendar/ui/widget/day_view.dart';
import 'package:checkinn/screens/calendar/ui/widget/month_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/common_app_bar.dart';
import '../../Dashboard/widget/drawer_widget.dart';
import '../../bookings/ui/bookings_ui.dart';

class CalendarUi extends StatefulWidget {
  const CalendarUi({super.key});

  @override
  State<CalendarUi> createState() => _CalendarUiState();
}

class _CalendarUiState extends State<CalendarUi> {
  bool isDayView = false; // Start in month view by default
  DateTime? _selectedDateForDayView; // Date to show in day view when switching from month view

  void _onDateSelectedFromMonth(DateTime date) {
    setState(() {
      _selectedDateForDayView = date;
      isDayView = true; // Switch to day view
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: CommonAppBar.dashboard(
        notificationCount: 5,
      ),
      drawer: const DrawerWidget(),
      body: SafeArea(
        child: Container(
          color: const Color(0xFFF5F6FA),
          child: Column(
            children: [
              // Header row consistent with other screens
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                            'Calendar',
                        style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.format_list_bulleted_rounded, color: Color(0xFF1F2937)),
                          tooltip: 'Open bookings list',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const BookingsUi(showBackButton: true)),
                            );
                          },
                        ),
                        if (isDayView) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.calendar_month, color: Color(0xFF1F2937)),
                            tooltip: 'Month view',
                            onPressed: () {
                              setState(() {
                                isDayView = false;
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Calendar Content
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 8),
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
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: isDayView 
                        ? DayView(initialDate: _selectedDateForDayView)
                        : MonthView(onDateSelected: _onDateSelectedFromMonth),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    }
}
