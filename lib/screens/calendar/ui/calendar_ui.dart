import 'package:flutter/material.dart';
import 'package:checkinn/screens/calendar/ui/widget/day_view.dart';
import 'package:checkinn/screens/calendar/ui/widget/month_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/common_app_bar.dart';
import '../../Dashboard/widget/drawer_widget.dart';

class CalendarUi extends StatefulWidget {
  const CalendarUi({super.key});

  @override
  State<CalendarUi> createState() => _CalendarUiState();
}

class _CalendarUiState extends State<CalendarUi> {
  bool isDayView = true; // Variable to track the selected view
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
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar.dashboard(
        notificationCount: 5,
      ),
      drawer: const DrawerWidget(),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Color(0xFFF8FAFC),
              ],
            ),
          ),
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
                    // Toggle buttons compact
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() {
                              isDayView = true;
                              _selectedDateForDayView = null; // Reset to today when manually switching
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isDayView ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: isDayView ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Day',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDayView ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => isDayView = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: !isDayView ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    color: !isDayView ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Month',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: !isDayView ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
