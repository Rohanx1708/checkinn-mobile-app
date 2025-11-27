import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoomTypeBottomSheet extends StatefulWidget {
  final Map<String, int>? initialRoomTypes;
  final Function(Map<String, int>, Map<String, String>) onRoomTypeSelected;

  const RoomTypeBottomSheet({
    super.key,
    this.initialRoomTypes,
    required this.onRoomTypeSelected,
  });

  @override
  State<RoomTypeBottomSheet> createState() => _RoomTypeBottomSheetState();
}

class _RoomTypeBottomSheetState extends State<RoomTypeBottomSheet> {
  Map<String, int> _roomTypeCounts = {};

  // Mock room types - in real app, this would come from API
  final List<Map<String, dynamic>> _roomTypes = [
    {
      'name': 'Standard Room',
      'capacity': '2 guests',
      'price': '2,500',
    },
    {
      'name': 'Deluxe Room',
      'capacity': '2 guests',
      'price': '4,000',
    },
    {
      'name': 'Suite',
      'capacity': '4 guests',
      'price': '6,500',
    },
    {
      'name': 'Family Room',
      'capacity': '6 guests',
      'price': '5,500',
    },
  ];

  @override
  void initState() {
    super.initState();
    _roomTypeCounts = Map<String, int>.from(widget.initialRoomTypes ?? {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Room Type',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Room Type List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _roomTypes.length,
              itemBuilder: (context, index) {
                final roomType = _roomTypes[index];
                final roomName = roomType['name'] as String;
                final count = _roomTypeCounts[roomName] ?? 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: count > 0
                          ? const Color(0xFF1F2937).withOpacity(0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: count > 0
                            ? const Color(0xFF1F2937)
                            : const Color(0xFFE5E7EB),
                        width: count > 0 ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Room name and capacity
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                roomName,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people,
                                    size: 12,
                                    color: const Color(0xFF6B7280),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    roomType['capacity'] as String,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '₹${roomType['price'] as String}',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Counter buttons
                        Row(
                          children: [
                            GestureDetector(
                              onTap: count > 0
                                  ? () {
                                      setState(() {
                                        if (count > 1) {
                                          _roomTypeCounts[roomName] = count - 1;
                                        } else {
                                          _roomTypeCounts.remove(roomName);
                                        }
                                      });
                                    }
                                  : null,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: count > 0
                                      ? const Color(0xFF1F2937)
                                      : const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  color: count > 0 ? Colors.white : const Color(0xFF9CA3AF),
                                  size: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 26,
                              child: Text(
                                count.toString(),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _roomTypeCounts[roomName] = (count) + 1;
                                });
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1F2937),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer with Apply Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _roomTypeCounts.isNotEmpty
                      ? () {
                          // Create map of room prices
                          Map<String, String> roomPrices = {};
                          for (var entry in _roomTypeCounts.entries) {
                            final roomType = _roomTypes.firstWhere(
                              (rt) => rt['name'] == entry.key,
                              orElse: () => {'price': '0'},
                            );
                            roomPrices[entry.key] = roomType['price'] as String;
                          }
                          widget.onRoomTypeSelected(_roomTypeCounts, roomPrices);
                          Navigator.of(context).pop();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    disabledForegroundColor: const Color(0xFF9CA3AF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Apply',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
}

