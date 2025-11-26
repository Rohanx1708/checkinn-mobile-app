import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tabs/customers_tab.dart';
import 'tabs/leads_tab.dart';
import 'tabs/analytics_tab.dart';
import '../../../widgets/common_app_bar.dart';
import '../../Dashboard/widget/drawer_widget.dart';

class CrmUi extends StatefulWidget {
  const CrmUi({super.key});

  @override
  State<CrmUi> createState() => _CrmUiState();
}

class _CrmUiState extends State<CrmUi> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar.dashboard(
        notificationCount: 5,
      ),
      drawer: const DrawerWidget(),
      body: Container(
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
        child: DefaultTabController(
          length: 3,
          child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6366F1),
                          const Color(0xFF8B5CF6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.people_outline, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer Relationship Management',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          height: 3,
                          width: 86,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage your customers and leads',
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
            ),

            // Tabs
            Padding(
              padding: EdgeInsets.fromLTRB(screenWidth * 0.04, 0, screenWidth * 0.04,8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TabBar(
                  labelColor: Color(0xFF1F2937),
                  unselectedLabelColor: Color(0xFF6B7280),
                  indicatorColor: Color(0xFF6366F1),
                  tabs: [
                    Tab(text: 'Customers'),
                    Tab(text: 'Leads'),
                    Tab(text: 'Analytics'),
                  ],
                ),
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  CustomersTab(),
                  LeadsTab(),
                  AnalyticsTab(),
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}



