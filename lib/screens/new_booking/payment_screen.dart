import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.totalAmount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _paymentMode = 'full'; // 'full' or 'partial'
  final TextEditingController _partialAmountController =
      TextEditingController();
  String _paymentMethod = 'upi'; // upi, card, cash
  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardExpiryController = TextEditingController();
  final TextEditingController _cardCvvController = TextEditingController();

  @override
  void dispose() {
    _partialAmountController.dispose();
    _upiController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.totalAmount;
    final bool isPartial = _paymentMode == 'partial';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Payment',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionCard(
                        title: 'Amount to Pay',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RadioListTile<String>(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              value: 'full',
                              groupValue: _paymentMode,
                              activeColor: const Color(0xFF1F2937),
                              onChanged: (v) {
                                setState(() {
                                  _paymentMode = v ?? 'full';
                                  _partialAmountController.clear();
                                });
                              },
                              title: Text(
                                'Pay full amount (₹${total.toStringAsFixed(2)})',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ),
                            RadioListTile<String>(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              value: 'partial',
                              groupValue: _paymentMode,
                              activeColor: const Color(0xFF1F2937),
                              onChanged: (v) {
                                setState(() {
                                  _paymentMode = v ?? 'partial';
                                });
                              },
                              title: Text(
                                'Pay partial amount',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ),
                            if (isPartial) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Enter partial amount',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _partialAmountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  prefixText: '₹ ',
                                  prefixStyle: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: const Color(0xFF1F2937),
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide:
                                        const BorderSide(color: Color(0xFFE5E7EB)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF1F2937),
                                      width: 1.4,
                                    ),
                                  ),
                                  hintText: 'Enter amount up to ₹${total.toStringAsFixed(2)}',
                                  hintStyle: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                                onChanged: (value) {
                                  final parsed = double.tryParse(value.trim());
                                  if (parsed != null && parsed > total) {
                                    final capped = total.toStringAsFixed(2);
                                    _partialAmountController.value =
                                        TextEditingValue(
                                          text: capped,
                                          selection: TextSelection.collapsed(
                                            offset: capped.length,
                                          ),
                                        );
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Payment Method',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _PaymentMethodTile(
                              label: 'UPI',
                              icon: Icons.qr_code,
                              selected: _paymentMethod == 'upi',
                              onTap: () {
                                setState(() => _paymentMethod = 'upi');
                              },
                            ),
                            _PaymentMethodTile(
                              label: 'Card',
                              icon: Icons.credit_card,
                              selected: _paymentMethod == 'card',
                              onTap: () {
                                setState(() => _paymentMethod = 'card');
                              },
                            ),
                            _PaymentMethodTile(
                              label: 'Cash',
                              icon: Icons.payments,
                              selected: _paymentMethod == 'cash',
                              onTap: () {
                                setState(() => _paymentMethod = 'cash');
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {}, // looks active but does nothing
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save Booking',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  const _PaymentMethodTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFF3F4F6),
          child: Icon(icon, color: const Color(0xFF1F2937), size: 18),
        ),
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        trailing: selected
            ? const Icon(Icons.check_circle, color: Color(0xFF10B981))
            : const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: selected ? const Color(0xFFF3F4F6) : Colors.white,
      ),
    );
  }
}
