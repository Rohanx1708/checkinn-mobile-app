import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/common_app_bar.dart';
import '../models/agent_model.dart';
import '../widgets/agent_card.dart';
import 'add_agent_screen.dart';
import 'agent_detail_ui.dart';
import '../../Dashboard/widget/drawer_widget.dart';
import '../../../widgets/list_item_animation.dart';

class AgentUi extends StatefulWidget {
  const AgentUi({super.key});

  @override
  State<AgentUi> createState() => _AgentUiState();
}

class _AgentUiState extends State<AgentUi> {
  final List<Agent> _agents = [
    const Agent(
      name: "John Doe",
      status: "Active",
      company: "ABC Travels",
      photoUrl: "https://via.placeholder.com/150",
      mobile: "9876543210",
      altMobile: "9123456780",
      email: "john@example.com",
      address: "123 Street, City"
    ),
    const Agent(
      name: "Jane Smith",
      status: "Inactive",
      company: "XYZ Holidays",
      photoUrl: "https://via.placeholder.com/150",
      mobile: "9988776655",
      altMobile: "9001122334",
      email: "jane@example.com",
      address: "456 Avenue, City"
    ),
  ];

  Future<void> _showAddAgentScreen() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddAgentScreen(),
      ),
    );

    if (result != null && result is Agent) {
      setState(() {
        _agents.add(result);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agent added successfully: ${result.name}'),
            backgroundColor: const Color(0xFF1F2937),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar.dashboard(
        notificationCount: 5,
      ),
      drawer: const DrawerWidget(),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1F2937).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showAddAgentScreen,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(
            Icons.person_add,
            color: Colors.white,
            size: 24,
          ),
          label: Text(
            'Add Agent',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
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
                          'Agent Management',
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

            // Agents List
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: _agents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.all(Radius.circular(50)),
                              ),
                              child: const Icon(
                                Icons.people_outline,
                                size: 60,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No agents added yet',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first agent to get started',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _agents.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final agent = _agents[index];
                          return ListItemAnimation(
                            delay: ListItemAnimationConfig.getDelayForIndex(index),
                            child: AgentCard(
                            agent: agent,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AgentDetailUi(
                                    name: agent.name,
                                    status: agent.status,
                                    company: agent.company,
                                    photoUrl: agent.photoUrl,
                                    mobile: agent.mobile,
                                    altMobile: agent.altMobile,
                                    email: agent.email,
                                    address: agent.address,
                                  ),
                                ),
                              );
                            },
                            onEdit: () {
                              // TODO: Implement edit functionality
                            },
                          ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
