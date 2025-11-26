import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/report_components.dart';
import 'tabs/overview_tab.dart';
import 'tabs/bookings_tab.dart';
import 'tabs/revenue_tab.dart';
import 'tabs/properties_tab.dart';
import '../../widgets/common_app_bar.dart';
import '../Dashboard/widget/drawer_widget.dart';

class ReportsUi extends StatefulWidget {
  const ReportsUi({super.key});

  @override
  State<ReportsUi> createState() => _ReportsUiState();
}

class _ReportsUiState extends State<ReportsUi> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
        child: Column(
          children: [
            // Header Section
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
                          'Reports & Analytics',
                          style: GoogleFonts.poppins(
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
            
            // Tabs Section
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: const Color(0xFF8B5CF6),
                unselectedLabelColor: const Color(0xFF6B7280),
                labelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Bookings'),
                  Tab(text: 'Revenue'),
                  Tab(text: 'Properties'),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  OverviewTab(),
                  BookingsTab(),
                  RevenueTab(),
                  PropertiesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}