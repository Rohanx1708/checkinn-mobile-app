import 'package:flutter/material.dart';

/// Property data model
class Property {
  final String id;
  final String name;
  final String address;
  final String location;
  final String pincode;
  final List<String> amenities;
  final List<String> images;
  final double rating;
  final int capacity;
  final String description;
  final PropertyStatus status;
  final PropertyType type;
  final double price;
  final String ownerName;
  final String ownerPhone;
  final String ownerEmail;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Property({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    this.pincode = '',
    required this.amenities,
    required this.images,
    this.rating = 0.0,
    this.capacity = 1,
    this.description = '',
    this.status = PropertyStatus.active,
    this.type = PropertyType.apartment,
    this.price = 0.0,
    this.ownerName = '',
    this.ownerPhone = '',
    this.ownerEmail = '',
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Property copyWith({
    String? id,
    String? name,
    String? address,
    String? location,
    String? pincode,
    List<String>? amenities,
    List<String>? images,
    double? rating,
    int? capacity,
    String? description,
    PropertyStatus? status,
    PropertyType? type,
    double? price,
    String? ownerName,
    String? ownerPhone,
    String? ownerEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Property(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      location: location ?? this.location,
      pincode: pincode ?? this.pincode,
      amenities: amenities ?? this.amenities,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      capacity: capacity ?? this.capacity,
      description: description ?? this.description,
      status: status ?? this.status,
      type: type ?? this.type,
      price: price ?? this.price,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'location': location,
      'pincode': pincode,
      'amenities': amenities,
      'images': images,
      'rating': rating,
      'capacity': capacity,
      'description': description,
      'status': status.name,
      'type': type.name,
      'price': price,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'ownerEmail': ownerEmail,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Property.fromMap(Map<String, dynamic> map) {
    // Build location from city, state, country
    String location = '';
    if (map['city'] != null) location += map['city'];
    if (map['state'] != null) location += (location.isNotEmpty ? ', ' : '') + map['state'];
    if (map['country'] != null) location += (location.isNotEmpty ? ', ' : '') + map['country'];
    
    return Property(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      location: location,
      pincode: (map['pincode'] ?? map['postal_code'] ?? '').toString(),
      amenities: List<String>.from(map['amenities'] ?? []),
      images: List<String>.from(map['images'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      capacity: int.tryParse(map['room_count']?.toString() ?? '1') ?? 1,
      description: map['description'] ?? '',
      status: PropertyStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PropertyStatus.active,
      ),
      type: PropertyType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => PropertyType.apartment,
      ),
      price: (map['price'] ?? 0.0).toDouble(),
      ownerName: map['owner_name'] ?? '',
      ownerPhone: map['contact_phone'] ?? '',
      ownerEmail: map['contact_email'] ?? '',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? ''),
    );
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property.fromMap(json);
  }
}

/// Property status enum
enum PropertyStatus {
  active,
  inactive,
  maintenance,
  booked,
  available,
}

/// Property type enum
enum PropertyType {
  apartment,
  house,
  villa,
  penthouse,
  studio,
  hotel,
  resort,
}

/// Property form data model
class PropertyFormData {
  final String name;
  final String address;
  final String location;
  final List<String> amenities;
  final List<String> images;
  final int capacity;
  final String description;
  final PropertyType type;
  final double price;
  final String ownerName;
  final String ownerPhone;
  final String ownerEmail;

  const PropertyFormData({
    required this.name,
    required this.address,
    required this.location,
    required this.amenities,
    required this.images,
    required this.capacity,
    required this.description,
    required this.type,
    required this.price,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerEmail,
  });

  PropertyFormData copyWith({
    String? name,
    String? address,
    String? location,
    List<String>? amenities,
    List<String>? images,
    int? capacity,
    String? description,
    PropertyType? type,
    double? price,
    String? ownerName,
    String? ownerPhone,
    String? ownerEmail,
  }) {
    return PropertyFormData(
      name: name ?? this.name,
      address: address ?? this.address,
      location: location ?? this.location,
      amenities: amenities ?? this.amenities,
      images: images ?? this.images,
      capacity: capacity ?? this.capacity,
      description: description ?? this.description,
      type: type ?? this.type,
      price: price ?? this.price,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerEmail: ownerEmail ?? this.ownerEmail,
    );
  }
}

/// Property validation helper
class PropertyValidator {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Property name is required';
    }
    if (value.trim().length < 3) {
      return 'Property name must be at least 3 characters';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    if (value.trim().length < 10) {
      return 'Address must be at least 10 characters';
    }
    return null;
  }

  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Location is required';
    }
    return null;
  }

  static String? validateCapacity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Capacity is required';
    }
    final capacity = int.tryParse(value);
    if (capacity == null || capacity < 1) {
      return 'Capacity must be at least 1';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null || price < 0) {
      return 'Price must be a valid number';
    }
    return null;
  }

  static String? validateOwnerName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Owner name is required';
    }
    return null;
  }

  static String? validateOwnerPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Owner phone is required';
    }
    if (value.trim().length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    return null;
  }

  static String? validateOwnerEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Owner email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static bool isValidPropertyForm(PropertyFormData formData) {
    return validateName(formData.name) == null &&
           validateAddress(formData.address) == null &&
           validateLocation(formData.location) == null &&
           validateCapacity(formData.capacity.toString()) == null &&
           validatePrice(formData.price.toString()) == null &&
           validateOwnerName(formData.ownerName) == null &&
           validateOwnerPhone(formData.ownerPhone) == null &&
           validateOwnerEmail(formData.ownerEmail) == null;
  }
}

