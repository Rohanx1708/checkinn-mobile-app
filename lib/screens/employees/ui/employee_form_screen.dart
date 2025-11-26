import 'package:flutter/material.dart';
import '../../common/app_form_styles.dart';
import '../services/employees_service.dart';

class EmployeeFormScreen extends StatefulWidget {
  const EmployeeFormScreen({super.key});

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  final List<String> _stepTitles = const [
    'Basic Information',
    'Address Information',
    'Employment Details',
    'Salary & Bank Details',
    'Emergency & Additional'
  ];

  // Basic info
  final TextEditingController _employeeIdCtrl = TextEditingController();
  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  DateTime? _dob;

  // Emergency
  final TextEditingController _emgNameCtrl = TextEditingController();
  final TextEditingController _emgPhoneCtrl = TextEditingController();

  // Address
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _stateCtrl = TextEditingController();
  final TextEditingController _postalCtrl = TextEditingController();
  final TextEditingController _countryCtrl = TextEditingController(text: 'India');

  // Employment
  String _department = '';
  String _role = '';
  String _employmentType = '';
  DateTime? _hireDate;
  DateTime? _contractEndDate;
  String _status = 'Active';

  final List<String> _departments = ['Front Desk', 'Housekeeping', 'F&B', 'Maintenance', 'HR'];
  final List<String> _roles = ['Manager', 'Supervisor', 'Associate', 'Executive'];
  final List<String> _employmentTypes = ['Full-time', 'Part-time', 'Contract'];
  final List<String> _statuses = ['Active', 'Inactive', 'On Leave'];
  final List<String> _nationalities = ['Indian', 'American', 'British', 'Canadian', 'Australian', 'Other'];
  final List<String> _idProofTypes = ['Aadhaar Card', 'PAN Card', 'Passport', 'Driving License', 'Voter ID'];

  // Salary Information
  final TextEditingController _basicSalaryCtrl = TextEditingController();
  String _currency = 'INR (₹)';
  String _payFrequency = '';
  final List<String> _currencies = ['INR (₹)', 'USD (\$)', 'EUR (€)'];
  final List<String> _frequencies = ['Monthly', 'Bi-Weekly', 'Weekly'];

  // Bank Details
  final TextEditingController _bankNameCtrl = TextEditingController();
  final TextEditingController _accountNumberCtrl = TextEditingController();
  final TextEditingController _ifscCtrl = TextEditingController();

  // Additional Information
  final TextEditingController _skillCtrl = TextEditingController();
  final List<String> _skills = [];
  final TextEditingController _notesCtrl = TextEditingController();
  
  // Required fields for API
  String _nationality = 'Indian';
  String _idProofType = '';
  final TextEditingController _idProofNumberCtrl = TextEditingController();

