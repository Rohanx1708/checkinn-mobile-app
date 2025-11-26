import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../../../services/auth_service.dart';

class ReportsService {
  static Future<Map<String, dynamic>> _get(String url, {Map<String, String>? query}) async {
    try {
      // Debug: log request
      // ignore: avoid_print
      print('[Reports] GET ' + url + ' ' + (query?.toString() ?? '')); 
      final token = await AuthService.getToken();
      final headers = token != null ? ApiConfig.getAuthHeaders(token) : ApiConfig.defaultHeaders;
      final uri = Uri.parse(url).replace(queryParameters: query);
      final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));
      // ignore: avoid_print
      print('[Reports] <- ${res.statusCode} for ' + uri.toString());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {'success': true, 'data': data};
      }
      try {
        final err = jsonDecode(res.body);
        // ignore: avoid_print
        print('[Reports] Error body: ' + res.body);
        return {'success': false, 'message': err['message'] ?? 'Failed to fetch report'};
      } catch (_) {
        // ignore: avoid_print
        print('[Reports] Non-JSON error: ' + res.body);
        return {'success': false, 'message': 'Server error: ${res.body}'};
      }
    } catch (e) {
      // ignore: avoid_print
      print('[Reports] Network error: ' + e.toString());
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Generic overview report
  static Future<Map<String, dynamic>> getOverview({String? propertyId, DateTime? start, DateTime? end}) {
    final query = <String, String>{};
    if (propertyId != null) query['property_id'] = propertyId;
    if (start != null) query['start_date'] = start.toIso8601String().split('T').first;
    if (end != null) query['end_date'] = end.toIso8601String().split('T').first;
    return _get(ApiConfig.baseUrl + '/v1/reports/overview', query: query);
  }

  static Future<Map<String, dynamic>> getBookingsReport({String? propertyId, DateTime? start, DateTime? end}) async {
    final query = <String, String>{};
    if (propertyId != null) query['property_id'] = propertyId;
    if (start != null) query['start_date'] = start.toIso8601String().split('T').first;
    if (end != null) query['end_date'] = end.toIso8601String().split('T').first;

    // First try a dedicated booking status endpoint
    final primary = await _get(ApiConfig.baseUrl + '/v1/reports/booking-status', query: query);
    if (primary['success'] == true) return primary;

    // Fallback: compute from dashboard window if available
    final s = query['start_date'] ?? DateTime.now().subtract(const Duration(days: 30)).toIso8601String().split('T').first;
    final e = query['end_date'] ?? DateTime.now().toIso8601String().split('T').first;
    final dash = await getDashboard(startDate: s, endDate: e);
    return dash['success'] == true ? dash : primary; // surface primary error if both fail
  }

  static Future<Map<String, dynamic>> getMonthlyBookingsTrend({int months = 12}) {
    final query = <String, String>{'months': months.toString()};
    return _get(ApiConfig.reportsMonthlyBookings, query: query);
  }

  static Future<Map<String, dynamic>> getRevenueReport({String? propertyId, DateTime? start, DateTime? end}) {
    final query = <String, String>{'type': 'revenue'};
    if (propertyId != null) query['property_id'] = propertyId;
    if (start != null) query['start_date'] = start.toIso8601String().split('T').first;
    if (end != null) query['end_date'] = end.toIso8601String().split('T').first;
    return _get(ApiConfig.reports, query: query);
  }

  static Future<Map<String, dynamic>> getRevenueMonthly({int months = 12, String period = 'month'}) {
    final query = <String, String>{'period': period, 'months': months.toString()};
    return _get(ApiConfig.baseUrl + '/v1/reports/revenue', query: query);
  }

  static Future<Map<String, dynamic>> getPropertiesReport({String? propertyId, DateTime? start, DateTime? end}) {
    final query = <String, String>{'type': 'properties'};
    if (propertyId != null) query['property_id'] = propertyId;
    if (start != null) query['start_date'] = start.toIso8601String().split('T').first;
    if (end != null) query['end_date'] = end.toIso8601String().split('T').first;
    return _get(ApiConfig.reports, query: query);
  }

  static Future<Map<String, dynamic>> getTopPerformingProperties({String? propertyId, DateTime? start, DateTime? end, int? limit}) {
    final query = <String, String>{'type': 'top_properties'};
    if (propertyId != null) query['property_id'] = propertyId;
    if (start != null) query['start_date'] = start.toIso8601String().split('T').first;
    if (end != null) query['end_date'] = end.toIso8601String().split('T').first;
    if (limit != null) query['limit'] = limit.toString();
    return _get(ApiConfig.reports, query: query);
  }

  static Future<Map<String, dynamic>> getTopRoomTypes({DateTime? start, DateTime? end, int? limit}) {
    final query = <String, String>{};
    if (start != null) query['start_date'] = start.toIso8601String().split('T').first;
    if (end != null) query['end_date'] = end.toIso8601String().split('T').first;
    if (limit != null) query['limit'] = limit.toString();
    return _get(ApiConfig.reportsTopRoomTypes, query: query);
  }

  static Future<Map<String, dynamic>> getDashboard({required String startDate, required String endDate}) async {
    try {
      final token = await AuthService.getToken();
      final headers = token != null ? ApiConfig.getAuthHeaders(token) : ApiConfig.defaultHeaders;
      final url = Uri.parse('${ApiConfig.baseUrl}/v1/reports/dashboard?start_date=$startDate&end_date=$endDate');
      print('[Reports] GET $url {}');
      final res = await http.get(url, headers: headers).timeout(const Duration(seconds: 30));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {'success': true, 'data': data};
      } else {
        print('[Reports] <- ${res.statusCode} for $url');
        print('[Reports] Error body: ${res.body}');
        return {'success': false, 'message': _extractMessage(res.body)};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static String _extractMessage(String body) {
    try {
      final j = jsonDecode(body);
      return j['message']?.toString() ?? 'Request failed';
    } catch (_) {
      return 'Request failed';
    }
  }
}


