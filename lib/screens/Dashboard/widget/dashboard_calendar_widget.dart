import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DashboardCalendarWidget extends StatefulWidget {
  final List<Map<String, dynamic>> bookings;
  final bool loading;
  final Function(DateTime)? onDateSelected;

  const DashboardCalendarWidget({
    super.key,
    required this.bookings,
    this.loading = false,
    this.onDateSelected,
  });

  @override
  State<DashboardCalendarWidget> createState() => _DashboardCalendarWidgetState();
}

class _DashboardCalendarWidgetState extends State<DashboardCalendarWidget> {
  DateTime _focusedDate = DateTime.now();
  DateTime? _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTime.now();
    _selectedDate = DateTime.now();
  }

  void _previousWeek() {
    setState(() {
      _focusedDate = _focusedDate.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _focusedDate = _focusedDate.add(const Duration(days: 7));
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    widget.onDateSelected?.call(date);
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    // Find the Monday of the focused week
    final focusedWeekMonday = _focusedDate.subtract(Duration(days: _focusedDate.weekday - 1));
    
    // Show only the current week (Monday to Sunday)
    List<DateTime> days = [];
    
    // Current week (Monday to Sunday)
    for (int i = 0; i < 7; i++) {
      days.add(focusedWeekMonday.add(Duration(days: i)));
    }
    
    return days;
  }

  List<Map<String, dynamic>> _getBookingsForDate(DateTime date) {
    return widget.bookings.where((booking) {
      final bookingDate = booking['date'] as DateTime?;
      if (bookingDate == null) return false;
      return bookingDate.year == date.year &&
             bookingDate.month == date.month &&
             bookingDate.day == date.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = _getDaysInMonth(_focusedDate);
    final selectedDateBookings = _selectedDate != null 
        ? _getBookingsForDate(_selectedDate!) 
        : <Map<String, dynamic>>[];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar Header with Month/Year and Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(_focusedDate),
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Row(
                children: [
                  // Left arrow
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: _previousWeek,
                      icon: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF1F2937),
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Right arrow
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: _nextWeek,
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF1F2937),
                        size: 20,
                      ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Day headers (Mon, Tue, Wed, Thu, Fri, Sat, Sun)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Calendar Grid - Show only one week (Monday to Sunday)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: daysInMonth.map((date) {
                  final isSelected = _selectedDate != null &&
                      _selectedDate!.year == date.year &&
                      _selectedDate!.month == date.month &&
                      _selectedDate!.day == date.day;
                  final isToday = date.year == DateTime.now().year &&
                      date.month == DateTime.now().month &&
                      date.day == DateTime.now().day;
                  final isCurrentMonth = date.month == _focusedDate.month;
                  final hasBooking = _getBookingsForDate(date).isNotEmpty;
                  final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(date),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1F2937)
                              : isToday
                                  ? const Color(0xFFF3F4F6)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          children: [
                            Text(
                              date.day.toString(),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                        ? const Color(0xFF1F2937)
                                        : isWeekend
                                            ? const Color(0xFF6B7280)
                                            : isCurrentMonth
                                                ? const Color(0xFF1F2937)
                                                : const Color(0xFF6B7280),
                              ),
                            ),
                            if (hasBooking)
                              Container(
                                width: 3,
                                height: 3,
                                margin: const EdgeInsets.only(top: 1),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 16),

          // Bookings Section
          if (_selectedDate != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bookings for ${DateFormat('MMMM d').format(_selectedDate!)}",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.loading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
                        ),
                      ),
                    )
                  else if (selectedDateBookings.isEmpty)
                    Text(
                      "No bookings for this date",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF9CA3AF),
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    ...selectedDateBookings.map((booking) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              booking['title'] ?? 'Booking',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
