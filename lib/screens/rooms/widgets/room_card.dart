import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/room_models.dart';
import '../ui/edit_room_type.dart';
import '../../../services/auth_service.dart';

class RoomCard extends StatefulWidget {
  final RoomEntity room;
  final VoidCallback? onViewPressed;
  final ValueChanged<RoomEntity>? onEdited;

  const RoomCard({
    super.key,
    required this.room,
    this.onViewPressed,
    this.onEdited,
  });

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextImage() {
    final roomImages = _getRoomImages();
    if (roomImages.isEmpty) return; // No images to navigate
    
    if (_currentImageIndex < roomImages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousImage() {
    final roomImages = _getRoomImages();
    if (roomImages.isEmpty) return; // No images to navigate
    
    if (_currentImageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _pageController.animateToPage(
        roomImages.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<dynamic> _getRoomImages() {
    print('🔍 RoomCard - Room ID: ${widget.room.id}');
    print('🔍 RoomCard - Image URLs: ${widget.room.imageUrls}');
    print('🔍 RoomCard - Photos: ${widget.room.photos}');
    
    // Only return actual uploaded images, no fallback colors
    if (widget.room.imageUrls != null && widget.room.imageUrls!.isNotEmpty) {
      print('🔍 RoomCard - Returning image URLs: ${widget.room.imageUrls}');
      return widget.room.imageUrls!;
    }
    
    print('🔍 RoomCard - No image URLs, returning empty list');
    // Return empty list if no images are uploaded
    return [];
  }

  Future<String?> _getAuthToken() async {
    return await AuthService.getToken();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final List<dynamic> roomImages = _getRoomImages();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image carousel section
          Stack(
            children: [
              Container(
                height: screenWidth * 0.5,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemCount: roomImages.isNotEmpty ? roomImages.length : 1,
                    itemBuilder: (context, index) {
                      // If no images are uploaded, show placeholder
                      if (roomImages.isEmpty) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No images uploaded',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      final imageData = roomImages[index];
                      
                      // Display actual uploaded image
                      print('🔍 RoomCard - Loading image: $imageData');
                      return FutureBuilder<String?>(
                        future: _getAuthToken(),
                        builder: (context, tokenSnapshot) {
                          return Image.network(
                            imageData as String,
                            fit: BoxFit.cover,
                            headers: tokenSnapshot.hasData && tokenSnapshot.data != null
                                ? {'Authorization': 'Bearer ${tokenSnapshot.data}'}
                                : {},
                            loadingBuilder: (context, child, loadingProgress) {
                              print('🔍 RoomCard - Image loading progress: $loadingProgress');
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print('🔍 RoomCard - Image load error: $error');
                              print('🔍 RoomCard - Image URL: $imageData');
                              return Container(
                                color: Colors.grey[100],
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Failed to load image',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              
              // Edit button positioned at top right
              Positioned(
                top: 16,
                right: 16,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditRoomType(room: widget.room),
                        ),
                      );
                      if (result == 'refresh') {
                        // Trigger refresh in parent
                        if (widget.onEdited != null) {
                          widget.onEdited!(widget.room); // Pass current room to trigger refresh
                        }
                      } else if (result != null && widget.onEdited != null) {
                        widget.onEdited!(result as RoomEntity);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.edit,
                        color: const Color(0xFF1F2937),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Price badge (moved from room type badge position)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF22C55E),
                        const Color(0xFF16A34A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '\$${widget.room.price.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // Navigation arrows
              // Left navigation arrow (only show if there are images)
              if (roomImages.isNotEmpty)
                Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _previousImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Color(0xFF6366F1),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),

              // Right navigation arrow (only show if there are images)
              if (roomImages.isNotEmpty)
                Positioned(
                  right: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _nextImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF6366F1),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),

              // Dot indicators (only show if there are images)
              if (roomImages.isNotEmpty)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      roomImages.length,
                      (index) => GestureDetector(
                        onTap: () {
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentImageIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // Content section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.room.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.room.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                
                // Amenities section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFF8FAFC),
                        const Color(0xFFF1F5F9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: widget.room.amenities.isNotEmpty
                      ? Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _buildAmenityIconsFromApi(widget.room.amenities),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildAmenityIcon(Icons.tv, 'TV'),
                            _buildAmenityIcon(Icons.ac_unit, 'AC'),
                            _buildAmenityIcon(Icons.wifi, 'WiFi'),
                            _buildAmenityIcon(Icons.local_bar, 'Mini Bar'),
                          ],
                        ),
                ),
                const SizedBox(height: 10),
                
                // View button
                Container(
                  width: double.infinity,
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
                      onTap: widget.onViewPressed,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.visibility,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'View Rooms',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  List<Widget> _buildAmenityIconsFromApi(List<String> amenities) {
    final Map<String, IconData> iconMap = {
      'wifi': Icons.wifi,
      'wi-fi': Icons.wifi,
      'internet': Icons.wifi,
      'ac': Icons.ac_unit,
      'air conditioning': Icons.ac_unit,
      'air-conditioner': Icons.ac_unit,
      'tv': Icons.tv,
      'television': Icons.tv,
      'mini bar': Icons.local_bar,
      'minibar': Icons.local_bar,
      'bar': Icons.local_bar,
      'parking': Icons.local_parking,
      'car parking': Icons.local_parking,
      'pool': Icons.pool,
      'swimming pool': Icons.pool,
      'restaurant': Icons.restaurant,
      'breakfast': Icons.free_breakfast,
      'gym': Icons.fitness_center,
      'fitness': Icons.fitness_center,
      'spa': Icons.spa,
      'heater': Icons.fireplace,
      'heating': Icons.fireplace,
      'hot water': Icons.water_drop,
      'water': Icons.water_drop,
      'laundry': Icons.local_laundry_service,
      'room service': Icons.room_service,
      'conference': Icons.meeting_room,
      'meeting room': Icons.meeting_room,
      'lift': Icons.elevator,
      'elevator': Icons.elevator,
      'pet friendly': Icons.pets,
      'balcony': Icons.balcony,
      'garden': Icons.park,
      'bbq': Icons.outdoor_grill,
      'fireplace': Icons.fireplace,
      'campfire': Icons.local_fire_department,
      'hiking': Icons.hiking,
      'adventure': Icons.terrain,
      'wildlife': Icons.eco,
      'toiletries': Icons.sanitizer,
      'towels': Icons.dry_cleaning,
      'private bathroom': Icons.bathroom,
      'shower': Icons.shower,
      'desk': Icons.desk,
      'coffee': Icons.coffee,
      'tea': Icons.coffee,
      'safe': Icons.lock,
      'hair dryer': Icons.blender,
    };

    final normalized = amenities
        .map((a) => a.toString().trim())
        .where((a) => a.isNotEmpty)
        .toList();

    // Limit to avoid overflow (show up to 5)
    final limited = normalized.take(5).toList();

    return limited.map((label) {
      final key = label.toLowerCase();
      final icon = iconMap.entries.firstWhere(
        (e) => key.contains(e.key),
        orElse: () => const MapEntry<String, IconData>('', Icons.check_circle_outline),
      ).value;
      // Replace underscores with spaces for better display
      final displayLabel = label.replaceAll('_', ' ');
      return _buildAmenityIcon(icon, displayLabel);
    }).toList();
  }
}
