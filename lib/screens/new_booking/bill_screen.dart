import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/common_app_bar.dart';
import 'payment_screen.dart';

class BillScreen extends StatefulWidget {
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int adults;
  final int children;
  final int infants;
  final Map<String, int> selectedRoomTypes;
  final Map<String, String> roomPrices;

  const BillScreen({
    super.key,
    required this.checkInDate,
    required this.checkOutDate,
    required this.adults,
    required this.children,
    required this.infants,
    required this.selectedRoomTypes,
    required this.roomPrices,
  });

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  late Map<String, String> _editablePrices;
  final Map<String, TextEditingController> _priceControllers = {};
  bool _includeGst = true;

  @override
  void initState() {
    super.initState();
    _editablePrices = Map<String, String>.from(widget.roomPrices);
    // Initialize controllers for each room type
    for (var roomType in widget.selectedRoomTypes.keys) {
      _priceControllers[roomType] = TextEditingController(
        text: _editablePrices[roomType] ?? '0',
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  int get _numberOfNights {
    return widget.checkOutDate.difference(widget.checkInDate).inDays;
  }

  double _getRoomTotal(String roomType, int quantity) {
    final priceStr = _editablePrices[roomType] ?? '0';
    final price = double.tryParse(priceStr.replaceAll(',', '')) ?? 0.0;
    return price * quantity * _numberOfNights;
  }

  double get _subtotal {
    double total = 0.0;
    for (var entry in widget.selectedRoomTypes.entries) {
      total += _getRoomTotal(entry.key, entry.value);
    }
    return total;
  }

  double get _tax {
    if (!_includeGst) return 0;
    return _subtotal * 0.18; // 18% GST
  }

  double get _total {
    return _subtotal + _tax;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar.withBackButton(
        title: 'Booking Bill',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Booking Summary
              _buildSectionCard(
                'Booking Summary',
                [
                  _buildSummaryRow('Check-in Date', _formatDate(widget.checkInDate)),
                  _buildSummaryRow('Check-out Date', _formatDate(widget.checkOutDate)),
                  _buildSummaryRow('Number of Nights', '$_numberOfNights'),
                  _buildSummaryRow('Adults', widget.adults.toString()),
                  if (widget.children > 0)
                    _buildSummaryRow('Children', widget.children.toString()),
                  if (widget.infants > 0)
                    _buildSummaryRow('Infants', widget.infants.toString()),
                ],
              ),

              const SizedBox(height: 16),

              // Room Details with Editable Prices
              _buildSectionCard(
                'Room Details',
                [
                  ...widget.selectedRoomTypes.entries.map((entry) {
                    final roomType = entry.key;
                    final quantity = entry.value;
                    return _buildRoomPriceRow(roomType, quantity);
                  }),
                ],
              ),

              const SizedBox(height: 16),

              // Bill Summary
              _buildSectionCard(
                'Bill Summary',
                [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Include GST (18%)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: _includeGst,
                          activeColor: const Color(0xFF1F2937),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          splashRadius: 16,
                          onChanged: (value) {
                            setState(() {
                              _includeGst = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildBillRow('Subtotal', _subtotal),
                  _buildBillRow('Tax (18% GST)', _tax),
                  const Divider(height: 24),
                  _buildBillRow('Total', _total, isTotal: true),
                ],
              ),

              const SizedBox(height: 24),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(totalAmount: _total),
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
                    'Proceed To Payment',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomPriceRow(String roomType, int quantity) {
    final controller = _priceControllers[roomType]!;
    final roomTotal = _getRoomTotal(roomType, quantity);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '$quantity x $roomType',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              Text(
                '₹${roomTotal.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Price: ',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1F2937),
                  ),
                  decoration: InputDecoration(
                    prefixText: '₹',
                    prefixStyle: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF1F2937),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFF1F2937), width: 1.5),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _editablePrices[roomType] = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '× $quantity × $_numberOfNights nights',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 14 : 12,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}

