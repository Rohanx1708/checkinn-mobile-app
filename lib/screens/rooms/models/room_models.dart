import 'package:flutter/material.dart';

/// Room type data model
class RoomType {
  final String id;
  final String name;
  final String? description;
  final String? amenities;
  final double basePrice;
  final int capacity;
  final List<String>? imageUrls; // Changed from List<Color> to List<String> (nullable)
  final List<Color> photos; // Keep for backward compatibility
  final RoomTypeStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RoomType({
    required this.id,
    required this.name,
    this.description,
    this.amenities,
    this.basePrice = 0.0,
    this.capacity = 1,
    this.imageUrls, // New field for image URLs (nullable)
    this.photos = const [], // Keep for backward compatibility
    this.status = RoomTypeStatus.active,
    required this.createdAt,
    this.updatedAt,
  });

  RoomType copyWith({
    String? id,
    String? name,
    String? description,
    String? amenities,
    double? basePrice,
    int? capacity,
    List<Color>? photos,
    RoomTypeStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoomType(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      amenities: amenities ?? this.amenities,
      basePrice: basePrice ?? this.basePrice,
      capacity: capacity ?? this.capacity,
      photos: photos ?? this.photos,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'amenities': amenities,
      'basePrice': basePrice,
      'capacity': capacity,
      'photos': photos.map((color) => color.value).toList(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory RoomType.fromMap(Map<String, dynamic> map) {
    return RoomType(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      amenities: map['amenities'],
      basePrice: (map['base_price'] ?? map['basePrice'] ?? 0.0).toDouble(),
      capacity: map['capacity'] ?? 1,
      photos: (map['photos'] as List<dynamic>?)
          ?.map((color) => Color(color is int ? color : int.parse(color.toString())))
          .toList() ?? [],
      status: RoomTypeStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RoomTypeStatus.active,
      ),
      createdAt: DateTime.tryParse(map['created_at'] ?? map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? map['updatedAt'] ?? ''),
    );
  }

  factory RoomType.fromJson(Map<String, dynamic> json) {
    return RoomType.fromMap(json);
  }
}

/// Room entity data model
class RoomEntity {
  final String id;
  final String name;
  final String roomType;
  final List<String>? imageUrls; // New field for image URLs (nullable)
  final List<Color> photos;
  final String description;
  final double price;
  final RoomStatus status;
  final int floor;
  final int roomNumber;
  final List<String> amenities;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RoomEntity({
    required this.id,
    required this.name,
    required this.roomType,
    this.imageUrls, // New field for image URLs (nullable)
    required this.photos,
    required this.description,
    required this.price,
    this.status = RoomStatus.available,
    this.floor = 1,
    this.roomNumber = 1,
    this.amenities = const [],
    required this.createdAt,
    this.updatedAt,
  });

  RoomEntity copyWith({
    String? id,
    String? name,
    String? roomType,
    List<Color>? photos,
    String? description,
    double? price,
    RoomStatus? status,
    int? floor,
    int? roomNumber,
    List<String>? amenities,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoomEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      roomType: roomType ?? this.roomType,
      photos: photos ?? this.photos,
      description: description ?? this.description,
      price: price ?? this.price,
      status: status ?? this.status,
      floor: floor ?? this.floor,
      roomNumber: roomNumber ?? this.roomNumber,
      amenities: amenities ?? this.amenities,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'roomType': roomType,
      'photos': photos.map((color) => color.value).toList(),
      'description': description,
      'price': price,
      'status': status.name,
      'floor': floor,
      'roomNumber': roomNumber,
      'amenities': amenities,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory RoomEntity.fromMap(Map<String, dynamic> map) {
    return RoomEntity(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      roomType: map['room_type'] ?? map['roomType'] ?? '',
      photos: (map['photos'] as List<dynamic>?)
          ?.map((color) => Color(color is int ? color : int.parse(color.toString())))
          .toList() ?? [],
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      status: RoomStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RoomStatus.available,
      ),
      floor: map['floor'] ?? 1,
      roomNumber: map['room_number'] ?? map['roomNumber'] ?? 1,
      amenities: List<String>.from(map['amenities'] ?? []),
      createdAt: DateTime.tryParse(map['created_at'] ?? map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? map['updatedAt'] ?? ''),
    );
  }

  factory RoomEntity.fromJson(Map<String, dynamic> json) {
    return RoomEntity.fromMap(json);
  }
}

/// Room type status enum
enum RoomTypeStatus {
  active,
  inactive,
  maintenance,
  deleted,
}

/// Room status enum
enum RoomStatus {
  available,
  occupied,
  maintenance,
  reserved,
  cleaning,
}

/// Room type form data model
class RoomTypeFormData {
  String name;
  String? description;
  String? amenities;
  double basePrice;
  int capacity;

  RoomTypeFormData({
    this.name = '',
    this.description,
    this.amenities,
    this.basePrice = 0.0,
    this.capacity = 1,
  });
}

/// Room form data model
class RoomFormData {
  String name;
  String roomType;
  String description;
  double price;
  int floor;
  int roomNumber;
  List<String> amenities;

  RoomFormData({
    this.name = '',
    this.roomType = '',
    this.description = '',
    this.price = 0.0,
    this.floor = 1,
    this.roomNumber = 1,
    this.amenities = const [],
  });
}

/// Room validation helper
class RoomValidator {
  static String? validateRoomName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Room name is required';
    }
    if (value.trim().length < 2) {
      return 'Room name must be at least 2 characters';
    }
    return null;
  }

  static String? validateRoomType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Room type is required';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return 'Please enter a valid price';
    }
    return null;
  }

