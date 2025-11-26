import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../../../services/auth_service.dart';

class CalendarService {
  // Calendar views
  static Future<Map<String, dynamic>> getMonthly({DateTime? date}) async {
    return _fetchCalendarView('monthly', date: date);
  }

  static Future<Map<String, dynamic>> getWeekly({DateTime? date}) async {
    return _fetchCalendarView('weekly', date: date);
  }

  static Future<Map<String, dynamic>> getDaily({DateTime? date}) async {
    return _fetchCalendarView('daily', date: date);
  }

  static Future<Map<String, dynamic>> _fetchCalendarView(String view, {DateTime? date}) async {
    try {
      final String url = '${ApiConfig.baseUrl}/v1/bookings/calendar/$view';
      final queryParams = <String, String>{
        if (date != null) 'date': date.toIso8601String().split('T')[0],
      };
      final uri = Uri.parse(url).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      print('🔍 Calendar API - Fetching $view view for date: $date');
      print('🔍 Calendar API - URL: $uri');

      final token = await AuthService.getToken();
      final headers = token != null ? ApiConfig.getAuthHeaders(token) : ApiConfig.defaultHeaders;

      print('🔍 Calendar API - Headers: $headers');

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));
      
      print('🔍 Calendar API - Response Status: ${response.statusCode}');
      print('🔍 Calendar API - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      }
      try {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to fetch $view calendar'};
      } catch (_) {
        return {'success': false, 'message': 'Server error: ${response.body}'};
      }
    } catch (e) {
      print('🔍 Calendar API - Error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Fetch events within a date range
  static Future<Map<String, dynamic>> getEvents({
    required DateTime startDate,
    required DateTime endDate,
    String? propertyId,
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, String>{
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
        'page': page.toString(),
        'per_page': limit.toString(),
        'limit': limit.toString(),
        if (propertyId != null && propertyId.isNotEmpty) 'property_id': propertyId,
      };

      // Reuse bookings endpoint for calendar events if a dedicated endpoint isn't available
      final uri = Uri.parse(ApiConfig.bookings).replace(queryParameters: queryParams);

      print('🔍 Calendar Events API - Fetching events from $startDate to $endDate');
      print('🔍 Calendar Events API - URL: $uri');
      print('🔍 Calendar Events API - Query Params: $queryParams');

      final token = await AuthService.getToken();
      final headers = token != null ? ApiConfig.getAuthHeaders(token) : ApiConfig.defaultHeaders;

      print('🔍 Calendar Events API - Headers: $headers');

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));
      
      print('🔍 Calendar Events API - Response Status: ${response.statusCode}');
      print('🔍 Calendar Events API - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      }
      try {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to fetch events'};
      } catch (_) {
        return {'success': false, 'message': 'Server error: ${response.body}'};
      }
    } catch (e) {
      print('🔍 Calendar Events API - Error: $e');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Create a calendar event (booking placeholder)
  static Future<Map<String, dynamic>> createEvent(Map<String, dynamic> body) async {
    try {
      final token = await AuthService.getToken();
      final headers = token != null ? ApiConfig.getAuthHeaders(token) : ApiConfig.defaultHeaders;
      final response = await http.post(Uri.parse(ApiConfig.bookings), headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      }
      try {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to create event'};
      } catch (_) {
        return {'success': false, 'message': 'Server error: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Update a calendar event
  static Future<Map<String, dynamic>> updateEvent(String id, Map<String, dynamic> body) async {
    try {
      final token = await AuthService.getToken();
      final headers = token != null ? ApiConfig.getAuthHeaders(token) : ApiConfig.defaultHeaders;
      final response = await http.put(Uri.parse('${ApiConfig.bookings}/$id'), headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      }
      try {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to update event'};
      } catch (_) {
        return {'success': false, 'message': 'Server error: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Delete a calendar event
  static Future<Map<String, dynamic>> deleteEvent(String id) async {
    try {
      final token = await AuthService.getToken();
      final headers = token != null ? ApiConfig.getAuthHeaders(token) : ApiConfig.defaultHeaders;
      final response = await http.delete(Uri.parse('${ApiConfig.bookings}/$id'), headers: headers)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      }
      try {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to delete event'};
      } catch (_) {
        return {'success': false, 'message': 'Server error: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}


