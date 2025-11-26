import 'package:flutter/material.dart';
import 'package:checkinn/screens/calendar/ui/widget/eventlist_tile.dart'; // Updated import
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:checkinn/screens/calendar/services/calendar_service.dart';
import 'package:checkinn/screens/bookings/bookingdetailpage.dart';
import 'package:checkinn/screens/bookings/models/bookingdetails.dart';
import 'package:checkinn/screens/bookings/services/bookings_service.dart';

class DayView extends StatefulWidget {
  const DayView({super.key});

  @override
  State<DayView> createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  int? startHour;
  int? endHour;
  DateTime selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _events = [];
  late ScrollController _dayScrollController;

  final List<String> hours = [
    "1 AM",
    "2 AM",
    "3 AM",
    "4 AM",
    "5 AM",
    "6 AM",
    "7 AM",
    "8 AM",
    "9 AM",
    "10 AM",
    "11 AM",
    "12 PM",
    "1 PM",
    "2 PM",
    "3 PM",
    "4 PM",
    "5 PM",
    "6 PM",
    "7 PM",
    "8 PM",
    "9 PM",
    "10 PM",
    "11 PM",
    "12 AM"
  ];

  // ScrollController removed as it's not used in the current UI implementation

  @override
  void initState() {
    super.initState();
    _dayScrollController = ScrollController();
    _setInitialSelectedTime();
    _loadDaily();
    // Scroll to selected date after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void dispose() {
    _dayScrollController.dispose();
    super.dispose();
  }

  void _setInitialSelectedTime() {
    final now = DateTime.now();
    final currentHour = now.hour;
    final index = currentHour % 24;
    setState(() {
      startHour = index;
      endHour = null;
    });
    // Note: ScrollController animation removed as there's no corresponding scrollable widget
    // This was causing the "ScrollController not attached to any scroll views" error
  }

  void _onHourTap(int index) {
    setState(() {
      if (startHour == null || (startHour != null && endHour != null)) {
        startHour = index;
        endHour = null;
      } else {
        if (index >= startHour!) {
          endHour = index;
        } else {
          startHour = index;
          endHour = null;
        }
      }
    });
  }

