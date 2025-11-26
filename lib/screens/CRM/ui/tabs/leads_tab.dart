import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/crm_service.dart';
import 'package:checkinn/services/auth_service.dart';

class LeadsTab extends StatefulWidget {
  const LeadsTab({super.key});

  @override
  State<LeadsTab> createState() => _LeadsTabState();
}

class _LeadsTabState extends State<LeadsTab> {
  final TextEditingController _leadSearchCtrl = TextEditingController();
  String _leadStatus = 'All Status';

  final List<_Lead> _leads = <_Lead>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  List<_Lead> get _leadFiltered {
    final query = _leadSearchCtrl.text.trim().toLowerCase();
    return _leads.where((l) {
      final matchesStatus = _leadStatus == 'All Status' || l.status.toLowerCase() == _leadStatus.toLowerCase();
      if (!matchesStatus) return false;
      if (query.isEmpty) return true;
      return l.name.toLowerCase().contains(query) || l.email.toLowerCase().contains(query) || l.phone.toLowerCase().contains(query) || l.source.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _leadSearchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadLeads() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await AuthService.getToken();
      CrmService.authToken = token;
      final list = await CrmService.fetchAllLeads(perPage: 200);
      final parsed = list.map<_Lead>(_parseLead).toList();
      setState(() { _leads..clear()..addAll(parsed); _loading = false; });
    } catch (e) {
      setState(() { _error = '$e'; _loading = false; });
    }
  }

  _Lead _parseLead(Map<String, dynamic> m) {
    final id = (m['id'] ?? m['_id'] ?? m['lead_id'] ?? '').toString();
    String name = (m['name'] ?? '').toString().trim();
    if (name.isEmpty) name = (m['full_name'] ?? m['fullName'] ?? 'Unknown').toString();
    final email = (m['email'] ?? '').toString();
    final phone = (m['phone'] ?? m['mobile'] ?? '').toString();
    String status = (m['status'] ?? 'new').toString();
    status = status.isEmpty ? 'new' : status.toLowerCase();
    status = {
      'new': 'New', 'contacted': 'Contacted', 'qualified': 'Qualified', 'converted': 'Converted', 'lost': 'Lost'
    }[status] ?? 'New';
    String source = (m['source'] ?? '').toString();
    if (source.isEmpty) source = 'direct';
    final interest = (m['interest'] ?? m['room_type_interest'] ?? '').toString();
    double budget = 0;
    final bd = m['budget']; if (bd is num) budget = bd.toDouble(); else if (bd is String) budget = double.tryParse(bd) ?? 0;
    final timeline = (m['timeline'] ?? '').toString();
    DateTime? expectedIn; final ei = m['expected_check_in'] ?? m['expectedIn']; if (ei is String && ei.isNotEmpty) { try { expectedIn = DateTime.parse(ei); } catch (_) {} }
    DateTime? expectedOut; final eo = m['expected_check_out'] ?? m['expectedOut']; if (eo is String && eo.isNotEmpty) { try { expectedOut = DateTime.parse(eo); } catch (_) {} }
    int adults = 1; final ad = m['adults']; if (ad is int) adults = ad; else if (ad is String) adults = int.tryParse(ad) ?? 1;
    int children = 0; final ch = m['children']; if (ch is int) children = ch; else if (ch is String) children = int.tryParse(ch) ?? 0;
    int infants = 0; final inf = m['infants']; if (inf is int) infants = inf; else if (inf is String) infants = int.tryParse(inf) ?? 0;
    final notes = (m['notes'] ?? '').toString();
    final special = (m['special_requests'] ?? m['specialRequests'] ?? '').toString();
    int score = 0; final sc = m['score']; if (sc is int) score = sc; else if (sc is String) score = int.tryParse(sc) ?? 0;
    return _Lead(
      id: id,
      name: name, source: source, email: email, phone: phone, status: status,
      interest: interest, budget: budget, timeline: timeline,
      expectedCheckIn: expectedIn, expectedCheckOut: expectedOut,
      adults: adults, children: children, infants: infants,
      notes: notes, specialRequests: special, score: score,
    );
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
                    controller: _leadSearchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search leads...',
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
                    value: _leadStatus,
                    items: const [
                      DropdownMenuItem(value: 'All Status', child: Text('All Status')),
                      DropdownMenuItem(value: 'New', child: Text('New')),
                      DropdownMenuItem(value: 'Contacted', child: Text('Contacted')),
                      DropdownMenuItem(value: 'Qualified', child: Text('Qualified')),
                      DropdownMenuItem(value: 'Converted', child: Text('Converted')),
                      DropdownMenuItem(value: 'Lost', child: Text('Lost')),
                    ],
                    onChanged: (v) => setState(() { if (v != null) _leadStatus = v; }),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadLeads,
            child: _loading
                ? ListView(
                    children: const [
                      SizedBox(height: 200),
                      Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
                        ),
                      ),
                    ],
                  )
                : (_error != null
                    ? ListView(children: [
                        SizedBox(height: 120),
                        Center(child: Text('Failed to load leads', style: GoogleFonts.poppins(color: Colors.red))),
                        const SizedBox(height: 6),
                        Center(child: OutlinedButton(onPressed: _loadLeads, child: const Text('Retry'))),
                      ])
                    : ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 8),
            itemCount: _leadFiltered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final l = _leadFiltered[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
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
                          child: Text(_initials(l.name), style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15, color: const Color(0xFF111827))),
                              const SizedBox(height: 2),
                              Text(l.source, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                        _statusChip(l.status),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              await _openEditLeadSheet(l);
                            } else if (value == 'delete') {
                              await _confirmDeleteLead(l);
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
                        const Icon(Icons.alternate_email, size: 16, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('${l.email} • ${l.phone}', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.interests_outlined, size: 16, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 6),
                        Text('Interest: ${l.interest}', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                        const SizedBox(width: 16),
                        const Icon(Icons.payments_outlined, size: 16, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 6),
                        Text('Budget: ₹${l.budget.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 16, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 6),
                        Text('Timeline: ${l.timeline}', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
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
            onPressed: _openAddLeadSheet,
            icon: const Icon(Icons.person_add_alt),
            label: const Text('Add Lead'),
            backgroundColor: const Color(0xFF10B981),
          ),
        ),
      ],
    );
  }

