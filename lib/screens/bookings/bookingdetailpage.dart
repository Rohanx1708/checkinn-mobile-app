import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:checkinn/screens/bookings/models/bookingdetails.dart';
import 'package:checkinn/screens/bookings/services/bookings_service.dart';
import 'package:checkinn/screens/bookings/add_booking/add_booking_ui.dart';
import 'package:checkinn/widgets/common_app_bar.dart';


class BookingDetailsPage extends StatefulWidget {
  final Booking booking;
  final VoidCallback? onBookingUpdated; // Callback to refresh booking list

  const BookingDetailsPage({super.key, required this.booking, this.onBookingUpdated});

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  late Booking booking;

  @override
  void initState() {
    super.initState();
    booking = widget.booking;
  }

  String _formatCurrency(double value) {
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return format.format(value);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFEF4444),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Delete Booking',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this booking? This action cannot be undone.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteBooking(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBooking(BuildContext context) async {
    // show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
            ),
            const SizedBox(height: 16),
            Text(
              'Deleting booking...',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );

    final result = await BookingsService.deleteBooking(booking.id);
    Navigator.of(context).pop();

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Booking deleted successfully',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      // Pop details page and signal parent to refresh if needed
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  result['message']?.toString() ?? 'Failed to delete booking',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
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
  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return const Color(0xFFF59E0B); // Yellow
      case 'completed':
        return const Color(0xFF22C55E); // Green
      case 'cancelled':
        return const Color(0xFFEF4444); // Red
      case 'confirmed':
        return const Color(0xFF22C55E); // Green
      case 'pending':
        return const Color(0xFFF59E0B); // Yellow
      case 'checked_in':
      case 'checked-in':
        return const Color(0xFF0EA5E9); // Light Blue
      case 'checked_out':
      case 'checked-out':
        return const Color(0xFF6B7280); // Grey
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  void _downloadBill(BuildContext context) {
    // Show confirmation dialog
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
                  Icons.receipt_long,
                  color: Color(0xFF1F2937),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Download Bill',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: Text(
            'Would you like to download the bill for "${booking.title}"?',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processBillDownload(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Download',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _processBillDownload(BuildContext context) {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
              ),
              const SizedBox(height: 16),
              Text(
                'Generating bill...',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        );
      },
    );

    // Simulate bill generation and download
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Close loading dialog
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Bill downloaded successfully!',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar.withBackButton(
        title: '',
        onBackPressed: () => Navigator.of(context).pop(),
        actions: [
          IconButton(
            tooltip: 'Download Bill',
            icon: const Icon(Icons.receipt_long, color: Color(0xFF1F2937)),
            onPressed: () => _downloadBill(context),
          ),
        ],
      ),
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
          child: RefreshIndicator(
            onRefresh: _refreshBookingData,
          child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                                 // Header Section
                 Container(
                   width: double.infinity,
                   margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.01),
                   padding: const EdgeInsets.all(20),
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(16),
                     color: Colors.white,
                     boxShadow: [
                       BoxShadow(
                         color: Colors.black.withOpacity(0.05),
                         blurRadius: 12,
                         offset: const Offset(0, 4),
                       ),
                     ],
                     border: Border.all(
                       color: const Color(0xFFF1F5F9),
                       width: 1,
                     ),
                   ),
                   child: Row(
                     children: [
                       // Title and Company Name
                       Expanded(
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Text(
                               booking.title,
                               style: GoogleFonts.inter(
                                 fontSize: 18,
                                 fontWeight: FontWeight.w700,
                                 color: const Color(0xFF1F2937),
                               ),
                             ),
                             const SizedBox(height: 4),
                             Text(
                               booking.companyName,
                               style: GoogleFonts.inter(
                                 fontSize: 14,
                                 fontWeight: FontWeight.w400,
                                 color: const Color(0xFF6B7280),
                               ),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
                 ),

                // Content Sections
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Column(
                children: [
                      // Customer Information Section
                      _buildSectionCard(
                        'Customer Information',
                        null,
                        const Color(0xFF1F2937),
                        [
                    _buildDetailRow('Name', booking.customer.name),
                    _buildDetailRow('Phone', booking.customer.phone),
                    _buildDetailRow('Email', booking.customer.email ?? 'Not provided', maxLines: 10),
                    _buildDetailRow('Total Guests', booking.totalGuests.toString()),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Booking Details Section
                      _buildSectionCard(
                        'Booking Details',
                        null,
                        const Color(0xFF1F2937),
                        [
                          _buildDetailRow('Booking ID', booking.id),
                          _buildDetailRow('Booking Date', _formatDate(booking.date)),
                          _buildDetailRow('Check-in Date', _formatDate(booking.checkInDate)),
                          _buildDetailRow('Check-out Date', _formatDate(booking.checkOutDate)),
                          _buildDetailRow('Status', booking.status),
                          _buildDetailRow('Payment Status', booking.paymentStatus ?? 'Pending'),
                          _buildDetailRow('Source', booking.source ?? 'Direct'),
                          _buildDetailRow('Property Address', booking.propertyAddress ?? 'Not specified'),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Property Information Section
                      _buildSectionCard(
                        'Property Information',
                        null,
                        const Color(0xFF1F2937),
                        [
                          _buildDetailRow('Property Name', booking.propertyName ?? 'Not specified'),
                          _buildDetailRow('Property Address', booking.propertyAddress ?? 'Not specified'),
                          _buildDetailRow('Property ID', booking.propertyId ?? 'Not specified'),
                        ],
                      ),

                      const SizedBox(height: 20),
                      _buildSectionCard(
                        'Room Selection',
                        null,
                        const Color(0xFF1F2937),
                        [
                          _buildRoomPairsRow('Room(s)', booking.roomType, booking.selectedRoom),
                          _buildDetailRow('Remarks', booking.remarks ?? 'None'),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Financial Summary Section
                      _buildSectionCard(
                        'Financial Summary',
                        null,
                        const Color(0xFF1F2937),
                        [
                    _buildDetailRow('Total Cost', _formatCurrency(booking.totalCost)),
                    _buildDetailRow('Discount', booking.discount != null ? _formatCurrency(booking.discount!) : '—'),
                    _buildDetailRow('Final Amount', _formatCurrency(booking.finalAmount)),
                          _buildDetailRow('Amount Spent', _formatCurrency(booking.amountSpend)),
                          _buildDetailRow('Balance Due', _formatCurrency(booking.balanceDue)),
                        ],
                      ),

                      // Add-ons Section (if any)
                      if (booking.addOns.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildSectionCard(
                          'Add-ons',
                          null,
                          const Color(0xFF1F2937),
                          [
                            for (final addOn in booking.addOns)
                              _buildDetailRow(addOn.name, _formatCurrency(addOn.price)),
                          ],
                        ),
                      ],

                      // Extras Section (if any)
                      if (booking.extras.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _buildSectionCard(
                          'Extra Services',
                          null,
                          const Color(0xFF1F2937),
                          [
                            for (final extra in booking.extras)
                              _buildDetailRow('${extra.name} (${extra.quantity})', _formatCurrency(extra.price * extra.quantity)),
                          ],
                        ),
                      ],

                      const SizedBox(height: 20),
                      
                      // Action Buttons Row
                      Row(
                        children: [
                          // Edit Booking Details Button
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F2937),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1F2937).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AddBookingUi(
                                          existingBooking: booking,
                                          onBookingUpdated: widget.onBookingUpdated,
                                        ),
                                      ),
                                    ).then((result) async {
                                      if (result == true || (result is Map && result['success'] == true)) {
                                        // Refetch booking details and update in place
                                        try {
                                          print('🔄 Refreshing booking details for ID: ${booking.id}');
                                          final res = await BookingsService.getBooking(booking.id);
                                          if (res['success'] == true) {
                                            final data = res['data'];
                                            final payload = (data is Map && data['data'] is Map) ? data['data'] : data;
                                            if (payload is Map<String, dynamic>) {
                                              print('🔍 Updated booking data: $payload');
                                              print('🔍 Room types in response: ${payload['room_types']}');
                                              print('🔍 Rooms in response: ${payload['rooms']}');
                                              print('🔍 Booking rooms in response: ${payload['booking_rooms']}');
                                              
                                              // Always use form data if available, otherwise use API data
                                              final updatedBooking = Booking.fromMap(payload);
                                              print('🔍 Parsed room type: "${updatedBooking.roomType}"');
                                              print('🔍 Parsed selected room: "${updatedBooking.selectedRoom}"');
                                              
                                              // Check if we have room data from the form
                                              String? formRoomType;
                                              String? formSelectedRoom;
                                              if (result is Map && result['roomData'] != null) {
                                                formRoomType = result['roomData']['roomType'];
                                                formSelectedRoom = result['roomData']['selectedRoom'];
                                                print('🔍 Form room data: "$formRoomType" / "$formSelectedRoom"');
                                              }
                                              
                                              // Always prioritize form data over API data for room information
                                              // This ensures the UI shows the correct room selection from the form
                                              if (formRoomType != null && formSelectedRoom != null) {
                                                print('🔄 Using form room data for dynamic update');
                                                
                                                // Create a new booking with form room data
                                                final dynamicBooking = Booking(
                                                  id: updatedBooking.id,
                                                  title: updatedBooking.title,
                                                  companyName: updatedBooking.companyName,
                                                  imageUrl: updatedBooking.imageUrl,
                                                  date: updatedBooking.date,
                                                  status: updatedBooking.status,
                                                  amountSpend: updatedBooking.amountSpend,
                                                  balanceDue: updatedBooking.balanceDue,
                                                  address: updatedBooking.address,
                                                  notes: updatedBooking.notes,
                                                  checkInDate: updatedBooking.checkInDate,
                                                  checkOutDate: updatedBooking.checkOutDate,
                                                  roomDetails: updatedBooking.roomDetails,
                                                  bookingFee: updatedBooking.bookingFee,
                                                  customer: updatedBooking.customer,
                                                  totalGuests: updatedBooking.totalGuests,
                                                  remarks: updatedBooking.remarks,
                                                  roomType: formRoomType, // Use form room type
                                                  selectedRoom: formSelectedRoom, // Use form selected room
                                                  roomRemarks: updatedBooking.roomRemarks,
                                                  roomTypeId: updatedBooking.roomTypeId,
                                                  roomId: updatedBooking.roomId,
                                                  propertyName: updatedBooking.propertyName,
                                                  propertyAddress: updatedBooking.propertyAddress,
                                                  propertyId: updatedBooking.propertyId,
                                                  paymentStatus: updatedBooking.paymentStatus,
                                                  source: updatedBooking.source,
                                                  subtotal: updatedBooking.subtotal,
                                                  gst: updatedBooking.gst,
                                                  totalCost: updatedBooking.totalCost,
                                                  discount: updatedBooking.discount,
                                                  finalAmount: updatedBooking.finalAmount,
                                                  guests: updatedBooking.guests,
                                                  guide: updatedBooking.guide,
                                                  extras: updatedBooking.extras,
                                                  addOns: updatedBooking.addOns,
                                                );
                                                
                                                print('🔍 Dynamic room data: "${dynamicBooking.roomType}" / "${dynamicBooking.selectedRoom}"');
                                                
                                                setState(() {
                                                  booking = dynamicBooking;
                                                });
                                                print('✅ Booking details updated with dynamic form data');
                                              } else {
                                                setState(() {
                                                  booking = updatedBooking;
                                                });
                                                print('✅ Booking details updated with API data');
                                              }
                                            }
                                          } else {
                                            print('⚠️ Failed to fetch updated booking: ${res['message']}');
                                          }
                                        } catch (e) {
                                          print('💥 Error refreshing booking details: $e');
                                        }
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    'Booking updated successfully!',
                                                    style: GoogleFonts.inter(fontWeight: FontWeight.w500),
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
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Edit Booking',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                      // Delete Booking Button
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFEF4444).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                              onTap: () => _confirmDelete(context),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                    Icons.delete_outline,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Delete Booking',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
            ),
          ),
        ],
      ),
      ),
          ),
        ),
      ),

    );
  }

  Widget _buildSectionCard(String title, IconData? icon, Color color, List<Widget> children) {
    return Container(
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
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Section Content
          Padding(
            padding: const EdgeInsets.all(20),
        child: Column(
          children: children,
        ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {int maxLines = 3, TextAlign? align}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: align ?? TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
              overflow: maxLines == 10 ? TextOverflow.clip : TextOverflow.ellipsis,
              maxLines: maxLines,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommaListRow(String label, String value) {
    final parts = (value.isNotEmpty ? value.split(',') : <String>[])
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return _buildDetailRow(label, 'Not specified');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: parts
                  .map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          p,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomPairsRow(String label, String roomTypesCsv, String roomsCsv) {
    final roomTypes = (roomTypesCsv.isNotEmpty ? roomTypesCsv.split(',') : <String>[]) 
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final rooms = (roomsCsv.isNotEmpty ? roomsCsv.split(',') : <String>[]) 
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final int pairs = roomTypes.isEmpty && rooms.isEmpty
        ? 0
        : (roomTypes.isEmpty ? rooms.length : (rooms.isEmpty ? roomTypes.length : (roomTypes.length > rooms.length ? roomTypes.length : rooms.length)));

    if (pairs == 0) return _buildDetailRow(label, 'Not specified');

    List<String> combined = [];
    for (int i = 0; i < pairs; i++) {
      final rt = i < roomTypes.length ? roomTypes[i] : '';
      final r = i < rooms.length ? rooms[i] : '';
      final text = (rt.isNotEmpty && r.isNotEmpty)
          ? '$rt - $r'
          : (rt.isNotEmpty ? rt : (r.isNotEmpty ? r : ''));
      if (text.isNotEmpty) combined.add(text);
    }

    if (combined.isEmpty) return _buildDetailRow(label, 'Not specified');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: combined
                  .map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          p,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
              overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Pull-to-refresh booking data with dynamic room handling
  Future<void> _refreshBookingData() async {
    try {
      print('🔄 Refreshing booking data for ID: ${booking.id}');
      
      // Fetch the latest booking data
      final res = await BookingsService.getBooking(booking.id);
      
      if (res['success'] == true) {
        final data = res['data'];
        final payload = (data is Map && data['data'] is Map) ? data['data'] : data;
        
        if (payload is Map<String, dynamic>) {
          print('🔍 Refreshed booking data: $payload');
          print('🔍 Room types in response: ${payload['room_types']}');
          print('🔍 Rooms in response: ${payload['rooms']}');
          print('🔍 Booking rooms in response: ${payload['booking_rooms']}');
          
          // Check if API has room data, if not preserve existing room data
          final updatedBooking = Booking.fromMap(payload);
          print('🔍 API room type: "${updatedBooking.roomType}"');
          print('🔍 API selected room: "${updatedBooking.selectedRoom}"');
          
          // If API doesn't have room data or has old data, preserve current room data
          if (updatedBooking.roomType.isEmpty || updatedBooking.selectedRoom.isEmpty || 
              updatedBooking.roomType.contains('GLU13') || updatedBooking.selectedRoom.contains('GLU13')) {
            print('🔄 API missing room data - preserving current room data');
            
            // Create booking with preserved room data
            final preservedBooking = Booking(
              id: updatedBooking.id,
              title: updatedBooking.title,
              companyName: updatedBooking.companyName,
              imageUrl: updatedBooking.imageUrl,
              date: updatedBooking.date,
              status: updatedBooking.status,
              amountSpend: updatedBooking.amountSpend,
              balanceDue: updatedBooking.balanceDue,
              address: updatedBooking.address,
              notes: updatedBooking.notes,
              checkInDate: updatedBooking.checkInDate,
              checkOutDate: updatedBooking.checkOutDate,
              roomDetails: updatedBooking.roomDetails,
              bookingFee: updatedBooking.bookingFee,
              customer: updatedBooking.customer,
              totalGuests: updatedBooking.totalGuests,
              remarks: updatedBooking.remarks,
              roomType: booking.roomType, // Preserve current room type
              selectedRoom: booking.selectedRoom, // Preserve current selected room
              roomRemarks: updatedBooking.roomRemarks,
              roomTypeId: updatedBooking.roomTypeId,
              roomId: updatedBooking.roomId,
              propertyName: updatedBooking.propertyName,
              propertyAddress: updatedBooking.propertyAddress,
              propertyId: updatedBooking.propertyId,
              paymentStatus: updatedBooking.paymentStatus,
              source: updatedBooking.source,
              subtotal: updatedBooking.subtotal,
              gst: updatedBooking.gst,
              totalCost: updatedBooking.totalCost,
              discount: updatedBooking.discount,
              finalAmount: updatedBooking.finalAmount,
              guests: updatedBooking.guests,
              guide: updatedBooking.guide,
              extras: updatedBooking.extras,
              addOns: updatedBooking.addOns,
            );
            
            setState(() {
              booking = preservedBooking;
            });
            print('✅ Booking data refreshed with preserved room data');
          } else {
            setState(() {
              booking = updatedBooking;
            });
            print('✅ Booking data refreshed with API room data');
          }
        } else {
          print('⚠️ Invalid booking data format');
        }
      } else {
        print('⚠️ Failed to fetch booking: ${res['message']}');
      }
    } catch (e) {
      print('💥 Error refreshing booking data: $e');
    }
  }
}
