import 'package:flutter/material.dart';
import 'package:checkinn/utils/routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:checkinn/screens/calendar/services/calendar_service.dart';
import 'package:checkinn/screens/bookings/bookingdetailpage.dart';
import 'package:checkinn/screens/bookings/models/bookingdetails.dart';
import 'package:checkinn/screens/bookings/services/bookings_service.dart';
import 'package:checkinn/screens/bookings/add_booking/add_booking_ui.dart';

class MonthView extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  
  const MonthView({
    super.key,
    this.onDateSelected,
  });

  @override
  State<MonthView> createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _focusedMonth;
  bool _isLoading = false;
  String? _errorMessage;
  Map<DateTime, List<dynamic>> _monthlyBookings = {};

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    _loadMonthlyBookings();
  }

  void _previousMonth() {
    setState(() {
      if (_focusedMonth.month == 1) {
        _focusedMonth = DateTime(_focusedMonth.year - 1, 12, 1);
      } else {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
      }
    });
    _loadMonthlyBookings();
  }

  void _nextMonth() {
    setState(() {
      if (_focusedMonth.month == 12) {
        _focusedMonth = DateTime(_focusedMonth.year + 1, 1, 1);
      } else {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
      }
    });
    _loadMonthlyBookings();
  }

  Future<void> _loadMonthlyBookings() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Calculate start and end dates for the month
      final startDate = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
      final endDate = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

      print('🔍 Month View - Loading bookings for ${DateFormat('MMMM yyyy').format(_focusedMonth)}');
      print('🔍 Month View - Start date: $startDate, End date: $endDate');

      // Use BookingsService to fetch bookings for the month
      final result = await BookingsService.getBookings(
        checkInDate: startDate,
        checkOutDate: endDate,
        limit: 200, // Get more bookings for the month
      );

      print('🔍 Month View - API Response: $result');

      if (!mounted) return;

      if (result['success'] == true) {
        final data = result['data'];
        final List<dynamic> bookings = (data['data'] ?? data['bookings'] ?? data['items'] ?? []) as List<dynamic>;
        
        print('🔍 Month View - Loaded ${bookings.length} bookings');

        // Group bookings by date
        final Map<DateTime, List<dynamic>> monthlyBookings = {};
        for (var booking in bookings) {
          try {
            final checkInDate = DateTime.tryParse(booking['check_in_date'] ?? booking['check_in_time'] ?? '');
            if (checkInDate != null) {
              final dateKey = DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
              monthlyBookings[dateKey] = monthlyBookings[dateKey] ?? [];
              monthlyBookings[dateKey]!.add(booking);
            }
          } catch (e) {
            print('🔍 Month View - Error parsing booking date: $e');
          }
        }

        print('🔍 Month View - Grouped bookings into ${monthlyBookings.length} dates');

        if (!mounted) return;
        setState(() {
          _monthlyBookings = monthlyBookings;
          _isLoading = false;
        });
      } else {
        print('🔍 Month View - API Error: ${result['message']}');
        if (!mounted) return;
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load monthly bookings';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🔍 Month View - Exception: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error loading bookings: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    
    // Notify parent to switch to day view with selected date
    if (widget.onDateSelected != null) {
      widget.onDateSelected!(date);
    }
  }

  void _showBookingSelectionDialog(List<dynamic> bookings) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.event,
                  color: Color(0xFF1F2937),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Select Booking',
                style: GoogleFonts.inter(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final guestName = (booking['customer_name'] ?? 
                    booking['guest_name'] ?? 
                    booking['customer']?['name'] ?? 
                    'Guest').toString();
                final status = (booking['status'] ?? '').toString().toLowerCase();
                // derive guest count
                int guestsCount = 1;
                try {
                  dynamic v = booking['total_guests'] ?? booking['guests_count'] ?? booking['guest_count'] ?? booking['no_of_guests'] ?? booking['num_guests'];
                  if (v == null && booking['guests'] is List) {
                    v = (booking['guests'] as List).length;
                  }
                  if (v == null) {
                    final adults = int.tryParse((booking['adults'] ?? '0').toString()) ?? 0;
                    final children = int.tryParse((booking['children'] ?? '0').toString()) ?? 0;
                    v = adults + children;
                  }
                  guestsCount = int.tryParse(v.toString()) ?? 1;
                } catch (_) {}

                String fmtDate(dynamic v) {
                  try {
                    final dt = DateTime.tryParse((v ?? '').toString());
                    if (dt != null) return DateFormat('dd MMM yyyy').format(dt);
                  } catch (_) {}
                  return '-';
                }
                final checkIn = fmtDate(booking['check_in_date']);
                final checkOut = fmtDate(booking['check_out_date']);
                
                Color statusColor;
                if (status.contains('confirmed') || status.contains('upcoming')) {
                  statusColor = const Color(0xFF1F2937);
                } else if (status.contains('checked') || status.contains('completed')) {
                  statusColor = const Color(0xFF22C55E);
                } else if (status.contains('cancel')) {
                  statusColor = const Color(0xFFEF4444);
                } else {
                  statusColor = const Color(0xFF1F2937);
                }

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                  ),
                  child: ListTile(
                  // no leading icon per requirement
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text(
                    guestName,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 2),
                      Row(
                        children: [
                      const Icon(Icons.people_outline, size: 14, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Text(
                        '$guestsCount Guests',
                        style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.login, size: 14, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                      Text('Check-in: $checkIn', style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.logout, size: 14, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                      Text('Check-out: $checkOut', style: GoogleFonts.inter(color: const Color(0xFF6B7280), fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  // trailing status chip removed as requested
                  onTap: () {
                    Navigator.of(context).pop();
                    _navigateToBookingDetail(booking);
                  },
                ));
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showNoBookingsDialog(DateTime date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.event_available,
                  color: Color(0xFF1F2937),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No Bookings',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No bookings on',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(date),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This date is available for new bookings',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F2937), Color(0xFF1F2937)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to add booking screen or show add booking sheet
                  _showAddBookingSheet();
                },
                child: Text(
                  'Add Booking',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddBookingSheet() {
    // Navigate to the add booking form
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddBookingUi(),
      ),
    ).then((result) {
      // Refresh the calendar if a booking was created
      if (result == true) {
        _loadMonthlyBookings();
      }
    });
  }

  void _navigateToBookingDetail(Map<String, dynamic> booking) {
    try {
      // Convert the booking data to Booking model
      final bookingModel = Booking.fromMap(booking);
      
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    try {
      final DateTime firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
      // Calculate how many empty cells we need at the start
      // Sunday = 7, Monday = 1, Tuesday = 2, etc.
      final int firstWeekdayOfMonth = firstDayOfMonth.weekday == 7 ? 0 : firstDayOfMonth.weekday;
      final int daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

      final List<DateTime?> calendarDates = <DateTime?>[];
      
      // Add empty cells for days before the first day of the month
      for (int i = 0; i < firstWeekdayOfMonth; i++) {
        calendarDates.add(null);
      }
      
      // Add all days of the month
      for (int i = 1; i <= daysInMonth; i++) {
        calendarDates.add(DateTime(_focusedMonth.year, _focusedMonth.month, i));
      }
      
          // Ensure we have enough cells to fill the grid (6 rows * 7 columns = 42 cells)
    // Add empty cells at the end if needed
    while (calendarDates.length < 42) {
      calendarDates.add(null);
    }
    
    // Limit to maximum 6 rows to prevent overflow
    if (calendarDates.length > 42) {
      calendarDates.removeRange(42, calendarDates.length);
    }

    return Column(
        children: [
          // Month navigation
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1F2937).withOpacity(0.2), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: const Color(0xFF1F2937)),
                  onPressed: _previousMonth,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    DateFormat('MMMM yyyy').format(_focusedMonth),
                    style: GoogleFonts.inter(
                      fontSize: screenWidth * .045,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: const Color(0xFF1F2937)),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          // Week headers
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 6),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map((day) => Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Text(
                  day,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                    fontSize: 14,
                  ),
                ),
              ))
                  .toList(),
            ),
          ),
          // Calendar grid
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
                    ),
                  )
                : _errorMessage != null
                    ? Center(
            child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load calendar',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadMonthlyBookings,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.0,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: calendarDates.length,
              itemBuilder: (context, index) {
                final date = calendarDates[index];
                if (date == null) return const SizedBox.shrink();

                final isSelected = date.year == _selectedDate.year &&
                    date.month == _selectedDate.month &&
                    date.day == _selectedDate.day;

                final isToday = date.year == DateTime.now().year &&
                    date.month == DateTime.now().month &&
                    date.day == DateTime.now().day;

                final dateKey = DateTime(date.year, date.month, date.day);
                final hasEvent = _monthlyBookings.containsKey(dateKey) && _monthlyBookings[dateKey]!.isNotEmpty;
                final bookingCount = _monthlyBookings[dateKey]?.length ?? 0;

                return GestureDetector(
                  onTap: () => _selectDate(date),
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1F2937)
                          : isToday
                          ? const Color(0xFF1F2937).withOpacity(0.1)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            '${date.day}',
                            style: GoogleFonts.inter(
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                  ? const Color(0xFF1F2937)
                                  : const Color(0xFF1F2937),
                              fontWeight: isToday || isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (hasEvent)
                          Positioned(
                            bottom: 6,
                            right: 0,
                            left: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Show booking indicators based on status
                                ..._monthlyBookings[dateKey]!.take(3).map((booking) {
                                  final status = (booking['status'] ?? '').toString().toLowerCase();
                                  Color indicatorColor;
                                  if (status.contains('confirmed') || status.contains('upcoming')) {
                                    indicatorColor = const Color(0xFF1F2937);
                                  } else if (status.contains('checked') || status.contains('completed')) {
                                    indicatorColor = const Color(0xFF22C55E);
                                  } else if (status.contains('cancel')) {
                                    indicatorColor = const Color(0xFFEF4444);
                                  } else {
                                    indicatorColor = const Color(0xFF1F2937);
                                  }
                                  
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 1),
                                    child: CircleAvatar(
                                  radius: 2.5,
                                      backgroundColor: indicatorColor,
                                    ),
                                  );
                                }).toList(),
                                // Show count if more than 3 bookings
                                if (bookingCount > 3)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 2),
                                    child: Text(
                                      '+${bookingCount - 3}',
                                      style: GoogleFonts.inter(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
              ),
          ),
        ],
      );
    } catch (e) {
      // Return a simple error widget if something goes wrong
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Calendar Error',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }
  }
}