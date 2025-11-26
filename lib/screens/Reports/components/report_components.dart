import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/reports_service.dart';

class EnhancedChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const EnhancedChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class QuickStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const QuickStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class BookingsTrendChart extends StatefulWidget {
  const BookingsTrendChart({super.key});

  @override
  State<BookingsTrendChart> createState() => _BookingsTrendChartState();
}

class _BookingsTrendChartState extends State<BookingsTrendChart> {
  bool _loading = true;
  List<double> _values = const [];
  List<String> _labels = const [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static const List<String> _monthAbbr = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  List<String> _normalizeMonthLabels(List<String> raw) {
    if (raw.isEmpty) return raw;
    return raw.map((l) {
      final s = l.trim();
      if (_monthAbbr.contains(s)) return s;
      final onlyDigits = RegExp(r'^(\d{1,2})$');
      final yyyymm = RegExp(r'^(\d{4})-(\d{1,2})');
      if (onlyDigits.hasMatch(s)) {
        final m = int.tryParse(s) ?? 0;
        if (m >= 1 && m <= 12) return _monthAbbr[m - 1];
      }
      final yMatch = yyyymm.firstMatch(s);
      if (yMatch != null) {
        final m = int.tryParse(yMatch.group(2)!) ?? 0;
        if (m >= 1 && m <= 12) return _monthAbbr[m - 1];
      }
      return s;
    }).toList();
  }

  dynamic _unwrap(dynamic input) {
    var curr = input;
    // Unwrap nested { data: ... } objects up to a reasonable depth
    for (int i = 0; i < 3; i++) {
      if (curr is Map && curr.length == 1 && curr.containsKey('data')) {
        curr = curr['data'];
      } else {
        break;
      }
    }
    return curr;
  }

  Future<void> _fetch() async {
    final res = await ReportsService.getMonthlyBookingsTrend();
    if (!mounted) return;
    if (res['success'] == true) {
      final root = res['data'];
      final unwrapped = _unwrap(root);
      List<double> values = [];
      List<String> labels = [];

      // Case 1: Already-unwrapped map with labels and bookings
      if (unwrapped is Map<String, dynamic> && unwrapped['bookings'] is List) {
        values = (unwrapped['bookings'] as List).map<double>(_toDouble).toList();
        if (unwrapped['labels'] is List) {
          labels = (unwrapped['labels'] as List).map((e) => e.toString()).toList();
        }
      }

      // Case 2: { data: { labels, bookings } }
      if (values.isEmpty && unwrapped is Map<String, dynamic> && unwrapped['data'] is Map) {
        final inner = unwrapped['data'] as Map;
        if (inner['bookings'] is List) {
          values = (inner['bookings'] as List).map<double>(_toDouble).toList();
          if (inner['labels'] is List) {
            labels = (inner['labels'] as List).map((e) => e.toString()).toList();
          }
        }
      }

      // Fallbacks
      if (values.isEmpty) {
        final data = unwrapped;
        if (data is Map<String, dynamic>) {
          var rawSeries = (data['series'] ?? data['data']);
          var rawLabels = (data['labels'] ?? data['months']);
          if (rawSeries is Map && (rawSeries['series'] != null || rawSeries['data'] != null)) {
            rawLabels = rawLabels ?? rawSeries['labels'] ?? rawSeries['months'];
            rawSeries = rawSeries['series'] ?? rawSeries['data'];
          }
          if (rawSeries is List) {
            values = rawSeries.map<double>((e) {
              if (e is num) return e.toDouble();
              if (e is Map && e['value'] != null) return _toDouble(e['value']);
              if (e is Map && e['count'] != null) return _toDouble(e['count']);
              return _toDouble(e);
            }).toList();
          } else if (rawSeries is Map) {
            final entries = rawSeries.entries.toList()
              ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));
            labels = entries.map((e) => e.key.toString()).toList();
            values = entries.map<double>((e) => _toDouble(e.value)).toList();
          }
          if (rawLabels is List && rawLabels.isNotEmpty) {
            labels = rawLabels.map((e) => e.toString()).toList();
          }
          if (values.isEmpty && data['items'] is List) {
            final items = data['items'] as List;
            labels = items.map((e) => (e as Map)['month']?.toString() ?? '').toList();
            values = items.map<double>((e) => _toDouble((e as Map)['count'] ?? (e as Map)['value'])).toList();
          }
        } else if (data is List) {
          if (data.isNotEmpty && data.first is Map) {
            labels = data.map((e) => (e as Map)['month']?.toString() ?? '').toList();
            values = data.map<double>((e) => _toDouble((e as Map)['value'] ?? (e as Map)['count'])).toList();
          } else {
            values = data.map<double>(_toDouble).toList();
          }
        }
      }

      if (values.isEmpty) {
        // ignore: avoid_print
        print('[Reports] Bookings trend parsed empty. Raw: ' + root.toString());
      }

      setState(() {
        _values = values;
        _labels = _normalizeMonthLabels(labels.isNotEmpty ? labels : List.generate(values.length, (i) => 'M${i + 1}'));
        _loading = false;
      });
    } else {
      setState(() {
        _values = const [];
        _labels = const [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<double> values = _values.isNotEmpty ? List<double>.from(_values) : List<double>.filled(6, 0.0);
    final List<String> labels = _labels.isNotEmpty ? List<String>.from(_labels) : ['M1', 'M2', 'M3', 'M4', 'M5', 'M6'];
    final double maxY = values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) * 1.2 : 100.0;
    final double safeMaxY = maxY <= 0 ? 10.0 : maxY;
    final double interval = (safeMaxY / 5).clamp(1, double.infinity);
    int step = 1;
    if (labels.length > 6) {
      step = (labels.length / 6).ceil();
    }

    String _shortLabel(String s) {
      final t = s.trim();
      // Already like Jan/Feb
      if (_monthAbbr.contains(t)) return t;
      // Try formats like "Nov 2024" or "2024-11" or "2024 Nov"
      final monYear1 = RegExp(r'^(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d{2,4}$', caseSensitive: false);
      if (monYear1.hasMatch(t)) {
        return t.split(' ').first.substring(0, 3);
      }
      final yymm = RegExp(r'^(\d{4})-(\d{1,2})$');
      final m1 = yymm.firstMatch(t);
      if (m1 != null) {
        final m = int.tryParse(m1.group(2)!) ?? 0;
        if (m >= 1 && m <= 12) return _monthAbbr[m - 1];
      }
      final yyMon = RegExp(r'^(\d{4})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)$', caseSensitive: false);
      final m2 = yyMon.firstMatch(t);
      if (m2 != null) {
        return m2.group(2)!.substring(0, 3);
      }
      return t.length > 3 ? t.substring(0, 3) : t;
    }

    return SizedBox(
      height: 260,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : LineChart(
              LineChartData(
                minY: 0,
                maxY: safeMaxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: const Color(0xFFE5E7EB),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: const Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        // Show at most ~6 labels
                        if (idx % step != 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _shortLabel(labels[idx]),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
                    left: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
                  ),
                ),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.white,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (spots) => spots.map((s) {
                      return LineTooltipItem(
                        '${labels[s.x.toInt()]}\n${s.y.toStringAsFixed(0)}',
                        GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i].toDouble())),
                    isCurved: true,
                    color: const Color(0xFF3B82F6),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (p0, p1, p2, p3) => FlDotCirclePainter(
                        radius: 3,
                        color: Colors.white,
                        strokeColor: const Color(0xFF3B82F6),
                        strokeWidth: 2,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF3B82F6).withOpacity(0.25),
                          const Color(0xFF3B82F6).withOpacity(0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class TopPropertiesTable extends StatefulWidget {
  const TopPropertiesTable({super.key});

  @override
  State<TopPropertiesTable> createState() => _TopPropertiesTableState();
}

class _TopPropertiesTableState extends State<TopPropertiesTable> {
  bool _loading = true;
  List<List<String>> _rows = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _currency(num v) => '\u20B9' + v.toDouble().toStringAsFixed(2);

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

  Future<void> _load() async {
    setState(() => _loading = true);
    // Use Top Room Types as the data source for this table
    final rtRes = await ReportsService.getTopRoomTypes(limit: 5);
    if (rtRes['success'] == true) {
      final rtRoot = rtRes['data'];
      final data = _unwrap(rtRoot);
      List<dynamic> items;
      if (data is Map<String, dynamic>) {
        items = (data['data'] ?? data['items'] ?? data['room_types'] ?? []) as List? ?? [];
      } else if (data is List) {
        items = data;
      } else {
        items = [];
      }

      final rows = items.map<List<String>>((e) {
        if (e is Map) {
          final name = (e['name'] ?? e['room_type'] ?? '').toString();
          final bookingsAny = (e['bookings'] ?? e['booking_count'] ?? 0);
          final bookings = bookingsAny.toString();
          final revenueAny = (e['revenue'] ?? 0);
          final revenueNum = revenueAny is num ? revenueAny : num.tryParse(revenueAny.toString()) ?? 0;
          final revenue = _currency(revenueNum);
          final occupancyAny = (e['occupancy'] ?? 0);
          final occupancy = occupancyAny is num ? '${occupancyAny.toStringAsFixed(1)}%' : occupancyAny.toString();
          return [
            name.isEmpty ? '—' : name,
            bookings,
            revenue,
            '-',
            occupancy.isEmpty ? '-' : occupancy,
            name.isEmpty ? '-' : name,
          ];
        }
        return [e.toString(), '0', _currency(0), '-', '-', '-'];
      }).toList();

      setState(() {
        _rows = rows;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Widget headerCell(String text) => Expanded(
    flex: 1,
    child: Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 9,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF6B7280),
        letterSpacing: 0.4,
      ),
    ),
  );

  Widget dataCell(String text, {FontWeight weight = FontWeight.w500, Color color = const Color(0xFF111827)}) => Expanded(
    flex: 1,
    child: Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.poppins(
        fontSize: 10,
        fontWeight: weight,
        color: color,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    final rows = _rows.isNotEmpty
        ? _rows
        : const [
            ['—', '—', '—', '—', '—', '—'],
          ];

    int _crossAxisCount(double w) {
      if (w >= 1100) return 3;
      if (w >= 700) return 2;
      return 1;
    }

    Widget _kv(String k, String v) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            k,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = _crossAxisCount(constraints.maxWidth);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          itemCount: rows.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 220, // increased to prevent overflow
          ),
          itemBuilder: (context, index) {
            final r = rows[index];
            final property = r[0];
            final bookings = r[1];
            final revenue = r[2];
            final rating = r[3];
            final occupancy = r[4];
            final topRoom = r.length > 5 ? r[5] : '-';
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFF1F5F9),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.apartment, color: Color(0xFF6366F1), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          property,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _kv('Bookings', bookings),
                        _kv('Revenue', revenue),
                        _kv('Rating', rating),
                        _kv('Occupancy', occupancy),
                        _kv('Top Room Type', topRoom),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}