  Future<void> _openAddLeadSheet() async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final interestCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    final timelineCtrl = TextEditingController();
    final adultsCtrl = TextEditingController(text: '1');
    final childrenCtrl = TextEditingController(text: '0');
    final infantsCtrl = TextEditingController(text: '0');
    final notesCtrl = TextEditingController();
    final specialRequestsCtrl = TextEditingController();
    DateTime? expectedIn;
    DateTime? expectedOut;

    String status = 'New';
    String source = '';

    final _formKey = GlobalKey<FormState>();

    final result = await showModalBottomSheet<_Lead>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        final media = MediaQuery.of(ctx);
        final double screenWidth = media.size.width;
        final double sheetHeight = media.size.height * 0.8;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SizedBox(
            height: sheetHeight,
            child: SingleChildScrollView(
              child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Add New Lead', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
                    const SizedBox(height: 16),

                    // Basic info
                    Text('Basic Information', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name *', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: nameCtrl,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Full name'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
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
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Status', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: status,
                                decoration: const InputDecoration(border: OutlineInputBorder()),
                                items: const [
                                  DropdownMenuItem(value: 'New', child: Text('New')),
                                  DropdownMenuItem(value: 'Contacted', child: Text('Contacted')),
                                  DropdownMenuItem(value: 'Qualified', child: Text('Qualified')),
                                  DropdownMenuItem(value: 'Converted', child: Text('Converted')),
                                  DropdownMenuItem(value: 'Lost', child: Text('Lost')),
                                ],
                                onChanged: (v) { if (v != null) status = v; },
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
                              Text('Source', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
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
                                onChanged: (v) { if (v != null) source = v; },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Interest (Room Type)', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: interestCtrl,
                                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'e.g., Deluxe'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Booking Details', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Budget', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: budgetCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'e.g., 5000'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Timeline', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: timelineCtrl,
                                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'e.g., Next month'),
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
                              Text('Expected Check-in', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
                                  if (picked != null) {
                                    expectedIn = picked;
                                  }
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'mm/dd/yyyy'),
                                  child: Text(expectedIn == null ? 'mm/dd/yyyy' : '${expectedIn!.month}/${expectedIn!.day}/${expectedIn!.year}', style: GoogleFonts.poppins(fontSize: 14)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Expected Check-out', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(context: ctx, initialDate: expectedIn ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
                                  if (picked != null) {
                                    expectedOut = picked;
                                  }
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'mm/dd/yyyy'),
                                  child: Text(expectedOut == null ? 'mm/dd/yyyy' : '${expectedOut!.month}/${expectedOut!.day}/${expectedOut!.year}', style: GoogleFonts.poppins(fontSize: 14)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Guest Details
                    Text('Guest Details', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Adults', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: adultsCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '1'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Children', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: childrenCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '0'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Infants', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: infantsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '0'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Additional Information
                    Text('Additional Information', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Text('Notes', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: ''),
                    ),
                    const SizedBox(height: 12),
                    Text('Special Requests', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: specialRequestsCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: ''),
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
                            final newLead = _Lead(
                              id: '',
                              name: nameCtrl.text.trim(),
                              source: source,
                              email: emailCtrl.text.trim(),
                              phone: phoneCtrl.text.trim(),
                              status: status,
                              interest: interestCtrl.text.trim(),
                              budget: double.tryParse(budgetCtrl.text.trim()).toDoubleSafely(),
                              timeline: timelineCtrl.text.trim(),
                              expectedCheckIn: expectedIn,
                              expectedCheckOut: expectedOut,
                              adults: int.tryParse(adultsCtrl.text.trim()) ?? 1,
                              children: int.tryParse(childrenCtrl.text.trim()) ?? 0,
                              infants: int.tryParse(infantsCtrl.text.trim()) ?? 0,
                              notes: notesCtrl.text.trim(),
                              specialRequests: specialRequestsCtrl.text.trim(),
                              score: 0,
                            );
                            Navigator.of(ctx).pop(newLead);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text('Create Lead'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
        );

      },
    );

    if (result != null) {
      try {
        final token = await AuthService.getToken();
        CrmService.authToken = token;
        final payload = {
          'name': result.name,
          'email': result.email,
          'phone': result.phone,
          'status': result.status.toLowerCase(),
          'source': result.source,
          'interest': result.interest,
          'budget': result.budget,
          'timeline': result.timeline,
          'expected_check_in': _dateOnly(result.expectedCheckIn),
          'expected_check_out': _dateOnly(result.expectedCheckOut),
          'adults': result.adults,
          'children': result.children,
          'infants': result.infants,
          'notes': result.notes,
          'special_requests': result.specialRequests,
        };
        final created = await CrmService.createLead(payload);
        final createdLead = _parseLead(created['data'] ?? created);
        setState(() { _leads.insert(0, createdLead); });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lead created')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('API error: $e')));
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
    switch (status.toLowerCase()) {
      case 'new':
        bg = const Color(0xFFEFF6FF); fg = const Color(0xFF1D4ED8); break;
      case 'contacted':
        bg = const Color(0xFFFFFBEB); fg = const Color(0xFF92400E); break;
      case 'qualified':
        bg = const Color(0xFFE7F5FF); fg = const Color(0xFF0369A1); break;
      case 'converted':
        bg = const Color(0xFFE9FCEB); fg = const Color(0xFF16A34A); break;
      case 'lost':
        bg = const Color(0xFFFEE2E2); fg = const Color(0xFFB91C1C); break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(status, style: GoogleFonts.poppins(fontSize: 12, color: fg, fontWeight: FontWeight.w600)),
    );
  }

  String? _dateOnly(DateTime? d) {
    if (d == null) return null;
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<void> _confirmDeleteLead(_Lead l) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Lead'),
        content: Text('Are you sure you want to delete ${l.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      try {
        final token = await AuthService.getToken();
        CrmService.authToken = token;
        await CrmService.deleteLead(l.id.isNotEmpty ? l.id : l.email);
        setState(() { _leads.remove(l); });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lead deleted')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
        }
      }
    }
  }

  Future<void> _openEditLeadSheet(_Lead lead) async {
    final nameCtrl = TextEditingController(text: lead.name);
    final emailCtrl = TextEditingController(text: lead.email);
    final phoneCtrl = TextEditingController(text: lead.phone);
    final interestCtrl = TextEditingController(text: lead.interest);
    final budgetCtrl = TextEditingController(text: lead.budget.toStringAsFixed(0));
    final timelineCtrl = TextEditingController(text: lead.timeline);
    final adultsCtrl = TextEditingController(text: lead.adults.toString());
    final childrenCtrl = TextEditingController(text: lead.children.toString());
    final infantsCtrl = TextEditingController(text: lead.infants.toString());
    final notesCtrl = TextEditingController(text: lead.notes);
    final specialRequestsCtrl = TextEditingController(text: lead.specialRequests);
    DateTime? expectedIn = lead.expectedCheckIn;
    DateTime? expectedOut = lead.expectedCheckOut;
    String status = lead.status;
    String source = lead.source;

    final _formKey = GlobalKey<FormState>();

    final updated = await showModalBottomSheet<_Lead>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        final media = MediaQuery.of(ctx);
        final double screenWidth = media.size.width;
        final double sheetHeight = media.size.height * 0.8;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SizedBox(
            height: sheetHeight,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Edit Lead', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Name *', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))), const SizedBox(height: 6),
                          TextFormField(controller: nameCtrl, validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null, decoration: const InputDecoration(border: OutlineInputBorder())),
                        ])),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Email *', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))), const SizedBox(height: 6),
                          TextFormField(controller: emailCtrl, validator: (v) => (v == null || v.trim().isEmpty) ? 'Email is required' : null, decoration: const InputDecoration(border: OutlineInputBorder())),
                        ])),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Phone', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))), const SizedBox(height: 6),
                          TextFormField(controller: phoneCtrl, decoration: const InputDecoration(border: OutlineInputBorder())),
                        ])),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Status', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))), const SizedBox(height: 6),
                          DropdownButtonFormField<String>(value: status, decoration: const InputDecoration(border: OutlineInputBorder()), items: const [
                            DropdownMenuItem(value: 'New', child: Text('New')),
                            DropdownMenuItem(value: 'Contacted', child: Text('Contacted')),
                            DropdownMenuItem(value: 'Qualified', child: Text('Qualified')),
                            DropdownMenuItem(value: 'Converted', child: Text('Converted')),
                            DropdownMenuItem(value: 'Lost', child: Text('Lost')),
                          ], onChanged: (v) { if (v != null) status = v; }),
                        ])),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Source', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))), const SizedBox(height: 6),
                          DropdownButtonFormField<String>(value: source.isEmpty ? null : source, decoration: const InputDecoration(border: OutlineInputBorder()), items: const [
                            DropdownMenuItem(value: 'direct', child: Text('Direct')),
                            DropdownMenuItem(value: 'website', child: Text('Website')),
                            DropdownMenuItem(value: 'phone', child: Text('Phone')),
                            DropdownMenuItem(value: 'ota', child: Text('OTA')),
                            DropdownMenuItem(value: 'walk_in', child: Text('Walk-in')),
                          ], onChanged: (v) { if (v != null) source = v; }),
                        ])),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Interest (Room Type)', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))), const SizedBox(height: 6),
                          TextFormField(controller: interestCtrl, decoration: const InputDecoration(border: OutlineInputBorder())),
                        ])),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Budget', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))), const SizedBox(height: 6),
                          TextFormField(controller: budgetCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder())),
                        ])),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Timeline', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))), const SizedBox(height: 6),
                          TextFormField(controller: timelineCtrl, decoration: const InputDecoration(border: OutlineInputBorder())),
                        ])),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Expected Check-in', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))), const SizedBox(height: 6),
                          InkWell(onTap: () async { final picked = await showDatePicker(context: ctx, initialDate: expectedIn ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100)); if (picked != null) { expectedIn = picked; } }, child: InputDecorator(decoration: const InputDecoration(border: OutlineInputBorder()), child: Text(expectedIn == null ? 'mm/dd/yyyy' : '${expectedIn!.month}/${expectedIn!.day}/${expectedIn!.year}'))),
                        ])),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Expected Check-out', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))), const SizedBox(height: 6),
                          InkWell(onTap: () async { final picked = await showDatePicker(context: ctx, initialDate: expectedOut ?? expectedIn ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100)); if (picked != null) { expectedOut = picked; } }, child: InputDecorator(decoration: const InputDecoration(border: OutlineInputBorder()), child: Text(expectedOut == null ? 'mm/dd/yyyy' : '${expectedOut!.month}/${expectedOut!.day}/${expectedOut!.year}'))),
                        ])),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Adults', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))), const SizedBox(height: 6),
                          TextFormField(controller: adultsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder())),
                        ])),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Children', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))), const SizedBox(height: 6),
                          TextFormField(controller: childrenCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder())),
                        ])),
                      ]),
                      const SizedBox(height: 12),
                      Text('Infants', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))), const SizedBox(height: 6),
                      TextFormField(controller: infantsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      Text('Notes', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))), const SizedBox(height: 6),
                      TextFormField(controller: notesCtrl, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
                      const SizedBox(height: 12),
                      Text('Special Requests', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))), const SizedBox(height: 6),
                      TextFormField(controller: specialRequestsCtrl, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
                      const SizedBox(height: 16),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(), style: TextButton.styleFrom(foregroundColor: const Color(0xFF111827), backgroundColor: const Color(0xFFE5E7EB), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text('Cancel')),
                        const SizedBox(width: 12),
                        ElevatedButton(onPressed: () {
                          if (!_formKey.currentState!.validate()) return;
                          Navigator.of(ctx).pop(_Lead(id: lead.id, name: nameCtrl.text.trim(), source: source, email: emailCtrl.text.trim(), phone: phoneCtrl.text.trim(), status: status, interest: interestCtrl.text.trim(), budget: double.tryParse(budgetCtrl.text.trim()).toDoubleSafely(), timeline: timelineCtrl.text.trim(), expectedCheckIn: expectedIn, expectedCheckOut: expectedOut, adults: int.tryParse(adultsCtrl.text.trim()) ?? 1, children: int.tryParse(childrenCtrl.text.trim()) ?? 0, infants: int.tryParse(infantsCtrl.text.trim()) ?? 0, notes: notesCtrl.text.trim(), specialRequests: specialRequestsCtrl.text.trim(), score: lead.score));
                        }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0), child: const Text('Save Changes')),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (updated != null) {
      try {
        final token = await AuthService.getToken();
        CrmService.authToken = token;
        await CrmService.updateLead(id: lead.id.isNotEmpty ? lead.id : lead.email, updates: {
          'name': updated.name,
          'email': updated.email,
          'phone': updated.phone,
          'status': updated.status.toLowerCase(),
          'source': updated.source,
          'interest': updated.interest,
          'budget': updated.budget,
          'timeline': updated.timeline,
          'expected_check_in': _dateOnly(updated.expectedCheckIn),
          'expected_check_out': _dateOnly(updated.expectedCheckOut),
          'adults': updated.adults,
          'children': updated.children,
          'infants': updated.infants,
          'notes': updated.notes,
          'special_requests': updated.specialRequests,
        });
        setState(() {
          final idx = _leads.indexOf(lead);
          if (idx != -1) _leads[idx] = updated;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lead updated')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
        }
      }
    }
  }
}

class _Lead {
  final String id;
  final String name;
  final String source;
  final String email;
  final String phone;
  final String status;
  final String interest;
  final double budget;
  final String timeline;
  final DateTime? expectedCheckIn;
  final DateTime? expectedCheckOut;
  final int adults;
  final int children;
  final int infants;
  final String notes;
  final String specialRequests;
  final int score;

  const _Lead({
    required this.id,
    required this.name,
    required this.source,
    required this.email,
    required this.phone,
    required this.status,
    required this.interest,
    required this.budget,
    required this.timeline,
    required this.expectedCheckIn,
    required this.expectedCheckOut,
    required this.adults,
    required this.children,
    required this.infants,
    required this.notes,
    required this.specialRequests,
    required this.score,
  });
}

extension _ParseExt on double? {
  double toDoubleSafely() => this ?? 0.0;
}


