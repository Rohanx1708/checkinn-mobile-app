import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/room_models.dart';

class AddRoomSheet extends StatefulWidget {
  final List<RoomType> roomTypes;
  final Function(RoomEntity) onRoomAdded;

  const AddRoomSheet({
    super.key,
    required this.roomTypes,
    required this.onRoomAdded,
  });

  @override
  State<AddRoomSheet> createState() => _AddRoomSheetState();
}

class _AddRoomSheetState extends State<AddRoomSheet> {
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _roomDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _roomDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(2)
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Header section
              Text(
                'Add New Room',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              
              const SizedBox(height: 24),

              // Room Name Field
              _buildFieldLabel('Room Name'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _roomNameController,
                hintText: 'Enter room name',
                icon: Icons.meeting_room,
              ),
              const SizedBox(height: 16),

              // Description Field
              _buildFieldLabel('Description'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _roomDescriptionController,
                hintText: 'Enter room description',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.save,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Save Room',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937),
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? prefixText,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          prefixText: prefixText,
          prefixIcon: Icon(icon, color: const Color(0xFF1F2937)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintStyle: GoogleFonts.inter(
            color: const Color(0xFF9CA3AF),
            fontSize: 14,
          ),
        ),
        style: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFF1F2937),
        ),
      ),
    );
  }

  void _saveRoom() {
    if (_roomNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter room name'))
      );
      return;
    }

    final newRoom = RoomEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _roomNameController.text.trim(),
      roomType: 'Standard', // Default room type
      description: _roomDescriptionController.text.trim(),
      status: RoomStatus.available, // Default status
      floor: 1, // Default floor
      roomNumber: 101, // Default room number
      price: 99.99, // Default price
      amenities: ['WiFi', 'TV', 'AC'], // Default amenities
      photos: [Colors.blue], // Default photo
      createdAt: DateTime.now(),
    );

    widget.onRoomAdded(newRoom);
    Navigator.pop(context);
  }
}
