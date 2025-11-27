import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/room_model.dart';

class FilterSheet extends StatefulWidget {
  final String statusFilter;
  final String buildingFilter;
  final String typeFilter;
  final List<Room> rooms;
  final Function(String, String, String) onApplyFilters;

  const FilterSheet({
    super.key,
    required this.statusFilter,
    required this.buildingFilter,
    required this.typeFilter,
    required this.rooms,
    required this.onApplyFilters,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String tempStatus;
  late String tempBuilding;
  late String tempType;

  @override
  void initState() {
    super.initState();
    tempStatus = widget.statusFilter;
    tempBuilding = widget.buildingFilter;
    tempType = widget.typeFilter;
  }

  Widget _buildFilterField({
    required String label,
    required IconData icon,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFF6366F1),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              items: items,
              onChanged: onChanged,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: const Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
              ),
              icon: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF6366F1),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with drag indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title with icon
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
                      Icons.filter_list,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filter Rooms',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Status Filter
              _buildFilterField(
                label: 'Room Status',
                icon: Icons.cleaning_services,
                value: tempStatus,
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All Statuses')),
                  DropdownMenuItem(value: 'Clean', child: Text('Clean')),
                  DropdownMenuItem(value: 'Dirty', child: Text('Dirty')),
                  DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'Out of Order', child: Text('Out of Order')),
                ],
                onChanged: (value) => setState(() => tempStatus = value!),
              ),
              
              const SizedBox(height: 16),
              
              // Building Filter
              _buildFilterField(
                label: 'Building',
                icon: Icons.business,
                value: tempBuilding,
                items: [
                  const DropdownMenuItem(value: 'All', child: Text('All Buildings')),
                  ...widget.rooms.map((room) => room.building).toSet().map((building) =>
                    DropdownMenuItem(value: building, child: Text(building)),
                  ),
                ],
                onChanged: (value) => setState(() => tempBuilding = value!),
              ),
              
              const SizedBox(height: 16),
              
              // Type Filter
              _buildFilterField(
                label: 'Room Type',
                icon: Icons.king_bed,
                value: tempType,
                items: [
                  const DropdownMenuItem(value: 'All', child: Text('All Types')),
                  ...widget.rooms.map((room) => room.type).toSet().map((type) =>
                    DropdownMenuItem(value: type, child: Text(type)),
                  ),
                ],
                onChanged: (value) => setState(() => tempType = value!),
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            tempStatus = 'All';
                            tempBuilding = 'All';
                            tempType = 'All';
                          });
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Reset All',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onApplyFilters(tempStatus, tempBuilding, tempType);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Apply Filters',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
