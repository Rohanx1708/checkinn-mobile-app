import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/property_models.dart';

class FilterSheet extends StatefulWidget {
  final PropertyType? selectedType;
  final PropertyStatus? selectedStatus;
  final double? minPrice;
  final double? maxPrice;
  final int? minCapacity;
  final Function(PropertyType?) onTypeChanged;
  final Function(PropertyStatus?) onStatusChanged;
  final Function(double?) onMinPriceChanged;
  final Function(double?) onMaxPriceChanged;
  final Function(int?) onMinCapacityChanged;
  final VoidCallback onApplyFilters;
  final VoidCallback onClearFilters;

  const FilterSheet({
    super.key,
    this.selectedType,
    this.selectedStatus,
    this.minPrice,
    this.maxPrice,
    this.minCapacity,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onMinPriceChanged,
    required this.onMaxPriceChanged,
    required this.onMinCapacityChanged,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late PropertyType? _selectedType;
  late PropertyStatus? _selectedStatus;
  late double? _minPrice;
  late double? _maxPrice;
  late int? _minCapacity;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _selectedStatus = widget.selectedStatus;
    _minPrice = widget.minPrice;
    _maxPrice = widget.maxPrice;
    _minCapacity = widget.minCapacity;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.filter_list,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Filter Properties',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedType = null;
                      _selectedStatus = null;
                      _minPrice = null;
                      _maxPrice = null;
                      _minCapacity = null;
                    });
                    widget.onClearFilters();
                  },
                  child: Text(
                    'Clear',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Type
                  _buildSectionTitle('Property Type'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: PropertyType.values.map((type) {
                      final isSelected = _selectedType == type;
                      return FilterChip(
                        label: Text(
                          PropertyHelper.getTypeLabel(type),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = selected ? type : null;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF6366F1).withOpacity(0.1),
                        checkmarkColor: const Color(0xFF6366F1),
                        side: BorderSide(
                          color: isSelected 
                              ? const Color(0xFF6366F1) 
                              : Colors.grey.shade300,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Property Status
                  _buildSectionTitle('Property Status'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: PropertyStatus.values.map((status) {
                      final isSelected = _selectedStatus == status;
                      return FilterChip(
                        label: Text(
                          PropertyHelper.getStatusLabel(status),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = selected ? status : null;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: const Color(0xFF6366F1).withOpacity(0.1),
                        checkmarkColor: const Color(0xFF6366F1),
                        side: BorderSide(
                          color: isSelected 
                              ? const Color(0xFF6366F1) 
                              : Colors.grey.shade300,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Price Range
                  _buildSectionTitle('Price Range'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Min Price',
                          _minPrice?.toString() ?? '',
                          (value) {
                            setState(() {
                              _minPrice = double.tryParse(value);
                            });
                          },
                          prefix: '\$',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          'Max Price',
                          _maxPrice?.toString() ?? '',
                          (value) {
                            setState(() {
                              _maxPrice = double.tryParse(value);
                            });
                          },
                          prefix: '\$',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Capacity
                  _buildSectionTitle('Minimum Capacity'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    'Capacity',
                    _minCapacity?.toString() ?? '',
                    (value) {
                      setState(() {
                        _minCapacity = int.tryParse(value);
                      });
                    },
                    suffix: 'guests',
                  ),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6366F1),
                    const Color(0xFF8B5CF6),
                  ],
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    widget.onTypeChanged(_selectedType);
                    widget.onStatusChanged(_selectedStatus);
                    widget.onMinPriceChanged(_minPrice);
                    widget.onMaxPriceChanged(_maxPrice);
                    widget.onMinCapacityChanged(_minCapacity);
                    widget.onApplyFilters();
                    Navigator.of(context).pop();
                  },
                  child: Center(
                    child: Text(
                      'Apply Filters',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    Function(String) onChanged, {
    String? prefix,
    String? suffix,
  }) {
    return TextField(
      controller: TextEditingController(text: value),
      onChanged: onChanged,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: const Color(0xFF6B7280),
          fontSize: 14,
        ),
        prefixText: prefix,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
