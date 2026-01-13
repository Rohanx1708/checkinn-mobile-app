import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
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
    // Only return actual uploaded images, no fallback colors
    if (widget.room.imageUrls != null && widget.room.imageUrls!.isNotEmpty) {
      return widget.room.imageUrls!;
    }
    
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
    final String formattedPrice = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(widget.room.price);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
          color: const Color(0xFFE5E7EB), // light grey border
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
                      
                      // Display actual uploaded image with caching
                      return FutureBuilder<String?>(
                        future: _getAuthToken(),
                        builder: (context, tokenSnapshot) {
                          final imageUrl = imageData as String;
                          final headers = tokenSnapshot.hasData && tokenSnapshot.data != null
                              ? {'Authorization': 'Bearer ${tokenSnapshot.data}'}
                              : <String, String>{};
                          
                          return CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            httpHeaders: headers,
                            placeholder: (context, url) => Container(
                              color: const Color(0xFFF3F4F6),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFFF3F4F6),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 40,
                                      color: Color(0xFF6B7280),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Failed to load image',
                                      style: TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.room.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$formattedPrice / night',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.room.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 10),
                
                // Amenities section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
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
                
                // View & Edit buttons row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1F2937).withOpacity(0.3),
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
                              padding: const EdgeInsets.symmetric(vertical: 10),
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
                                    style: GoogleFonts.inter(
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
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF1F2937),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1F2937).withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final roomImages = _getRoomImages();
                              for (final imageData in roomImages) {
                                if (imageData is String) {
                                  final token = await _getAuthToken();
                                  final headers = token != null
                                      ? {'Authorization': 'Bearer $token'}
                                      : <String, String>{};
                                  precacheImage(
                                    CachedNetworkImageProvider(imageData, headers: headers),
                                    context,
                                  );
                                }
                              }

                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EditRoomType(room: widget.room),
                                ),
                              );
                              if (result == 'refresh') {
                                if (widget.onEdited != null) {
                                  widget.onEdited!(widget.room);
                                }
                              } else if (result != null && widget.onEdited != null) {
                                widget.onEdited!(result as RoomEntity);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.edit,
                                    color: Color(0xFF1F2937),
                                    size: 12,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Edit',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1F2937),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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
            color: const Color(0xFF1F2937).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
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
