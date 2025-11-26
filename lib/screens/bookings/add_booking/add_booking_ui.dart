import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../config/api_config.dart';
import '../../../../services/auth_service.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/common_app_bar.dart';
import '../models/bookingdetails.dart';
import '../services/bookings_service.dart';
import '../../rooms/services/rooms_service.dart';
import '../../../../utils/app_fonts.dart';
import 'services/booking_meta_service.dart';
import 'widgets/section_header.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/date_field.dart';
import 'widgets/guest_counter.dart';

class AddBookingUi extends ConsumerStatefulWidget {
  final Booking? existingBooking; // For editing existing bookings
  final VoidCallback? onBookingUpdated; // Callback to refresh booking list
  
  const AddBookingUi({super.key, this.existingBooking, this.onBookingUpdated});

  @override
  ConsumerState<AddBookingUi> createState() => _AddBookingUiState();
}

class _AddBookingUiState extends ConsumerState<AddBookingUi> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _remarksController = TextEditingController();
  final _subtotalController = TextEditingController();
  final _gstController = TextEditingController();
  final _discountController = TextEditingController();

  // Form data
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  // Room selection state
  // Removed deprecated single-room variables - use _roomSelections instead
  int? _selectedRoomId;
  // [Deprecated single-room arrays removed] Use `_roomSelections` instead
  int _totalGuests = 1;
  String _selectedStatus = 'confirmed';
  String _selectedPaymentStatus = 'pending';
  String _selectedSource = 'direct';
  double _subtotal = 0.0;
  double _gst = 0.0;
  double _totalCost = 0.0;
  double _discount = 0.0;
  double _finalAmount = 0.0;

  // Meta options
  List<String> _paymentStatuses = const ['pending','paid','partial','refunded','failed'];
  List<String> _sources = const ['direct','website','walk-in','phone','ota','agent'];

  // API Data
  List<Map<String, dynamic>> _roomTypes = [];
  List<Map<String, dynamic>> _rooms = [];
