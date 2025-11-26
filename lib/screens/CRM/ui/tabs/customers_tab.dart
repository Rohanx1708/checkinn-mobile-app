import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/crm_service.dart';
import 'package:checkinn/services/auth_service.dart';

class CustomersTab extends StatefulWidget {
  const CustomersTab({super.key});

  @override
  State<CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends State<CustomersTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _status = 'All Status';

  final List<_Customer> _all = <_Customer>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await AuthService.getToken();
      CrmService.authToken = token;
      final list = await CrmService.fetchAllCustomers(perPage: 50);
      final parsed = list.map<_Customer>(_parseCustomer).toList();
      setState(() {
        _all
          ..clear()
          ..addAll(parsed);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  _Customer _parseCustomer(Map<String, dynamic> m) {
    String name = (m['name'] ?? '').toString().trim();
    if (name.isEmpty) {
      final first = (m['first_name'] ?? m['firstName'] ?? '').toString();
      final last = (m['last_name'] ?? m['lastName'] ?? '').toString();
      name = (first + ' ' + last).trim();
      if (name.isEmpty) name = (m['full_name'] ?? m['fullName'] ?? 'Unknown').toString();
    }
    final email = (m['email'] ?? '').toString();
    final phone = (m['phone'] ?? m['mobile'] ?? '').toString();
    String status = (m['status'] ?? 'prospect').toString();
    if (status.isNotEmpty) {
      final s = status.toLowerCase();
      if (s == 'active') status = 'Active';
      else if (s == 'inactive') status = 'Inactive';
      else status = 'Prospect';
    } else {
      status = 'Prospect';
    }
    String source = (m['source'] ?? '').toString();
    if (source.isEmpty) source = 'direct';

    int bookings = 0;
    final bk = m['bookings'] ?? m['bookings_count'] ?? m['total_bookings'];
    if (bk is int) bookings = bk; else if (bk is String) { bookings = int.tryParse(bk) ?? 0; }

    double totalSpent = 0;
    final ts = m['total_spent'] ?? m['revenue'] ?? m['lifetime_value'];
    if (ts is num) totalSpent = ts.toDouble(); else if (ts is String) { totalSpent = double.tryParse(ts) ?? 0; }

    DateTime lastBooking = DateTime.now();
    final lb = m['last_booking'] ?? m['latest_booking_date'] ?? m['last_booking_at'];
    if (lb is String && lb.isNotEmpty) {
      try { lastBooking = DateTime.parse(lb); } catch (_) {}
    }

    return _Customer(
      name: name,
      source: source,
      email: email,
      phone: phone,
      status: status,
      bookings: bookings,
      totalSpent: totalSpent,
      lastBooking: lastBooking,
    );
  }

  List<_Customer> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _all.where((c) {
      final matchesStatus = _status == 'All Status' || c.status.toLowerCase() == _status.toLowerCase();
      if (!matchesStatus) return false;
      if (q.isEmpty) return true;
      return c.name.toLowerCase().contains(q) || c.email.toLowerCase().contains(q) || c.phone.toLowerCase().contains(q) || c.source.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search customers...',
                      hintStyle: GoogleFonts.poppins(color: const Color(0xFF94A3B8), fontSize: 14),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF6366F1)),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _status,
                    items: const [
                      DropdownMenuItem(value: 'All Status', child: Text('All Status')),
                      DropdownMenuItem(value: 'Active', child: Text('Active')),
                      DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                      DropdownMenuItem(value: 'Prospect', child: Text('Prospect')),
                    ],
                    onChanged: (v) => setState(() { if (v != null) _status = v; }),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadCustomers,
            child: _loading
                ? ListView(children: const [SizedBox(height: 200), Center(child: CircularProgressIndicator())])
                : (_error != null
                    ? ListView(children: [
                        SizedBox(height: 120),
                        Center(child: Text('Failed to load customers', style: GoogleFonts.poppins(color: Colors.red))),
                        const SizedBox(height: 6),
                        Center(child: Text('Tap to retry', style: TextStyle(color: Colors.black54))),
                        const SizedBox(height: 12),
                        Center(child: OutlinedButton(onPressed: _loadCustomers, child: const Text('Retry'))),
                      ])
                    : ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 8),
            itemCount: _filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final c = _filtered[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                          ),
                          alignment: Alignment.center,
                          child: Text(_initials(c.name), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15, color: const Color(0xFF111827))),
                              const SizedBox(height: 2),
                              Text(c.source, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                        _statusChip(c.status),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              _openEditCustomerSheet(c);
                            } else if (value == 'delete') {
                              await _confirmDeleteCustomer(c);
                            }
                          },
                          itemBuilder: (ctx) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${c.email}', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                              const SizedBox(height: 2),
                              Text(c.phone, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text('${c.bookings} booking${c.bookings == 1 ? '' : 's'}', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF374151), fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.login_rounded, size: 16, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 6),
                        Text('Last booking: ${_fmtDate(c.lastBooking)}', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                        const SizedBox(width: 16),
                        const Icon(Icons.payments_outlined, size: 16, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 6),
                        Text('Total: ${_formatCurrency(c.totalSpent)}', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                      ],
                    ),

                ],
                ),
              );
            },
          )),
        ),
        ),
      ],
    ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: _openAddCustomerSheet,
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text('Add Customer'),
            backgroundColor: const Color(0xFF6366F1),
          ),
        ),
      ],
    );
  }

  Future<void> _openAddCustomerSheet() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final ratingCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String status = 'Prospect';
    String source = '';

    final _formKey = GlobalKey<FormState>();

    final result = await showModalBottomSheet<_Customer>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        final double screenWidth = MediaQuery.of(ctx).size.width;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Add New Customer', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
                    const SizedBox(height: 16),
                    Text('Name *', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: nameCtrl,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Full name'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email *', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: emailCtrl,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Email is required' : null,
                                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'email@example.com'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Phone', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: phoneCtrl,
                                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '+91 9999999999'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status *', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: status,
                                decoration: const InputDecoration(border: OutlineInputBorder()),
                                items: const [
                                  DropdownMenuItem(value: 'Prospect', child: Text('Prospect')),
                                  DropdownMenuItem(value: 'Active', child: Text('Active')),
                                  DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                                ],
                                onChanged: (v) { if (v != null) status = v; },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Source *', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: source.isEmpty ? null : source,
                                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Select Source'),
                                items: const [
                                  DropdownMenuItem(value: 'direct', child: Text('Direct')),
                                  DropdownMenuItem(value: 'website', child: Text('Website')),
                                  DropdownMenuItem(value: 'phone', child: Text('Phone')),
                                  DropdownMenuItem(value: 'ota', child: Text('OTA')),
                                  DropdownMenuItem(value: 'walk_in', child: Text('Walk-in')),
                                ],
                                validator: (v) => (v == null || v.isEmpty) ? 'Source is required' : null,
                                onChanged: (v) { if (v != null) source = v; },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Rating (0-5)', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: ratingCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'e.g. 4.5'),
                    ),
                    const SizedBox(height: 12),
                    Text('Notes', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: notesCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Additional details'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF111827),
                            backgroundColor: const Color(0xFFE5E7EB),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) return;
                            final newCustomer = _Customer(
                              name: nameCtrl.text.trim(),
                              source: source,
                              email: emailCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                              status: status,
                              bookings: 0,
                              totalSpent: 0,
                              lastBooking: DateTime.now(),
                            );
                            Navigator.of(ctx).pop(newCustomer);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text('Create Customer'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (result != null) {
      try {
        await CrmService.createCustomer(
          name: result.name,
          email: result.email,
          phone: result.phone,
          status: result.status,
          source: result.source,
          rating: null,
          notes: '',
        );
        setState(() {
          _all.insert(0, result);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Customer created')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('API error: $e')),
          );
        }
      }
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Widget _statusChip(String status) {
    Color bg = const Color(0xFFE5E7EB);
    Color fg = const Color(0xFF6B7280);
    if (status.toLowerCase() == 'active') {
      bg = const Color(0xFFE9FCEB);
      fg = const Color(0xFF16A34A);
    } else if (status.toLowerCase() == 'inactive') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFEF4444);
    } else if (status.toLowerCase() == 'prospect') {
      bg = const Color(0xFFE0EAFF);
      fg = const Color(0xFF2563EB);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(status, style: GoogleFonts.poppins(fontSize: 12, color: fg, fontWeight: FontWeight.w600)),
    );
  }

  String _fmtDate(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _formatCurrency(double v) {
    return '₹' + v.toStringAsFixed(2);
  }

  Future<void> _confirmDeleteCustomer(_Customer c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${c.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await CrmService.deleteCustomer(c.email);
        setState(() {
          _all.remove(c);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer deleted')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
        }
      }
    }
  }

  Future<void> _openEditCustomerSheet(_Customer customer) async {
    final nameCtrl = TextEditingController(text: customer.name);
    final emailCtrl = TextEditingController(text: customer.email);
    final phoneCtrl = TextEditingController(text: customer.phone);
    String status = customer.status;
    String source = customer.source;
    final _formKey = GlobalKey<FormState>();

    final updated = await showModalBottomSheet<_Customer>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        final double screenWidth = MediaQuery.of(ctx).size.width;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Edit Customer', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
                    const SizedBox(height: 16),
                    Text('Name *', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                    const SizedBox(height: 6),
                    TextFormField(controller: nameCtrl, validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null, decoration: const InputDecoration(border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Email *', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))), const SizedBox(height: 6),
                        TextFormField(controller: emailCtrl, validator: (v) => (v == null || v.trim().isEmpty) ? 'Email is required' : null, decoration: const InputDecoration(border: OutlineInputBorder())),
                      ])),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Phone', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))), const SizedBox(height: 6),
                        TextFormField(controller: phoneCtrl, decoration: const InputDecoration(border: OutlineInputBorder())),
                      ])),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Status *', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))), const SizedBox(height: 6),
                        DropdownButtonFormField<String>(value: status, decoration: const InputDecoration(border: OutlineInputBorder()), items: const [
                          DropdownMenuItem(value: 'Prospect', child: Text('Prospect')),
                          DropdownMenuItem(value: 'Active', child: Text('Active')),
                          DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                        ], onChanged: (v) { if (v != null) status = v; }),
                      ])),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Source *', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))), const SizedBox(height: 6),
                        DropdownButtonFormField<String>(value: source.isEmpty ? null : source, decoration: const InputDecoration(border: OutlineInputBorder()), items: const [
                          DropdownMenuItem(value: 'direct', child: Text('Direct')),
                          DropdownMenuItem(value: 'website', child: Text('Website')),
                          DropdownMenuItem(value: 'phone', child: Text('Phone')),
                          DropdownMenuItem(value: 'ota', child: Text('OTA')),
                          DropdownMenuItem(value: 'walk_in', child: Text('Walk-in')),
                        ], onChanged: (v) { if (v != null) source = v; }),
                      ])),
                    ]),
                    const SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(), style: TextButton.styleFrom(foregroundColor: const Color(0xFF111827), backgroundColor: const Color(0xFFE5E7EB), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Cancel')),
                      const SizedBox(width: 12),
                      ElevatedButton(onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        Navigator.of(ctx).pop(_Customer(name: nameCtrl.text.trim(), source: source, email: emailCtrl.text.trim(), phone: phoneCtrl.text.trim(), status: status, bookings: customer.bookings, totalSpent: customer.totalSpent, lastBooking: customer.lastBooking));
                      }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0), child: const Text('Save Changes')),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (updated != null) {
      try {
        await CrmService.updateCustomer(id: customer.email, updates: {
          'name': updated.name,
          'email': updated.email,
          'phone': updated.phone,
          'status': updated.status.toLowerCase(),
          'source': updated.source,
        });
        setState(() {
          final idx = _all.indexOf(customer);
          if (idx != -1) _all[idx] = updated;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Customer updated')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
        }
      }
    }
  }
}

class _Customer {
  final String name;
  final String source;
  final String email;
  final String phone;
  final String status;
  final int bookings;
  final double totalSpent;
  final DateTime lastBooking;

  const _Customer({
    required this.name,
    required this.source,
    required this.email,
    required this.phone,
    required this.status,
    required this.bookings,
    required this.totalSpent,
    required this.lastBooking,
  });
}


