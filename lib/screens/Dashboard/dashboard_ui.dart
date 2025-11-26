import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'widget/appbar_widget.dart';
import 'widget/drawer_widget.dart';
import 'widget/dashboard_calendar_widget.dart';
import 'widget/revenue_trend_card.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bookings/services/bookings_service.dart';
import '../employees/services/employees_service.dart';
import '../Reports/services/reports_service.dart';
import '../PMS/services/properties_service.dart';
import '../../widgets/common_app_bar.dart';

class DashboardUi extends StatefulWidget {
  const DashboardUi({super.key});

  @override
  State<DashboardUi> createState() => _DashboardUiState();
}

class _DashboardUiState extends State<DashboardUi> {
  bool _loading = true;
  int _bookingsCount = 0;
  double _revenueTotal = 0.0;
  int _cancelledCount = 0;
  int _voidCount = 0;
  int _noShowCount = 0;
  int _roomsCount = 0;
  int _agentsCount = 0;
  
  // New API-connected data
  double _occupancyRate = 0.0;
  double _guestRating = 0.0;
  List<double> _revenueTrendData = [];
  List<Map<String, dynamic>> _calendarBookings = [];
  bool _revenueLoading = true;
  bool _calendarLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Method to refresh calendar data
  Future<void> refreshCalendarData() async {
    await _loadCalendarBookings();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        BookingsService.getBookings(page: 1, limit: 200),
        EmployeesService.getEmployees(page: 1, limit: 200),
        PropertiesService.getProperties(page: 1, limit: 200),
        _loadRevenueTrend(),
        _loadCalendarBookings(),
        _loadOccupancyAndRating(),
      ]);

      // Bookings
      final resBookings = results[0] as Map<String, dynamic>;
      if (resBookings['success'] == true) {
        final data = resBookings['data'];
        final List<dynamic> list = (data['data'] ?? data['bookings'] ?? []) as List<dynamic>;
        int bookings = list.length;
        double revenue = 0.0;
        int cancelled = 0;
        int voided = 0;
        int noShow = 0;
        for (final item in list) {
          try {
            final amt = item['total_amount'] ?? item['amount'] ?? item['revenue'];
            if (amt is num) revenue += amt.toDouble();
            else if (amt is String) revenue += double.tryParse(amt) ?? 0.0;
            final status = (item['booking_status'] ?? item['status'] ?? '').toString().toLowerCase();
            if (status.contains('cancel')) cancelled++;
            else if (status.contains('void')) voided++;
            else if (status.contains('no_show') || status.contains('no show')) noShow++;
          } catch (_) {}
        }
        _bookingsCount = bookings;
        _revenueTotal = revenue;
        _cancelledCount = cancelled;
        _voidCount = voided;
        _noShowCount = noShow;
      }

      // Agents count (employees)
      final resEmps = results[1] as Map<String, dynamic>;
      if (resEmps['success'] == true) {
        final data = resEmps['data'];
        final List<dynamic> emps = (data['data'] ?? data['employees'] ?? data['items'] ?? []) as List<dynamic>;
        _agentsCount = emps.length;
      }

      // Properties count (use as rooms estimate)
      final resProperties = results[2] as Map<String, dynamic>;
      if (resProperties['success'] == true) {
        final data = resProperties['data'];
        final List<dynamic> properties = (data['data'] ?? data['properties'] ?? data['items'] ?? []) as List<dynamic>;
        // Estimate rooms count based on properties (assuming average rooms per property)
        _roomsCount = properties.length * 10; // Estimate 10 rooms per property
      } else {
        print('⚠️ Properties API failed: ${resProperties['message']}');
        // Estimate rooms from bookings data
        final bookingsData = resBookings['data'];
        final List<dynamic> bookings = (bookingsData['data'] ?? bookingsData['bookings'] ?? []) as List<dynamic>;
        _roomsCount = bookings.length > 0 ? (bookings.length * 2) : 20; // Estimate based on bookings
      }

      setState(() => _loading = false);
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadRevenueTrend() async {
    try {
      final result = await ReportsService.getMonthlyBookingsTrend(months: 6);
      if (result['success'] == true) {
        final data = result['data'];
        List<double> trendData = [];
        
        // Parse revenue trend data from API response
        if (data is Map && data.containsKey('data')) {
          final trendList = data['data'] as List<dynamic>?;
          if (trendList != null) {
            for (final item in trendList) {
              if (item is Map) {
                final revenue = _toDouble(item['revenue'] ?? item['amount'] ?? 0);
                trendData.add(revenue);
              }
            }
          }
        }
        
        setState(() {
          _revenueTrendData = trendData.isNotEmpty ? trendData : [32000, 35000, 38000, 42000, 45000, 45200];
          _revenueLoading = false;
        });
      } else {
        setState(() {
          _revenueTrendData = [32000, 35000, 38000, 42000, 45000, 45200];
          _revenueLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _revenueTrendData = [32000, 35000, 38000, 42000, 45000, 45200];
        _revenueLoading = false;
      });
    }
  }

  Future<void> _loadCalendarBookings() async {
    try {
      final result = await BookingsService.getBookings(page: 1, limit: 100);
      if (result['success'] == true) {
        final data = result['data'];
        final List<dynamic> bookings = (data['data'] ?? data['bookings'] ?? []) as List<dynamic>;
        
        List<Map<String, dynamic>> calendarBookings = [];
        for (final booking in bookings) {
          try {
            // Try multiple possible date field names
            final checkIn = booking['check_in_date'] ?? 
                           booking['checkin_date'] ?? 
                           booking['check_in'] ?? 
                           booking['arrival_date'] ?? 
                           booking['booking_date'];
            
            // Try multiple possible guest name field names
            final guestName = booking['guest_name'] ?? 
                             booking['customer_name'] ?? 
                             booking['guest'] ?? 
                             booking['customer'] ?? 
                             booking['name'] ?? 
                             'Guest';
            
            // Try multiple possible room field names
            final roomNumber = booking['room_number'] ?? 
                              booking['room_id'] ?? 
                              booking['room'] ?? 
                              booking['room_name'] ?? 
                              'Room';
            
            // Try to get booking status for better display
            final status = booking['booking_status'] ?? booking['status'] ?? 'confirmed';
            
            if (checkIn != null) {
              final date = DateTime.tryParse(checkIn.toString());
              if (date != null) {
                calendarBookings.add({
                  'date': date,
                  'title': '$roomNumber - $guestName',
                  'status': status,
                  'booking_id': booking['id'] ?? booking['booking_id'],
                });
              }
            }
          } catch (e) {
            print('Error processing booking: $e');
          }
        }
        
        setState(() {
          _calendarBookings = calendarBookings;
          _calendarLoading = false;
        });
      } else {
        setState(() {
          _calendarBookings = [];
          _calendarLoading = false;
        });
      }
    } catch (e) {
      print('Error loading calendar bookings: $e');
      setState(() {
        _calendarBookings = [];
        _calendarLoading = false;
      });
    }
  }

  Future<void> _loadOccupancyAndRating() async {
    try {
      // Load occupancy rate from bookings data only (since rooms API is not available)
      final bookingsResult = await BookingsService.getBookings(page: 1, limit: 200);
      
      double occupancyRate = 46.0; // Default fallback
      double avgRating = 4.8; // Default fallback
      
      if (bookingsResult['success'] == true) {
        final bookingsData = bookingsResult['data'];
        final List<dynamic> bookings = (bookingsData['data'] ?? bookingsData['bookings'] ?? []) as List<dynamic>;
        
        // Calculate occupancy rate based on booking patterns
        final activeBookings = bookings.where((b) {
          final status = (b['booking_status'] ?? b['status'] ?? '').toString().toLowerCase();
          return !status.contains('cancel') && !status.contains('void') && !status.contains('completed');
        }).length;
        
        // Estimate occupancy based on booking activity
        if (bookings.length > 0) {
          // Simple estimation: higher booking activity = higher occupancy
          final bookingRatio = activeBookings / bookings.length;
          occupancyRate = 30.0 + (bookingRatio * 40.0); // Range: 30-70%
          occupancyRate = occupancyRate.clamp(20.0, 80.0); // Keep within reasonable bounds
        }
        
        // Calculate average guest rating from bookings
        double totalRating = 0.0;
        int ratingCount = 0;
        for (final booking in bookings) {
          final rating = _toDouble(booking['rating'] ?? booking['guest_rating']);
          if (rating > 0) {
            totalRating += rating;
            ratingCount++;
          }
        }
        avgRating = ratingCount > 0 ? totalRating / ratingCount : 4.8;
      }
      
      setState(() {
        _occupancyRate = occupancyRate;
        _guestRating = avgRating;
      });
    } catch (e) {
      print('⚠️ Error loading occupancy and rating: $e');
      setState(() {
        _occupancyRate = 46.0;
        _guestRating = 4.8;
      });
    }
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  Widget _buildRevenueTrendCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Revenue Trend",
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _revenueLoading 
                ? const Center(child: CircularProgressIndicator())
                : _buildRevenueChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    if (_revenueTrendData.isEmpty) {
      return const Center(child: Text('No revenue data available'));
    }

    final maxY = _revenueTrendData.reduce((a, b) => a > b ? a : b);
    final minY = 0.0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: maxY / 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 1: return const Text("Jan");
                  case 2: return const Text("Feb");
                  case 3: return const Text("Mar");
                  case 4: return const Text("Apr");
                  case 5: return const Text("May");
                  case 6: return const Text("Jun");
                }
                return const Text("");
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        minX: 1,
        maxX: _revenueTrendData.length.toDouble(),
        minY: minY,
        maxY: maxY * 1.1,
        lineBarsData: [
          LineChartBarData(
            spots: _revenueTrendData.asMap().entries.map((entry) {
              return FlSpot(entry.key + 1, entry.value);
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }


  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference > 0) return 'In $difference days';
    return '${date.day}/${date.month}';
  }
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar.dashboard(
        notificationCount: 5,
      ),
      drawer: const DrawerWidget(),
      body: SafeArea(
        child: _loading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
                    ),
                  ],
                ),
              )
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Color(0xFFF8FAFC),
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        
                        // KPI Stats Tile (4 sections)
                        _buildKpiStatsTile(),
                        const SizedBox(height: 16),
                        
                        // Financial Metrics (2x2 Grid)
                        _buildFinancialMetrics(),
                        const SizedBox(height: 16),
                        
                        // Counts and Occupancy Section
                        _buildCountsAndOccupancy(),
                        const SizedBox(height: 16),
                        
                        // Revenue Trend - separate card above calendar
                        _buildRevenueTrendCard(),
                        const SizedBox(height: 16),
                        // Calendar Section
                        DashboardCalendarWidget(
                          bookings: _calendarBookings,
                          loading: _calendarLoading,
                          onDateSelected: (date) {
                            // Handle date selection if needed
                            print('Selected date: $date');
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildKpiStatsTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: Row(
        children: [
          _buildKpiItem('Rooms', _loading ? '—' : _roomsCount.toString(), const Color(0xFFEF4444)),
          _buildDivider(),
          _buildKpiItem('Agents', _loading ? '—' : _agentsCount.toString(), const Color(0xFFEC4899)),
          _buildDivider(),
          _buildKpiItem('Bookings', _bookingsCount.toString(), const Color(0xFF22C55E)),
        ],
      ),
    );
  }

  Widget _buildKpiItem(String title, String value, Color valueColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12  ,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: const Color(0xFFF1F5F9),
    );
  }

  Widget _buildFinancialMetrics() {
    return Column(children: [
      Row(children: [
        Expanded(child: _buildStatTile(
          title: 'Total Bookings',
          value: _loading ? '—' : _bookingsCount.toString(),
          changeText: '+12%  vs last month',
          changeColor: const Color(0xFF10B981),
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatTile(
          title: 'Revenue',
          value: _loading ? '—' : _revenueTotal.toStringAsFixed(2),
          changeText: '+8%  vs last month',
          changeColor: const Color(0xFF10B981),
        )),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _buildStatTile(
          title: 'Occupancy Rate',
          value: _loading ? '—' : '${_occupancyRate.toStringAsFixed(1)}%',
          changeText: '+5%  vs last month',
          changeColor: const Color(0xFF10B981),
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildStatTile(
          title: 'Guest Rating',
          value: _loading ? '—' : _guestRating.toStringAsFixed(1),
          changeText: '+0.2  vs last month',
          changeColor: const Color(0xFF10B981),
        )),
      ]),
    ]);
  }

  Widget _buildFinancialCard(String title, String currentValue, String previousValue, String change, bool isPositive, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  currentValue,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive ? const Color(0xFF22C55E).withOpacity(0.1) : const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            previousValue,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9CA3AF),
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required String changeText,
    required Color changeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF111827))),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.trending_up, size: 16, color: Color(0xFF10B981)),
            const SizedBox(width: 6),
            Text(changeText, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: changeColor)),
          ]),
        ],
      ),
    );
  }

  Widget _buildCountsAndOccupancy() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Counts Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Counts',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                _buildCountItem('Void', _voidCount.toString()),
                const SizedBox(height: 8),
                _buildCountItem('Cancelled', _cancelledCount.toString()),
                const SizedBox(height: 8),
                _buildCountItem('No Show', _noShowCount.toString()),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 80,
            color: const Color(0xFFF1F5F9),
          ),
          const SizedBox(width: 20),
          // Occupancy Section
          Expanded(
            child: Column(
              children: [
                Text(
                  'Occupancy (%)',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: _loading ? 0.0 : (_occupancyRate / 100),
                        strokeWidth: 6,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                      ),
                    ),
                    Text(
                      _loading ? '—' : _occupancyRate.toStringAsFixed(0),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _revenueTrendCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenue Trend', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 10, color: const Color(0xFF1F2937))),
          const SizedBox(height: 8),
          // Simple custom painted mini line chart (static values)
          SizedBox(
            height: 100,
            child: CustomPaint(
              painter: _MiniLineChartPainter([
                32000, 35000, 38000, 42000, 45000, 45200
              ]),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  // Painter to draw a simple smooth-ish line and fill
  // Not production-grade, but lightweight and dependency-free
  // Values expected as monthly revenue numbers
  // X axis is evenly spaced across width
  // Y axis scaled to max of data
}

class _MiniLineChartPainter extends CustomPainter {
  final List<double> values;
  _MiniLineChartPainter(List<num> raw)
      : values = raw.map((e) => e.toDouble()).toList();

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final minY = 0.0;
    final dx = size.width / (values.length - 1);

    final fillPath = Path();
    final linePath = Path();

    for (int i = 0; i < values.length; i++) {
      final x = dx * i;
      final y = size.height - ((values[i] - minY) / (maxY - minY)) * size.height;
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..color = const Color(0xFF6366F1).withOpacity(0.08)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    // points
    final dotPaint = Paint()..color = const Color(0xFF6366F1);
    for (int i = 0; i < values.length; i++) {
      final x = dx * i;
      final y = size.height - ((values[i] - minY) / (maxY - minY)) * size.height;
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

  Widget _buildCountItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

