import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/common_app_bar.dart';
import '../models/room_models.dart';
import '../services/rooms_service.dart';
import '../widgets/empty_state.dart';
import 'add_room_screen.dart';

class RoomTypesUi extends StatefulWidget {
  final String categoryName;
  final List<RoomEntity> rooms;

  const RoomTypesUi({super.key, required this.categoryName, required this.rooms});

  @override
  State<RoomTypesUi> createState() => _RoomTypesUiState();
}

class _RoomTypesUiState extends State<RoomTypesUi> {
  // Local list of rooms for this category
  late List<RoomEntity> _localRooms;

  @override
  void initState() {
    super.initState();
    _initializeRooms();
  }

  void _initializeRooms() {
    // Create 5-6 sample rooms for this category
    _localRooms = [
      RoomEntity(
        id: '1',
        name: '${widget.categoryName} Room 101',
        description: 'Beautiful ${widget.categoryName.toLowerCase()} room with modern amenities and comfortable furnishings. Perfect for a relaxing stay.',
        roomType: widget.categoryName,
        status: RoomStatus.available,
        floor: 1,
        roomNumber: 101,
        price: 149.99,
        amenities: ['WiFi', 'TV', 'AC', 'Private Bathroom'],
        photos: [Colors.blue, Colors.lightBlue],
        createdAt: DateTime.now(),
      ),
      RoomEntity(
        id: '2',
        name: '${widget.categoryName} Room 102',
        description: 'Spacious ${widget.categoryName.toLowerCase()} room featuring elegant decor and premium amenities. Ideal for business or leisure travelers.',
        roomType: widget.categoryName,
        status: RoomStatus.occupied,
        floor: 1,
        roomNumber: 102,
        price: 149.99,
        amenities: ['WiFi', 'TV', 'AC', 'Private Bathroom', 'Mini Bar'],
        photos: [Colors.green, Colors.lightGreen],
        createdAt: DateTime.now(),
      ),
      RoomEntity(
        id: '3',
        name: '${widget.categoryName} Room 201',
        description: 'Luxurious ${widget.categoryName.toLowerCase()} room on the second floor with stunning views and top-tier facilities.',
        roomType: widget.categoryName,
        status: RoomStatus.maintenance,
        floor: 2,
        roomNumber: 201,
        price: 179.99,
        amenities: ['WiFi', 'TV', 'AC', 'Private Bathroom', 'Balcony'],
        photos: [Colors.orange, Colors.deepOrange],
        createdAt: DateTime.now(),
      ),
      RoomEntity(
        id: '4',
        name: '${widget.categoryName} Room 202',
        description: 'Comfortable ${widget.categoryName.toLowerCase()} room with contemporary design and essential amenities for a pleasant stay.',
        roomType: widget.categoryName,
        status: RoomStatus.available,
        floor: 2,
        roomNumber: 202,
        price: 149.99,
        amenities: ['WiFi', 'TV', 'AC', 'Private Bathroom'],
        photos: [Colors.purple, Colors.deepPurple],
        createdAt: DateTime.now(),
      ),
      RoomEntity(
        id: '5',
        name: '${widget.categoryName} Room 301',
        description: 'Premium ${widget.categoryName.toLowerCase()} room offering luxury comfort with sophisticated amenities and elegant atmosphere.',
        roomType: widget.categoryName,
        status: RoomStatus.cleaning,
        floor: 3,
        roomNumber: 301,
      price: 199.99,
        amenities: ['WiFi', 'TV', 'AC', 'Private Bathroom', 'Mini Bar', 'Balcony'],
        photos: [Colors.red, Colors.redAccent],
      createdAt: DateTime.now(),
      ),
      RoomEntity(
        id: '6',
        name: '${widget.categoryName} Room 302',
        description: 'Exclusive ${widget.categoryName.toLowerCase()} room featuring premium furnishings and exceptional service for discerning guests.',
        roomType: widget.categoryName,
        status: RoomStatus.available,
        floor: 3,
        roomNumber: 302,
        price: 169.99,
        amenities: ['WiFi', 'TV', 'AC', 'Private Bathroom', 'Work Desk'],
        photos: [Colors.indigo, Colors.indigoAccent],
        createdAt: DateTime.now(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CommonAppBar.withBackButton(
        title: 'Room Listings',
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Rooms List
          Expanded(
            child: _localRooms.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    child: EmptyState(
                      title: 'No Rooms Available',
                      subtitle: 'Add rooms to this category to get started.',
                      icon: Icons.hotel,
                      onActionPressed: _showAddRoomBottomSheet,
                      actionText: 'Add Room',
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                    itemCount: _localRooms.length,
                    itemBuilder: (context, index) {
                      final room = _localRooms[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Room Icon
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.key,
                                  color: Color(0xFF1F2937),
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Room Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      room.name,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1F2937),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      room.description,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: const Color(0xFF6B7280),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF1F2937),
                                        borderRadius: BorderRadius.all(Radius.circular(20)),
                                      ),
                                      child: Text(
                                        room.roomType,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Edit Icon
                              IconButton(
                                onPressed: () {
                                  // Handle edit room
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Color(0xFF1F2937),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                         ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRoomBottomSheet,
        backgroundColor: const Color(0xFF1F2937),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Room',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showAddRoomBottomSheet() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddRoomScreen(
          categoryName: widget.categoryName,
          onRoomAdded: (room) {
            // Add the new room to the local list
            setState(() {
              _localRooms.add(room);
            });
          },
        ),
      ),
    );
    
    if (result == true) {
      // Room was added successfully, list will be updated via callback
    }
  }
}