  @override
  void dispose() {
    _employeeIdCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _emgNameCtrl.dispose();
    _emgPhoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _postalCtrl.dispose();
    _countryCtrl.dispose();
    _basicSalaryCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _ifscCtrl.dispose();
    _skillCtrl.dispose();
    _notesCtrl.dispose();
    _idProofNumberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final double pad = 16;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6366F1)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Hire New Employee',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(pad, pad, pad, 8),
            child: AppFormStyles.stepHeader(_stepTitles[_currentStep], _currentStep, _stepTitles.length),
          ),
          const SizedBox(height: 8),
          // Form content
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(pad),
                child: _buildCurrentStep(),
              ),
            ),
          ),
          // Navigation buttons
          Padding(
            padding: EdgeInsets.all(pad),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep == _stepTitles.length - 1 ? _submit : _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(_currentStep == _stepTitles.length - 1 ? 'Create Employee' : 'Next'),
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
    switch (_currentStep) {
      case 0:
        return _buildBasicInfo();
      case 1:
        return _buildAddressInfo();
      case 2:
        return _buildEmploymentDetails();
      case 3:
        return _buildSalaryBank();
      case 4:
        return _buildEmergencyAdditional();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBasicInfo() {
    return _section(
      icon: Icons.badge,
      title: 'Basic Information',
      child: Column(
        children: [
          _row(
            _text('Employee ID', _employeeIdCtrl, hint: 'Auto-generated if empty'),
            _text('First Name *', _firstNameCtrl, validator: _required),
            _text('Last Name *', _lastNameCtrl, validator: _required),
          ),
          const SizedBox(height: 12),
          _row(
            _text('Email *', _emailCtrl, keyboardType: TextInputType.emailAddress, validator: _required, hint: 'example@email.com'),
            _text('Phone *', _phoneCtrl, keyboardType: TextInputType.phone, validator: _required, hint: '+91 1234567890'),
            _date('Date of Birth *', _dob, (d) => setState(() => _dob = d), validator: () => _dob == null ? 'Required' : null, lastDate: DateTime.now()),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressInfo() {
    return _section(
      icon: Icons.location_on_outlined,
      title: 'Address Information',
      child: Column(
        children: [
          _text('Address *', _addressCtrl, validator: _required, hint: '123 Main St'),
          const SizedBox(height: 12),
          _row(
            _text('City *', _cityCtrl, validator: _required, prefix: Icons.location_city_outlined),
            _text('State *', _stateCtrl, validator: _required, prefix: Icons.map_outlined),
          ),
          const SizedBox(height: 12),
          _row(
            _text('Postal Code *', _postalCtrl, keyboardType: TextInputType.number, validator: _required, prefix: Icons.local_post_office_outlined),
            _text('Country', _countryCtrl, prefix: Icons.flag_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildEmploymentDetails() {
    return _section(
      icon: Icons.work_outline,
      title: 'Employment Details',
      child: Column(
        children: [
          _row(
            _dropdown('Department *', _department, _departments, (v) => setState(() => _department = v), validator: _requiredStr),
            _dropdown('Role *', _role, _roles, (v) => setState(() => _role = v), validator: _requiredStr),
            _dropdown('Employment Type *', _employmentType, _employmentTypes, (v) => setState(() => _employmentType = v), validator: _requiredStr),
          ),
          const SizedBox(height: 12),
          _row(
            _date('Hire Date *', _hireDate, (d) => setState(() => _hireDate = d), validator: () => _hireDate == null ? 'Required' : null),
            _date('Contract End Date', _contractEndDate, (d) => setState(() => _contractEndDate = d)),
            _dropdown('Status', _status, _statuses, (v) => setState(() => _status = v)),
          ),
        ],
      ),
    );
  }

  Widget _buildSalaryBank() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section(
          icon: Icons.payments_outlined,
          title: 'Salary Information',
          child: Column(
            children: [
              _row(
                _text('Basic Salary *', _basicSalaryCtrl, keyboardType: TextInputType.number, validator: _required, prefix: Icons.currency_rupee),
                _dropdown('Currency', _currency, _currencies, (v) => setState(() => _currency = v)),
                _dropdown('Payment Frequency *', _payFrequency, _frequencies, (v) => setState(() => _payFrequency = v), validator: _requiredStr),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _section(
          icon: Icons.account_balance_outlined,
          title: 'Bank Details',
          child: Column(
            children: [
              _row(
                _text('Bank Name', _bankNameCtrl, prefix: Icons.account_balance),
                _text('Account Number', _accountNumberCtrl, keyboardType: TextInputType.number, prefix: Icons.numbers),
                _text('IFSC Code', _ifscCtrl, prefix: Icons.qr_code_2_outlined),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyAdditional() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section(
          icon: Icons.phone_in_talk,
          title: 'Emergency Contact',
          child: Column(
            children: [
              _row(
                _text('Emergency Contact Name', _emgNameCtrl, prefix: Icons.person_outline),
                _text('Emergency Contact Phone', _emgPhoneCtrl, keyboardType: TextInputType.phone, prefix: Icons.phone_outlined),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _section(
          icon: Icons.badge_outlined,
          title: 'Identity Information',
          child: Column(
            children: [
              _row(
                _dropdown('Nationality *', _nationality, _nationalities, (v) => setState(() => _nationality = v), validator: _requiredStr),
                _dropdown('ID Proof Type *', _idProofType, _idProofTypes, (v) => setState(() => _idProofType = v), validator: _requiredStr),
              ),
              const SizedBox(height: 12),
              _text('ID Proof Number *', _idProofNumberCtrl, validator: _required, hint: 'Enter ID proof number'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _section(
          icon: Icons.info_outline,
          title: 'Additional Information',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Skills', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
              const SizedBox(height: 6),
              Builder(builder: (context) {
                final bool narrow = MediaQuery.of(context).size.width < 700;
                if (narrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _text('Add Skill', _skillCtrl, hint: 'e.g., Excel, Communication'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          final value = _skillCtrl.text.trim();
                          if (value.isEmpty) return;
                          if (_skills.contains(value)) { _skillCtrl.clear(); return; }
                          setState(() { _skills.add(value); _skillCtrl.clear(); });
                        },
                        child: const Text('+ Add Skill'),
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: _text('Add Skill', _skillCtrl, hint: 'e.g., Excel, Communication')),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        final value = _skillCtrl.text.trim();
                        if (value.isEmpty) return;
                        if (_skills.contains(value)) { _skillCtrl.clear(); return; }
                        setState(() { _skills.add(value); _skillCtrl.clear(); });
                      },
                      child: const Text('+ Add Skill'),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 8),
              if (_skills.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skills.map((s) => Chip(label: Text(s), onDeleted: () => setState(() => _skills.remove(s)))).toList(),
                ),
              const SizedBox(height: 16),
              Text('Notes', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 4,
                decoration: _inputDecoration(hint: 'Additional notes about the employee...'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _requiredStr(String v) => (v.trim().isEmpty) ? 'Required' : null;

  Widget _section({required IconData icon, required String title, required Widget child}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF6366F1), size: 20),
            const SizedBox(width: 10),
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _row(Widget left, [Widget? middle, Widget? right]) {
    final double w = MediaQuery.of(context).size.width;
    final bool narrow = w < 700;
    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          left,
          if (middle != null) const SizedBox(height: 12),
          if (middle != null) middle,
          if (right != null) const SizedBox(height: 12),
          if (right != null) right,
        ],
      );
    }
    final List<Widget> children = [];
    children.add(Expanded(child: left));
    if (middle != null) {
      children..add(const SizedBox(width: 16))..add(Expanded(child: middle));
    }
    if (right != null) {
      children..add(const SizedBox(width: 16))..add(Expanded(child: right));
    }
    return Row(children: children);
  }

  InputDecoration _inputDecoration({String? hint, IconData? prefix}) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      prefixIcon: prefix == null ? null : Icon(prefix, size: 18, color: const Color(0xFF6366F1)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFF6366F1), width: 2)),
    );
  }

  Widget _text(String label, TextEditingController c, {TextInputType? keyboardType, String? Function(String?)? validator, String? hint, IconData? prefix}) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
      const SizedBox(height: 6),
      TextFormField(
        controller: c,
        keyboardType: keyboardType,
        validator: validator,
        decoration: _inputDecoration(hint: hint),
      ),
    ]);
  }

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String> onChanged, {String? Function(String)? validator}) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: value.isEmpty ? null : value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => onChanged(v ?? ''),
        validator: validator == null ? null : (_) => validator(value.isEmpty ? '' : value),
        decoration: _inputDecoration(),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6366F1)),
      ),
    ]);
  }

  Widget _date(String label, DateTime? date, ValueChanged<DateTime> onPicked, {String? Function()? validator, DateTime? firstDate, DateTime? lastDate}) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
      const SizedBox(height: 6),
      InkWell(
        onTap: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: date ?? now,
            firstDate: firstDate ?? DateTime(1950),
            lastDate: lastDate ?? DateTime(now.year + 5),
          );
          if (picked != null) onPicked(picked);
        },
        borderRadius: BorderRadius.circular(10),
        child: InputDecorator(
          decoration: _inputDecoration(hint: 'mm/dd/yyyy', prefix: Icons.calendar_today),
          child: Text(
            date == null ? 'mm/dd/yyyy' : _fmt(date),
            style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF111827)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ]);
  }

  String _fmt(DateTime d) => '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

  void _reset() {
    _formKey.currentState?.reset();
    _employeeIdCtrl.clear();
    _firstNameCtrl.clear();
    _lastNameCtrl.clear();
    _emailCtrl.clear();
    _phoneCtrl.clear();
    _basicSalaryCtrl.clear();
    _bankNameCtrl.clear();
    _accountNumberCtrl.clear();
    _ifscCtrl.clear();
    _skillCtrl.clear();
    _notesCtrl.clear();
    _emgNameCtrl.clear();
    _emgPhoneCtrl.clear();
    _addressCtrl.clear();
    _cityCtrl.clear();
    _stateCtrl.clear();
    _postalCtrl.clear();
    _countryCtrl.text = 'India';
    _idProofNumberCtrl.clear();
    setState(() {
      _dob = null;
      _hireDate = null;
      _contractEndDate = null;
      _department = '';
      _role = '';
      _employmentType = '';
      _status = 'Active';
      _currency = 'INR (₹)';
      _payFrequency = '';
      _skills.clear();
      _nationality = 'Indian';
      _idProofType = '';
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation for required fields
    if (_department.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a department'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_employmentType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select employment type'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_idProofType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select ID proof type'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_idProofNumberCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter ID proof number'), backgroundColor: Colors.red),
      );
      return;
    }
    if (_payFrequency.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select payment frequency'), backgroundColor: Colors.red),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
        ),
      ),
    );

    try {
      // Generate a unique employee ID to avoid backend duplicate issues
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomSuffix = (timestamp % 10000).toString().padLeft(4, '0');
      final uniqueEmployeeId = 'EMP$randomSuffix';
      
      print('🆔 Generated unique employee ID: $uniqueEmployeeId');
      
      // Prepare employee data
      final employeeData = <String, dynamic>{
        'employee_id': uniqueEmployeeId,
        'first_name': _firstNameCtrl.text.trim(),
        'last_name': _lastNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'date_of_birth': _dob?.toIso8601String().split('T').first,
        'address': _addressCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'postal_code': _postalCtrl.text.trim(),
        'country': _countryCtrl.text.trim(),
        'department': _department,
        'role': _role,
        'employment_type': _employmentType,
        'hire_date': _hireDate?.toIso8601String().split('T').first,
        'contract_end_date': _contractEndDate?.toIso8601String().split('T').first,
        'status': _status,
        'basic_salary': _basicSalaryCtrl.text.trim().isEmpty ? null : double.tryParse(_basicSalaryCtrl.text.trim()),
        'currency': _currency,
        'pay_frequency': _payFrequency.isEmpty ? null : _payFrequency,
        'bank_name': _bankNameCtrl.text.trim().isEmpty ? null : _bankNameCtrl.text.trim(),
        'account_number': _accountNumberCtrl.text.trim().isEmpty ? null : _accountNumberCtrl.text.trim(),
        'ifsc_code': _ifscCtrl.text.trim().isEmpty ? null : _ifscCtrl.text.trim(),
        'emergency_contact_name': _emgNameCtrl.text.trim().isEmpty ? null : _emgNameCtrl.text.trim(),
        'emergency_contact_phone': _emgPhoneCtrl.text.trim().isEmpty ? null : _emgPhoneCtrl.text.trim(),
        'nationality': _nationality,
        'id_proof_type': _idProofType,
        'id_proof_number': _idProofNumberCtrl.text.trim(),
        'salary_currency': _currency,
        'payment_frequency': _payFrequency,
        'skills': _skills,
        'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      };

      // Remove null values
      employeeData.removeWhere((key, value) => value == null || (value is String && value.isEmpty));

      print('📝 Creating employee with data: $employeeData');

      // Call API
      final result = await EmployeesService.createEmployee(employeeData);
      
      print('📡 API Response: $result');

      // Close loading dialog
      Navigator.of(context).pop();

      if (result['success'] == true) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Employee created successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } else {
        // Error - show detailed error message
        final errorMessage = result['message'] ?? 'Failed to create employee';
        print('❌ Employee creation failed: $errorMessage');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                _submit(); // Retry the submission
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
