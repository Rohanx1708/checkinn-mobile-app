import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../../../services/auth_service.dart';

class BookingsService {
  // Get all bookings
  static Future<Map<String, dynamic>> getBookings({
    int page = 1,
    int limit = 50,
    String? search,
    String? status,
    String? propertyId,
    DateTime? checkInDate,
    DateTime? checkOutDate,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        // Many Laravel APIs expect per_page rather than limit
        'per_page': limit.toString(),
        // Keep limit for compatibility in case backend supports it
        'limit': limit.toString(),
      };
      
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      
      if (propertyId != null && propertyId.isNotEmpty) {
        queryParams['property_id'] = propertyId;
      }
      
      if (checkInDate != null) {
        queryParams['check_in_date'] = checkInDate.toIso8601String().split('T')[0];
        queryParams['start_date'] = checkInDate.toIso8601String().split('T')[0];
        queryParams['date_from'] = checkInDate.toIso8601String().split('T')[0];
      }
      
      if (checkOutDate != null) {
        queryParams['check_out_date'] = checkOutDate.toIso8601String().split('T')[0];
        queryParams['end_date'] = checkOutDate.toIso8601String().split('T')[0];
        queryParams['date_to'] = checkOutDate.toIso8601String().split('T')[0];
      }
      
      final uri = Uri.parse(ApiConfig.bookings).replace(
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
        final List<dynamic> list = (data['data'] ?? data['bookings'] ?? []) as List<dynamic>;
        final sampleId = list.isNotEmpty ? list.first is Map ? (list.first as Map)['id'] : null : null;
        return {
          'success': true,
          'data': data,
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to fetch bookings',
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

  // Get single booking by ID
  static Future<Map<String, dynamic>> getBooking(String bookingId) async {
    try {
      
      // Get auth token
      final token = await AuthService.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await http.get(
        Uri.parse('${ApiConfig.bookings}/$bookingId'),
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
            'message': error['message'] ?? 'Failed to fetch booking',
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

  // Create new booking with named parameters
  static Future<Map<String, dynamic>> createBookingWithParams({
    required String customerName,
    String? customerEmail,
    required String customerPhone,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int totalGuests,
    required String propertyId,
    String? status,
    String? notes,
    String? remarks,
    double? subtotal,
    double? gst,
    double? totalCost,
    double? discount,
    double? finalAmount,
    List<Map<String, dynamic>>? guests,
    List<Map<String, dynamic>>? addOns,
    // Additional fields
    int? adults,
    int? children,
    int? infants,
    double? totalAmount,
    String? paymentStatus,
    String? bookingStatus,
    String? source,
    String? roomType,
  }) async {
    try {
      
      final requestBody = {
        'guest_name': customerName,
        'guest_email': customerEmail ?? '',
        'guest_phone': customerPhone,
        'check_in_date': checkInDate.toIso8601String(),
        'check_out_date': checkOutDate.toIso8601String(),
        // Map to backend's expected naming
        'guest_count': totalGuests,
        'property_id': propertyId,
        if (roomType != null && roomType.isNotEmpty) 'room_type': roomType,
        'adults': adults ?? totalGuests,
        'children': children ?? 0,
        'infants': infants ?? 0,
        'total_amount': totalAmount ?? totalCost ?? 0.0,
        'payment_status': paymentStatus ?? 'pending',
        'booking_status': bookingStatus ?? status ?? 'pending',
        'source': source ?? 'direct',
        if (notes != null && notes.isNotEmpty) 'special_requests': notes,
        if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
        if (subtotal != null) 'subtotal': subtotal,
        if (gst != null) 'gst': gst,
        if (totalCost != null) 'total_cost': totalCost,
        if (discount != null) 'discount': discount,
        if (finalAmount != null) 'final_amount': finalAmount,
        if (guests != null) 'guests': guests,
        if (addOns != null) 'add_ons': addOns,
      };
      
      // Get auth token
      final token = await AuthService.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await http.post(
        Uri.parse(ApiConfig.bookings),
        headers: headers,
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));

      print('📡 Create Booking API Response Status: ${response.statusCode}');
      print('📄 Create Booking API Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Booking created successfully',
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to create booking',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.body}',
          };
        }
      }
    } catch (e) {
      print('💥 Create Booking API Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Update booking
  static Future<Map<String, dynamic>> updateBooking({
    required String bookingId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      
      // Validate required fields
      final requiredFields = ['guest_name', 'guest_phone', 'check_in_date', 'check_out_date'];
      final missingFields = requiredFields.where((field) => 
        updateData[field] == null || updateData[field].toString().isEmpty
      ).toList();
      
      if (missingFields.isNotEmpty) {
        return {
          'success': false,
          'message': 'Missing required fields: ${missingFields.join(', ')}',
        };
      }
      
      
      // Get auth token
      final token = await AuthService.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final url = '${ApiConfig.bookings}/$bookingId';

      // Try PATCH method first, then PUT if PATCH fails
      var response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(updateData),
      ).timeout(const Duration(seconds: 30));
      
      // If PATCH method is not supported, try PUT
      if (response.statusCode == 405) {
        response = await http.put(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(updateData),
        ).timeout(const Duration(seconds: 30));
      }
      
      // If PUT also fails, try POST with _method override
      if (response.statusCode == 405) {
        final postData = Map<String, dynamic>.from(updateData);
        postData['_method'] = 'PUT';
        
        response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(postData),
        ).timeout(const Duration(seconds: 30));
      }


      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        return {
          'success': true,
          'data': data,
          'message': 'Booking updated successfully',
        };
      } else if (response.statusCode == 422) {
        // Validation error - show specific field errors
        try {
          final errorData = jsonDecode(response.body);
          final errors = errorData['errors'] ?? {};
          final errorMessages = <String>[];
          
          errors.forEach((field, messages) {
            if (messages is List) {
              errorMessages.addAll(messages.map((msg) => '$field: $msg'));
            }
          });
          
          return {
            'success': false,
            'message': 'Validation failed: ${errorMessages.join(', ')}',
            'validationErrors': errors,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Validation failed: ${response.body}',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Authentication failed. Please login again.',
          'needsAuth': true,
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': 'You don\'t have permission to update this booking',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Booking not found',
        };
      } else if (response.statusCode == 422) {
        // Validation errors
        try {
          final error = jsonDecode(response.body);
          final errors = error['errors'] ?? error['data'];
          String errorMessage = 'Validation failed';
          if (errors != null && errors is Map) {
            errorMessage = errors.values.first?.first?.toString() ?? errorMessage;
          }
          return {
            'success': false,
            'message': errorMessage,
            'errors': errors,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Validation failed: ${response.body}',
          };
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to update booking',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error ${response.statusCode}: ${response.body}',
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

  // Delete booking
  static Future<Map<String, dynamic>> deleteBooking(String bookingId) async {
    try {
      
      // Get auth token
      final token = await AuthService.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await http.delete(
        Uri.parse('${ApiConfig.bookings}/$bookingId'),
        headers: headers,
      ).timeout(const Duration(seconds: 30));


      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Booking deleted successfully',
        };
      } else if (response.statusCode == 404) {
        // Treat not found as already deleted for idempotent UX
        return {
          'success': true,
          'message': 'Booking already removed',
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to delete booking',
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

  // Get booking statistics
  static Future<Map<String, dynamic>> getBookingStats({
    String? bookingId,
    String? propertyId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      
      String url = ApiConfig.bookings;
      if (bookingId != null) {
        url += '/$bookingId/stats';
      } else {
        url += '/stats';
      }
      
      final queryParams = <String, String>{};
      if (propertyId != null) {
        queryParams['property_id'] = propertyId;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
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
            'message': error['message'] ?? 'Failed to fetch booking stats',
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

  // Create new booking
  static Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final token = await AuthService.getToken();
      final headers = token != null ? ApiConfig.getAuthHeaders(token) : ApiConfig.defaultHeaders;
      
      final response = await http.post(
        Uri.parse(ApiConfig.bookings),
        headers: headers,
        body: jsonEncode(bookingData),
      ).timeout(const Duration(seconds: 30));
      
      print('📡 Create Booking API Response Status: ${response.statusCode}');
      print('📄 Create Booking API Response Body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Booking created successfully',
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to create booking',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Server error: ${response.body}',
          };
        }
      }
    } catch (e) {
      print('💥 Create Booking API Error: $e');
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Get available rooms for specific room type and dates
  static Future<Map<String, dynamic>> getAvailableRooms({
    required int roomTypeId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
  }) async {
    try {
      
      final queryParams = <String, String>{
        'room_type_id': roomTypeId.toString(),
        'check_in_date': checkInDate.toIso8601String().split('T')[0],
        'check_out_date': checkOutDate.toIso8601String().split('T')[0],
      };
      
      final uri = Uri.parse('${ApiConfig.baseUrl}/v1/bookings/available-rooms').replace(
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
            'message': error['message'] ?? 'Failed to fetch available rooms',
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

  // Update booking status
  static Future<Map<String, dynamic>> updateBookingStatus({
    required String bookingId,
    required String status,
    String? notes,
  }) async {
    try {
      print('📅 Updating booking status: $bookingId to $status');
      
      final requestBody = {
        'status': status,
        if (notes != null) 'notes': notes,
      };
      
      // Get auth token
      final token = await AuthService.getToken();
      final headers = token != null 
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final response = await http.patch(
        Uri.parse('${ApiConfig.bookings}/$bookingId/status'),
        headers: headers,
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));


      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Booking status updated successfully',
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {
            'success': false,
            'message': error['message'] ?? 'Failed to update booking status',
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

  // Alternative room allocation method - try different formats
  static Future<Map<String, dynamic>> allocateRoomAlternative({
    required String bookingId,
    required int roomId,
  }) async {
    try {

      final token = await AuthService.getToken();
      final headers = token != null
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final url = '${ApiConfig.baseUrl}/v1/bookings/$bookingId/allocate-rooms';
      
      // Try single room_id format
      final body = jsonEncode({'room_id': roomId});
      
      print('🌐 Alternative Allocate Room URL: $url');
      print('📝 Alternative Allocate Room Body: $body');
      print('🔍 Trying format: single room_id');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 30));

      print('📡 Alternative Allocate Room API Status: ${response.statusCode}');
      print('📄 Alternative Allocate Room API Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data, 'message': 'Room allocated successfully'};
      } else if (response.statusCode == 500) {
        print('⚠️ Alternative room allocation server error (500)');
        return {
          'success': false, 
          'message': 'Room allocation failed due to server error',
          'serverError': true
        };
      }
      try {
        final err = jsonDecode(response.body);
        return {'success': false, 'message': err['message'] ?? 'Failed to allocate room'};
      } catch (_) {
        return {'success': false, 'message': 'Server error: ${response.body}'};
      }
    } catch (e) {
      print('💥 Alternative Allocate Room API Error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> allocateRoom({
    required String bookingId,
    required int roomId,
  }) async {
    try {
      print('🏨 Allocating room: booking=$bookingId, roomId=$roomId');

      final token = await AuthService.getToken();
      final headers = token != null
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final url = '${ApiConfig.baseUrl}/v1/bookings/$bookingId/allocate-rooms';
      
      // Try different body formats to find what the backend expects
      Map<String, dynamic> bodyData;
      
      // Format 1: Array of room IDs
      bodyData = {'room_ids': [roomId]};
      
      // Format 2: Single room ID (if backend expects different format)
      // bodyData = {'room_id': roomId};
      
      // Format 3: Direct array
      // bodyData = [roomId];
      
      final body = jsonEncode(bodyData);
      
      print('🌐 Allocate Room URL: $url');
      print('📝 Allocate Room Body: $body');
      print('🔍 Trying format: room_ids array');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 30));

      print('📡 Allocate Room API Status: ${response.statusCode}');
      print('📄 Allocate Room API Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data, 'message': 'Room allocated successfully'};
      } else if (response.statusCode == 500) {
        // Server error - room allocation failed but booking was updated
        print('⚠️ Room allocation server error (500) - booking update still succeeded');
        return {
          'success': false, 
          'message': 'Room allocation failed due to server error, but booking was updated successfully',
          'serverError': true
        };
      }
      try {
        final err = jsonDecode(response.body);
        return {'success': false, 'message': err['message'] ?? 'Failed to allocate room'};
      } catch (_) {
        return {'success': false, 'message': 'Server error: ${response.body}'};
      }
    } catch (e) {
      print('💥 Allocate Room API Error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Room allocation using new API endpoint
  static Future<Map<String, dynamic>> allocateRooms({
    required String bookingId,
    required List<int> roomIds,
  }) async {
    try {
      print('🏨 Allocating rooms: booking=$bookingId, roomIds=$roomIds');

      final token = await AuthService.getToken();
      final headers = token != null
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final url = '${ApiConfig.baseUrl}/v1/bookings/$bookingId/allocate-rooms';
      
      final body = jsonEncode({
        'room_ids': roomIds,
      });
      
      print('🌐 Room Allocation URL: $url');
      print('📝 Room Allocation Body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 30));

      print('📡 Room Allocation API Status: ${response.statusCode}');
      print('📄 Room Allocation API Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data, 'message': 'Rooms allocated successfully'};
      } else if (response.statusCode == 500) {
        print('⚠️ Room allocation server error (500)');
        return {
          'success': false, 
          'message': 'Room allocation failed due to server error',
          'serverError': true
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {'success': false, 'message': error['message'] ?? 'Failed to allocate rooms'};
        } catch (_) {
          return {'success': false, 'message': 'Server error: ${response.body}'};
        }
      }
    } catch (e) {
      print('💥 Room Allocation API Error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Update room allocations using new API endpoint
  static Future<Map<String, dynamic>> updateRoomAllocations({
    required String bookingId,
    required List<int> roomIds,
  }) async {
    try {
      print('🔄 Updating room allocations: booking=$bookingId, roomIds=$roomIds');

      final token = await AuthService.getToken();
      final headers = token != null
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final url = '${ApiConfig.baseUrl}/v1/bookings/$bookingId/allocate-rooms';
      
      final body = jsonEncode({
        'room_ids': roomIds,
      });
      
      print('🌐 Update Room Allocation URL: $url');
      print('📝 Update Room Allocation Body: $body');

      // Try PUT method first
      var response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 30));
      
      // If PUT fails, try POST method
      if (response.statusCode == 405 || response.statusCode == 404) {
        print('⚠️ PUT method failed (${response.statusCode}), trying POST method');
        response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: body,
        ).timeout(const Duration(seconds: 30));
      }

      print('📡 Update Room Allocation API Status: ${response.statusCode}');
      print('📄 Update Room Allocation API Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data, 'message': 'Room allocations updated successfully'};
      } else if (response.statusCode == 500) {
        print('⚠️ Update room allocation server error (500)');
        return {
          'success': false, 
          'message': 'Room allocation update failed due to server error',
          'serverError': true
        };
      } else {
        try {
          final error = jsonDecode(response.body);
          return {'success': false, 'message': error['message'] ?? 'Failed to update room allocations'};
        } catch (_) {
          return {'success': false, 'message': 'Server error: ${response.body}'};
        }
      }
    } catch (e) {
      print('💥 Update Room Allocation API Error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Clear all room allocations for a booking
  static Future<Map<String, dynamic>> clearRoomAllocations({
    required String bookingId,
  }) async {
    try {
      print('🗑️ Clearing room allocations for booking: $bookingId');

      final token = await AuthService.getToken();
      final headers = token != null
          ? ApiConfig.getAuthHeaders(token)
          : ApiConfig.defaultHeaders;

      final url = '${ApiConfig.baseUrl}/v1/bookings/$bookingId/allocate-rooms';
      
      final body = jsonEncode({
        'room_ids': [],
      });
      
      print('🌐 Clear Room Allocation URL: $url');
      print('📝 Clear Room Allocation Body: $body');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 30));

      print('📡 Clear Room Allocation API Status: ${response.statusCode}');
      print('📄 Clear Room Allocation API Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data, 'message': 'Room allocations cleared successfully'};
      } else {
        try {
          final error = jsonDecode(response.body);
          return {'success': false, 'message': error['message'] ?? 'Failed to clear room allocations'};
        } catch (_) {
          return {'success': false, 'message': 'Server error: ${response.body}'};
        }
      }
    } catch (e) {
      print('💥 Clear Room Allocation API Error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
