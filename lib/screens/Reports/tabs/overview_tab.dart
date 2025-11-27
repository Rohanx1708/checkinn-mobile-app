import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/report_components.dart';
import '../services/reports_service.dart';

class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  bool _loading = true;
  int _totalBookings = 0;
  int _totalProperties = 0;
  int _totalEmployees = 0;
  double _totalRevenue = 0.0;

  // Default to last 30 days
  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _end = DateTime(now.year, now.month, now.day);
    _start = _end.subtract(const Duration(days: 30));
    _load();
  }

  String _fmtDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  dynamic _unwrap(dynamic input) {
    var curr = input;
    for (int i = 0; i < 3; i++) {
      if (curr is Map && curr.length == 1 && curr.containsKey('data')) {
        curr = curr['data'];
      } else {
        break;
      }
    }
    return curr;
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);

    try {
      // Fetch overview (supports optional range/property)
      final ov = await ReportsService.getOverview(start: _start, end: _end);

      // Fetch dashboard windowed metrics
      final dh = await ReportsService.getDashboard(startDate: _fmtDate(_start), endDate: _fmtDate(_end));

      if (!mounted) return;

      // Parse overview
      int totalBookings = 0;
      int totalProperties = 0;
      int totalEmployees = 0;
      double totalRevenue = 0.0;
      if (ov['success'] == true) {
        final root = ov['data'];
        final data = _unwrap(root);
        if (data is Map<String, dynamic>) {
          totalBookings = _toInt(data['total_bookings'] ?? data['bookings']);
          totalProperties = _toInt(data['total_properties']);
          totalEmployees = _toInt(data['total_employees']);
          totalRevenue = _toDouble(data['total_revenue'] ?? data['revenue']);
        }
      }

      // Enrich with dashboard if present
      if (dh['success'] == true) {
        final root = dh['data'];
        final data = _unwrap(root);
        if (data is Map<String, dynamic>) {
          // Common alternates (adjust as backend provides)
          totalBookings = _toInt(data['total_bookings'] ?? data['bookings_total'] ?? data['bookings']);
          totalRevenue = _toDouble(data['total_revenue'] ?? data['revenue_total'] ?? data['revenue']);
        }
      }

      setState(() {
        _totalBookings = totalBookings;
        _totalProperties = totalProperties;
        _totalEmployees = totalEmployees;
        _totalRevenue = totalRevenue;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  String _currency(double v) => '\u20B9' + v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.02),

          // Quick Stats Grid (2x2)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: QuickStatCard(
                      title: 'Total Bookings',
                      value: _loading ? '—' : _totalBookings.toString(),
                      icon: Icons.description,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickStatCard(
                      title: 'Total Properties',
                      value: _loading ? '—' : _totalProperties.toString(),
                      icon: Icons.business,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                children: [
                  Expanded(
                    child: QuickStatCard(
                      title: 'Total Employees',
                      value: _loading ? '—' : _totalEmployees.toString(),
                      icon: Icons.people,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickStatCard(
                      title: 'Total Revenue',
                      value: _loading ? '—' : _currency(_totalRevenue),
                      icon: Icons.attach_money,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: screenHeight * 0.02),

          // Monthly Bookings Trend Chart (Area Line)
          const EnhancedChartCard(
            title: 'Monthly Bookings Trend',
            subtitle: 'Recent months performance',
            child: BookingsTrendChart(),
          ),

          SizedBox(height: screenHeight * 0.02),

          // Top Performing Properties Table -> Tiles
          const EnhancedChartCard(
            title: 'Top Performing Properties',
            subtitle: 'Best properties by bookings and revenue',
            child: TopPropertiesTable(),
          ),

          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }
}


