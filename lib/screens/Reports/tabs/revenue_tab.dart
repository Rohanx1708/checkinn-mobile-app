import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/report_components.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/reports_service.dart';


class RevenueTab extends StatefulWidget {
  const RevenueTab({super.key});

  @override
  State<RevenueTab> createState() => _RevenueTabState();
}

class _RevenueTabState extends State<RevenueTab> {
  bool _loading = true;
  double _totalRevenue = 0.0;
  double _avgMonthly = 0.0;
  double _growthRate = 0.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    const int _monthsWindow = 12;
    final res = await ReportsService.getRevenueMonthly(months: _monthsWindow);
    if (!mounted) return;
    if (res['success'] == true) {
      final dataAny = res['data'];
      Map<String, dynamic> data;
      if (dataAny is Map<String, dynamic>) {
        data = dataAny.containsKey('data') && dataAny['data'] is Map<String, dynamic> ? (dataAny['data'] as Map<String, dynamic>) : dataAny;
      } else {
        data = {};
      }
      final totalRevenue = _toDouble(data['total_revenue'] ?? data['revenue_total'] ?? data['revenue']);
      final providedAvgMonthly = _toDouble(data['avg_monthly'] ?? data['average_monthly']);
      final avgMonthly = providedAvgMonthly > 0 ? providedAvgMonthly : (totalRevenue / _monthsWindow);
      setState(() {
        _totalRevenue = totalRevenue;
        _avgMonthly = avgMonthly;
        _growthRate = _toDouble(data['growth_rate'] ?? data['growth'] ?? 0);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  String _currency(double v) => '\u20B9' + v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Revenue Analysis',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
          _RevenueAnalysisTiles(
            loading: _loading,
            totalRevenue: _totalRevenue,
            avgMonthly: _avgMonthly,
            growthRate: _growthRate,
          ),
        ],
      ),
    );
  }
}

class _RevenueAnalysisTiles extends StatelessWidget {
  final bool loading;
  final double totalRevenue;
  final double avgMonthly;
  final double growthRate;
  const _RevenueAnalysisTiles({this.loading = false, this.totalRevenue = 0.0, this.avgMonthly = 0.0, this.growthRate = 0.0});

  @override
  Widget build(BuildContext context) {
    Widget tile({
      required String value,
      required String label,
      required Color color,
      required IconData icon,
      Color? bg,
    }) {
      return Expanded(
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (bg ?? color.withOpacity(0.12)).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            tile(
              value: loading ? '—' : '\u20B9' + totalRevenue.toStringAsFixed(2),
              label: 'Total Revenue',
              color: const Color(0xFF059669),
              icon: Icons.attach_money,
              bg: const Color(0xFFEFFDF6),
            ),
            const SizedBox(width: 12),
            tile(
              value: loading ? '—' : '\u20B9' + avgMonthly.toStringAsFixed(2),
              label: 'Average Monthly',
              color: const Color(0xFF2563EB),
              icon: Icons.calendar_month,
              bg: const Color(0xFFF1F6FF),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            tile(
              value: loading ? '—' : '${growthRate.toStringAsFixed(1)}%',
              label: 'Growth Rate',
              color: const Color(0xFFD97706),
              icon: Icons.trending_up,
              bg: const Color(0xFFFFF9EB),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


