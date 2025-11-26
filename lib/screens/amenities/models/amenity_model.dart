import 'package:flutter/material.dart';

class Amenity {
  final IconData icon;
  final String label;
  final String description;
  final int colorIndex;

  const Amenity({
    required this.icon,
    required this.label,
    required this.description,
    required this.colorIndex,
  });

  factory Amenity.fromMap(Map<String, dynamic> map) {
    return Amenity(
      icon: map['icon'] as IconData,
      label: map['label'] as String,
      description: map['description'] as String,
      colorIndex: map['colorIndex'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'icon': icon,
      'label': label,
      'description': description,
      'colorIndex': colorIndex,
    };
  }

  Amenity copyWith({
    IconData? icon,
    String? label,
    String? description,
    int? colorIndex,
  }) {
    return Amenity(
      icon: icon ?? this.icon,
      label: label ?? this.label,
      description: description ?? this.description,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }
}

class AmenityType {
  static const String room = "Room";
  static const String property = "Property";
  
  static List<String> get all => [room, property];
}

class AmenityHelper {
  // Color gradients for amenities tiles
  static final List<List<Color>> amenityColors = [
    [const Color(0xFF6366F1), const Color(0xFF8B5CF6)], // Indigo to Purple
    [const Color(0xFF22C55E), const Color(0xFF16A34A)], // Green
    [const Color(0xFFF59E0B), const Color(0xFFD97706)], // Orange
    [const Color(0xFFEF4444), const Color(0xFFDC2626)], // Red
    [const Color(0xFF06B6D4), const Color(0xFF0891B2)], // Cyan
    [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)], // Purple
    [const Color(0xFFEC4899), const Color(0xFFDB2777)], // Pink
    [const Color(0xFF10B981), const Color(0xFF059669)], // Emerald
  ];

  static final List<IconData> availableIcons = [
    Icons.tv, Icons.ac_unit, Icons.local_cafe, Icons.bathtub, Icons.kitchen,
    Icons.speaker, Icons.wifi, Icons.pool, Icons.local_parking, Icons.fitness_center,
    Icons.restaurant, Icons.local_bar, Icons.spa, Icons.beach_access, Icons.room_service,
    Icons.cleaning_services, Icons.security, Icons.elevator, Icons.meeting_room,
    Icons.business_center, Icons.child_care, Icons.pets, Icons.smoke_free,
    Icons.accessibility, Icons.airline_seat_flat, Icons.balcony, Icons.bed,
    Icons.bed_outlined, Icons.bedtime, Icons.baby_changing_station, Icons.iron, Icons.dry_cleaning,
    Icons.cleaning_services, Icons.beach_access, Icons.bed, Icons.bed_outlined, Icons.bedtime,
    Icons.phone, Icons.alarm, Icons.curtains, Icons.lightbulb, Icons.thermostat,
  ];

  static List<Amenity> getDefaultRoomAmenities() {
    return [
      Amenity(icon: Icons.tv, label: 'Television', description: 'HD TV with streaming services', colorIndex: 0),
      Amenity(icon: Icons.ac_unit, label: 'Air Conditioning', description: 'Climate control system', colorIndex: 1),
      Amenity(icon: Icons.local_cafe, label: 'Coffee Maker', description: 'In-room coffee facilities', colorIndex: 2),
      Amenity(icon: Icons.bathtub, label: 'Bathtub', description: 'Private bathroom with bathtub', colorIndex: 3),
      Amenity(icon: Icons.kitchen, label: 'Mini Fridge', description: 'Refrigerator for beverages', colorIndex: 4),
      Amenity(icon: Icons.speaker, label: 'Sound System', description: 'Bluetooth speaker system', colorIndex: 5),
    ];
  }

  static List<Amenity> getDefaultPropertyAmenities() {
    return [
      Amenity(icon: Icons.wifi, label: 'Free Wi-Fi', description: 'High-speed internet access', colorIndex: 0),
      Amenity(icon: Icons.pool, label: 'Swimming Pool', description: 'Outdoor swimming pool', colorIndex: 1),
      Amenity(icon: Icons.local_parking, label: 'Parking', description: 'Free parking available', colorIndex: 2),
      Amenity(icon: Icons.fitness_center, label: 'Gym', description: '24/7 fitness center', colorIndex: 3),
      Amenity(icon: Icons.restaurant, label: 'Restaurant', description: 'On-site dining options', colorIndex: 4),
      Amenity(icon: Icons.local_bar, label: 'Bar', description: 'Lounge and bar area', colorIndex: 5),
      Amenity(icon: Icons.spa, label: 'Spa', description: 'Wellness and spa services', colorIndex: 6),
      Amenity(icon: Icons.beach_access, label: 'Beach Access', description: 'Direct beach access', colorIndex: 7),
    ];
  }
}
