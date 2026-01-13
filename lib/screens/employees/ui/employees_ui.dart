import 'package:flutter/material.dart';
import 'employee_form_screen.dart';
import 'employee_detail_screen.dart';
import '../services/employees_service.dart';
import '../../../widgets/common_app_bar.dart';
import '../../../widgets/skeleton_loader.dart';
import '../../Dashboard/widget/drawer_widget.dart';
import '../../../widgets/list_item_animation.dart';

class EmployeesUi extends StatefulWidget {
  const EmployeesUi({super.key});

  @override
  State<EmployeesUi> createState() => _EmployeesUiState();
}

class _EmployeesUiState extends State<EmployeesUi> {
  List<Map<String, String>> _employees = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Search & Filter state
  final TextEditingController _searchCtrl = TextEditingController();
  String _statusFilter = 'All Status';
  final List<String> _statusOptions = const ['All Status', 'Active', 'Inactive', 'Terminated', 'On Leave'];
  String _deptFilter = 'All Departments';
  String _roleFilter = 'All Roles';
  List<String> _deptOptions = const [
    'All Departments',
    'Kitchen',
    'Housekeeping',
    'Maintenance',
    'Front Office',
    'Security',
    'Management',
    'Other',
  ];
  List<String> _roleOptions = const ['All Roles'];
  List<String> _statusDropdownOptions = const ['All Status', 'Active', 'Inactive', 'Terminated', 'On Leave'];

