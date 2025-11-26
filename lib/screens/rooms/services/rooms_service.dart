import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../config/api_config.dart';
import '../../../services/auth_service.dart';

class RoomsService {
  // Get all rooms
  static Future<Map<String, dynamic>> getRooms({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    String? roomType,
    int? propertyId,
  }) async {
    try {
      
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      
      if (roomType != null && roomType.isNotEmpty) {
        queryParams['room_type'] = roomType;
      }
      
      if (propertyId != null) {
        queryParams['property_id'] = propertyId.toString();
      }
      
      // Use the correct rooms endpoint
      final uri = Uri.parse(ApiConfig.rooms).replace(
        queryParameters: queryParams,
      );
      
      // Get auth token
      final token = await AuthService.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 30));


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to fetch rooms',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.body}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get single room by ID
  static Future<Map<String, dynamic>> getRoom(String roomId) async {
    try {
      // Get auth token
      final token = await AuthService.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await http.get(
        Uri.parse('${ApiConfig.rooms}/$roomId'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to fetch room',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.body}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Create new room
  static Future<Map<String, dynamic>> createRoom({
    required String name,
    required String roomType,
    required String description,
    required double price,
    required int floor,
    required int roomNumber,
    required int propertyId,
    String? status,
    List<String>? amenities,
    List<String>? images,
  }) async {
    try {
      
      final requestBody = {
        'name': name,
        'room_type': roomType,
        'description': description,
        'price': price,
        'floor': floor,
        'room_number': roomNumber,
        'property_id': propertyId,
        if (status != null) 'status': status,
        if (amenities != null) 'amenities': amenities,
        if (images != null) 'images': images,
      };
      
      // Get auth token
      final token = await AuthService.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await http.post(
        Uri.parse(ApiConfig.rooms),
        headers: headers,
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));


      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Room created successfully',
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to create room',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.body}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Update room
  static Future<Map<String, dynamic>> updateRoom({
    required String roomId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      // Get auth token
      final token = await AuthService.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await http.put(
        Uri.parse('${ApiConfig.rooms}/$roomId'),
        headers: headers,
        body: jsonEncode(updateData),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Room updated successfully',
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to update room',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.body}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Delete room
  static Future<Map<String, dynamic>> deleteRoom(String roomId) async {
    try {
      // Get auth token
      final token = await AuthService.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await http.delete(
        Uri.parse('${ApiConfig.rooms}/$roomId'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Room deleted successfully',
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to delete room',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.body}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get room statistics
  static Future<Map<String, dynamic>> getRoomStats({
    String? roomId,
    int? propertyId,
  }) async {
    try {
      
      String url = ApiConfig.rooms;
      if (roomId != null) {
        url += '/$roomId/stats';
      } else {
        url += '/stats';
      }
      
      final queryParams = <String, String>{};
      if (propertyId != null) {
        queryParams['property_id'] = propertyId.toString();
      }
      
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      
      // Get auth token
      final token = await AuthService.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 30));


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to fetch room stats',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.body}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get room types
  static Future<Map<String, dynamic>> getRoomTypes({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
  }) async {
    try {
      
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      
      final uri = Uri.parse('${ApiConfig.baseUrl}/v1/room-types').replace(
        queryParameters: queryParams,
      );
      
      // Get auth token
      final token = await AuthService.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await http.get(
        uri,
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to fetch room types',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.body}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get single room type by ID
  static Future<Map<String, dynamic>> getRoomType(String roomTypeId) async {
    try {
      // Get auth token
      final token = await AuthService.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await http.get(
        Uri.parse('${ApiConfig.roomTypes}/$roomTypeId'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to fetch room type',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.body}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Create room type
  static Future<Map<String, dynamic>> createRoomType({
    required String name,
    required String description,
    required double basePrice,
    required int capacity,
    String? amenities,
    String? status,
    int? propertyId,
    int? floor,
    int? floorStartNumber,
    String? accommodationType,
    String? currency,
    int? quantity,
    List<String>? amenitiesList,
  }) async {
    try {
      
      final requestBody = {
        'name': name,
        'description': description,
        'base_price': basePrice,
        'capacity': capacity,
        'floor': floor ?? 0,
        'floor_start_number': floorStartNumber ?? 1,
        'accommodation_type': accommodationType ?? 'room',
        'currency': currency ?? 'INR',
        'max_occupancy': capacity,
        'quantity': quantity ?? 1,
        'amenities': amenitiesList ?? (amenities != null ? amenities.split(',').map((e) => e.trim()).toList() : []),
        'is_active': status != 'inactive',
        if (propertyId != null) 'property_id': propertyId,
      };
      
      // Get auth token
      final token = await AuthService.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/v1/room-types'),
        headers: headers,
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Room type created successfully',
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to create room type',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.body}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Update room type
  static Future<Map<String, dynamic>> updateRoomType({
    required String roomTypeId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      // Get auth token
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final headers = ApiConfig.getAuthHeaders(token);
      
      final url = '${ApiConfig.roomTypes}/$roomTypeId';
      print('🔍 Update Room Type URL: $url');
      print('🔍 Room Type ID: $roomTypeId');
      print('🔍 Room Type ID Type: ${roomTypeId.runtimeType}');
      print('🔍 Update Data: $updateData');
      print('🔍 JSON Body: ${jsonEncode(updateData)}');
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(updateData),
      ).timeout(const Duration(seconds: 30));

      print('🔍 Update Room Type Response Status: ${response.statusCode}');
      print('🔍 Update Room Type Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Room type updated successfully',
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? error['error'] ?? 'Failed to update room type',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.body}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Upload room type images
  static Future<Map<String, dynamic>> uploadRoomTypeImages({
    required String roomTypeId,
    required List<Uint8List> imageBytesList,
  }) async {
    try {
      // Validate inputs
      if (roomTypeId.isEmpty) {
        return {
          'success': false,
          'message': 'Room type ID is required',
        };
      }
      
      if (imageBytesList.isEmpty) {
        return {
          'success': false,
          'message': 'No images to upload',
        };
      }
      
      // Get auth token
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final headers = ApiConfig.getAuthMultipartHeaders(token);
      
      // Create multipart request with POST method
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/v1/room-types/$roomTypeId/upload-images'),
      );
      
      // Add headers
      request.headers.addAll(headers);
      
      // Add image files with proper content type
      for (int i = 0; i < imageBytesList.length; i++) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'images[]',
            imageBytesList[i],
            filename: 'room_type_image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 120));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Room type images uploaded successfully',
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? error['error'] ?? 'Failed to upload room type images',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.body}',
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Alternative upload method for room type images with fallback approaches
  static Future<Map<String, dynamic>> uploadRoomTypeImagesWithFallback({
    required String roomTypeId,
    required List<Uint8List> imageBytesList,
  }) async {
    // Try the primary method first
    var result = await uploadRoomTypeImages(
      roomTypeId: roomTypeId,
      imageBytesList: imageBytesList,
    );
    
    if (result['success'] == true) {
      return result;
    }
    
    // If primary method fails, try alternative approaches
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final headers = ApiConfig.getAuthMultipartHeaders(token);
      
      // Try with PUT method and different URL structure
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConfig.baseUrl}/v1/room-types/$roomTypeId/upload-images'),
      );
      
      request.headers.addAll(headers);
      
      for (int i = 0; i < imageBytesList.length; i++) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'images[]',
            imageBytesList[i],
            filename: 'room_type_image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 120));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Room type images uploaded successfully (fallback method)',
        };
      }
    } catch (e) {
      // Fallback also failed
    }
    
    // Return the original error if all methods fail
    return result;
  }
}