/// Property helper class
class PropertyHelper {
  static Color getStatusColor(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.active:
        return Colors.green;
      case PropertyStatus.inactive:
        return Colors.grey;
      case PropertyStatus.maintenance:
        return Colors.orange;
      case PropertyStatus.booked:
        return Colors.red;
      case PropertyStatus.available:
        return Colors.blue;
    }
  }

  static String getStatusLabel(PropertyStatus status) {
    switch (status) {
      case PropertyStatus.active:
        return 'Active';
      case PropertyStatus.inactive:
        return 'Inactive';
      case PropertyStatus.maintenance:
        return 'Maintenance';
      case PropertyStatus.booked:
        return 'Booked';
      case PropertyStatus.available:
        return 'Available';
    }
  }

  static IconData getTypeIcon(PropertyType type) {
    switch (type) {
      case PropertyType.apartment:
        return Icons.apartment;
      case PropertyType.house:
        return Icons.house;
      case PropertyType.villa:
        return Icons.villa;
      case PropertyType.penthouse:
        return Icons.home_work;
      case PropertyType.studio:
        return Icons.single_bed;
      case PropertyType.hotel:
        return Icons.hotel;
      case PropertyType.resort:
        return Icons.beach_access;
    }
  }

  static String getTypeLabel(PropertyType type) {
    switch (type) {
      case PropertyType.apartment:
        return 'Apartment';
      case PropertyType.house:
        return 'House';
      case PropertyType.villa:
        return 'Villa';
      case PropertyType.penthouse:
        return 'Penthouse';
      case PropertyType.studio:
        return 'Studio';
      case PropertyType.hotel:
        return 'Hotel';
      case PropertyType.resort:
        return 'Resort';
    }
  }

  static List<Property> getDefaultProperties() {
    return [
      Property(
        id: '1',
        name: 'Royal Garden Penthouse',
        address: '123 Luxury Avenue, Downtown',
        location: 'Downtown, City Center',
        amenities: ['Free Wifi', 'Free Parking', 'Min Bar', 'Swimming Pool'],
        images: [
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
          'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
          'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800',
        ],
        description: 'Luxurious penthouse with stunning city views, marble floors, and premium amenities.',
        capacity: 4,
        type: PropertyType.penthouse,
        price: 5000.0,
        ownerName: 'John Smith',
        ownerPhone: '+1234567890',
        ownerEmail: 'john@example.com',
      ),
      Property(
        id: '2',
        name: 'Seaside Villa',
        address: '456 Beach Road, Coastal Area',
        location: 'Coastal Area, Beach Front',
        amenities: ['Private Beach', 'Garden', 'BBQ Area', 'Ocean View'],
        images: [
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800',
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
        ],
        description: 'Beautiful villa with direct beach access and panoramic ocean views.',
        capacity: 6,
        type: PropertyType.villa,
        price: 8000.0,
        ownerName: 'Sarah Johnson',
        ownerPhone: '+1234567891',
        ownerEmail: 'sarah@example.com',
      ),
    ];
  }
}

/// PMS state management
class PmsState {
  final bool isLoading;
  final String? errorMessage;
  final List<Property> properties;
  final String searchQuery;
  final PropertyType? selectedType;
  final PropertyStatus? selectedStatus;

  const PmsState({
    this.isLoading = false,
    this.errorMessage,
    this.properties = const [],
    this.searchQuery = '',
    this.selectedType,
    this.selectedStatus,
  });

  PmsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Property>? properties,
    String? searchQuery,
    PropertyType? selectedType,
    PropertyStatus? selectedStatus,
  }) {
    return PmsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      properties: properties ?? this.properties,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }

  List<Property> get filteredProperties {
    return properties.where((property) {
      final matchesSearch = property.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                           property.address.toLowerCase().contains(searchQuery.toLowerCase()) ||
                           property.location.toLowerCase().contains(searchQuery.toLowerCase());
      
      final matchesType = selectedType == null || property.type == selectedType;
      final matchesStatus = selectedStatus == null || property.status == selectedStatus;
      
      return matchesSearch && matchesType && matchesStatus;
    }).toList();
  }
}
