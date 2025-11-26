import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../config/api_config.dart';
import '../../../services/auth_service.dart';

class PropertiesService {
  // Get all properties
  static Future<Map<String, dynamic>> getProperties({
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
      
      final uri = Uri.parse(ApiConfig.properties).replace(
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
            'message': error['message'] ?? 'Failed to fetch properties',
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

  // Get single property by ID
  static Future<Map<String, dynamic>> getProperty(String propertyId) async {
    try {
      // Get auth token
      final token = await AuthService.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await http.get(
        Uri.parse('${ApiConfig.properties}/$propertyId'),
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
            'message': error['message'] ?? 'Failed to fetch property',
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

  // Create new property
  static Future<Map<String, dynamic>> createProperty({
    required String name,
    required String address,
    required String city,
    required String state,
    required String country,
    required String postalCode,
    required String phone,
    required String email,
    String? description,
    String? website,
    int? totalRooms,
    String? propertyType,
    List<String>? amenities,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'name': name,
        'type': propertyType,
        'description': description,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'pincode': postalCode,
        'contact_phone': phone,
        'contact_email': email,
        'room_count': totalRooms,
        'website': website,
        'amenities': amenities,
      }..removeWhere((k, v) => v == null || (v is String && v.trim().isEmpty));
      
      // Get auth token
      final token = await AuthService.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await http.post(
        Uri.parse(ApiConfig.properties),
        headers: headers,
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Property created successfully',
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to create property',
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

  // Update property
  static Future<Map<String, dynamic>> updateProperty({
    required String propertyId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      // Get auth token
      final token = await AuthService.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await http.put(
        Uri.parse('${ApiConfig.properties}/$propertyId'),
        headers: headers,
        body: jsonEncode(updateData),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Property updated successfully',
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to update property',
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

  // Delete property
  static Future<Map<String, dynamic>> deleteProperty(String propertyId) async {
    try {
      // Get auth token
      final token = await AuthService.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await http.delete(
        Uri.parse('${ApiConfig.properties}/$propertyId'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Property deleted successfully',
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to delete property',
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

  // Get property statistics
  static Future<Map<String, dynamic>> getPropertyStats(String propertyId) async {
    try {
      print('📊 Fetching property stats: $propertyId');
      
      // Get auth token
      final token = await AuthService.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await http.get(
        Uri.parse('${ApiConfig.properties}/$propertyId/stats'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));

      print('📡 Property Stats API Response Status: ${response.statusCode}');
      print('📄 Property Stats API Response Body: ${response.body}');

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
            'message': error['message'] ?? 'Failed to fetch property stats',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.body}',
          };
        }
      }
    } catch (e) {
      print('💥 Property Stats API Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Upload property logo
  static Future<Map<String, dynamic>> uploadPropertyLogo({
    required String propertyId,
    required Uint8List logoBytes,
  }) async {
    try {
      // Validate property ID
      if (propertyId.isEmpty) {
        return {
          'success': false,
          'message': 'Property ID is required',
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
        Uri.parse('${ApiConfig.baseUrl}/v1/properties/$propertyId/upload-logo'),
      );
      
      // Add headers
      request.headers.addAll(headers);
      
      // Add logo file with proper content type
      request.files.add(
        http.MultipartFile.fromBytes(
          'logo',
          logoBytes,
          filename: 'property_logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Logo uploaded successfully',
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? error['error'] ?? 'Failed to upload logo',
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

  // Upload property images
  static Future<Map<String, dynamic>> uploadPropertyImages({
    required String propertyId,
    required List<Uint8List> imageBytesList,
  }) async {
    try {
      // Validate inputs
      if (propertyId.isEmpty) {
        return {
          'success': false,
          'message': 'Property ID is required',
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
        Uri.parse('${ApiConfig.baseUrl}/v1/properties/$propertyId/upload-images'),
      );
      
      // Add headers
      request.headers.addAll(headers);
      
      // Add image files with proper content type
      for (int i = 0; i < imageBytesList.length; i++) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'images[]',
            imageBytesList[i],
            filename: 'property_image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
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
          'message': 'Images uploaded successfully',
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? error['error'] ?? 'Failed to upload images',
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

  // Alternative upload method with fallback approaches
  static Future<Map<String, dynamic>> uploadPropertyLogoWithFallback({
    required String propertyId,
    required Uint8List logoBytes,
  }) async {
    // Try the primary method first
    var result = await uploadPropertyLogo(
      propertyId: propertyId,
      logoBytes: logoBytes,
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
        Uri.parse('${ApiConfig.baseUrl}/v1/properties/$propertyId/upload-logo'),
      );
      
      request.headers.addAll(headers);
      request.files.add(
        http.MultipartFile.fromBytes(
          'logo',
          logoBytes,
          filename: 'property_logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Logo uploaded successfully (fallback method)',
        };
      }
    } catch (e) {
      // Fallback also failed
    }
    
    // Return the original error if all methods fail
    return result;
  }

  // Alternative upload method for images with fallback approaches
  static Future<Map<String, dynamic>> uploadPropertyImagesWithFallback({
    required String propertyId,
    required List<Uint8List> imageBytesList,
  }) async {
    // Try the primary method first
    var result = await uploadPropertyImages(
      propertyId: propertyId,
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
        Uri.parse('${ApiConfig.baseUrl}/v1/properties/$propertyId/upload-images'),
      );
      
      request.headers.addAll(headers);
      
      for (int i = 0; i < imageBytesList.length; i++) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'images[]',
            imageBytesList[i],
            filename: 'property_image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
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
          'message': 'Images uploaded successfully (fallback method)',
        };
      }
    } catch (e) {
      // Fallback also failed
    }
    
    // Return the original error if all methods fail
    return result;
  }
}