// Rooms filtered by selected room type
  // Multi-room-type selections: each item {roomTypeId, roomTypeName, roomId, roomLabel}
  final List<Map<String, dynamic>> _roomSelections = [];
  final Map<int, List<Map<String, dynamic>>> _availableRoomsByType = {};
  // Removed property selection state
  bool _isLoadingAvailableRooms = false;
  bool _isSubmitting = false; // Loading state for form submission
  
  List<String> _statuses = const [
    'confirmed', 
    'checked-in', 
    'checked-out', 
    'pending',
    'cancelled',
  ];

  String _statusToApi(String value) {
    final v = (value).trim().toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
    return v;
  }

  String _statusToDisplay(String value) {
    final v = (value).trim().toLowerCase().replaceAll('_', '-');
    return v;
  }

  @override
  void initState() {
    super.initState();
    // Kick off meta fetch via Riverpod; also keep local loaders for current screen needs
    ref.read(bookingMetaProvider.future).then((meta) {
      if (!mounted) return;
      setState(() {
        _paymentStatuses = meta.paymentStatuses;
        _statuses = meta.bookingStatuses.map((s) => _statusToDisplay(s)).toList();
        _sources = meta.sources;
      });
    });

    _loadInitialData().then((_) async {
      if (widget.existingBooking != null) {
        // Wait a bit to ensure room types are fully loaded
        await Future.delayed(const Duration(milliseconds: 100));
        await _populateFormWithExistingData();
      }
    });
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadRoomTypes(),
      _loadMetaOptions(),
    ]);
    
    // Initialize rooms with fallback data directly
    _rooms = _getFallbackRooms();
    
    // Initialize available rooms - no longer needed as we use _availableRoomsByType
    // Only initialize empty selection for new bookings, not when editing existing bookings
    if (_roomSelections.isEmpty && widget.existingBooking == null) {
      _roomSelections.add({
        'roomTypeId': 0,
        'roomTypeName': '',
        'roomId': null,
        'roomLabel': '',
      });
    }
    
    // Load available rooms for any existing room selections
    if (_roomSelections.isNotEmpty && _checkInDate != null && _checkOutDate != null) {
      _reloadAllAvailableRooms();
    }

  }

  Future<void> _loadMetaOptions() async {
    try {
      // Prepare headers
      final token = await AuthService.getToken();
      final headers = token != null ? ApiConfig.getAuthHeaders(token) : ApiConfig.defaultHeaders;

      // Try primary endpoint
      final metaUris = <Uri>[
        Uri.parse('${ApiConfig.baseUrl}/v1/bookings/meta'),
        Uri.parse('${ApiConfig.baseUrl}/v1/bookings/options'),
      ];

      List<String>? fetchedPaymentStatuses;
      List<String>? fetchedSources;
      List<String>? fetchedBookingStatuses;

      for (final uri in metaUris) {
        try {
          final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
          if (res.statusCode >= 200 && res.statusCode < 300 && res.body.isNotEmpty) {
            final decoded = jsonDecode(res.body);
            final Map<String, dynamic> meta = (decoded is Map && decoded['data'] is Map)
                ? (decoded['data'] as Map).cast<String, dynamic>()
                : (decoded is Map ? decoded.cast<String, dynamic>() : <String, dynamic>{});
            final psDyn = meta['payment_statuses'] ?? meta['paymentStatuses'] ?? meta['payment-statuses'] ?? meta['payments'] ?? [];
            final srcDyn = meta['sources'] ?? meta['booking_sources'] ?? meta['bookingSources'] ?? [];
            final bsDyn = meta['booking_statuses'] ?? meta['bookingStatuses'] ?? meta['statuses'] ?? [];
            if (psDyn is List) {
              fetchedPaymentStatuses = psDyn.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
            }
            if (srcDyn is List) {
              fetchedSources = srcDyn.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
            }
            if (bsDyn is List) {
              fetchedBookingStatuses = bsDyn.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
            }
          }
        } catch (_) {}
        if (fetchedPaymentStatuses != null || fetchedSources != null || fetchedBookingStatuses != null) break;
      }

      // Fallback: dedicated sources endpoint
      if (fetchedSources == null) {
        try {
          final uri = Uri.parse('${ApiConfig.baseUrl}/v1/bookings/sources');
          final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
          if (res.statusCode >= 200 && res.statusCode < 300) {
            final decoded = jsonDecode(res.body);
            final list = (decoded['data'] ?? decoded['sources'] ?? decoded) as dynamic;
            if (list is List) {
              fetchedSources = list.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
            }
          }
        } catch (_) {}
      }

      // Fallback: dedicated booking statuses endpoint
      if (fetchedBookingStatuses == null) {
        try {
          final uri = Uri.parse('${ApiConfig.baseUrl}/v1/bookings/statuses');
          final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
          if (res.statusCode >= 200 && res.statusCode < 300) {
            final decoded = jsonDecode(res.body);
            final list = (decoded['data'] ?? decoded['statuses'] ?? decoded) as dynamic;
            if (list is List) {
              fetchedBookingStatuses = list.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
            }
          }
        } catch (_) {}
      }

      // Fallback: CRM customer sources; use keys as labels
      if (fetchedSources == null) {
        try {
          final uri = Uri.parse('${ApiConfig.baseUrl}/v1/crm/customer-sources');
          final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
          if (res.statusCode >= 200 && res.statusCode < 300) {
            final decoded = jsonDecode(res.body);
            final map = (decoded['data'] ?? decoded) as Map<String, dynamic>;
            fetchedSources = map.keys.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
          }
        } catch (_) {}
      }

      if (!mounted) return;
    setState(() {
        if (fetchedPaymentStatuses != null && fetchedPaymentStatuses.isNotEmpty) {
          _paymentStatuses = fetchedPaymentStatuses!;
          if (!_paymentStatuses.contains(_selectedPaymentStatus)) {
            _selectedPaymentStatus = _paymentStatuses.first;
          }
        }
        if (fetchedSources != null && fetchedSources.isNotEmpty) {
          _sources = fetchedSources!;
          if (!_sources.contains(_selectedSource)) {
            _selectedSource = _sources.first;
          }
        }
        if (fetchedBookingStatuses != null && fetchedBookingStatuses.isNotEmpty) {
          // Show hyphenated labels to users
          _statuses = fetchedBookingStatuses!.map((s) => _statusToDisplay(s)).toList();
          final normalized = _statusToDisplay(_selectedStatus).toLowerCase();
          final match = _statuses.firstWhere(
            (s) => s.toLowerCase() == normalized,
            orElse: () => _statuses.first,
          );
          _selectedStatus = match;
        }
      });
    } catch (_) {}
  }
  

  // Removed _loadProperties function and PropertiesService usage

  Future<void> _loadRoomTypes() async {
    try {
      final result = await RoomsService.getRoomTypes(
        search: '',
        limit: 100, // Load all room types
      );

      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _roomTypes = _extractRoomTypes(result['data']);
        });
      } else {
        _showErrorSnackBar('Failed to load room types: ${result['message']}');
      }
    } catch (e) {
      _showErrorSnackBar('Error loading room types: ${e.toString()}');
    }
  }


  // Removed deprecated _loadAvailableRooms method - use _loadAvailableRoomsForType instead
  
  Future<void> _reloadAllAvailableRooms() async {
    for (final selection in _roomSelections) {
      final roomTypeId = selection['roomTypeId'] as int;
      if (roomTypeId > 0 && _checkInDate != null && _checkOutDate != null) {
        await _loadAvailableRoomsForType(roomTypeId);
      }
    }
  }
  
  void _clearRoomSelection(int index) {
      setState(() {
      _roomSelections[index]['roomId'] = null;
      _roomSelections[index]['roomLabel'] = '';
    });
  }

  Future<void> _loadAvailableRoomsForType(int roomTypeId) async {
    if (roomTypeId == 0 || _checkInDate == null || _checkOutDate == null) {
      _availableRoomsByType[roomTypeId] = [];
      setState(() {});
      return;
    }
    setState(() {
      _isLoadingAvailableRooms = true;
    });
    try {
      final result = await BookingsService.getAvailableRooms(
        roomTypeId: roomTypeId,
        checkInDate: _checkInDate!,
        checkOutDate: _checkOutDate!,
      );
      List<Map<String, dynamic>> availableRooms = [];
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
        if (data is Map && data.containsKey('data')) {
          final roomsData = data['data'];
          if (roomsData is Map && roomsData.containsKey('rooms')) {
            final rooms = roomsData['rooms'];
            if (rooms is List) availableRooms = List<Map<String, dynamic>>.from(rooms);
          } else if (roomsData is List) {
            availableRooms = List<Map<String, dynamic>>.from(roomsData);
          }
        } else if (data is List) {
          availableRooms = List<Map<String, dynamic>>.from(data);
        }
      }
      setState(() {
        _availableRoomsByType[roomTypeId] = availableRooms;
        _isLoadingAvailableRooms = false;
      });
    } catch (e) {
      setState(() {
        _availableRoomsByType[roomTypeId] = [];
        _isLoadingAvailableRooms = false;
      });
    }
  }


  List<Map<String, dynamic>> _extractRoomTypes(dynamic data) {
    try {
      List<Map<String, dynamic>> roomTypes = [];
      
      if (data is Map) {
        // Handle single room type
        if (data.containsKey('id') && data.containsKey('name')) {
          roomTypes.add(Map<String, dynamic>.from(data));
        }
        // Handle paginated response
        else if (data.containsKey('data') && data['data'] is List) {
          roomTypes.addAll(List<Map<String, dynamic>>.from(data['data']));
        }
      } else if (data is List) {
        // Handle list response
        roomTypes.addAll(List<Map<String, dynamic>>.from(data));
      }
      
      return roomTypes;
    } catch (e) {
      return [];
    }
  }

  List<Map<String, dynamic>> _getFallbackRooms() {
    // Return hardcoded fallback rooms when API fails
    return [
      {
        'id': '1',
        'name': 'Room 101',
        'room_type': {'name': 'Standard'},
        'floor': '1',
        'status': 'available',
        'base_price': 1500.0,
      },
      {
        'id': '2',
        'name': 'Room 102',
        'room_type': {'name': 'Standard'},
        'floor': '1',
        'status': 'available',
        'base_price': 1500.0,
      },
      {
        'id': '3',
        'name': 'Room 201',
        'room_type': {'name': 'Deluxe'},
        'floor': '2',
        'status': 'available',
        'base_price': 2500.0,
      },
      {
        'id': '4',
        'name': 'Room 202',
        'room_type': {'name': 'Deluxe'},
        'floor': '2',
        'status': 'available',
        'base_price': 2500.0,
      },
      {
        'id': '5',
        'name': 'Room 301',
        'room_type': {'name': 'Suite'},
        'floor': '3',
        'status': 'available',
        'base_price': 3500.0,
      },
    ];
  }


  Future<void> _sendBookingConfirmation(dynamic bookingData) async {
    try {
      // Extract booking ID from response
      String? bookingId;
      if (bookingData is Map<String, dynamic>) {
        bookingId = bookingData['id']?.toString() ?? bookingData['booking_id']?.toString();
      }

      if (bookingId != null) {
        // Update booking status to confirmed
        final statusResult = await BookingsService.updateBookingStatus(
          bookingId: bookingId,
          status: 'confirmed',
          notes: 'Booking confirmed via mobile app',
        );

        if (statusResult['success'] == true) {
          _showInfoSnackBar('Booking confirmation sent to customer');
        }
      }
    } catch (e) {
      // Don't show error to user as booking was already created successfully
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppFonts.poppins(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showInfoSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppFonts.poppins(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppFonts.poppins(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }


  @override
  void dispose() {
    _pageController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _remarksController.dispose();
    _subtotalController.dispose();
    _gstController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _populateFormWithExistingData() async {
    final booking = widget.existingBooking!;
    
    // Customer Information
    _customerNameController.text = booking.customer.name;
    _customerPhoneController.text = booking.customer.phone;
    _customerEmailController.text = booking.customer.email ?? '';
    _remarksController.text = booking.remarks ?? '';
    
    // Booking Details
    _checkInDate = booking.checkInDate;
    _checkOutDate = booking.checkOutDate;
    _totalGuests = booking.totalGuests;
    // Normalize existing booking status for display
    final displayStatus = _statusToDisplay(booking.status);
    _selectedStatus = _statuses.contains(displayStatus) ? displayStatus : _statuses.first;
    _selectedPaymentStatus = (booking.paymentStatus ?? _selectedPaymentStatus).toLowerCase();
    _selectedSource = (booking.source ?? _selectedSource).toLowerCase();
    
    // Room Information - For editing, start with empty selections to avoid confusion
    // The user should explicitly select which rooms they want to keep
    _roomSelections.clear();
    
    // Add one empty room selection for the user to fill
    _roomSelections.add({
      'roomTypeId': 0,
      'roomTypeName': '',
      'roomId': null,
      'roomLabel': '',
    });
    
    // No need to load existing room data - user will select fresh
    
    // Pricing
    _subtotal = booking.subtotal;
    _gst = booking.gst;
    _totalCost = booking.totalCost;
    _discount = booking.discount ?? 0.0;
    _finalAmount = booking.finalAmount;
    
    // Update pricing controllers
    _subtotalController.text = _subtotal.toStringAsFixed(2);
    _gstController.text = _gst.toStringAsFixed(2);
    _discountController.text = _discount.toStringAsFixed(2);
    
    setState(() {});
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _calculateTotal() {
    _totalCost = _subtotal + _gst;
    _finalAmount = _totalCost - _discount;
    if (_finalAmount < 0) _finalAmount = 0;
  }

  Future<void> _calculatePricing() async {
    if (_roomSelections.isEmpty || _checkInDate == null || _checkOutDate == null) {
      return;
    }

    try {
      // Calculate number of nights
      final nights = _checkOutDate!.difference(_checkInDate!).inDays;
      if (nights <= 0) return;

      // Sum subtotal across selected room types
      double subtotal = 0.0;
      final selections = _roomSelections.where((s) => (s['roomId'] != null && (s['roomTypeId'] ?? 0) != 0)).toList();
      if (selections.isEmpty) {
        // Use first selected room type for fallback pricing
        final firstSelection = _roomSelections.firstWhere((s) => (s['roomTypeId'] ?? 0) != 0, orElse: () => {});
        final roomTypeName = firstSelection['roomTypeName'] ?? '';
      final roomType = _roomTypes.firstWhere(
          (rt) => (rt['name'] ?? '').toLowerCase() == roomTypeName.toLowerCase(),
        orElse: () => {},
      );
      if (roomType.isNotEmpty) {
          final basePrice = double.tryParse((roomType['base_price'] ?? roomType['price'] ?? 0.0).toString()) ?? 0.0;
          final count = _roomSelections.where((s) => s['roomId'] != null).length == 0 ? 1 : _roomSelections.where((s) => s['roomId'] != null).length;
          subtotal = basePrice * nights * count;
        }
      } else {
        for (final s in selections) {
          final int typeId = s['roomTypeId'];
          Map<String, dynamic> rt = {};
          try {
            rt = _roomTypes.firstWhere((r) => (r['id'] ?? r['room_type_id']) == typeId, orElse: () => {});
          } catch (_) {}
          final basePrice = double.tryParse((rt['base_price'] ?? rt['price'] ?? 0.0).toString()) ?? 0.0;
          subtotal += basePrice * nights;
        }
      }
      if (subtotal > 0) {
        final gstRate = 0.18; // 18% GST
        final gst = subtotal * gstRate;
        final totalCost = subtotal + gst;

        setState(() {
          _subtotal = subtotal;
          _gst = gst;
          _totalCost = totalCost;
          _finalAmount = totalCost - _discount;
        });

        // Update the text controllers to reflect the calculated values
        _subtotalController.text = _subtotal.toStringAsFixed(2);
        _gstController.text = _gst.toStringAsFixed(2);
      }
    } catch (e) {
    }
  }

  Future<void> _submitBooking() async {
    if (_isSubmitting) return; // Prevent multiple submissions
    
    if (!_formKey.currentState!.validate()) return;
    
    // Additional validation for required fields
    if (_checkInDate == null || _checkOutDate == null) {
      _showErrorSnackBar('Please select check-in and check-out dates');
      return;
    }
    
    final selectedIds = _roomSelections
        .where((s) => s['roomId'] != null)
        .map<int>((s) => (s['roomId'] as int))
        .toList();
    if (selectedIds.isEmpty) {
      _showErrorSnackBar('Please select at least one room');
      return;
    }

    // Check authentication before proceeding
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      _showErrorSnackBar('Please login to continue');
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFF1F2937)),
            const SizedBox(height: 16),
            Text(
              widget.existingBooking != null 
                  ? 'Updating booking...'
                  : 'Creating booking...',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );

    try {
      // Create booking data with correct API field names
      // Create booking data - exclude room_type_id for new bookings due to backend DB issue
      final bookingData = {
        // Customer Information
        'guest_name': _customerNameController.text,
        'guest_phone': _customerPhoneController.text,
        'guest_email': _customerEmailController.text,
        
        // Booking Dates
        'check_in_date': _checkInDate!.toIso8601String(),
        'check_out_date': _checkOutDate!.toIso8601String(),
        
        // Room Information (exclude room_type_id for new bookings)
        'room_type': _roomSelections.map((s) => s['roomTypeName']).where((name) => name != null && name.isNotEmpty).join(','),
        'room_types': _roomSelections
            .where((s) => (s['roomTypeId'] ?? 0) != 0)
            .map((s) => s['roomTypeId'])
            .toList(),
        'selected_room': _roomSelections
            .where((s) => (s['roomLabel'] ?? '').toString().isNotEmpty)
            .map((s) => s['roomLabel'] as String)
            .join(', '),
        'room_id': (_roomSelections.firstWhere(
              (s) => s['roomId'] != null,
              orElse: () => {'roomId': null},
            )['roomId']) ?? _selectedRoomId ?? _getSelectedRoomId(),
        'room_ids': selectedIds,
        
        // Guest Count
        'guest_count': _totalGuests,
        'adults': _totalGuests, // Assuming all guests are adults for now
        'children': 0,
        'infants': 0,
        
        // Payment and Status
        'total_amount': _finalAmount,
        'payment_status': _selectedPaymentStatus,
        'booking_status': _statusToApi(_selectedStatus),
        'status': _statusToApi(_selectedStatus), // Some APIs might expect 'status' field
        
        // Source and Remarks
        'source': _selectedSource,
        'special_requests': _remarksController.text,
        // removed room_remarks
        
        // Pricing Breakdown
        'subtotal': _subtotal,
        'gst': _gst,
        'total_cost': _totalCost,
        'discount': _discount,
        'final_amount': _finalAmount,
        
        // Additional fields for better API compatibility
        'created_by': 'user', // Default user - you might want to get this from auth
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // For updates, include room_type_id only when exactly one type is selected
      final finalBookingData = Map<String, dynamic>.from(bookingData);
      if (widget.existingBooking != null) {
        final uniqueTypeIds = _roomSelections
            .where((s) => (s['roomTypeId'] ?? 0) != 0)
            .map<int>((s) => s['roomTypeId'] as int)
            .toSet()
            .toList();
        if (uniqueTypeIds.length == 1) {
          finalBookingData['room_type_id'] = uniqueTypeIds.first;
        } else {
          finalBookingData.remove('room_type_id');
        }
        
        // Remove fields that might cause issues in updates
        finalBookingData.remove('created_by'); // Don't update created_by
        finalBookingData.remove('updated_at'); // Let server handle timestamps
      }
      
      final result = widget.existingBooking != null
          ? await BookingsService.updateBooking(
              bookingId: widget.existingBooking!.id,
              updateData: finalBookingData,
            )
          : await BookingsService.createBooking(bookingData);
      
      Navigator.of(context).pop(); // Close loading dialog

      // Check if authentication is required
      if (result['needsAuth'] == true) {
        _showErrorSnackBar('Please login to continue');
        // Navigate to login screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
        return;
      }

      if (result['success'] == true) {
        // Show success message
        _showSuccessSnackBar(
          widget.existingBooking != null 
            ? 'Booking updated successfully!'
            : 'Booking created successfully!'
        );

        // Allocate room if we have a booking id and selected room id
        try {
          String? bookingId;
          
          // For existing bookings, use the existing booking ID
          if (widget.existingBooking != null) {
            bookingId = widget.existingBooking!.id;
          } else {
            // For new bookings, extract ID from API response
            final data = result['data'];
            if (data is Map && data['data'] is Map) {
              bookingId = (data['data']['id'] ?? data['id'])?.toString();
            } else if (data is Map) {
              bookingId = data['id']?.toString();
            }
          }
          
          // Only get room IDs that have been explicitly selected by the user
          // Filter out any room selections that don't have both roomTypeId and roomId set
          final selectedIds = _roomSelections
              .where((s) => s['roomId'] != null && s['roomTypeId'] != null && s['roomTypeId'] != 0)
              .map<int>((s) => s['roomId'] as int)
              .toList();
          
          // Use new room allocation API
          if (bookingId != null && selectedIds.isNotEmpty) {
            if (widget.existingBooking != null) {
              // Update room allocations for existing booking
              // First, try to clear existing room allocations
              final clearResult = await BookingsService.clearRoomAllocations(
                bookingId: bookingId,
              );
              
              // Then, add the new room allocations
              final allocResult = await BookingsService.updateRoomAllocations(
                bookingId: bookingId,
                roomIds: selectedIds,
              );
              
              if (allocResult['success'] == true) {
                _showSuccessSnackBar('Booking updated successfully! Room allocations updated.');
              } else {
                _showSuccessSnackBar('Booking updated successfully! Room allocation failed: ${allocResult['message']}');
              }
            } else {
              // Allocate rooms for new booking
              final allocResult = await BookingsService.allocateRooms(
                bookingId: bookingId,
                roomIds: selectedIds,
              );
              
              if (allocResult['success'] == true) {
                _showSuccessSnackBar('Booking created successfully! Rooms allocated.');
              } else {
                _showSuccessSnackBar('Booking created successfully! Room allocation failed: ${allocResult['message']}');
              }
            }
          } else {
            // No room allocation needed
            if (widget.existingBooking != null) {
              _showSuccessSnackBar('Booking updated successfully!');
            } else {
              _showSuccessSnackBar('Booking created successfully!');
            }
          }
        } catch (e) {
          // Error handling for room allocation
        }

        // Send booking confirmation if it's a new booking
        if (widget.existingBooking == null) {
          await _sendBookingConfirmation(result['data']);
        }

        // For updates, we need to refresh the booking data since the API response
        // doesn't include all the room information we sent
        if (widget.existingBooking != null) {
          // Fetch the updated booking data to ensure it's properly refreshed
          try {
            final updatedBooking = await BookingsService.getBooking(widget.existingBooking!.id);
            if (updatedBooking['success'] == true) {
              // Create a new Booking instance with the updated data

              // Store the updated room data for the booking detail page
              final updatedRoomData = {
                'roomType': _roomSelections.map((s) => s['roomTypeName'] as String).join(', '),
                'selectedRoom': _roomSelections.map((s) => s['roomLabel'] as String).join(', '),
              };
              
              // Note: We can't directly update widget.existingBooking since it's final
              // The parent widget should handle refreshing the booking data
            }
          } catch (e) {
            // Error fetching updated booking
          }
        }

        // Call the callback to refresh booking list if provided
        if (widget.onBookingUpdated != null) {
          widget.onBookingUpdated!();
        }

        // Navigate back with updated room data
        Navigator.of(context).pop({
          'success': true,
          'roomData': {
            'roomType': _roomSelections.map((s) => s['roomTypeName'] as String).join(', '),
            'selectedRoom': _roomSelections.map((s) => s['roomLabel'] as String).join(', '),
          }
        });
      } else {
        // Show error message with better formatting
        final errorMessage = widget.existingBooking != null 
          ? (result['message'] ?? 'Failed to update booking')
          : (result['message'] ?? 'Failed to create booking');
        
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      
      final errorMessage = widget.existingBooking != null 
        ? 'Error updating booking: ${e.toString()}'
        : 'Error creating booking: ${e.toString()}';
      
      _showErrorSnackBar(errorMessage);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar.withBackButton(
        title: widget.existingBooking != null ? 'Edit Booking' : 'Add New Booking',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 16),
            child: Column(
              children: [
                Row(
                  children: List.generate(_totalSteps, (index) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: index < _totalSteps - 1 ? 8 : 0),
                        height: 4,
                        decoration: BoxDecoration(
                          color: index <= _currentStep
                              ? const Color(0xFF6366F1)
                              : const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStepLabel('Customer', 0),
                    _buildStepLabel('Dates', 1),
                    _buildStepLabel('Room', 2),
                    _buildStepLabel('Summary', 3),
                  ],
                ),
              ],
            ),
          ),

          // Form content
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildCustomerStep(),
                  _buildDatesStep(),
                  _buildRoomStep(),
                  _buildSummaryStep(),
                ],
              ),
            ),
          ),

          // Navigation buttons
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _previousStep,
                          borderRadius: BorderRadius.circular(12),
                          child: Center(
                            child: Text(
                              'Previous',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isSubmitting ? null : (_currentStep == _totalSteps - 1 ? _submitBooking : _nextStep),
                        borderRadius: BorderRadius.circular(12),
                        child: Center(
                          child: _isSubmitting && _currentStep == _totalSteps - 1
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Processing...',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  _currentStep == _totalSteps - 1 
                                      ? (widget.existingBooking != null ? 'Update Booking' : 'Create Booking')
                                      : 'Next',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLabel(String label, int step) {
    return GestureDetector(
      onTap: () => _goToStep(step),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: step <= _currentStep ? FontWeight.w600 : FontWeight.w400,
          color: step <= _currentStep ? const Color(0xFF6366F1) : const Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildCustomerStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Customer Information', icon: Icons.person),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _customerNameController,
            label: 'Full Name',
            hint: 'Enter full name',
            validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _customerPhoneController,
            label: 'Phone Number',
            hint: 'Enter phone number',
            keyboardType: TextInputType.phone,
            validator: (value) => value?.isEmpty == true ? 'Phone is required' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _customerEmailController,
            label: 'Email Address',
            hint: 'Enter email address',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty == true) return 'Email is required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                return 'Enter valid email';
              }
              return null;
            },
          ),
          // Removed Remarks here; moved to Room section
        ],
      ),
    );
  }

  Widget _buildDatesStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Booking Dates', icon: Icons.calendar_today),
          const SizedBox(height: 20),
          DateField(
            label: 'Check-in Date',
            date: _checkInDate,
            onTap: () => _selectDate(context, true),
          ),
          const SizedBox(height: 20),
          DateField(
            label: 'Check-out Date',
            date: _checkOutDate,
            onTap: () => _selectDate(context, false),
          ),
          const SizedBox(height: 20),
          SectionHeader(title: 'Guest Information', icon: Icons.people),
          const SizedBox(height: 20),
          GuestCounter(
            totalGuests: _totalGuests,
            onChanged: (value) {
              setState(() {
                _totalGuests = value;
              });
            },
          ),
          const SizedBox(height: 20),
          SectionHeader(title: 'Booking Status', icon: Icons.flag),
          const SizedBox(height: 20),
          _buildStatusDropdown(),
          const SizedBox(height: 20),
          SectionHeader(title: 'Payment Status', icon: Icons.payments_outlined),
          const SizedBox(height: 20),
          _buildPaymentStatusDropdown(),
          const SizedBox(height: 20),
          SectionHeader(title: 'Source', icon: Icons.source),
          const SizedBox(height: 20),
          _buildSourceDropdown(),
        ],
      ),
    );
  }

  Widget _buildRoomStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Room Selection', icon: Icons.bed),
          const SizedBox(height: 20),
          _buildMultiRoomTypeSection(),
          const SizedBox(height: 20),
          // Use general remarks here in place of room remarks
          CustomTextField(
            controller: _remarksController,
            label: 'Remarks',
            hint: 'Any special room requirements or notes',
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          SectionHeader(title: 'Pricing', icon: Icons.account_balance_wallet),
          const SizedBox(height: 20),
          _buildPricingFields(),
        ],
      ),
    );
  }

  Widget _buildSummaryStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Booking Summary', icon: Icons.summarize),
          const SizedBox(height: 20),
          _buildSummaryCard(),
        ],
      ),
    );
  }


  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Booking Status',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedStatus,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: _statuses.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(
                status.toUpperCase(),
                style: AppFonts.poppins(),
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedStatus = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPaymentStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _paymentStatuses.contains(_selectedPaymentStatus) ? _selectedPaymentStatus : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: _paymentStatuses.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(
                status.toUpperCase(),
                style: AppFonts.poppins(),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedPaymentStatus = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSourceDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _sources.contains(_selectedSource) ? _selectedSource : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: _sources.map((src) {
            return DropdownMenuItem(
              value: src,
              child: Text(
                src.toUpperCase(),
                style: AppFonts.poppins(),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedSource = value;
            });
          },
        ),
      ],
    );
  }

  // Removed deprecated single room type/room dropdowns

  // Removed deprecated _buildMultiRoomSection - use _buildMultiRoomTypeSection instead

  // New: Multi room-type + room selection
  Widget _buildMultiRoomTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._roomSelections.asMap().entries.map((entry) {
          final index = entry.key;
          final sel = entry.value;
          final int roomTypeId = sel['roomTypeId'] ?? 0;
          final String roomTypeName = sel['roomTypeName'] ?? '';
          final int? roomId = sel['roomId'];
          final String roomLabel = sel['roomLabel'] ?? '';
          final List<Map<String, dynamic>> roomsOfType = _availableRoomsByType[roomTypeId] ?? [];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Room Type ${index + 1}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: roomTypeId == 0 || roomTypeName.isEmpty ? null : '$roomTypeId|$roomTypeName',
                  decoration: InputDecoration(
                    hintText: 'Select room type',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: _roomTypes.map<DropdownMenuItem<String>>((roomType) {
                    final name = roomType['name'] ?? roomType['room_type'] ?? 'Unknown';
                    final id = roomType['id'] ?? roomType['room_type_id'] ?? 0;
                    return DropdownMenuItem<String>(
                      value: '$id|$name',
                      child: Text(name, style: AppFonts.poppins()),
            );
          }).toList(),
                  onChanged: (value) async {
                    if (value == null) return;
                    final parts = value.split('|');
                    final newTypeId = int.tryParse(parts[0]) ?? 0;
                    final newTypeName = parts[1];
                    
                    setState(() {
                      _roomSelections[index]['roomTypeId'] = newTypeId;
                      _roomSelections[index]['roomTypeName'] = newTypeName;
                    });
                    
                    // Clear the room selection when room type changes
                    _clearRoomSelection(index);
                    
                    // Load available rooms for the new room type
                    if (newTypeId > 0 && _checkInDate != null && _checkOutDate != null) {
                      await _loadAvailableRoomsForType(newTypeId);
                    }
                    
                    _calculatePricing();
                  },
                ),
                const SizedBox(height: 12),
        DropdownButtonFormField<String>(
                  value: (roomId == null || roomLabel.isEmpty) ? null : '$roomId|$roomLabel',
          decoration: InputDecoration(
                    hintText: roomTypeId == 0
                ? 'Select room type first' 
                : (_isLoadingAvailableRooms 
                    ? 'Loading rooms...' 
                            : (roomsOfType.isEmpty ? 'No rooms available' : 'Select room')),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: roomTypeId == 0
                      ? <DropdownMenuItem<String>>[]
                      : () {
                          // Include selected room even if not in available rooms
                          final allRooms = <Map<String, dynamic>>[...roomsOfType];
                          if (roomId != null && roomLabel.isNotEmpty) {
                            final selectedRoomExists = allRooms.any((r) => r['id'] == roomId);
                            if (!selectedRoomExists) {
                              allRooms.add({
                                'id': roomId,
                                'room_number': roomLabel,
                                'name': roomLabel,
                              });
                            }
                          }
                          
                          if (allRooms.isEmpty) {
                            return <DropdownMenuItem<String>>[
            const DropdownMenuItem<String>(
              value: 'none',
                                child: Text('No rooms available'),
                              )
                            ];
                          }
                          
                          return allRooms.map<DropdownMenuItem<String>>((room) {
                            final roomNumber = room['room_number']?.toString() ?? room['name']?.toString() ?? 'Unknown';
                            final id = room['id']?.toString() ?? roomNumber;
            return DropdownMenuItem<String>(
                              value: '$id|$roomNumber',
                              child: Text(roomNumber, style: AppFonts.poppins()),
                            );
                          }).toList();
                        }(),
                  onChanged: (value) {
                    if (value == null || value == 'none') return;
                    final parts = value.split('|');
                    final idPart = parts.first;
                    final labelPart = parts.length > 1 ? parts.sublist(1).join('|') : parts.first;
                    setState(() {
                      _roomSelections[index]['roomId'] = int.tryParse(idPart);
                      _roomSelections[index]['roomLabel'] = labelPart;
                    });
                    _calculatePricing();
                  },
                ),
                  Row(
                    children: [
                    if (_roomSelections.length > 1)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _roomSelections.removeAt(index);
                          });
                          _calculatePricing();
                        },
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        label: const Text('Remove'),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: (_isLoadingAvailableRooms)
              ? null 
                : () {
                  setState(() {
                      _roomSelections.add({
                        'roomTypeId': 0,
                        'roomTypeName': '',
                        'roomId': null,
                        'roomLabel': '',
                      });
                  });
                },
            icon: const Icon(Icons.add),
            label: const Text('Add another room type'),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingFields() {
    return Column(
      children: [
          CustomTextField(
            controller: _subtotalController,
            label: 'Subtotal (₹)',
            hint: 'Enter subtotal amount',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _subtotal = double.tryParse(value) ?? 0.0;
                _calculateTotal();
              });
            },
          ),
        const SizedBox(height: 16),
          CustomTextField(
            controller: _gstController,
            label: 'GST (₹)',
            hint: 'Enter GST amount',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _gst = double.tryParse(value) ?? 0.0;
                _calculateTotal();
              });
            },
          ),
        const SizedBox(height: 16),
          CustomTextField(
            controller: _discountController,
            label: 'Discount (₹)',
            hint: 'Enter discount amount',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _discount = double.tryParse(value) ?? 0.0;
                _calculateTotal();
              });
            },
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                '₹${_finalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6366F1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _getSelectedRoomId() {
    // Get first selected room ID from room selections
    final firstSelection = _roomSelections.firstWhere(
      (s) => s['roomId'] != null,
      orElse: () => {},
    );
    return firstSelection['roomId'] ?? 0;
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryRow('Customer', _customerNameController.text),
          _buildSummaryRow('Phone', _customerPhoneController.text),
          _buildSummaryRow('Email', _customerEmailController.text),
          _buildSummaryRow('Check-in', _checkInDate != null ? DateFormat('MMM dd, yyyy').format(_checkInDate!) : 'Not selected'),
          _buildSummaryRow('Check-out', _checkOutDate != null ? DateFormat('MMM dd, yyyy').format(_checkOutDate!) : 'Not selected'),
          // Multi-selection summary (flattened rows)
          _buildSummaryRow(
            'Room Type(s)',
            _roomSelections.where((s) => (s['roomTypeName'] ?? '').toString().isNotEmpty)
                .map((s) => s['roomTypeName'] as String)
                .toSet()
                .join(', '),
          ),
          _buildSummaryRow(
            'Room Type ID(s)',
            _roomSelections.where((s) => (s['roomTypeId'] ?? 0) != 0)
                .map((s) => (s['roomTypeId'] as int).toString())
                .toList()
                .join(', '),
          ),
          _buildSummaryRow(
            'Selected Room(s)',
            _roomSelections.where((s) => (s['roomLabel'] ?? '').toString().isNotEmpty)
                .map((s) => s['roomLabel'] as String)
                .toList()
                .join(', '),
          ),
          _buildSummaryRow(
            'Room ID(s)',
            _roomSelections.where((s) => s['roomId'] != null)
                .map((s) => (s['roomId'] as int).toString())
                .toList()
                .join(', '),
          ),
          _buildSummaryRow('Guests', _totalGuests.toString()),
          _buildSummaryRow('Status', _selectedStatus.toUpperCase()),
          const Divider(),
          _buildSummaryRow('Total Amount', '₹${_finalAmount.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: isTotal ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? const Color(0xFF6366F1) : const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? (_checkInDate ?? DateTime.now()) : (_checkOutDate ?? DateTime.now()),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          // If check-out is before check-in, clear it
          if (_checkOutDate != null && _checkOutDate!.isBefore(picked)) {
            _checkOutDate = null;
          }
        } else {
          _checkOutDate = picked;
        }
      });
      
      // Reload available rooms for all selected room types when dates change
      for (final selection in _roomSelections) {
        final roomTypeId = selection['roomTypeId'] as int;
        if (roomTypeId > 0) {
          await _loadAvailableRoomsForType(roomTypeId);
        }
      }
      
      // Recalculate pricing when dates change
      _calculatePricing();
    }
  }
}
