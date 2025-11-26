import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FiltersModal extends StatefulWidget {
  final Function(String?, String?) onApplyFilters;
  final String? currentStatus;
  final String? currentDateFilter;
  
  const FiltersModal({
    super.key,
    required this.onApplyFilters,
    this.currentStatus,
    this.currentDateFilter,
  });

  @override
  State<FiltersModal> createState() => _FiltersModalState();
}

class _FiltersModalState extends State<FiltersModal> {
  String? selectedStatus;
  String? selectedDateFilter;
  DateTime? selectedCheckInDate;
  DateTime? selectedCheckOutDate;

  final List<String> statusOptions = [
    "All Statuses",
    "Pending",
    "Confirmed", 
    "Checked In",
    "Checked Out",
    "Cancelled"
  ];
  
  final List<String> dateFilterOptions = [
    "All Dates",
    "Today",
    "Tomorrow", 
    "This Week",
    "This Month",
    "Upcoming"
  ];


  @override
  void initState() {
    super.initState();
    // Initialize with current filter values or defaults
    selectedStatus = widget.currentStatus ?? "All Statuses";
    selectedDateFilter = widget.currentDateFilter ?? "All Dates";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Filter Bookings',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Apply filters to find specific bookings',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

          _buildFilterField(
            label: "Booking Status",
            value: selectedStatus,
            items: statusOptions,
            onChanged: (value) => setState(() => selectedStatus = value),
            icon: Icons.flag,
          ),
          const SizedBox(height: 16),

          _buildFilterField(
            label: "Date Filter",
            value: selectedDateFilter,
            items: dateFilterOptions,
            onChanged: (value) => setState(() => selectedDateFilter = value),
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: 16),



          const SizedBox(height: 32),

          // Clear filters button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  selectedStatus = "All Statuses";
                  selectedDateFilter = "All Dates";
                });
              },
              icon: const Icon(Icons.clear_all, color: Color(0xFF6366F1)),
              label: Text(
                'Clear All Filters',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6366F1),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF6366F1)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onApplyFilters(
                  selectedStatus, 
                  selectedDateFilter,
                );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.search, color: Colors.white),
              label: Text(
                "Apply Filters",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildFilterField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(
                  icon,
                  color: const Color(0xFF6366F1),
                  size: 20,
                ),
              ),
              Expanded(
                                 child: DropdownButton<String>(
                   value: value,
                   items: items.map((String item) {
                     return DropdownMenuItem<String>(
                       value: item,
                       child: Text(
                         item,
                         style: GoogleFonts.poppins(
                           fontSize: 14,
                           color: Colors.black,
                         ),
                       ),
                     );
                   }).toList(),
                   onChanged: onChanged,
                   style: GoogleFonts.poppins(
                     fontSize: 14,
                     color: Colors.black,
                   ),
                   dropdownColor: Colors.white,
                   icon: const Icon(
                     Icons.keyboard_arrow_down,
                     color: Color(0xFF6366F1),
                   ),
                   isExpanded: true,
                   underline: Container(),
                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                 ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}
