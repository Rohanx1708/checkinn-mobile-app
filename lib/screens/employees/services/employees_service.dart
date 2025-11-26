import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../../../services/auth_service.dart';

class EmployeesService {
  // List employees (with pagination and optional search/property filter)
  static Future<Map<String, dynamic>> getEmployees({
    int page = 1,
    int limit = 50,
    String? search,
    String? propertyId,
    String? department,
    String? role,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': limit.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (propertyId != null && propertyId.isNotEmpty) 'property_id': propertyId,
        if (department != null && department.isNotEmpty && department != 'All' && department != 'All Departments') 'department': department,
        if (role != null && role.isNotEmpty && role != 'All' && role != 'All Roles') 'role': role,
        if (status != null && status.isNotEmpty && status != 'All' && status != 'All Status') 'status': status,
      };

      final uri = Uri.parse(ApiConfig.employees).replace(queryParameters: queryParams);
      final token = await AuthService.getToken();
      final headers = token != null ? ApiConfig.getAuthHeaders(token) : ApiConfig.defaultHeaders;

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      }
      try {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to fetch employees'};
      } catch (_) {
        return {'success': false, 'message': 'Server error: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get single employee
  static Future<Map<String, dynamic>> getEmployee(String employeeId) async {
    try {
      final token = await AuthService.getToken();
      final headers = token != null ? ApiConfig.getAuthHeaders(token) : ApiConfig.defaultHeaders;

      final response = await http
          .get(Uri.parse('${ApiConfig.employees}/$employeeId'), headers: headers)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      }
      try {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to fetch employee'};
      } catch (_) {
        return {'success': false, 'message': 'Server error: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Create employee
  static Future<Map<String, dynamic>> createEmployee(Map<String, dynamic> body) async {
    try {
      print('🏢 Creating employee via API: ${ApiConfig.employees}');
      print('📤 Request body: ${jsonEncode(body)}');
      
      final token = await AuthService.getToken();
      final headers = token != null ? ApiConfig.getAuthHeaders(token) : ApiConfig.defaultHeaders;
      
      print('🔑 Using token: ${token != null ? 'Yes' : 'No'}');
      print('📋 Headers: $headers');

      final response = await http
          .post(Uri.parse(ApiConfig.employees), headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Employee created successfully');
        return {'success': true, 'data': data, 'message': 'Employee created successfully'};
      }
      try {
        final error = jsonDecode(response.body);
        print('❌ API Error: ${error['message']}');
        return {'success': false, 'message': error['message'] ?? 'Failed to create employee'};
      } catch (_) {
        print('❌ Server Error: ${response.body}');
        return {'success': false, 'message': 'Server error: ${response.body}'};
      }
    } catch (e) {
      print('❌ Network Error: ${e.toString()}');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Update employee
  static Future<Map<String, dynamic>> updateEmployee(String employeeId, Map<String, dynamic> body) async {
    try {
      final token = await AuthService.getToken();
      final headers = token != null ? ApiConfig.getAuthHeaders(token) : ApiConfig.defaultHeaders;

      final response = await http
          .put(Uri.parse('${ApiConfig.employees}/$employeeId'), headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data, 'message': 'Employee updated successfully'};
      }
      try {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to update employee'};
      } catch (_) {
        return {'success': false, 'message': 'Server error: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Delete employee
  static Future<Map<String, dynamic>> deleteEmployee(String employeeId) async {
    try {
      final token = await AuthService.getToken();
      final headers = token != null ? ApiConfig.getAuthHeaders(token) : ApiConfig.defaultHeaders;

      final response = await http
          .delete(Uri.parse('${ApiConfig.employees}/$employeeId'), headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true, 'message': 'Employee deleted successfully'};
      }
      try {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to delete employee'};
      } catch (_) {
        return {'success': false, 'message': 'Server error: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> getFilterOptions() async {
    try {
      final token = await AuthService.getToken();
      final headers = token != null ? ApiConfig.getAuthHeaders(token) : ApiConfig.defaultHeaders;

      final uri = Uri.parse('${ApiConfig.employees}/filters');
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      }
      try {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Failed to fetch filters'};
      } catch (_) {
        return {'success': false, 'message': 'Server error: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}


