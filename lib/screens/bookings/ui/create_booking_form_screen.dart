import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/app_form_styles.dart';
import 'package:intl/intl.dart';

class CreateBookingFormScreen extends StatefulWidget {
  const CreateBookingFormScreen({super.key});

  @override
  State<CreateBookingFormScreen> createState() => _CreateBookingFormScreenState();
}

class _CreateBookingFormScreenState extends State<CreateBookingFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  final List<String> _stepTitles = const ['Guest & Stay Details', 'Payment & Extras'];

  final TextEditingController _guestNameCtrl = TextEditingController();
  final TextEditingController _guestEmailCtrl = TextEditingController();
  final TextEditingController _guestPhoneCtrl = TextEditingController();
  final TextEditingController _roomTypeCtrl = TextEditingController();
  final TextEditingController _roomCountCtrl = TextEditingController(text: '1');
  final TextEditingController _totalAmountCtrl = TextEditingController();
  final TextEditingController _adultsCtrl = TextEditingController(text: '1');
  final TextEditingController _childrenCtrl = TextEditingController(text: '0');
  final TextEditingController _infantsCtrl = TextEditingController(text: '0');
  final TextEditingController _specialReqCtrl = TextEditingController();
  final TextEditingController _sortOrderCtrl = TextEditingController(text: '1');

  DateTime _checkInDate = DateTime.now();
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _arrivalTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _departureTime = const TimeOfDay(hour: 11, minute: 0);

  String _paymentStatus = 'pending';
  String _bookingStatus = 'pending';
  String _source = 'direct';

  final List<String> _paymentStatuses = ['pending', 'paid', 'refunded'];
  final List<String> _bookingStatuses = ['pending', 'confirmed', 'cancelled', 'completed'];
  final List<String> _sources = ['direct', 'agent', 'ota'];

  @override
  void dispose() {
    _guestNameCtrl.dispose();
    _guestEmailCtrl.dispose();
    _guestPhoneCtrl.dispose();
    _roomTypeCtrl.dispose();
    _roomCountCtrl.dispose();
    _totalAmountCtrl.dispose();
    _adultsCtrl.dispose();
    _childrenCtrl.dispose();
    _infantsCtrl.dispose();
    _specialReqCtrl.dispose();
    _sortOrderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Booking', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: AppFormStyles.stepHeader(_stepTitles[_currentStep], _currentStep, _stepTitles.length),
          ),
          const SizedBox(height: 8),
          // Content
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: _buildCurrentStep(),
              ),
            ),
          ),
          // Nav buttons
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text('Previous', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep == _stepTitles.length - 1 ? _submit : _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Text(_currentStep == _stepTitles.length - 1 ? 'Create Booking' : 'Next', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _next() {
    if (_formKey.currentState!.validate()) {
      setState(() => _currentStep++);
    }
  }

  Widget _buildCurrentStep() {
    if (_currentStep == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row(
            left: _text('Guest Name *', _guestNameCtrl, validator: _required),
            right: _text('Guest Email *', _guestEmailCtrl, keyboardType: TextInputType.emailAddress, validator: _required),
          ),
          const SizedBox(height: 16),
          _text('Guest Phone *', _guestPhoneCtrl, keyboardType: TextInputType.phone, validator: _required),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _text('Room Type *', _roomTypeCtrl, hint: 'e.g., Deluxe Room, Suite', validator: _required)),
            const SizedBox(width: 16),
            Expanded(child: _dropdown('Source', _source, _sources, (v) => setState(() => _source = v))),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _date('Check-in Date *', _checkInDate, (d) => setState(() => _checkInDate = d))),
            const SizedBox(width: 16),
            Expanded(child: _date('Check-out Date *', _checkOutDate, (d) => setState(() => _checkOutDate = d))),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _text('Room Count *', _roomCountCtrl, keyboardType: TextInputType.number, validator: _required)),
            const SizedBox(width: 16),
            Expanded(child: _text('Total Amount *', _totalAmountCtrl, keyboardType: TextInputType.number, validator: _required)),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _text('Adults *', _adultsCtrl, keyboardType: TextInputType.number, validator: _required)),
            const SizedBox(width: 16),
            Expanded(child: _text('Children', _childrenCtrl, keyboardType: TextInputType.number)),
            const SizedBox(width: 16),
            Expanded(child: _text('Infants', _infantsCtrl, keyboardType: TextInputType.number)),
          ]),
        ],
      );
    }
    // Step 2
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(child: _dropdown('Booking Status', _bookingStatus, _bookingStatuses, (v) => setState(() => _bookingStatus = v))),
          const SizedBox(width: 16),
          Expanded(child: _dropdown('Payment Status', _paymentStatus, _paymentStatuses, (v) => setState(() => _paymentStatus = v))),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _time('Arrival Time', _arrivalTime, (t) => setState(() => _arrivalTime = t))),
          const SizedBox(width: 16),
          Expanded(child: _time('Departure Time', _departureTime, (t) => setState(() => _departureTime = t))),
        ]),
        const SizedBox(height: 16),
        _multiline('Special Requests', _specialReqCtrl, hint: 'Any special requests or notes...'),
      ],
    );
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  Widget _row({required Widget left, required Widget right}) {
    final double w = MediaQuery.of(context).size.width;
    final bool narrow = w < 700;
    if (narrow) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [left, const SizedBox(height: 16), right]);
    }
    return Row(children: [Expanded(child: left), const SizedBox(width: 16), Expanded(child: right)]);
  }

  Widget _text(String label, TextEditingController c, {TextInputType? keyboardType, String? Function(String?)? validator, String? hint}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
      const SizedBox(height: 8),
      TextFormField(
        controller: c,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Color(0xFF6366F1), width: 2)),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    ]);
  }

  Widget _multiline(String label, TextEditingController c, {String? hint}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
      const SizedBox(height: 8),
      TextFormField(
        controller: c,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Color(0xFF6366F1), width: 2)),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    ]);
  }

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String> onChanged) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: DropdownButtonFormField<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black)))).toList(),
          onChanged: (v) => onChanged(v ?? value),
          decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16)),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6366F1)),
        ),
      ),
    ]);
  }

  Widget _date(String label, DateTime date, ValueChanged<DateTime> onPicked) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
      const SizedBox(height: 8),
      InkWell(
        onTap: () async {
          final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
          if (picked != null) onPicked(picked);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12), color: Colors.grey.shade50),
          child: Row(children: [
            const Icon(Icons.calendar_today, color: Color(0xFF6366F1)),
            const SizedBox(width: 12),
            Text(DateFormat('dd/MM/yyyy').format(date), style: GoogleFonts.poppins(fontSize: 14)),
          ]),
        ),
      ),
    ]);
  }

  Widget _time(String label, TimeOfDay time, ValueChanged<TimeOfDay> onPicked) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
      const SizedBox(height: 8),
      InkWell(
        onTap: () async {
          final picked = await showTimePicker(context: context, initialTime: time);
          if (picked != null) onPicked(picked);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12), color: Colors.grey.shade50),
          child: Row(children: [
            const Icon(Icons.access_time, color: Color(0xFF6366F1)),
            const SizedBox(width: 12),
            Text(time.format(context), style: GoogleFonts.poppins(fontSize: 14)),
          ]),
        ),
      ),
    ]);
  }

  void _reset() {
    _formKey.currentState?.reset();
    _guestNameCtrl.clear();
    _guestEmailCtrl.clear();
    _guestPhoneCtrl.clear();
    _roomTypeCtrl.clear();
    _roomCountCtrl.text = '1';
    _totalAmountCtrl.clear();
    _adultsCtrl.text = '1';
    _childrenCtrl.text = '0';
    _infantsCtrl.text = '0';
    _specialReqCtrl.clear();
    setState(() {
      _paymentStatus = 'Pending';
      _bookingStatus = 'Pending';
      _source = 'Direct';
      _checkInDate = DateTime.now();
      _checkOutDate = DateTime.now().add(const Duration(days: 1));
      _arrivalTime = const TimeOfDay(hour: 12, minute: 0);
      _departureTime = const TimeOfDay(hour: 11, minute: 0);
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking created'), backgroundColor: Colors.green));
    Navigator.of(context).pop();
  }
}
