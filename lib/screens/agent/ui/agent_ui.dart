import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/common_app_bar.dart';
import '../models/agent_model.dart';
import '../widgets/agent_card.dart';
import '../widgets/add_agent_sheet.dart';
import 'agent_detail_ui.dart';
import '../../Dashboard/widget/drawer_widget.dart';

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

  void _showAddAgentBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddAgentSheet(
        onSave: _saveAgent,
      ),
    );
  }

  void _saveAgent(String name, String status, String company, String mobile, String altMobile, String email, String address) {
    final newAgent = Agent(
      name: name,
      status: status,
      company: company,
      photoUrl: "https://via.placeholder.com/150",
      mobile: mobile,
      altMobile: altMobile,
      email: email,
      address: address,
    );

    setState(() {
      _agents.add(newAgent);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Agent added successfully: $name'),
        backgroundColor: const Color(0xFF22C55E),
      ),
    );
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
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6366F1),
              const Color(0xFF8B5CF6),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showAddAgentBottomSheet,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(
            Icons.person_add,
            color: Colors.white,
            size: 24,
          ),
          label: Text(
            'Add Agent',
            style: GoogleFonts.poppins(
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
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
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
                    child: const Icon(Icons.people, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Agent Management',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          height: 3,
                          width: 110,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Manage your travel agents and partners',
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
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Icon(
                                Icons.people_outline,
                                size: 60,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No agents added yet',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first agent to get started',
                              style: GoogleFonts.poppins(
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
                          return AgentCard(
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
