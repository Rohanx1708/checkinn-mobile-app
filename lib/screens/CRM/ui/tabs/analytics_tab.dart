import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/crm_service.dart';
import 'package:checkinn/services/auth_service.dart';

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  bool _loading = true;
  String? _error;
  List<_SourceSlice> _sources = const [];
  double _avgRating = 0;
  double _avgCustomerValue = 0;
  bool _analyticsFailed = false;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await AuthService.getToken();
      CrmService.authToken = token;
      // Fetch sources and metrics independently so one failing doesn't block the other
      Map<String, dynamic> sourcesData = const {};
      Map<String, dynamic> data = const {};
      try {
        sourcesData = await CrmService.fetchCustomerSources();
      } catch (e) {
        // ignore: avoid_print
        print('[CRM Analytics] fetchCustomerSources failed: ' + e.toString());
      }
      try {
        data = await CrmService.fetchCrmAnalytics();
      } catch (e) {
        // ignore: avoid_print
        print('[CRM Analytics] fetchCrmAnalytics failed: ' + e.toString());
        _analyticsFailed = true;
      }
      // Debug
      // ignore: avoid_print
      print('[CRM Analytics] sourcesData: ' + sourcesData.toString());

      // Parse acquisition sources: expect array of {label,count} or map {label:count}
      final List<_SourceSlice> parsedSources = [];
      // Fixed colors for known sources to match desired palette
      const blue = Color(0xFF60A5FA);      // Direct
      const green = Color(0xFF34D399);     // Phone
      const orange = Color(0xFFF59E0B);    // Walk_in
      const purple = Color(0xFFA78BFA);    // Website
      const pink = Color(0xFFFB7185);      // Referral
      final fallbackPalette = const [
        Color(0xFF22D3EE), Color(0xFF4ADE80), Color(0xFFFBBF24), Color(0xFF06B6D4), Color(0xFF10B981)
      ];
      int fallbackIdx = 0;

      Color _colorForLabel(String label) {
        final key = label.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
        switch (key) {
          case 'direct':
            return blue;
          case 'phone':
            return green;
          case 'walk_in':
            return orange;
          case 'website':
            return purple;
          case 'referral':
            return pink;
          default:
            final c = fallbackPalette[fallbackIdx % fallbackPalette.length];
            fallbackIdx++;
            return c;
        }
      }
      dynamic sources = sourcesData['sources'] ?? sourcesData['acquisition'] ?? sourcesData['acquisition_sources'] ?? sourcesData['customer_sources'] ?? sourcesData['customers_by_source'] ?? sourcesData['source_breakdown'];
      // Try common nested containers
      sources ??= (sourcesData['data'] != null) ? (sourcesData['data']['sources'] ?? sourcesData['data']['acquisition'] ?? sourcesData['data']['acquisition_sources'] ?? sourcesData['data']['customer_sources'] ?? sourcesData['data']['customers_by_source'] ?? sourcesData['data']['source_breakdown']) : null;
      sources ??= (sourcesData['analytics'] != null) ? (sourcesData['analytics']['sources'] ?? sourcesData['analytics']['acquisition'] ?? sourcesData['analytics']['acquisition_sources'] ?? sourcesData['analytics']['customer_sources'] ?? sourcesData['analytics']['customers_by_source'] ?? sourcesData['analytics']['source_breakdown']) : null;
      sources ??= (sourcesData['crm'] != null) ? (sourcesData['crm']['sources'] ?? sourcesData['crm']['acquisition'] ?? sourcesData['crm']['acquisition_sources'] ?? sourcesData['crm']['customer_sources'] ?? sourcesData['crm']['customers_by_source'] ?? sourcesData['crm']['source_breakdown']) : null;
      // Fallback: data.data itself is a flat map of source->count
      if (sources == null && sourcesData['data'] is Map) {
        final m = Map<String, dynamic>.from(sourcesData['data'] as Map);
        final keys = m.keys.map((e) => e.toString().toLowerCase()).toSet();
        final looksLikeFlat = keys.contains('direct') || keys.contains('phone') || keys.contains('walk_in') || keys.contains('website') || keys.contains('referral');
        if (looksLikeFlat) {
          sources = m;
        }
      }
      // Fallback: sourcesData itself is a flat map of source->count
      if (sources == null && sourcesData is Map) {
        final m = Map<String, dynamic>.from(sourcesData as Map);
        final keys = m.keys.map((e) => e.toString().toLowerCase()).toSet();
        final looksLikeFlat = keys.contains('direct') || keys.contains('phone') || keys.contains('walk_in') || keys.contains('website') || keys.contains('referral');
        if (looksLikeFlat) {
          sources = m;
        }
      }
      if (sources is List) {
        for (final s in sources) {
          final label = (s['label'] ?? s['name'] ?? s['source'] ?? s['key'] ?? '').toString();
          final value = (s['value'] ?? s['count'] ?? s['bookings'] ?? s['customers'] ?? s['total'] ?? 0);
          final v = value is num ? value.toInt() : int.tryParse(value.toString()) ?? 0;
          parsedSources.add(_SourceSlice(label: label, value: v, color: _colorForLabel(label)));
        }
      } else if (sources is Map) {
        sources.forEach((k, v) {
          final label = k.toString();
          int val;
          if (v is Map) {
            final inner = v['value'] ?? v['count'] ?? v['bookings'] ?? v['customers'] ?? v['total'] ?? 0;
            val = inner is num ? inner.toInt() : int.tryParse(inner.toString()) ?? 0;
          } else {
            val = v is num ? v.toInt() : int.tryParse(v.toString()) ?? 0;
          }
          parsedSources.add(_SourceSlice(label: label, value: val, color: _colorForLabel(label)));
        });
      }
      // ignore: avoid_print
      print('[CRM Analytics] parsedSources: ' + parsedSources.map((e) => '${e.label}:${e.value}').join(', '));

      // Keep a stable legend order for known sources
      final order = {
        'direct': 0,
        'phone': 1,
        'walk_in': 2,
        'website': 3,
        'referral': 4,
      };
      parsedSources.sort((a, b) {
        final ak = a.label.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
        final bk = b.label.trim().toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
        final ai = order.containsKey(ak) ? order[ak]! : 100 + a.label.compareTo(b.label);
        final bi = order.containsKey(bk) ? order[bk]! : 100 + b.label.compareTo(a.label);
        return ai.compareTo(bi);
      });

      // Average rating
      final ratingRaw = data['avg_rating'] ?? data['average_rating'] ?? data['rating'] ?? (data['data'] != null ? (data['data']['avg_rating'] ?? data['data']['average_rating'] ?? data['data']['rating']) : null) ?? 0;
      final avgRating = ratingRaw is num ? ratingRaw.toDouble() : double.tryParse(ratingRaw.toString()) ?? 0;

      // Average customer value / LTV
      final valueRaw = data['avg_customer_value'] ?? data['average_customer_value'] ?? data['ltv'] ?? (data['data'] != null ? (data['data']['avg_customer_value'] ?? data['data']['average_customer_value'] ?? data['data']['ltv']) : null) ?? 0;
      final avgValue = valueRaw is num ? valueRaw.toDouble() : double.tryParse(valueRaw.toString()) ?? 0;

      if (!mounted) return;
      setState(() {
        _sources = parsedSources;
        _avgRating = avgRating;
        _avgCustomerValue = avgValue;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = '$e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04, vertical: 12),
      children: [
        _analyticsCard(
          title: 'Customer Acquisition Sources',
          child: Column(
            children: [
              SizedBox(
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_loading)
                      const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
                        ),
                      )
                    else
                      PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 60,
                          sections: () {
                            final total = _sources.fold<int>(0, (sum, s) => sum + s.value);
                    if (total <= 0) {
                              return [
                                PieChartSectionData(color: const Color(0xFFE5E7EB), value: 1, radius: 80, title: ''),
                              ];
                            }
                            return _sources
                                .map((s) => PieChartSectionData(color: s.color, value: s.value.toDouble(), radius: 80, title: ''))
                                .toList();
                          }(),
                        ),
                      ),
                    if (!_loading)
                      Text(
                        _sources.fold<int>(0, (sum, s) => sum + s.value) > 0 ? 'Sources' : 'No data',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: _sources.isEmpty
                    ? const []
                    : _sources
                        .map((s) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(width: 14, height: 10, decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(2))),
                                const SizedBox(width: 6),
                                Text(s.label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280))),
                              ],
                            ))
                        .toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _analyticsCard(
                title: 'Customer Satisfaction',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_analyticsFailed ? 'N/A' : '${_avgRating.toStringAsFixed(1)}/5.0', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF6366F1))),
                    const SizedBox(height: 4),
                    Text('Average Rating', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _analyticsCard(
                title: 'Average Customer Value',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_analyticsFailed ? 'N/A' : '₹${_avgCustomerValue.toStringAsFixed(2)}', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF16A34A))),
                    const SizedBox(height: 4),
                    Text('Per Customer', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _analyticsCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF111827))),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SourceSlice {
  final String label;
  final int value;
  final Color color;
  const _SourceSlice({required this.label, required this.value, required this.color});
}