  List<Map<String, String>> get _filteredEmployees {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _employees.where((e) {
      final matchesStatus = _statusFilter == 'All Status' || (e['status'] ?? '') == _statusFilter;
      final matchesDept = _deptFilter == 'All Departments' || (e['department'] ?? '') == _deptFilter;
      final matchesRole = _roleFilter == 'All Roles' || (e['role'] ?? '') == _roleFilter;
      final blob = [e['name'], e['id'], e['role'], e['phone']].whereType<String>().join(' ').toLowerCase();
      final matchesQuery = q.isEmpty || blob.contains(q);
      return matchesStatus && matchesDept && matchesRole && matchesQuery;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _loadFilterOptions();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final res = await EmployeesService.getEmployees(
      page: 1,
      limit: 100,
      search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      department: _deptFilter,
      role: _roleFilter,
      status: _statusFilter,
    );
    if (res['success'] == true) {
      final data = res['data'];
      final List<dynamic> list = (data['data'] ?? data['employees'] ?? []) as List<dynamic>;
      final mapped = list.map<Map<String, String>>((item) {
        final m = item as Map<String, dynamic>;
        String clean(Object? v) {
          final str = (v ?? '').toString().trim();
          if (str.isEmpty) return '';
          final lower = str.toLowerCase();
          if (lower == 'null' || lower == 'undefined' || lower == 'na' || lower == 'n/a') return '';
          return str;
        }
        // Resolve name from multiple possible shapes
        String name = '';
        List<String> directKeys = [
          clean(m['name']),
          clean(m['full_name']),
          clean(m['fullName']),
          clean(m['employee_name']),
          clean(m['employeeName']),
          clean(m['display_name']),
          clean(m['displayName']),
        ];
        name = directKeys.firstWhere((v) => v.isNotEmpty, orElse: () => '').trim();
        if (name.isEmpty) {
          final String firstName = clean(m['first_name']) .isNotEmpty ? clean(m['first_name']) : (clean(m['firstname']).isNotEmpty ? clean(m['firstname']) : clean(m['firstName']));
          final String lastName = clean(m['last_name']) .isNotEmpty ? clean(m['last_name']) : (clean(m['lastname']).isNotEmpty ? clean(m['lastname']) : clean(m['lastName']));
          final combined = [firstName, lastName].where((s) => s.trim().isNotEmpty).join(' ').trim();
          if (combined.isNotEmpty) name = combined;
        }
        if (name.isEmpty) {
          // Try nested objects like user/employee/profile
          for (final key in ['user', 'employee', 'profile']) {
            final nested = m[key];
            if (nested is Map<String, dynamic>) {
              final n = clean(nested['name']).isNotEmpty
                  ? clean(nested['name'])
                  : (clean(nested['full_name']).isNotEmpty
                      ? clean(nested['full_name'])
                      : (clean(nested['fullName']).isNotEmpty
                          ? clean(nested['fullName'])
                          : (clean(nested['display_name']).isNotEmpty
                              ? clean(nested['display_name'])
                              : clean(nested['displayName']))));
              if (n.isNotEmpty) {
                name = n;
                break;
              }
              final String fn = clean(nested['first_name']).isNotEmpty
                  ? clean(nested['first_name'])
                  : (clean(nested['firstname']).isNotEmpty ? clean(nested['firstname']) : clean(nested['firstName']));
              final String ln = clean(nested['last_name']).isNotEmpty
                  ? clean(nested['last_name'])
                  : (clean(nested['lastname']).isNotEmpty ? clean(nested['lastname']) : clean(nested['lastName']));
              final comb = [fn, ln].where((s) => s.trim().isNotEmpty).join(' ').trim();
              if (comb.isNotEmpty) {
                name = comb;
                break;
              }
            }
          }
        }
        String id = clean(m['id']).isNotEmpty ? clean(m['id']) : clean(m['employee_id']);
        String employeeId = clean(m['employee_id']);
        String firstNameField = clean(m['first_name']).isNotEmpty ? clean(m['first_name']) : (clean(m['firstname']).isNotEmpty ? clean(m['firstname']) : clean(m['firstName']));
        String lastNameField = clean(m['last_name']).isNotEmpty ? clean(m['last_name']) : (clean(m['lastname']).isNotEmpty ? clean(m['lastname']) : clean(m['lastName']));
        String role = clean(m['role']).isNotEmpty ? clean(m['role']) : clean(m['designation']);
        String phone = clean(m['phone']).isNotEmpty ? clean(m['phone']) : (clean(m['contact']).isNotEmpty ? clean(m['contact']) : clean(m['mobile']));
        String status = clean(m['status']).isNotEmpty ? clean(m['status']) : 'Active';
        String department = clean(m['department']).isNotEmpty ? clean(m['department']) : clean(m['dept']);
        return {
          'name': name.isNotEmpty ? name : (id.isNotEmpty ? 'Employee $id' : '—'),
          'id': id,
          'employee_id': employeeId,
          'first_name': firstNameField,
          'last_name': lastNameField,
          'email': clean(m['email']),
          'date_of_birth': clean(m['date_of_birth']),
          'nationality': clean(m['nationality']),
          'id_proof_type': clean(m['id_proof_type']),
          'id_proof_number': clean(m['id_proof_number']),
          'role': role,
          'phone': phone,
          'status': status,
          'department': department,
          'employment_type': clean(m['employment_type']),
          'hire_date': clean(m['hire_date']),
          'contract_end_date': clean(m['contract_end_date']),
          'basic_salary': clean(m['basic_salary']),
          'salary_currency': clean(m['salary_currency']),
          'payment_frequency': clean(m['payment_frequency']),
          'bank_name': clean(m['bank_name']),
          'bank_account_number': clean(m['bank_account_number']),
          'ifsc_code': clean(m['ifsc_code']),
          'emergency_contact_name': clean(m['emergency_contact_name']),
          'emergency_contact_phone': clean(m['emergency_contact_phone']),
          'address': clean(m['address']),
          'city': clean(m['city']),
          'state': clean(m['state']),
          'postal_code': clean(m['postal_code']),
          'country': clean(m['country']),
          'notes': clean(m['notes']),
        };
      }).toList();
      
      // Save fresh data to cache
      if (mounted) {
      setState(() {
        _employees = mapped;
        _isLoading = false;
      });
      }
    } else {
      setState(() {
        _errorMessage = res['message'] ?? 'Failed to load employees';
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadEmployees();
  }

  Future<void> _loadFilterOptions() async {
    final res = await EmployeesService.getFilterOptions();
    if (res['success'] == true) {
      final data = res['data'] as Map<String, dynamic>;
      final List<dynamic> depts = (data['departments'] ?? []) as List<dynamic>;
      final List<dynamic> roles = (data['roles'] ?? []) as List<dynamic>;
      final List<dynamic> statuses = (data['statuses'] ?? []) as List<dynamic>;
      setState(() {
        _deptOptions = ['All Departments', ...depts.map((e) => e.toString())];
        _roleOptions = ['All Roles', ...roles.map((e) => e.toString())];
        _statusDropdownOptions = ['All Status', ...statuses.map((e) => e.toString())];
      });
    }
  }

  void _showFilters() {
    // Store current filter values as local variables for the modal
    String tempDeptFilter = _deptFilter;
    String tempRoleFilter = _roleFilter;
    String tempStatusFilter = _statusFilter;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final departments = _deptOptions;
        final roles = _roleOptions;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Department (vertical)
                  const Text('Department', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: departments.contains(tempDeptFilter) ? tempDeptFilter : 'All Departments',
                    items: departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (v) => setModalState(() => tempDeptFilter = v ?? 'All Departments'),
                    isDense: true,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Role (vertical)
                  const Text('Role', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: roles.contains(tempRoleFilter) ? tempRoleFilter : 'All Roles',
                    items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (v) => setModalState(() => tempRoleFilter = v ?? 'All Roles'),
                    isDense: true,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _statusDropdownOptions.contains(tempStatusFilter) ? tempStatusFilter : 'All Status',
                    items: _statusDropdownOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setModalState(() => tempStatusFilter = v ?? 'All Status'),
                    isDense: true,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempDeptFilter = 'All Departments';
                            tempRoleFilter = 'All Roles';
                            tempStatusFilter = 'All Status';
                          });
                        },
                        child: const Text('Clear'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1F2937), foregroundColor: Colors.white),
                        onPressed: () async {
                          // Update the main state with the temporary values
                          setState(() {
                            _deptFilter = tempDeptFilter;
                            _roleFilter = tempRoleFilter;
                            _statusFilter = tempStatusFilter;
                          });
                          Navigator.pop(ctx);
                          await _loadEmployees();
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: CommonAppBar.dashboard(
        notificationCount: 5,
      ),
      drawer: const DrawerWidget(),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1F2937),
        foregroundColor: Colors.white,
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EmployeeFormScreen()),
          );
          
          // If employee was created successfully, refresh the list
          if (result == true) {
            print('🔄 Employee created successfully, refreshing list...');
            await _loadEmployees();
          }
        },
        label: const Text('Add Employee'),
        icon: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page heading section
          Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Employees',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search + Filters
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Row(
              children: [
                // Search
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search by name, ID, role or phone',
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: Color(0xFF1F2937), width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Filter button (opens bottom sheet)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: Color(0xFF64748B)),
                    tooltip: 'Filters',
                    onPressed: _showFilters,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Employees list
          Expanded(
            child: _isLoading
                ? SkeletonListLoader(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 8),
                    itemCount: 5,
                    itemBuilder: (context, index) => const SkeletonListCard(),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(_errorMessage!, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red)),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                          itemCount: _filteredEmployees.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final emp = _filteredEmployees[index];
                            final status = emp['status'] ?? 'Active';
                            final statusColor = status == 'Active'
                                ? Colors.green
                                : status == 'On Leave'
                                    ? Colors.orange
                                    : Colors.grey;
                            final String displayName = (emp['name'] ?? '').trim();
                            final String firstName = (emp['first_name'] ?? '').toString().trim();
                            final String lastName = (emp['last_name'] ?? '').toString().trim();
                            final String empCode = (emp['employee_id'] ?? '').toString().trim();
                            final String finalName = displayName.isNotEmpty
                                ? displayName
                                : ([firstName, lastName].where((e) => e.isNotEmpty).join(' ').trim().isNotEmpty
                                    ? [firstName, lastName].where((e) => e.isNotEmpty).join(' ').trim()
                                    : (empCode.isNotEmpty
                                        ? empCode
                                        : ((emp['id'] ?? '').toString().isNotEmpty
                                            ? 'Employee ${(emp['id'] ?? '').toString()}'
                                            : 'Employee')));
                            final String initials = () {
                              if (displayName.isEmpty) return '';
                              final parts = displayName.split(' ').where((p) => p.isNotEmpty).toList();
                              if (parts.isEmpty) return '';
                              if (parts.length == 1) {
                                return parts.first.substring(0, 1).toUpperCase();
                              }
                              final first = parts.first.substring(0, 1).toUpperCase();
                              final last = parts.last.substring(0, 1).toUpperCase();
                              return '$first$last';
                            }();
                            return ListItemAnimation(
                              delay: ListItemAnimationConfig.getDelayForIndex(index),
                              child: InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => EmployeeDetailScreen(employee: emp),
                                  ),
                                );
                              },
                              child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Accent bar
                                  Container(
                                    width: 6,
                                    height: 90,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(14),
                                        bottomLeft: Radius.circular(14),
                                      ),
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 22,
                                            backgroundColor: const Color(0xFFF3F4F6),
                                            child: (finalName.isNotEmpty)
                                                ? Text(
                                                    () {
                                                      final parts = finalName.split(' ').where((p) => p.isNotEmpty).toList();
                                                      if (parts.isEmpty) return '';
                                                      if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
                                                      return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
                                                    }(),
                                                    style: theme.textTheme.titleMedium?.copyWith(
                                                      color: const Color(0xFF1F2937),
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  )
                                                : const Icon(Icons.person, color: Color(0xFF1F2937)),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        finalName,
                                                        style: theme.textTheme.titleSmall?.copyWith(
                                                          fontWeight: FontWeight.w800,
                                                          color: Colors.black,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: statusColor.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(14),
                                                        border: Border.all(color: statusColor.withOpacity(0.25)),
                                                      ),
                                                      child: Text(
                                                        status,
                                                        style: theme.textTheme.labelSmall?.copyWith(
                                                          color: statusColor,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  emp['role']?.toString().isNotEmpty == true ? (emp['role'] ?? '') : '—',
                                                  style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF374151)),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        'Emp ID: ${(emp['employee_id'] ?? emp['id'] ?? '').toString()}',
                                                        style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 14),
                                                    Icon(Icons.call_outlined, size: 16, color: const Color(0xFF64748B)),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        emp['phone'] ?? '',
                                                        style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B)),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              ),
                            ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
