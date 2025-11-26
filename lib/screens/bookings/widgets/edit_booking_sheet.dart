import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/bookingdetails.dart';
import '../services/bookings_service.dart';

class EditBookingBottomSheet extends StatefulWidget {
  final Booking booking;
  final VoidCallback? onUpdated;
  const EditBookingBottomSheet({super.key, required this.booking, this.onUpdated});

  @override
  State<EditBookingBottomSheet> createState() => _EditBookingBottomSheetState();
}

class _EditBookingBottomSheetState extends State<EditBookingBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _customerNameController;
  late final TextEditingController _customerPhoneController;
  late final TextEditingController _customerEmailController;
  late final TextEditingController _roomTypeController;
  late final TextEditingController _totalAmountController;
  late final TextEditingController _adultsController;
  late final TextEditingController _childrenController;
  late final TextEditingController _infantsController;
  late final TextEditingController _specialRequestsController;

  // Date and time
  late DateTime _checkInDate;
  late DateTime _checkOutDate;
  TimeOfDay _arrivalTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _departureTime = const TimeOfDay(hour: 11, minute: 0);

  // Status
  String _paymentStatus = 'pending';
  String _bookingStatus = 'pending';
  String _source = 'direct';

  final List<String> _paymentStatuses = ['pending', 'paid', 'refunded'];
  final List<String> _bookingStatuses = ['pending', 'confirmed', 'cancelled', 'completed'];
  final List<String> _sources = ['direct', 'agent', 'ota'];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final b = widget.booking;
    _customerNameController = TextEditingController(text: b.customer.name);
    _customerPhoneController = TextEditingController(text: b.customer.phone);
    _customerEmailController = TextEditingController(text: b.customer.email ?? '');
    _roomTypeController = TextEditingController(text: b.roomType);
    _totalAmountController = TextEditingController(text: b.totalCost.toStringAsFixed(0));
    _adultsController = TextEditingController(text: b.totalGuests.toString());
    _childrenController = TextEditingController(text: '0');
    _infantsController = TextEditingController(text: '0');
    _specialRequestsController = TextEditingController(text: b.notes ?? '');

    _checkInDate = b.checkInDate;
    _checkOutDate = b.checkOutDate;
    String normalize(String s) => s.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
    _bookingStatus = b.status.isNotEmpty ? normalize(b.status) : 'pending';
    _paymentStatus = 'pending';
    _source = b.companyName.isNotEmpty ? normalize(b.companyName) : 'direct';

    // Clamp to allowed values to avoid Dropdown initial value assertion
    if (!_bookingStatuses.contains(_bookingStatus)) {
      _bookingStatus = 'pending';
    }
    if (!_paymentStatuses.contains(_paymentStatus)) {
      _paymentStatus = 'pending';
    }
    if (!_sources.contains(_source)) {
      _source = 'direct';
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _roomTypeController.dispose();
    _totalAmountController.dispose();
    _adultsController.dispose();
    _childrenController.dispose();
    _infantsController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkInDate : _checkOutDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          if (!_checkOutDate.isAfter(_checkInDate)) {
            _checkOutDate = _checkInDate.add(const Duration(days: 1));
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(bool isArrival) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isArrival ? _arrivalTime : _departureTime,
    );
    if (picked != null) {
      setState(() {
        if (isArrival) {
          _arrivalTime = picked;
        } else {
          _departureTime = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final updateData = <String, dynamic>{
        'guest_name': _customerNameController.text.trim(),
        'guest_email': _customerEmailController.text.trim(),
        'guest_phone': _customerPhoneController.text.trim(),
        'check_in_date': _checkInDate.toIso8601String(),
        'check_out_date': _checkOutDate.toIso8601String(),
        'guest_count': int.tryParse(_adultsController.text.trim()) ?? widget.booking.totalGuests,
        'adults': int.tryParse(_adultsController.text.trim()) ?? widget.booking.totalGuests,
        'children': int.tryParse(_childrenController.text.trim()) ?? 0,
        'infants': int.tryParse(_infantsController.text.trim()) ?? 0,
        'total_amount': double.tryParse(_totalAmountController.text.trim()) ?? widget.booking.totalCost,
        'payment_status': _paymentStatus,
        'booking_status': _bookingStatus,
        'source': _source,
      };

      if (_specialRequestsController.text.trim().isNotEmpty) {
        updateData['special_requests'] = _specialRequestsController.text.trim();
      }
      if (_roomTypeController.text.trim().isNotEmpty) {
        updateData['room_type'] = _roomTypeController.text.trim();
      }

      final res = await BookingsService.updateBooking(
        bookingId: widget.booking.id,
        updateData: updateData,
      );

      if (res['success'] == true) {
        if (widget.onUpdated != null) widget.onUpdated!();
        if (mounted) Navigator.of(context).pop(true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message']?.toString() ?? 'Failed to update booking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Edit Booking',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Guest Information'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _textField(label: 'Guest Name *', controller: _customerNameController, validator: (v) => v?.isEmpty == true ? 'Required' : null),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _textField(label: 'Guest Phone *', controller: _customerPhoneController, keyboardType: TextInputType.phone, validator: (v) => v?.isEmpty == true ? 'Required' : null),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _textField(label: 'Guest Email', controller: _customerEmailController, keyboardType: TextInputType.emailAddress)),
                        const SizedBox(width: 16),
                        Expanded(child: _textField(label: 'Room Type *', controller: _roomTypeController, validator: (v) => v?.isEmpty == true ? 'Required' : null)),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle('Date Selection'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _dateField(label: 'Check-in Date *', date: _checkInDate, onTap: () => _selectDate(true))),
                        const SizedBox(width: 16),
                        Expanded(child: _dateField(label: 'Check-out Date *', date: _checkOutDate, onTap: () => _selectDate(false))),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle('Booking Details'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _textField(label: 'Adults *', controller: _adultsController, keyboardType: TextInputType.number, validator: (v) => v?.isEmpty == true ? 'Required' : null)),
                        const SizedBox(width: 16),
                        Expanded(child: _textField(label: 'Children', controller: _childrenController, keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _textField(label: 'Infants', controller: _infantsController, keyboardType: TextInputType.number)),
                        const SizedBox(width: 16),
                        Expanded(child: _textField(label: 'Total Amount *', controller: _totalAmountController, keyboardType: TextInputType.number, validator: (v) => v?.isEmpty == true ? 'Required' : null)),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle('Status and Source'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _dropdown(label: 'Payment Status', value: _paymentStatus, items: _paymentStatuses, onChanged: (v) => setState(() => _paymentStatus = v!))),
                        const SizedBox(width: 16),
                        Expanded(child: _dropdown(label: 'Booking Status', value: _bookingStatus, items: _bookingStatuses, onChanged: (v) => setState(() => _bookingStatus = v!))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _dropdown(label: 'Source', value: _source, items: _sources, onChanged: (v) => setState(() => _source = v!))),
                        const SizedBox(width: 16),
                        const Expanded(child: SizedBox()),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle('Time Selection'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _timeField(label: 'Arrival Time', time: _arrivalTime, onTap: () => _selectTime(true))),
                        const SizedBox(width: 16),
                        Expanded(child: _timeField(label: 'Departure Time', time: _departureTime, onTap: () => _selectTime(false))),
                      ],
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle('Special Requests'),
                    const SizedBox(height: 16),
                    _textArea(label: 'Special Requests', controller: _specialRequestsController, hintText: 'Any special requests or notes...'),

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _button(label: 'Cancel', onPressed: () => Navigator.pop(context), isPrimary: false),
                        const SizedBox(width: 16),
                        _button(label: 'Save Changes', onPressed: _isSubmitting ? null : _submit, isPrimary: true),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF333333)));
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF333333))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2196F3))),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _dateField({required String label, required DateTime date, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF333333))),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE0E0E0))),
            child: Row(
              children: [
                Text(DateFormat('MM/dd/yyyy').format(date), style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF333333))),
                const Spacer(),
                const Icon(Icons.calendar_today, size: 20, color: Color(0xFF666666)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _timeField({required String label, required TimeOfDay time, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF333333))),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE0E0E0))),
            child: Row(
              children: [
                Text(time.format(context), style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF333333))),
                const Spacer(),
                const Icon(Icons.access_time, size: 20, color: Color(0xFF666666)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdown({required String label, required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF333333))),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item.toUpperCase(), style: GoogleFonts.poppins(fontSize: 14)))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2196F3))),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _textArea({required String label, required TextEditingController controller, String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF333333))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2196F3))),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _button({
    required String label,
    required VoidCallback? onPressed,
    required bool isPrimary,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
        foregroundColor: isPrimary ? Colors.white : const Color(0xFF333333),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}


