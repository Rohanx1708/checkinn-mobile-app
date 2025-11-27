import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/property_models.dart';

class SearchFilterSection extends StatelessWidget {
  final String searchQuery;
  final PropertyType? selectedType;
  final PropertyStatus? selectedStatus;
  final Function(String) onSearchChanged;
  final Function(PropertyType?) onTypeChanged;
  final Function(PropertyStatus?) onStatusChanged;
  final VoidCallback onFilterPressed;

  const SearchFilterSection({
    super.key,
    required this.searchQuery,
    this.selectedType,
    this.selectedStatus,
    required this.onSearchChanged,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 16),
      child: Column(
        children: [
          // Search bar
          Container(
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
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search properties...',
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 16,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF6366F1),
                  size: 24,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Filter chips
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Type filter chips
                      ...PropertyType.values.map((type) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            PropertyHelper.getTypeLabel(type),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: selectedType == type,
                          onSelected: (selected) {
                            onTypeChanged(selected ? type : null);
                          },
                          backgroundColor: Colors.white,
                          selectedColor: const Color(0xFF6366F1).withOpacity(0.1),
                          checkmarkColor: const Color(0xFF6366F1),
                          side: BorderSide(
                            color: selectedType == type 
                                ? const Color(0xFF6366F1) 
                                : Colors.grey.shade300,
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              
              // Filter button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: onFilterPressed,
                  icon: const Icon(
                    Icons.filter_list,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FilterChip extends StatelessWidget {
  final Widget label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? checkmarkColor;
  final BorderSide? side;

  const FilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
    this.backgroundColor,
    this.selectedColor,
    this.checkmarkColor,
    this.side,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected?.call(!selected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? selectedColor : backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: side != null ? Border.all(color: side!.color, width: side!.width) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            label,
            if (selected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check,
                size: 16,
                color: checkmarkColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
