import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:checkinn/widgets/checkinn_logo.dart';
import '../models/room_model.dart';
import '../widgets/room_card.dart';
import '../widgets/status_tile.dart';
import '../widgets/search_filter_section.dart';
import '../widgets/housekeeping_header.dart';
import '../widgets/room_management_section.dart';
import '../widgets/status_action_sheet.dart';
import '../widgets/filter_sheet.dart';

class HousekeepingUi extends StatefulWidget {
  const HousekeepingUi({super.key});

  @override
  State<HousekeepingUi> createState() => _HousekeepingUiState();
}

class _HousekeepingUiState extends State<HousekeepingUi> {
  final List<Room> _rooms = [];
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All';
  String _buildingFilter = 'All';
  String _typeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _rooms.addAll(RoomHelper.getDefaultRooms());
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Room> get _filteredRooms {
    return RoomHelper.filterRooms(
      _rooms,
      _searchController.text,
      _statusFilter,
      _buildingFilter,
      _typeFilter,
    );
  }

  void _showStatusActionSheet(Room room) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatusActionSheet(
        room: room,
        onStatusUpdate: _updateRoomStatus,
      ),
    );
  }

  void _updateRoomStatus(Room room, String status) {
    Navigator.of(context).pop();
    setState(() {
      room.status = status;
      if (status == 'clean') {
        room.lastCleaned = DateTime.now();
      }
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => FilterSheet(
        statusFilter: _statusFilter,
        buildingFilter: _buildingFilter,
        typeFilter: _typeFilter,
        rooms: _rooms,
        onApplyFilters: _applyFilters,
      ),
    );
  }

  void _applyFilters(String status, String building, String type) {
    setState(() {
      _statusFilter = status;
      _buildingFilter = building;
      _typeFilter = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final int cleanCount = RoomHelper.countByStatus(_rooms, 'clean');
    final int dirtyCount = RoomHelper.countByStatus(_rooms, 'dirty');
    final int inProgressCount = RoomHelper.countByStatus(_rooms, 'in_progress');
    final int outOfOrderCount = RoomHelper.countByStatus(_rooms, 'out_of_order');
    final int totalRooms = _rooms.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        centerTitle: true,
        title: CheckInnLogo(
          iconSize: 32,
          fontSize: screenWidth * 0.045,
          textColor: const Color(0xFF6B7280),
          alignment: MainAxisAlignment.center,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),
                
                // Header section
                const HousekeepingHeader(),
                
                SizedBox(height: screenHeight * 0.03),

                // Housekeeping Overview Tiles in 2x2 grid
                Row(
                  children: [
                    Expanded(
                      child: StatusTile(
                        title: 'Clean',
                        count: '$cleanCount',
                        description: 'Rooms clean',
                        icon: Icons.check_circle,
                        color: const Color(0xFF22C55E),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatusTile(
                        title: 'Dirty',
                        count: '$dirtyCount',
                        description: 'Rooms dirty',
                        icon: Icons.cancel,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: StatusTile(
                        title: 'In Progress',
                        count: '$inProgressCount',
                        description: 'Rooms in progress',
                        icon: Icons.access_time,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatusTile(
                        title: 'Out of Order',
                        count: '$outOfOrderCount',
                        description: 'Rooms out of order',
                        icon: Icons.bed,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                
                // 5th tile centered
                Center(
                  child: SizedBox(
                    width: screenWidth * 0.5,
                    child: StatusTile(
                      title: 'Total Rooms',
                      count: '$totalRooms',
                      description: 'Total rooms in system',
                      icon: Icons.business,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                
                SizedBox(height: screenHeight * 0.04),

                // Rooms section
                const RoomManagementSection(),
                
                SizedBox(height: screenHeight * 0.02),

                // Search bar and Filter button
                SearchFilterSection(
                  searchController: _searchController,
                  onFilterTap: _showFilterSheet,
                ),
                SizedBox(height: screenHeight * 0.02),

                // Room List
                ..._filteredRooms.map((room) => Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                  child: RoomCard(
                    room: room,
                    onTap: () => _showStatusActionSheet(room),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
