import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../components/report_components.dart';
import '../services/reports_service.dart';
import '../../../widgets/skeleton_loader.dart';

class BookingsTab extends StatefulWidget {
  const BookingsTab({super.key});

  @override
  State<BookingsTab> createState() => _BookingsTabState();
}

class _BookingsTabState extends State<BookingsTab> {
  bool _loading = true;
  int _pending = 0;
  int _confirmed = 0;
  int _completed = 0;
  int _cancelled = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final res = await ReportsService.getBookingsReport();
    if (!mounted) return;
    if (res['success'] == true) {
      final data = res['data'];
      Map<String, dynamic> map;
      if (data is Map<String, dynamic>) {
        // unwrap {data:{...}} shapes
        map = data.containsKey('data') && data['data'] is Map<String, dynamic> ? (data['data'] as Map<String, dynamic>) : data;
      } else {
        map = {};
      }

      // Prefer explicit booking status keys; otherwise try dashboard style
      final pending = _toInt(map['pending'] ?? map['bookings_pending']);
      final confirmed = _toInt(map['confirmed'] ?? map['bookings_confirmed']);
      final completed = _toInt(map['completed'] ?? map['bookings_completed']);
      final cancelled = _toInt(map['cancelled'] ?? map['bookings_cancelled']);

      if (mounted) {
        setState(() {
          _pending = pending;
          _confirmed = confirmed;
          _completed = completed;
          _cancelled = cancelled;
          _loading = false;
        });
      }
    } else {
      setState(() => _loading = false);
    }
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Booking Statistics',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
          ),
          _loading
              ? Column(
                  children: [
                    Row(
                      children: const [
                        Expanded(child: SkeletonStatCard()),
                        SizedBox(width: 12),
                        Expanded(child: SkeletonStatCard()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        Expanded(child: SkeletonStatCard()),
                        SizedBox(width: 12),
                        Expanded(child: SkeletonStatCard()),
                      ],
                    ),
                  ],
                )
              : _BookingStatsGrid(
                  pending: _pending,
                  confirmed: _confirmed,
                  completed: _completed,
                  cancelled: _cancelled,
                  loading: false,
                ),
        ],
      ),
    );
  }
}

class _BookingStatsGrid extends StatelessWidget {
  final int pending;
  final int confirmed;
  final int completed;
  final int cancelled;
  final bool loading;
  const _BookingStatsGrid({this.pending = 0, this.confirmed = 0, this.completed = 0, this.cancelled = 0, this.loading = false});

  @override
  Widget build(BuildContext context) {
    Widget card({
      required String value,
      required String label,
      required Color color,
      required IconData icon,
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
                    color: color.withOpacity(0.12),
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
                  textAlign: TextAlign.left,
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
            card(value: loading ? '—' : pending.toString(), label: 'Pending', color: const Color(0xFF2563EB), icon: Icons.hourglass_empty),
            const SizedBox(width: 12),
            card(value: loading ? '—' : confirmed.toString(), label: 'Confirmed', color: const Color(0xFF16A34A), icon: Icons.check_circle),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            card(value: loading ? '—' : completed.toString(), label: 'Completed', color: const Color(0xFF7C3AED), icon: Icons.task_alt),
            const SizedBox(width: 12),
            card(value: loading ? '—' : cancelled.toString(), label: 'Cancelled', color: const Color(0xFFDC2626), icon: Icons.cancel),
          ],
        ),
      ],
    );
  }
}