  static String? validateRoomNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Room number is required';
    }
    final number = int.tryParse(value);
    if (number == null || number <= 0) {
      return 'Please enter a valid room number';
    }
    return null;
  }

  static bool isValidRoomForm(RoomFormData formData) {
    return validateRoomName(formData.name) == null &&
           validateRoomType(formData.roomType) == null &&
           validatePrice(formData.price.toString()) == null &&
           validateRoomNumber(formData.roomNumber.toString()) == null;
  }

  static String? validateRoomTypeName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Room type name is required';
    }
    if (value.trim().length < 2) {
      return 'Room type name must be at least 2 characters';
    }
    return null;
  }

  static bool isValidRoomTypeForm(RoomTypeFormData formData) {
    return validateRoomTypeName(formData.name) == null;
  }
}

/// Room state management
class RoomState {
  final List<RoomEntity> rooms;
  final List<RoomType> roomTypes;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final RoomStatus? selectedStatus;
  final String? selectedRoomType;

  RoomState({
    this.rooms = const [],
    this.roomTypes = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedStatus,
    this.selectedRoomType,
  });

  RoomState copyWith({
    List<RoomEntity>? rooms,
    List<RoomType>? roomTypes,
    bool? isLoading,
    String? error,
    String? searchQuery,
    RoomStatus? selectedStatus,
    String? selectedRoomType,
  }) {
    return RoomState(
      rooms: rooms ?? this.rooms,
      roomTypes: roomTypes ?? this.roomTypes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedRoomType: selectedRoomType ?? this.selectedRoomType,
    );
  }
}

/// Room helper class
class RoomHelper {
  static List<RoomType> getDefaultRoomTypes() {
    return [
      RoomType(
        id: '1',
        name: 'Standard',
        description: 'Basic room with essential amenities',
        amenities: 'TV, AC, WiFi',
        basePrice: 149.99,
        capacity: 2,
        photos: [Colors.blue, Colors.lightBlue],
        createdAt: DateTime.now(),
      ),
      RoomType(
        id: '2',
        name: 'Deluxe',
        description: 'Spacious room with city view',
        amenities: 'TV, AC, Mini Bar, WiFi',
        basePrice: 299.99,
        capacity: 2,
        photos: [Colors.green, Colors.lightGreen, Colors.orange],
        createdAt: DateTime.now(),
      ),
      RoomType(
        id: '3',
        name: 'Suite',
        description: 'Luxury suite with premium amenities',
        amenities: 'TV, AC, Mini Bar, WiFi, Jacuzzi',
        basePrice: 499.99,
        capacity: 4,
        photos: [Colors.purple, Colors.deepPurple, Colors.indigo],
        createdAt: DateTime.now(),
      ),
      RoomType(
        id: '4',
        name: 'Family',
        description: 'Large room perfect for families',
        amenities: 'TV, AC, WiFi, Extra Bed',
        basePrice: 399.99,
        capacity: 6,
        photos: [Colors.red, Colors.redAccent, Colors.pink],
        createdAt: DateTime.now(),
      ),
    ];
  }

  static List<RoomEntity> getDefaultRooms() {
    return [
      RoomEntity(
        id: '1',
        name: 'Deluxe Room 101',
        roomType: 'Deluxe',
        photos: [Colors.blue, Colors.orange, Colors.green],
        description: 'Spacious suite with a private garden view and modern amenities.',
        price: 299.99,
        floor: 1,
        roomNumber: 101,
        amenities: ['TV', 'AC', 'Mini Bar', 'WiFi'],
        createdAt: DateTime.now(),
      ),
      RoomEntity(
        id: '2',
        name: 'Standard Room 102',
        roomType: 'Standard',
        photos: [Colors.purple, Colors.red],
        description: 'Cozy room with queen bed and essential amenities for comfortable stay.',
        price: 149.99,
        floor: 1,
        roomNumber: 102,
        amenities: ['TV', 'AC', 'WiFi'],
        createdAt: DateTime.now(),
      ),
    ];
  }

  static String getStatusLabel(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return 'Available';
      case RoomStatus.occupied:
        return 'Occupied';
      case RoomStatus.maintenance:
        return 'Maintenance';
      case RoomStatus.reserved:
        return 'Reserved';
      case RoomStatus.cleaning:
        return 'Cleaning';
    }
  }

  static Color getStatusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return Colors.green;
      case RoomStatus.occupied:
        return Colors.red;
      case RoomStatus.maintenance:
        return Colors.orange;
      case RoomStatus.reserved:
        return Colors.blue;
      case RoomStatus.cleaning:
        return Colors.yellow;
    }
  }

  static String getRoomTypeStatusLabel(RoomTypeStatus status) {
    switch (status) {
      case RoomTypeStatus.active:
        return 'Active';
      case RoomTypeStatus.inactive:
        return 'Inactive';
      case RoomTypeStatus.maintenance:
        return 'Maintenance';
      case RoomTypeStatus.deleted:
        return 'Deleted';
    }
  }

  static Color getRoomTypeStatusColor(RoomTypeStatus status) {
    switch (status) {
      case RoomTypeStatus.active:
        return Colors.green;
      case RoomTypeStatus.inactive:
        return Colors.grey;
      case RoomTypeStatus.maintenance:
        return Colors.orange;
      case RoomTypeStatus.deleted:
        return Colors.red;
    }
  }
}
