import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/bookingdetails.dart';
import '../services/bookings_service.dart';

class AddBookingBottomSheet extends StatefulWidget {
  final Function(Booking)? onBookingAdded;
  
  const AddBookingBottomSheet({super.key, this.onBookingAdded});

  @override
  State<AddBookingBottomSheet> createState() => _AddBookingBottomSheetState();
}

class _AddBookingBottomSheetState extends State<AddBookingBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _roomTypeController = TextEditingController();
  final _roomCountController = TextEditingController(text: '1');
  final _totalAmountController = TextEditingController();
  final _adultsController = TextEditingController(text: '1');
  final _childrenController = TextEditingController(text: '0');
  final _infantsController = TextEditingController(text: '0');
  final _specialRequestsController = TextEditingController();
  
  // Date and time variables
  DateTime _checkInDate = DateTime.now();
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _arrivalTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _departureTime = const TimeOfDay(hour: 11, minute: 0);
  
  // Status variables
  String _paymentStatus = 'pending';
  String _bookingStatus = 'pending';
  String _source = 'direct';
  
  // Options
  final List<String> _paymentStatuses = ['pending', 'paid', 'refunded'];
  final List<String> _bookingStatuses = ['pending', 'confirmed', 'cancelled', 'completed'];
  final List<String> _sources = ['direct', 'agent', 'ota'];
  
  bool _isLoading = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _roomTypeController.dispose();
    _roomCountController.dispose();
    _totalAmountController.dispose();
    _adultsController.dispose();
    _childrenController.dispose();
    _infantsController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkInDate : _checkOutDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
          // Auto-adjust checkout date if it's before check-in
          if (_checkOutDate.isBefore(_checkInDate) || _checkOutDate.isAtSameMomentAs(_checkInDate)) {
            _checkOutDate = _checkInDate.add(const Duration(days: 1));
          }
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isArrival) async {
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

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final booking = Booking(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Booking for ${_customerNameController.text.trim()}',
        companyName: 'Hotel Booking',
        imageUrl: '',
        date: DateTime.now(),
        status: _bookingStatus,
        amountSpend: double.tryParse(_totalAmountController.text) ?? 0.0,
        balanceDue: 0.0,
        address: 'Hotel Address',
        notes: _specialRequestsController.text.trim(),
        checkInDate: _checkInDate,
        checkOutDate: _checkOutDate,
        roomDetails: _roomTypeController.text.trim(),
        bookingFee: 0.0,
        roomType: _roomTypeController.text.trim(),
        selectedRoom: 'Room 101',
        customer: Customer(
          name: _customerNameController.text.trim(),
          email: _customerEmailController.text.trim(),
          phone: _customerPhoneController.text.trim(),
          address: 'Customer Address',
          idProof: 'Aadhar',
          idProofNumber: '1234567890',
        ),
        totalGuests: int.parse(_adultsController.text) + int.parse(_childrenController.text) + int.parse(_infantsController.text),
        subtotal: double.tryParse(_totalAmountController.text) ?? 0.0,
        gst: 0.0,
        totalCost: double.tryParse(_totalAmountController.text) ?? 0.0,
        discount: 0.0,
        finalAmount: double.tryParse(_totalAmountController.text) ?? 0.0,
        addOns: [],
      );

      if (widget.onBookingAdded != null) {
        widget.onBookingAdded!(booking);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating booking: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
                  children: [
                    Text(
                  'Create New Booking',
                      style: GoogleFonts.inter(
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
          
          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Guest Information Section
                    _buildSectionTitle('Guest Information'),
                const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Guest Name *',
                            controller: _customerNameController,
                            validator: (value) => value?.isEmpty == true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Guest Phone *',
                            controller: _customerPhoneController,
                            keyboardType: TextInputType.phone,
                            validator: (value) => value?.isEmpty == true ? 'Required' : null,
                          ),
                        ),
                      ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                          child: _buildTextField(
                            label: 'Guest Email',
                            controller: _customerEmailController,
                            keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                          child: _buildTextField(
                            label: 'Room Type *',
                            controller: _roomTypeController,
                            hintText: 'e.g., Deluxe Room, Suite',
                            validator: (value) => value?.isEmpty == true ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                    
                const SizedBox(height: 24),

                    // Date Selection Section
                    _buildSectionTitle('Date Selection'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                            label: 'Check-in Date *',
                            date: _checkInDate,
                        onTap: () => _selectDate(context, true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateField(
                            label: 'Check-out Date *',
                            date: _checkOutDate,
                        onTap: () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),
                    
                const SizedBox(height: 24),

                    // Booking Details Section
                    _buildSectionTitle('Booking Details'),
                const SizedBox(height: 16),
                    Row(
                                children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Room Count *',
                            controller: _roomCountController,
                            keyboardType: TextInputType.number,
                            validator: (value) => value?.isEmpty == true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Adults *',
                            controller: _adultsController,
                            keyboardType: TextInputType.number,
                            validator: (value) => value?.isEmpty == true ? 'Required' : null,
                                    ),
                                  ),
                                ],
                              ),
                    const SizedBox(height: 16),
                              Row(
                                children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Total Amount *',
                            controller: _totalAmountController,
                            keyboardType: TextInputType.number,
                            validator: (value) => value?.isEmpty == true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Children',
                            controller: _childrenController,
                            keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                  const SizedBox(height: 16),
                    Row(
                          children: [
                        Expanded(
                          child: _buildTextField(
                            label: 'Infants',
                            controller: _infantsController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(child: SizedBox()), // Empty space for alignment
                      ],
                    ),
                    
                const SizedBox(height: 24),

                    // Status and Source Section
                    _buildSectionTitle('Status and Source'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                          child: _buildDropdown(
                            label: 'Payment Status',
                            value: _paymentStatus,
                            items: _paymentStatuses,
                            onChanged: (value) => setState(() => _paymentStatus = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                          child: _buildDropdown(
                            label: 'Booking Status',
                            value: _bookingStatus,
                            items: _bookingStatuses,
                            onChanged: (value) => setState(() => _bookingStatus = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                          child: _buildDropdown(
                            label: 'Source',
                            value: _source,
                            items: _sources,
                            onChanged: (value) => setState(() => _source = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                        const Expanded(child: SizedBox()), // Empty space for alignment
                      ],
                    ),
                    
                const SizedBox(height: 24),

                    // Time Selection Section
                    _buildSectionTitle('Time Selection'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                          child: _buildTimeField(
                            label: 'Arrival Time',
                            time: _arrivalTime,
                            onTap: () => _selectTime(context, true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                          child: _buildTimeField(
                            label: 'Departure Time',
                            time: _departureTime,
                            onTap: () => _selectTime(context, false),
                      ),
                    ),
                  ],
                ),
                    
                const SizedBox(height: 24),

                    // Special Requests Section
                    _buildSectionTitle('Special Requests'),
                const SizedBox(height: 16),
                    _buildTextArea(
                      label: 'Special Requests',
                      controller: _specialRequestsController,
                      hintText: 'Any special requests or notes...',
                    ),
                    
                const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildButton(
                          label: 'Reset',
                          onPressed: _resetForm,
                          isPrimary: false,
                        ),
                        const SizedBox(width: 16),
                        _buildButton(
                          label: 'Create Booking',
                          onPressed: _isLoading ? null : _submitBooking,
                          isPrimary: true,
                        ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
        color: const Color(0xFF333333),
          ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2196F3)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              children: [
                Text(
                  DateFormat('MM/dd/yyyy').format(date),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.calendar_today, size: 20, color: Color(0xFF666666)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            children: [
                Text(
                  time.format(context),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.access_time, size: 20, color: Color(0xFF666666)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(
              item.toUpperCase(),
              style: GoogleFonts.inter(fontSize: 14),
            ),
          )).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2196F3)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea({
    required String label,
    required TextEditingController controller,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2196F3)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
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
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _customerNameController.clear();
      _customerPhoneController.clear();
      _customerEmailController.clear();
      _roomTypeController.clear();
      _roomCountController.text = '1';
      _totalAmountController.clear();
      _adultsController.text = '1';
      _childrenController.text = '0';
      _infantsController.text = '0';
      _specialRequestsController.clear();
      _checkInDate = DateTime.now();
      _checkOutDate = DateTime.now().add(const Duration(days: 1));
      _arrivalTime = const TimeOfDay(hour: 12, minute: 0);
      _departureTime = const TimeOfDay(hour: 11, minute: 0);
      _paymentStatus = 'pending';
      _bookingStatus = 'pending';
      _source = 'direct';
    });
  }
}