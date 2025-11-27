import 'package:flutter/material.dart';

class EmployeeDetailScreen extends StatelessWidget {
  final Map<String, String> employee;
  const EmployeeDetailScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    String getVal(String key, [String dash = '—']) {
      final v = (employee[key] ?? '').toString().trim();
      return v.isEmpty ? dash : v;
    }

    final String title = getVal('name').isNotEmpty
        ? getVal('name')
        : ([getVal('first_name'), getVal('last_name')].where((e) => e != '—').join(' ').trim().isNotEmpty
            ? [getVal('first_name'), getVal('last_name')].where((e) => e != '—').join(' ').trim()
            : (getVal('employee_id') != '—' ? getVal('employee_id') : 'Employee'));
    final String roleStr = getVal('role');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Employee Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)), onPressed: () => Navigator.of(context).pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _headerCard(theme, colors, title, roleStr),
          const SizedBox(height: 16),
          _section(context, 'Basic', [
            _row('Emp ID', getVal('employee_id', getVal('id'))),
            _row('Role', getVal('role')),
            _row('Department', getVal('department')),
            _row('Status', getVal('status')),
            _row('Employment Type', getVal('employment_type')),
            _row('Hire Date', _fmtDate(getVal('hire_date'))),
            _row('Contract End', _fmtDate(getVal('contract_end_date'))),
          ]),
          const SizedBox(height: 16),
          _section(context, 'Contact', [
            _row('Phone', getVal('phone')),
            _row('Email', getVal('email')),
          ]),
          const SizedBox(height: 16),
          _section(context, 'Personal', [
            _row('First Name', getVal('first_name')),
            _row('Last Name', getVal('last_name')),
            _row('Date of Birth', _fmtDate(getVal('date_of_birth'))),
            _row('Nationality', getVal('nationality')),
            _row('ID Proof', getVal('id_proof_type')),
            _row('ID Number', getVal('id_proof_number')),
          ]),
          const SizedBox(height: 16),
          _section(context, 'Address', [
            _row('Address', getVal('address')),
            _row('City', getVal('city')),
            _row('State', getVal('state')),
            _row('Postal Code', getVal('postal_code')),
            _row('Country', getVal('country')),
          ]),
          const SizedBox(height: 16),
          _section(context, 'Salary & Bank', [
            _row('Basic Salary', getVal('basic_salary')),
            _row('Currency', getVal('salary_currency')),
            _row('Pay Frequency', getVal('payment_frequency')),
            _row('Bank Name', getVal('bank_name')),
            _row('Account Number', getVal('bank_account_number')),
            _row('IFSC Code', getVal('ifsc_code')),
          ]),
          const SizedBox(height: 16),
          _section(context, 'Emergency Contact', [
            _row('Contact Name', getVal('emergency_contact_name')),
            _row('Contact Phone', getVal('emergency_contact_phone')),
          ]),
          const SizedBox(height: 16),
          _section(context, 'Notes', [
            _row('Notes', getVal('notes')),
          ]),
        ],
      ),
    );
  }

  Widget _headerCard(ThemeData theme, ColorScheme colors, String title, String role) {
    String initials = '';
    final parts = title.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isNotEmpty) {
      initials = parts.length == 1 ? parts.first.substring(0, 1).toUpperCase() : (parts.first[0] + parts.last[0]).toUpperCase();
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(radius: 26, backgroundColor: const Color(0xFFF3F4F6), child: Text(initials, style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF1F2937), fontWeight: FontWeight.w800))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: Colors.black), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(role, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF374151))),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 6, height: 18, decoration: const BoxDecoration(color: Color(0xFF1F2937), borderRadius: BorderRadius.all(Radius.circular(4)))),
          const SizedBox(width: 8),
          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
        ]),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(color: Color(0xFF6B7280)))),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(color: Color(0xFF111827)))),
        ],
      ),
    );
  }

  String _fmtDate(String iso) {
    if (iso.isEmpty || iso == '—') return '—';
    try {
      final dt = DateTime.tryParse(iso);
      if (dt == null) return iso;
      final mm = dt.month.toString().padLeft(2, '0');
      final dd = dt.day.toString().padLeft(2, '0');
      return '$mm/$dd/${dt.year}';
    } catch (_) {
      return iso;
    }
  }
}


