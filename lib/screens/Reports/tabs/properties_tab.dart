import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../PMS/services/properties_service.dart';
import '../../../widgets/skeleton_loader.dart';

class PropertiesTab extends StatelessWidget {
  const PropertiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Property Performance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
          _PropertyPerformanceGrid(),
        ],
      ),
    );
  }
}

class _PropertyPerformanceGrid extends StatefulWidget {
  const _PropertyPerformanceGrid();

  @override
  State<_PropertyPerformanceGrid> createState() => _PropertyPerformanceGridState();
}

class _PropertyPerformanceGridState extends State<_PropertyPerformanceGrid> {
  bool _loading = true;
  String? _error;

  int _total = 0;
  int _active = 0;
  double _avgOccupancy = 0.0; // percent 0-100
  double _avgRating = 0.0;    // 0-5

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await PropertiesService.getProperties(limit: 100);
    if (!mounted) return;
    if (res['success'] == true) {
      final data = res['data'];
      final items = _extractItemsList(data);

      int total = _parseTotal(data, itemsLength: items.length);
      int active = _countActive(items);
      final occupancy = _computeAverageOccupancy(items);
      final rating = _computeAverageRating(items);

      if (mounted) {
        setState(() {
          _total = total;
          _active = active;
          _avgOccupancy = occupancy;
          _avgRating = rating;
          _loading = false;
        });
      }
    } else {
      setState(() {
        _error = (res['message']?.toString() ?? 'Failed to load');
        _loading = false;
      });
    }
  }

  List<dynamic> _extractItemsList(dynamic root) {
    if (root is Map<String, dynamic>) {
      if (root['data'] is List) return (root['data'] as List);
      if (root['items'] is List) return (root['items'] as List);
      if (root['rows'] is List) return (root['rows'] as List);
      // Some APIs nest within 'result' or 'payload'
      if (root['result'] is Map) return _extractItemsList(root['result']);
      if (root['payload'] is Map) return _extractItemsList(root['payload']);
    }
    if (root is List) return root;
    return const [];
  }

  int _parseTotal(dynamic root, {required int itemsLength}) {
    if (root is Map<String, dynamic>) {
      final meta = root['meta'];
      if (meta is Map && meta['total'] is num) return (meta['total'] as num).toInt();
      if (root['total'] is num) return (root['total'] as num).toInt();
      if (root['count'] is num) return (root['count'] as num).toInt();
    }
    return itemsLength;
  }

  int _countActive(List<dynamic> items) {
    int active = 0;
    for (final item in items) {
      if (item is Map) {
        final status = (item['status'] ?? item['state'] ?? '').toString().toLowerCase();
        final isActiveFlag = (item['is_active'] == true) || (item['active'] == true) || (item['active'] == 1);
        if (isActiveFlag || status == 'active' || status == 'published' || status == 'enabled') {
          active++;
        }
      }
    }
    return active;
  }

  double _computeAverageOccupancy(List<dynamic> items) {
    double sum = 0.0;
    int n = 0;
    for (final item in items) {
      if (item is Map) {
        final stats = item['stats'];
        final occ = item['occupancy'] ?? item['occupancy_rate'] ?? (stats is Map ? stats['occupancy'] ?? stats['occupancy_rate'] : null);
        if (occ is num) {
          sum += occ.toDouble();
          n++;
        } else if (occ is String) {
          final v = double.tryParse(occ.replaceAll('%', '').trim());
          if (v != null) {
            sum += v;
            n++;
          }
        }
      }
    }
    if (n == 0) return 0.0;
    // If values look like 0-1, scale to percent
    final avg = sum / n;
    return avg <= 1.0 ? (avg * 100.0) : avg;
  }

  double _computeAverageRating(List<dynamic> items) {
    double sum = 0.0;
    int n = 0;
    for (final item in items) {
      if (item is Map) {
        final stats = item['stats'];
        final rating = item['rating'] ?? item['average_rating'] ?? (stats is Map ? stats['rating'] ?? stats['avg_rating'] : null);
        if (rating is num) {
          sum += rating.toDouble();
          n++;
        } else if (rating is String) {
          final v = double.tryParse(rating);
          if (v != null) {
            sum += v;
            n++;
          }
        }
      }
    }
    if (n == 0) return 0.0;
    // Clamp to 0-5 if needed
    final avg = sum / n;
    return avg > 5.0 ? 5.0 : (avg < 0.0 ? 0.0 : avg);
  }

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

    if (_loading) {
      return Row(
        children: const [
          Expanded(child: SkeletonStatCard()),
          SizedBox(width: 12),
          Expanded(child: SkeletonStatCard()),
        ],
      );
    }

    if (_error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Failed to load properties', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(_error!, style: GoogleFonts.inter(color: const Color(0xFF6B7280))),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            card(value: _total.toString(), label: 'Total', color: const Color(0xFF2563EB), icon: Icons.apartment),
            const SizedBox(width: 12),
            card(value: _active.toString(), label: 'Active', color: const Color(0xFF16A34A), icon: Icons.check_circle),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            card(value: _formatPercent(_avgOccupancy), label: 'Occupancy', color: const Color(0xFF7C3AED), icon: Icons.hotel),
            const SizedBox(width: 12),
            card(value: _formatRating(_avgRating), label: 'Avg Rating', color: const Color(0xFFD97706), icon: Icons.star_rate_rounded),
          ],
        ),
      ],
    );
  }

  String _formatPercent(double v) {
    if (v.isNaN || v.isInfinite) return '0%';
    final p = v.clamp(0, 100);
    return p.toStringAsFixed(p == p.roundToDouble() ? 0 : 1) + '%';
  }

  String _formatRating(double v) {
    if (v.isNaN || v.isInfinite) return '0.0/5.0';
    final r = v.clamp(0, 5);
    return r.toStringAsFixed(1) + '/5.0';
  }
}

// Using SkeletonStatCard from skeleton_loader.dart instead


