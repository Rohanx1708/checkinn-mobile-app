import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/common_app_bar.dart';
import 'widgets/date_range_bottom_sheet.dart';
import 'widgets/guest_count_bottom_sheet.dart';
import 'widgets/room_type_bottom_sheet.dart';
import 'bill_screen.dart';

class NewBookingUi extends StatefulWidget {
  const NewBookingUi({super.key});

  @override
  State<NewBookingUi> createState() => _NewBookingUiState();
}

class _NewBookingUiState extends State<NewBookingUi> {
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  DateTime? _previousCheckInDate;
  DateTime? _previousCheckOutDate;
  int _adults = 0;
  int _children = 0;
  int _infants = 0;
  Map<String, int> _selectedRoomTypes = {};
  Map<String, String> _roomPrices = {};

  bool get _isDateRangeCompleted => _checkInDate != null && _checkOutDate != null;
  bool get _isGuestCountCompleted => _adults > 0;
  bool get _isRoomTypeCompleted => _selectedRoomTypes.isNotEmpty;
  bool get _shouldShowDateWarning {
    if (_selectedRoomTypes.isEmpty) return false;
    if (_checkInDate == null || _checkOutDate == null) return false;
    if (_previousCheckInDate == null || _previousCheckOutDate == null) return false;
    
    // Compare dates (not DateTime objects)
    final currentCheckIn = DateTime(_checkInDate!.year, _checkInDate!.month, _checkInDate!.day);
    final currentCheckOut = DateTime(_checkOutDate!.year, _checkOutDate!.month, _checkOutDate!.day);
    final previousCheckIn = DateTime(_previousCheckInDate!.year, _previousCheckInDate!.month, _previousCheckInDate!.day);
    final previousCheckOut = DateTime(_previousCheckOutDate!.year, _previousCheckOutDate!.month, _previousCheckOutDate!.day);
    
    return currentCheckIn != previousCheckIn || currentCheckOut != previousCheckOut;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar.withBackButton(
        title: 'New Booking',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Section
              _buildSection(
                title: 'Select Dates',
                isCompleted: _isDateRangeCompleted,
                onTap: _isDateRangeCompleted ? null : _showDateRangeBottomSheet,
                child: _isDateRangeCompleted
                    ? _buildCompletedSection(
                        '${_formatDate(_checkInDate!)} - ${_formatDate(_checkOutDate!)}',
                        onEdit: _showDateRangeBottomSheet,
                      )
                    : _buildIncompleteSection('Tap to select check-in and check-out dates'),
              ),

              // Guest Count Section (only show if date range is completed)
              if (_isDateRangeCompleted) ...[
                const SizedBox(height: 16),
                _buildSection(
                  title: 'Guest Count',
                  isCompleted: _isGuestCountCompleted,
                  onTap: !_isGuestCountCompleted
                      ? _showGuestCountBottomSheet
                      : null,
                  isEnabled: true,
                  child: _isGuestCountCompleted
                      ? _buildCompletedSection(
                          '$_adults Adult${_adults != 1 ? 's' : ''}${_children > 0 ? ', $_children Child${_children != 1 ? 'ren' : ''}' : ''}${_infants > 0 ? ', $_infants Infant${_infants != 1 ? 's' : ''}' : ''}',
                          onEdit: _showGuestCountBottomSheet,
                        )
                      : _buildIncompleteSection('Tap to select number of guests'),
                ),
              ],

              // Room Type Section (only show if guest count is completed)
              if (_isGuestCountCompleted) ...[
                const SizedBox(height: 16),
                _buildSection(
                  title: 'Room Type',
                  isCompleted: _isRoomTypeCompleted,
                  onTap: !_isRoomTypeCompleted
                      ? _showRoomTypeBottomSheet
                      : null,
                  isEnabled: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_shouldShowDateWarning)
                        _buildDateWarning(),
                      if (_isRoomTypeCompleted)
                        _buildCompletedSection(
                          _selectedRoomTypes.entries.map((e) => '${e.value}x ${e.key}').join(', '),
                          onEdit: _showRoomTypeBottomSheet,
                        )
                      else
                        _buildIncompleteSection('Tap to select room type'),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Continue Button (only show when all sections are completed)
              if (_isDateRangeCompleted && _isGuestCountCompleted && _isRoomTypeCompleted)
                _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool isCompleted,
    required VoidCallback? onTap,
    required Widget child,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEnabled
                ? (isCompleted ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB))
                : const Color(0xFFF3F4F6),
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: const Color(0xFF1F2937).withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF1F2937)
                        : (isEnabled ? const Color(0xFFF3F4F6) : const Color(0xFFF9FAFB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : Text(
                            _getSectionNumber(title),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isEnabled
                                  ? const Color(0xFF6B7280)
                                  : const Color(0xFFD1D5DB),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isEnabled
                          ? const Color(0xFF1F2937)
                          : const Color(0xFFD1D5DB),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedSection(String value, {required VoidCallback onEdit}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
        ),
        GestureDetector(
          onTap: onEdit,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Edit',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncompleteSection(String message) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFF9CA3AF),
        ),
      ],
    );
  }

  Widget _buildDateWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFFC107),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: const Color(0xFF856404),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Please adjust the room type availability as per selected dates',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF856404),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BillScreen(
                checkInDate: _checkInDate!,
                checkOutDate: _checkOutDate!,
                adults: _adults,
                children: _children,
                infants: _infants,
                selectedRoomTypes: _selectedRoomTypes,
                roomPrices: _roomPrices,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1F2937),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Continue',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getSectionNumber(String title) {
    if (title == 'Select Dates') return '1';
    if (title == 'Guest Count') return '2';
    if (title == 'Room Type') return '3';
    return '';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showDateRangeBottomSheet() {
    // Store previous dates before opening the bottom sheet
    final previousCheckIn = _checkInDate;
    final previousCheckOut = _checkOutDate;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DateRangeBottomSheet(
        initialCheckIn: _checkInDate,
        initialCheckOut: _checkOutDate,
        onDateRangeSelected: (checkIn, checkOut) {
          setState(() {
            // Update previous dates before changing current dates
            if (_checkInDate != null && _checkOutDate != null) {
              _previousCheckInDate = previousCheckIn;
              _previousCheckOutDate = previousCheckOut;
            }
            _checkInDate = checkIn;
            _checkOutDate = checkOut;
            
            // If dates changed and room types are selected, clear room types
            if (_previousCheckInDate != null && 
                _previousCheckOutDate != null &&
                (checkIn != _previousCheckInDate || checkOut != _previousCheckOutDate) &&
                _selectedRoomTypes.isNotEmpty) {
              // Keep the warning visible but don't clear room types automatically
              // User can manually adjust
            }
          });
        },
      ),
    );
  }

  void _showGuestCountBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GuestCountBottomSheet(
        initialAdults: _adults,
        initialChildren: _children,
        initialInfants: _infants,
        onGuestCountSelected: (adults, children, infants) {
          setState(() {
            _adults = adults;
            _children = children;
            _infants = infants;
          });
        },
      ),
    );
  }

  void _showRoomTypeBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RoomTypeBottomSheet(
        initialRoomTypes: _selectedRoomTypes,
        onRoomTypeSelected: (roomTypes, roomPrices) {
          setState(() {
            _selectedRoomTypes = roomTypes;
            _roomPrices = roomPrices;
            // Clear warning when room types are adjusted
            _previousCheckInDate = _checkInDate;
            _previousCheckOutDate = _checkOutDate;
          });
        },
      ),
    );
  }
}

