import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/room_models.dart';

class RoomStats extends StatelessWidget {
  final List<RoomEntity> rooms;
  final List<RoomType> roomTypes;

  const RoomStats({
    super.key,
    required this.rooms,
    required this.roomTypes,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Calculate statistics
    final totalRooms = rooms.length;
    final availableRooms = rooms.where((r) => r.status == RoomStatus.available).length;
    final occupiedRooms = rooms.where((r) => r.status == RoomStatus.occupied).length;
    final maintenanceRooms = rooms.where((r) => r.status == RoomStatus.maintenance).length;
    final totalRevenue = rooms.fold<double>(0, (sum, r) => sum + r.price);
    final averagePrice = rooms.isNotEmpty ? totalRevenue / rooms.length : 0.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 16),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Room Statistics',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'Total Rooms',
                totalRooms.toString(),
                Icons.hotel,
                const Color(0xFF6366F1),
              ),
              _buildStatCard(
                'Available',
                availableRooms.toString(),
                Icons.check_circle,
                Colors.green,
              ),
              _buildStatCard(
                'Occupied',
                occupiedRooms.toString(),
                Icons.person,
                Colors.red,
              ),
              _buildStatCard(
                'Maintenance',
                maintenanceRooms.toString(),
                Icons.build,
                Colors.orange,
              ),
              _buildStatCard(
                'Room Types',
                roomTypes.length.toString(),
                Icons.category,
                const Color(0xFF8B5CF6),
              ),
              _buildStatCard(
                'Avg Price',
                '\$${averagePrice.toStringAsFixed(0)}',
                Icons.attach_money,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
