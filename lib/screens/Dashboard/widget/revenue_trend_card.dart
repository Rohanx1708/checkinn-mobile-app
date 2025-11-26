import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RevenueTrendChart extends StatefulWidget {
  const RevenueTrendChart({super.key});

  @override
  State<RevenueTrendChart> createState() => _RevenueTrendChartState();
}

class _RevenueTrendChartState extends State<RevenueTrendChart> {
  bool _loading = true;
  List<double> _revenueData = [];

  @override
  void initState() {
    super.initState();
    _loadRevenueData();
  }

  Future<void> _loadRevenueData() async {
    // This will be called from the parent dashboard
    // For now, use static data as fallback
    setState(() {
      _revenueData = [33000, 35000, 37500, 41500, 44000, 44500];
      _loading = false;
    });
  }

  void updateData(List<double> data) {
    setState(() {
      _revenueData = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, // White card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Revenue Trend",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 5000,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 8),
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
                            case 1:
                              return const Text("Jan");
                            case 2:
                              return const Text("Feb");
                            case 3:
                              return const Text("Mar");
                            case 4:
                              return const Text("Apr");
                            case 5:
                              return const Text("May");
                            case 6:
                              return const Text("Jun");
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
                  maxX: 6,
                  minY: 0,
                  maxY: 50000,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _loading ? [] : _revenueData.asMap().entries.map((entry) {
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
