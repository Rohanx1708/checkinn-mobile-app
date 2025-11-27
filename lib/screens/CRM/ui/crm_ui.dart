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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer Relationship Management',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
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
                child: TabBar(
                  labelColor: const Color(0xFF1F2937),
                  unselectedLabelColor: const Color(0xFF6B7280),
                  indicatorColor: const Color(0xFF1F2937),
                  labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                  tabs: const [
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