  void _changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
    _loadDaily();
    _scrollToSelectedDate();
  }

  int _daysInMonth(DateTime date) {
    final firstDayNextMonth = (date.month == 12)
        ? DateTime(date.year + 1, 1, 1)
        : DateTime(date.year, date.month + 1, 1);
    return firstDayNextMonth.subtract(const Duration(days: 1)).day;
  }

  void _selectDay(int day) {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month, day);
    });
    _loadDaily();
    _scrollToSelectedDate();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      _loadDaily();
      _scrollToSelectedDate();
    }
  }

  void _scrollToSelectedDate() {
    if (_dayScrollController.hasClients) {
      final selectedDay = selectedDate.day;
      final screenWidth = MediaQuery.of(context).size.width;
      final dayWidth = screenWidth * 0.12; // Same as in the ListView.builder
      final margin = screenWidth * 0.012; // Same as in the ListView.builder
      final totalItemWidth = dayWidth + (margin * 2);
      final targetOffset = (selectedDay - 1) * totalItemWidth;
      
      _dayScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _loadDaily() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      print('🔍 Day View - Loading bookings for: $selectedDate');
      
      // Use BookingsService to fetch bookings for the selected date
      final res = await BookingsService.getBookings(
        checkInDate: selectedDate,
        limit: 100, // Get more bookings for the day
      );
      
      print('🔍 Day View - API Response: $res');
      
      if (res['success'] == true) {
        final data = res['data'];
        // Try different possible keys for booking data
        final List<dynamic> list = (data['data'] ??
            data['bookings'] ??
            data['items'] ??
            []) as List<dynamic>;
        
        print('🔍 Day View - Found ${list.length} bookings');
        
        // Filter bookings that are actually for this specific date
        final filteredBookings = list.where((booking) {
          try {
            // Check if booking is for the selected date
            final checkInDate = DateTime.tryParse(booking['check_in_date'] ?? '');
            final checkOutDate = DateTime.tryParse(booking['check_out_date'] ?? '');
            
            if (checkInDate != null) {
              final bookingDate = DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
              final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
              return bookingDate.isAtSameMomentAs(selectedDateOnly);
            }
            
            if (checkOutDate != null) {
              final bookingDate = DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);
              final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
              return bookingDate.isAtSameMomentAs(selectedDateOnly);
            }
            
            return false;
          } catch (e) {
            print('🔍 Day View - Error filtering booking: $e');
            return false;
          }
        }).toList();
        
        print('🔍 Day View - Filtered to ${filteredBookings.length} bookings for selected date');
        
        setState(() {
          _events = filteredBookings;
          _isLoading = false;
        });
      } else {
        print('🔍 Day View - API Error: ${res['message']}');
        setState(() {
          _errorMessage = res['message'] ?? 'Failed to load bookings';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('🔍 Day View - Exception: $e');
      setState(() {
        _errorMessage = 'Error loading bookings: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _navigateToBookingDetail(Map<String, dynamic> event) {
    try {
      // Convert the event data to Booking model
      final booking = Booking.fromMap(event);
      
      // Navigate to booking detail page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BookingDetailsPage(booking: booking),
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

    return Column(
      children: [
        // Date and Hour Selection
        Container(
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * .02,
            horizontal: screenWidth * .025,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.2), width: 1),
          ),
          child: Column(
            children: [
              // Date Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        size: screenWidth * .04,
                        color: const Color(0xFF6366F1)),
                    onPressed: () => _changeDate(-1),
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                        DateFormat('MMMM').format(selectedDate),
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * .035,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios,
                        size: screenWidth * .04,
                        color: const Color(0xFF6366F1)),
                    onPressed: () => _changeDate(1),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * .015),
              // Days of current month row
              SizedBox(
                height: screenHeight * .05,
                child: ListView.builder(
                  controller: _dayScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: _daysInMonth(selectedDate),
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final bool isSelected = day == selectedDate.day;
                    return GestureDetector(
                      onTap: () => _selectDay(day),
                      child: Container(
                        width: screenWidth * .12,
                        margin: EdgeInsets.symmetric(
                            horizontal: screenWidth * .012),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6366F1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFF6366F1).withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            day.toString(),
                            style: GoogleFonts.poppins(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: screenHeight * .015),

        // Room Bookings List
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * .017,
              vertical: screenHeight * .01,
            ),
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
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.poppins(
                                color: Colors.red, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : _events.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'No bookings on ${DateFormat('dd MMM').format(selectedDate)}',
                                style: GoogleFonts.poppins(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * .03,
                                      vertical: 8),
                                  child: Text(
                                    "Bookings",
                                    style: GoogleFonts.poppins(
                                      fontSize: screenWidth * .045,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * .008),
                                ..._events.asMap().entries.map((entry) {
                                  final event =
                                      entry.value as Map<String, dynamic>;
                                  String roomName = (event['room_name'] ??
                                          event['room']?['name'] ??
                                          'Room')
                                      .toString();
                                  String guestName = (event['customer_name'] ??
                                          event['guest_name'] ??
                                          event['customer']?['name'] ??
                                          'Guest')
                                      .toString();
                                  int guests = 1;
                                  try {
                                    guests = (event['total_guests'] ??
                                        event['guests']?.length ??
                                        1) as int;
                                  } catch (_) {
                                    guests = int.tryParse(
                                            (event['total_guests'] ?? '1')
                                                .toString()) ??
                                        1;
                                  }
                                  String formatDateOnly(dynamic v) {
                                    if (v == null) return '';
                                    try {
                                      final dt = DateTime.tryParse(v.toString());
                                      if (dt != null) {
                                        return DateFormat('dd MMM yyyy').format(dt);
                                      }
                                      return v.toString();
                                    } catch (_) {
                                      return v.toString();
                                    }
                                  }

                                  final checkIn = formatDateOnly(
                                      event['check_in_date']);
                                  final checkOut = formatDateOnly(
                                      event['check_out_date']);
                                  final String status = (event['status'] ?? '')
                                      .toString()
                                      .toLowerCase();
                                  final Color tileColor = status
                                              .contains('confirmed') ||
                                          status.contains('upcoming')
                                      ? const Color(0xFF6366F1).withOpacity(.3)
                                      : status.contains('checked') ||
                                              status.contains('completed')
                                          ? const Color(0xFF22C55E)
                                              .withOpacity(.25)
                                          : status.contains('cancel')
                                              ? const Color(0xFFEF4444)
                                                  .withOpacity(.25)
                                              : const Color(0xFF8B5CF6)
                                                  .withOpacity(.25);

                                  return Padding(
                                    padding: EdgeInsets.only(
                                        bottom: screenHeight * .015),
                                    child: GestureDetector(
                                      onTap: () => _navigateToBookingDetail(event),
                                      child: BookingListTile(
                                        roomName: roomName,
                                        checkInDate:
                                            checkIn.isEmpty ? '-' : checkIn,
                                        checkOutDate:
                                            checkOut.isEmpty ? '-' : checkOut,
                                        guestName: guestName,
                                        guestsCount: guests.toString(),
                                        tileColor: tileColor,
                                        bookingData: event,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
          ),
        )
      ],
    );
  }
}
