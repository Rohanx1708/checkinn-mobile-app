import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/room_models.dart';
import '../services/rooms_service.dart';
import '../widgets/room_card.dart';
import '../widgets/add_room_sheet.dart';
import '../widgets/add_room_type_sheet.dart';
import '../widgets/empty_state.dart';
import '../ui/rooms.dart';
import '../../../widgets/common_app_bar.dart';
import '../../Dashboard/widget/drawer_widget.dart';
import '../../../utils/routes.dart';

class RoomManagementUi extends StatefulWidget {
  const RoomManagementUi({super.key});

  @override
  State<RoomManagementUi> createState() => _RoomManagementUiState();
}

class _RoomManagementUiState extends State<RoomManagementUi> {
  List<RoomEntity> _rooms = [];
  List<RoomType> _roomTypes = [];
  bool _isLoading = true;

  // Helper method to parse image URLs from API response
  List<String> _parseImageUrls(dynamic imageData) {
    print('🔍 Parsing image data: $imageData');
    if (imageData == null) {
      print('🔍 Image data is null, returning empty list');
      return [];
    }
    
    if (imageData is List) {
      final urls = imageData.map((url) => _convertImageUrl(url.toString())).toList();
      print('🔍 Parsed image URLs: $urls');
      return urls;
    }
    
    print('🔍 Image data is not a list, returning empty list');
    return [];
  }

  // Helper method to convert localhost URLs to proper domain
  String _convertImageUrl(String url) {
    if (url.startsWith('http://localhost')) {
      final convertedUrl = url.replaceFirst('http://localhost', 'https://checkinn.club');
      print('🔍 Converted URL: $url -> $convertedUrl');
      return convertedUrl;
    }
    return url;
  }
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load room types (which seems to contain the actual room data)
      final roomTypesResult = await RoomsService.getRoomTypes(page: 1, limit: 50);

      if (roomTypesResult['success']) {
        List<RoomEntity> rooms = [];
        List<RoomType> roomTypes = [];

        // Parse room types data - this seems to contain the actual room/accommodation data
        final roomTypesData = roomTypesResult['data'];
        print('🔍 Room Types API Response: $roomTypesData');
        if (roomTypesData['data'] != null) {
          for (var roomData in roomTypesData['data']) {
            print('🔍 Room Data: $roomData');
            print('🔍 Room Images: ${roomData['images']}');
            print('🔍 Room Photos: ${roomData['photos']}');
            try {
              // Convert accommodation data to RoomEntity
              final room = RoomEntity(
                id: roomData['id'].toString(),
                name: roomData['name'] ?? '',
                roomType: roomData['accommodation_type'] ?? '',
                description: roomData['description'] ?? '',
                price: (roomData['base_price'] ?? 0.0).toDouble(),
                floor: roomData['floor'] ?? 1,
                roomNumber: roomData['room_number'] ?? 1,
                amenities: _extractAmenities(roomData['amenities']),
                imageUrls: _parseImageUrls(roomData['images'] ?? roomData['photos'] ?? []).isNotEmpty 
                    ? _parseImageUrls(roomData['images'] ?? roomData['photos'] ?? [])
                    : null,
                photos: [], // No photos in current response
                status: RoomStatus.available, // Default status
                createdAt: DateTime.tryParse(roomData['created_at'] ?? '') ?? DateTime.now(),
                updatedAt: DateTime.tryParse(roomData['updated_at'] ?? ''),
              );
              rooms.add(room);
              
              // Also create room type from the same data
              final roomType = RoomType(
                id: roomData['id'].toString(),
                name: roomData['name'] ?? '',
                description: roomData['description'] ?? '',
                amenities: _extractAmenities(roomData['amenities']).join(', '),
                basePrice: (roomData['base_price'] ?? 0.0).toDouble(),
                capacity: roomData['max_occupancy'] ?? 1,
                imageUrls: _parseImageUrls(roomData['images'] ?? roomData['photos'] ?? []).isNotEmpty 
                    ? _parseImageUrls(roomData['images'] ?? roomData['photos'] ?? [])
                    : null,
                status: roomData['is_active'] == true ? RoomTypeStatus.active : RoomTypeStatus.inactive,
                createdAt: DateTime.tryParse(roomData['created_at'] ?? '') ?? DateTime.now(),
                updatedAt: DateTime.tryParse(roomData['updated_at'] ?? ''),
              );
              roomTypes.add(roomType);
            } catch (e) {
              // Skip invalid room/accommodation data
            }
          }
        }

        setState(() {
          _rooms = rooms;
          _roomTypes = roomTypes;
          _isLoading = false;
        });

      } else {
        setState(() {
          _errorMessage = roomTypesResult['message'] ?? 'Failed to load data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<String> _extractAmenities(dynamic amenities) {
    try {
      if (amenities == null) return [];
      if (amenities is List) {
        if (amenities.isEmpty) return [];
        if (amenities.first is String) {
          return amenities
              .map((e) => e.toString())
              .where((e) => e.trim().isNotEmpty)
              .cast<String>()
              .toList();
        }
        if (amenities.first is Map) {
          return amenities
              .map((e) => (e['name'] ?? e['label'] ?? e['title'] ?? '').toString())
              .where((e) => e.trim().isNotEmpty)
              .cast<String>()
              .toList();
        }
      }
      if (amenities is String) {
        return amenities
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  void _onAddRoom() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AddRoomSheet(
            roomTypes: _roomTypes,
            onRoomAdded: _addRoom,
          ),
    );
  }

  Future<void> _addRoom(RoomEntity room) async {
    try {
      final result = await RoomsService.createRoom(
        name: room.name,
        roomType: room.roomType,
        description: room.description,
        price: room.price,
        floor: room.floor,
        roomNumber: room.roomNumber,
        propertyId: 1, // Default property ID - should be dynamic
        status: room.status.name,
        amenities: room.amenities,
      );

      if (result['success']) {
        // Refresh the rooms list
        await _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to add room'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding room: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onAddRoomType() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddRoomTypeSheet(
          onRoomTypeAdded: (roomType) {
            // This won't be called anymore since we're using Navigator.pop(true)
          },
        ),
      ),
    );
    
    // If room type was created successfully, refresh the data
    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final double screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar.dashboard(),
      drawer: const DrawerWidget(),
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
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Room Management',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Rooms List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F2937)),
                        ),
                      )
                    : _errorMessage != null
                        ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Failed to load rooms',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _errorMessage!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _refreshData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6366F1),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : _rooms.isEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                                child: EmptyState(
                                  title: 'No Rooms Added Yet',
                                  subtitle: 'Add your first room to get started',
                                  icon: Icons.hotel,
                                  onActionPressed: _onAddRoom,
                                  actionText: 'Add Room',
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                                itemCount: _rooms.length,
                                itemBuilder: (context, index) {
                                  final room = _rooms[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: RoomCard(
                                      room: room,
                                      onViewPressed: () {
                                        // Navigate to rooms screen
                                        Navigator.push(
                                          context,
                          MaterialPageRoute(
                            builder: (context) => RoomTypesUi(
                              categoryName: room.roomType,
                              rooms: _rooms.where((r) => r.roomType == room.roomType).toList(),
                            ),
                          ),
                        );
                      },
                      onEdited: (updated) {
                        // If this is a refresh signal, reload all data
                        if (updated.id == room.id) {
                          _loadData(); // Refresh all data to get updated images
                        } else {
                          setState(() {
                            final idx = _rooms.indexWhere((r) => r.id == updated.id);
                            if (idx != -1) _rooms[idx] = updated;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddRoomType,
        backgroundColor: const Color(0xFF6366F1),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Room Type',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
