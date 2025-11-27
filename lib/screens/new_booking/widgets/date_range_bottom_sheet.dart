import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DateRangeBottomSheet extends StatefulWidget {
  final DateTime? initialCheckIn;
  final DateTime? initialCheckOut;
  final Function(DateTime, DateTime) onDateRangeSelected;

  const DateRangeBottomSheet({
    super.key,
    this.initialCheckIn,
    this.initialCheckOut,
    required this.onDateRangeSelected,
  });

  @override
  State<DateRangeBottomSheet> createState() => _DateRangeBottomSheetState();
}

class _DateRangeBottomSheetState extends State<DateRangeBottomSheet> {
  DateTime? _selectedCheckIn;
  DateTime? _selectedCheckOut;
  DateTime _firstDate = DateTime.now();
  DateTime _lastDate = DateTime.now().add(const Duration(days: 365));
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedCheckIn = widget.initialCheckIn;
    _selectedCheckOut = widget.initialCheckOut;
    _currentMonth = widget.initialCheckIn ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Dates',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Calendar View
          Expanded(
            child: Column(
              children: [
                // Calendar
                Expanded(
                  child: _buildCalendar(),
                ),
                
                // Date Range Info
                if (_selectedCheckIn != null && _selectedCheckOut != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildDateRangeInfo(),
                  ),
              ],
            ),
          ),

          // Footer with Apply Button
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedCheckIn != null && _selectedCheckOut != null
                      ? () {
                          widget.onDateRangeSelected(_selectedCheckIn!, _selectedCheckOut!);
                          Navigator.of(context).pop();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    disabledForegroundColor: const Color(0xFF9CA3AF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Column(
      children: [
        // Month Navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                  });
                },
                icon: const Icon(Icons.chevron_left, color: Color(0xFF1F2937)),
              ),
              Text(
                '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                  });
                },
                icon: const Icon(Icons.chevron_right, color: Color(0xFF1F2937)),
              ),
            ],
          ),
        ),
        
        // Calendar Grid
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildMonthView(_currentMonth),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthView(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final firstDayWeekday = firstDay.weekday;
    final daysInMonth = lastDay.day;
    
    final List<Widget> dayWidgets = [];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    // Empty cells for days before month starts
    for (int i = 1; i < firstDayWeekday; i++) {
      dayWidgets.add(const Expanded(child: SizedBox()));
    }
    
    // Days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final isInRange = _isDateInRange(date);
      final isCheckIn = _selectedCheckIn != null && _isSameDay(date, _selectedCheckIn!);
      final isCheckOut = _selectedCheckOut != null && _isSameDay(date, _selectedCheckOut!);
      final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
      
      dayWidgets.add(
        Expanded(
          child: GestureDetector(
            onTap: isPast ? null : () {
              setState(() {
                if (_selectedCheckIn == null || (_selectedCheckIn != null && _selectedCheckOut != null)) {
                  _selectedCheckIn = date;
                  _selectedCheckOut = null;
                } else if (_selectedCheckIn != null && date.isAfter(_selectedCheckIn!)) {
                  _selectedCheckOut = date;
                } else if (date.isBefore(_selectedCheckIn!)) {
                  _selectedCheckOut = _selectedCheckIn;
                  _selectedCheckIn = date;
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isCheckIn || isCheckOut
                    ? const Color(0xFF1F2937)
                    : (isInRange ? const Color(0xFF1F2937).withOpacity(0.1) : Colors.transparent),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  day.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isCheckIn || isCheckOut ? FontWeight.w600 : FontWeight.w400,
                    color: isPast
                        ? const Color(0xFFD1D5DB)
                        : (isCheckIn || isCheckOut
                            ? Colors.white
                            : const Color(0xFF1F2937)),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    // Calculate number of rows needed
    final totalCells = dayWidgets.length;
    final numRows = (totalCells / 7).ceil();
    
    return Column(
      children: [
        // Weekday headers row
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: weekdays.map((day) => Expanded(
            child: Center(
              child: Text(
                day,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          )).toList()),
        ),
        // Calendar rows
        ...List.generate(numRows, (rowIndex) {
          final startIndex = rowIndex * 7;
          final endIndex = (startIndex + 7) > dayWidgets.length ? dayWidgets.length : startIndex + 7;
          final rowWidgets = dayWidgets.sublist(startIndex, endIndex);
          // Fill remaining cells if needed
          while (rowWidgets.length < 7) {
            rowWidgets.add(const Expanded(child: SizedBox()));
          }
          return Row(children: rowWidgets);
        }),
      ],
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  bool _isDateInRange(DateTime date) {
    if (_selectedCheckIn == null || _selectedCheckOut == null) return false;
    return date.isAfter(_selectedCheckIn!) && date.isBefore(_selectedCheckOut!);
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Widget _buildDateRangeInfo() {
    final days = _selectedCheckOut!.difference(_selectedCheckIn!).inDays;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1F2937).withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: const Color(0xFF1F2937),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$days night${days != 1 ? 's' : ''} stay',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

