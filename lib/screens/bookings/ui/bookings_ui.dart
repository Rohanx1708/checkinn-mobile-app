import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/bookingdetails.dart';
import '../services/bookings_service.dart';
import '../widgets/booking_header.dart';
import '../widgets/search_filter_section.dart';
import '../widgets/booking_list.dart';
import '../widgets/add_booking_sheet.dart';
import '../widgets/filter.dart';
import '../../../widgets/common_app_bar.dart';
import '../../Dashboard/widget/drawer_widget.dart';
import '../add_booking/add_booking_ui.dart';

class BookingsUi extends StatefulWidget {
  const BookingsUi({super.key});

  @override
  State<BookingsUi> createState() => BookingsUiState();
}

class BookingsUiState extends State<BookingsUi> {
  final TextEditingController _searchController = TextEditingController();
  String _status = "All"; // Default status

  List<Booking> allBookings = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  // Filter state
  String? _selectedStatus;
  String? _selectedDateFilter;

  @override
  void initState() {
    super.initState();
    
    _searchController.addListener(() {
      // Debounce search to avoid too many API calls
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          loadBookings();
        }
      });
    });
    
    // Load bookings from API
    loadBookings();
  }

  Future<void> loadBookings() async {
    print('🔄 BookingsUiState.loadBookings() called');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Convert filter values to API parameters
      String? apiStatus;
      DateTime? checkInDate;
      DateTime? checkOutDate;

      // Map status filter to API status
      if (_selectedStatus != null && _selectedStatus != "All Statuses") {
        switch (_selectedStatus) {
          case "Pending":
            apiStatus = "pending";
            break;
          case "Confirmed":
            apiStatus = "confirmed";
            break;
          case "Checked In":
            apiStatus = "checked_in";
            break;
          case "Checked Out":
            apiStatus = "checked_out";
            break;
          case "Cancelled":
            apiStatus = "cancelled";
            break;
        }
      }

      // Map date filter to date range
      if (_selectedDateFilter != null && _selectedDateFilter != "All Dates") {
        final now = DateTime.now();
        switch (_selectedDateFilter) {
          case "Today":
            checkInDate = DateTime(now.year, now.month, now.day);
            checkOutDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
            break;
          case "Tomorrow":
            final tomorrow = now.add(const Duration(days: 1));
            checkInDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
            checkOutDate = DateTime(
                tomorrow.year, tomorrow.month, tomorrow.day, 23, 59, 59);
            break;
          case "This Week":
            // Get start of week (Monday)
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            final endOfWeek = startOfWeek.add(const Duration(days: 6));
            checkInDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
            checkOutDate = DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);
            break;
          case "This Month":
            checkInDate = DateTime(now.year, now.month, 1);
            checkOutDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
            break;
          case "Upcoming":
            checkInDate = now;
            checkOutDate = now.add(const Duration(days: 30));
            break;
        }
      }

      print('🔍 API Params => status: $apiStatus, range: '
          '${checkInDate?.toIso8601String().split('T').first} - '
          '${checkOutDate?.toIso8601String().split('T').first}');
      print('🔍 Selected Date Filter: $_selectedDateFilter');
      print('🔍 CheckInDate: $checkInDate');
      print('🔍 CheckOutDate: $checkOutDate');

      final result = await BookingsService.getBookings(
        page: 1,
        limit: 50,
        search: _searchController.text.isNotEmpty
            ? _searchController.text
            : null,
        status: apiStatus,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
      );

      if (result['success']) {
        List<Booking> bookings = [];
        final data = result['data'];
        final List<dynamic> list = (data['data'] ?? data['bookings'] ?? []) as List<dynamic>;
        print('🧾 UI: bookings in payload: ${list.length}');

        if (data['bookings'] != null) {
          // Handle bookings array response
          print('🔍 UI: Found bookings array with ${(data['bookings'] as List).length} items');
          for (var bookingData in data['bookings']) {
            try {
              bookings.add(Booking.fromJson(bookingData));
            } catch (e) {
              print('❌ Error parsing booking: $e');
            }
          }
        } else if (data['data'] != null) {
          // Handle paginated response
          print('🔍 UI: Found paginated data array with ${(data['data'] as List).length} items');
          for (var bookingData in data['data']) {
            try {
              bookings.add(Booking.fromJson(bookingData));
            } catch (e) {
              print('❌ Error parsing booking: $e');
            }
          }
        } else {
          print('🔍 UI: No bookings or data array found in response');
        }

        // If backend returns pagination meta, fetch remaining pages
        try {
          final pagination = data['pagination'];
          if (pagination != null) {
            final int lastPage = pagination['last_page'] is int
                ? pagination['last_page']
                : int.tryParse(pagination['last_page'].toString()) ?? 1;
            if (lastPage > 1) {
              for (int p = 2; p <= lastPage; p++) {
                final pageRes = await BookingsService.getBookings(
                  page: p,
                  limit: 50,
                  search: _searchController.text.isNotEmpty
                      ? _searchController.text
                      : null,
                  status: apiStatus,
                  checkInDate: checkInDate,
                  checkOutDate: checkOutDate,
                );
                if (pageRes['success']) {
                  final pdata = pageRes['data'];
                  final List<dynamic> list2 = (pdata['data'] ?? pdata['bookings'] ?? []) as List<dynamic>;
                  for (var bookingData in list2) {
                    try {
                      bookings.add(Booking.fromJson(bookingData));
                    } catch (_) {}
                  }
                }
              }
            }
          }
        } catch (_) {}

        setState(() {
          allBookings = bookings;
          _isLoading = false;
        });

        print('📅 Loaded ${bookings.length} bookings (after pagination)');
        print('✅ BookingsUiState.loadBookings() completed successfully');
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load bookings';
          _isLoading = false;
        });
      }
    }
    catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshBookings() async {
    await loadBookings();
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedDateFilter = null;
    });
    loadBookings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FiltersModal(
        currentStatus: _selectedStatus,
        currentDateFilter: _selectedDateFilter,
        onApplyFilters: (status, dateFilter) {
          print('🔍 Applied filters - Status: $status, Date Filter: $dateFilter');
          setState(() {
            _selectedStatus = status;
            _selectedDateFilter = dateFilter;
          });
          loadBookings();
        },
      ),
    );
  }

  void _showAddBookingBottomSheet() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddBookingUi(),
      ),
    ).then((result) {
      // Refresh the bookings list if a booking was created
      if (result == true) {
        loadBookings();
      }
    });
  }

  Future<void> _addBooking(Booking booking) async {
    try {
      final result = await BookingsService.createBookingWithParams(
        customerName: booking.customer.name,
        customerEmail: booking.customer.email?.isNotEmpty == true ? booking.customer.email : null,
        customerPhone: booking.customer.phone,
        checkInDate: booking.checkInDate,
        checkOutDate: booking.checkOutDate,
        totalGuests: booking.totalGuests,
        propertyId: "1", 
        status: booking.status,
        notes: booking.notes,
        remarks: booking.remarks,
        subtotal: booking.subtotal,
        gst: booking.gst,
        totalCost: booking.totalCost,
        discount: booking.discount,
        finalAmount: booking.finalAmount,
        guests: booking.guests.map((g) => {
          'name': g.name,
          'email': g.email,
          'phone': g.phone,
        }).toList(),
        addOns: booking.addOns.map((a) => a.toMap()).toList(),
        // Additional required fields
        adults: booking.totalGuests,
        children: 0, // Default to 0 children
        infants: 0, // Default to 0 infants
        totalAmount: booking.totalCost,
        paymentStatus: 'pending', // Default payment status
        bookingStatus: booking.status,
        source: 'direct', // Default source
        roomType: booking.roomType,
      );

      if (result['success']) {
        // Refresh the bookings list
        await _refreshBookings();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to add booking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding booking: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

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
              // Header Section with Welcome Message
              const BookingHeader(),

              // Search and Filter Section
              SearchFilterSection(
                searchController: _searchController,
                onFilterTap: _showFilters,
              ),

              const SizedBox(height: 20),

              // Single list (no tabs)
              Expanded(
                child: _buildBookingsList("All"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsList(String type) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load bookings',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshBookings,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Filter bookings based on type and search
    List<Booking> filteredBookings = allBookings.where((booking) {
      bool matchesType = true;
      bool matchesSearch = true;

      // Filter by type
      if (type != "All") {
        if (type == "Upcoming") {
          matchesType = booking.status.toLowerCase() == "upcoming" || 
                       booking.status.toLowerCase() == "confirmed" ||
                       booking.status.toLowerCase() == "pending";
        } else if (type == "Completed") {
          matchesType = booking.status.toLowerCase() == "completed" || 
                       booking.status.toLowerCase() == "checked-out";
        }
      }

      // Filter by search
      if (_searchController.text.isNotEmpty) {
        final searchQuery = _searchController.text.toLowerCase();
        matchesSearch = booking.customer.name.toLowerCase().contains(searchQuery) ||
                       booking.title.toLowerCase().contains(searchQuery) ||
                       booking.customer.phone.toLowerCase().contains(searchQuery);
      }

      return matchesType && matchesSearch;
    }).toList();
    
    return RefreshIndicator(
      onRefresh: _refreshBookings,
      child: BookingList(
      bookings: filteredBookings,
      searchQuery: _searchController.text,
      ),
    );
  }
}
