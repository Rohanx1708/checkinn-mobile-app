import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/amenity_model.dart';
import '../widgets/amenity_card.dart';
import '../widgets/add_amenity_sheet.dart';
import '../widgets/amenity_type_toggle.dart';

class AmenitiesUi extends StatefulWidget {
  const AmenitiesUi({super.key});

  @override
  State<AmenitiesUi> createState() => _AmenitiesUiState();
}

class _AmenitiesUiState extends State<AmenitiesUi> {
  String selectedType = AmenityType.room; // Default selected
  final List<Amenity> _roomAmenities = [];
  final List<Amenity> _propertyAmenities = [];

  @override
  void initState() {
    super.initState();
    // Initialize with default amenities
    _roomAmenities.addAll(AmenityHelper.getDefaultRoomAmenities());
    _propertyAmenities.addAll(AmenityHelper.getDefaultPropertyAmenities());
  }

  void _showAddAmenityBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddAmenitySheet(
        selectedType: selectedType,
        onSave: _saveAmenity,
      ),
    );
  }

  void _saveAmenity(IconData icon, String name, String description, int colorIndex) {
    // Assign a random color index for new amenities
    final actualColorIndex = (selectedType == AmenityType.room ? _roomAmenities.length : _propertyAmenities.length) % AmenityHelper.amenityColors.length;

    final newAmenity = Amenity(
      icon: icon,
      label: name,
      description: description,
      colorIndex: actualColorIndex,
    );

    setState(() {
      if (selectedType == AmenityType.room) {
        _roomAmenities.add(newAmenity);
      } else {
        _propertyAmenities.add(newAmenity);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedType} amenity added successfully: $name'),
        backgroundColor: const Color(0xFF22C55E),
      ),
    );
  }

  void _deleteAmenity(Amenity amenity) {
    setState(() {
      if (selectedType == AmenityType.room) {
        _roomAmenities.remove(amenity);
      } else {
        _propertyAmenities.remove(amenity);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedType} amenity deleted: ${amenity.label}'),
        backgroundColor: const Color(0xFFEF4444),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              if (selectedType == AmenityType.room) {
                _roomAmenities.add(amenity);
              } else {
                _propertyAmenities.add(amenity);
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${selectedType} amenity restored: ${amenity.label}'),
                backgroundColor: const Color(0xFF22C55E),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amenities = selectedType == AmenityType.room ? _roomAmenities : _propertyAmenities;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

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
            icon: const Icon(Icons.arrow_back, color: Color(0xFF6366F1)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        centerTitle: true,
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'CHECK',
                style: GoogleFonts.inter(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              TextSpan(
                text: 'INN',
                style: GoogleFonts.inter(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                  background: Paint()
                    ..shader = LinearGradient(
                      colors: [
                        const Color(0xFF6366F1),
                        const Color(0xFF8B5CF6),
                      ],
                    ).createShader(const Rect.fromLTWH(0, 0, 100, 70)),
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
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
          onPressed: _showAddAmenityBottomSheet,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(
            Icons.add,
            color: Colors.white,
            size: 24,
          ),
          label: Text(
            'Add ${selectedType} Amenity',
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle between Room and Property
              AmenityTypeToggle(
                selectedType: selectedType,
                onTypeChanged: (type) => setState(() => selectedType = type),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Section title
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF22C55E),
                            const Color(0xFF16A34A),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.list,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${selectedType} Amenities (${amenities.length})',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Amenities Grid
              Expanded(
                child: amenities.isEmpty
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
                              child: Icon(
                                selectedType == AmenityType.room ? Icons.hotel_outlined : Icons.business_outlined,
                                size: 60,
                                color: const Color(0xFF6366F1),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No ${selectedType.toLowerCase()} amenities yet',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first ${selectedType.toLowerCase()} amenity',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: amenities.length,
                        itemBuilder: (context, index) {
                          final amenity = amenities[index];
                          return AmenityCard(
                            amenity: amenity,
                            amenityColors: AmenityHelper.amenityColors,
                            onTap: () {
                              // TODO: Show amenity details or edit
                            },
                            onDelete: () => _deleteAmenity(amenity),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
