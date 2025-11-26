import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';

class CrmService {
  static String? authToken;

  static Map<String, String> _headers() {
    if (authToken == null) return ApiConfig.defaultHeaders;
    return ApiConfig.getAuthHeaders(authToken!);
  }

  // Basic customer DTO
  static Map<String, dynamic> _customerToBody({
    required String name,
    required String email,
    required String phone,
    required String status,
    required String source,
    double? rating,
    String? notes,
  }) {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'status': status.toLowerCase(),
      'source': source,
      if (rating != null) 'rating': rating,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };
  }

  static Future<List<Map<String, dynamic>>> fetchCustomers({int page = 1, int perPage = 50}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/v1/crm/customers?page=$page&per_page=$perPage');
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = json.decode(res.body);
      final list = (data['data'] ?? data['customers'] ?? data['items'] ?? data) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to load customers (${res.statusCode})');
  }

  static Future<List<Map<String, dynamic>>> fetchAllCustomers({int perPage = 200}) async {
    final List<Map<String, dynamic>> all = [];
    int page = 1;
    while (true) {
      final batch = await fetchCustomers(page: page, perPage: perPage);
      if (batch.isEmpty) break;
      all.addAll(batch);
      if (batch.length < perPage) break;
      page++;
      if (page > 100) break; // safety guard
    }
    return all;
  }

  static Future<Map<String, dynamic>> createCustomer({
    required String name,
    required String email,
    required String phone,
    required String status,
    required String source,
    double? rating,
    String? notes,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/v1/crm/customers');
    final body = json.encode(_customerToBody(
      name: name,
      email: email,
      phone: phone,
      status: status,
      source: source,
      rating: rating,
      notes: notes,
    ));
    final res = await http.post(uri, headers: _headers(), body: body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Create failed (${res.statusCode}): ${res.body}');
  }

  static Future<Map<String, dynamic>> updateCustomer({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/v1/crm/customers/$id');
    final res = await http.put(uri, headers: _headers(), body: json.encode(updates));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Update failed (${res.statusCode}): ${res.body}');
  }

  static Future<void> deleteCustomer(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/v1/crm/customers/$id');
    final res = await http.delete(uri, headers: _headers());
    if (res.statusCode == 200 || res.statusCode == 204 || res.statusCode == 404) {
      return;
    }
    throw Exception('Delete failed (${res.statusCode})');
  }

  // LEADS
  static Future<List<Map<String, dynamic>>> fetchLeads({int page = 1, int perPage = 50}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/v1/crm/leads?page=$page&per_page=$perPage');
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = json.decode(res.body);
      final list = (data['data'] ?? data['leads'] ?? data['items'] ?? data) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    }
    throw Exception('Failed to load leads (${res.statusCode})');
  }

  static Future<List<Map<String, dynamic>>> fetchAllLeads({int perPage = 200}) async {
    final List<Map<String, dynamic>> all = [];
    int page = 1;
    while (true) {
      final batch = await fetchLeads(page: page, perPage: perPage);
      if (batch.isEmpty) break;
      all.addAll(batch);
      if (batch.length < perPage) break;
      page++;
      if (page > 100) break;
    }
    return all;
  }

  static Future<Map<String, dynamic>> createLead(Map<String, dynamic> body) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/v1/crm/leads');
    final res = await http.post(uri, headers: _headers(), body: json.encode(body));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Create lead failed (${res.statusCode}): ${res.body}');
  }

  static Future<Map<String, dynamic>> updateLead({required String id, required Map<String, dynamic> updates}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/v1/crm/leads/$id');
    final res = await http.put(uri, headers: _headers(), body: json.encode(updates));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Update lead failed (${res.statusCode}): ${res.body}');
  }

  static Future<void> deleteLead(String id) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/v1/crm/leads/$id');
    final res = await http.delete(uri, headers: _headers());
    if (res.statusCode == 200 || res.statusCode == 204 || res.statusCode == 404) {
      return;
    }
    throw Exception('Delete lead failed (${res.statusCode})');
  }

  // CRM Analytics
  static Future<Map<String, dynamic>> fetchCrmAnalytics() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/v1/crm/analytics');
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = json.decode(res.body);
      return (data['data'] ?? data) as Map<String, dynamic>;
    }
    throw Exception('Failed to load CRM analytics (${res.statusCode})');
  }

  // CRM Customer Sources (for acquisition donut)
  static Future<Map<String, dynamic>> fetchCustomerSources() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/v1/crm/customer-sources');
    final res = await http.get(uri, headers: _headers());
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = json.decode(res.body);
      return (data['data'] ?? data) as Map<String, dynamic>;
    }
    throw Exception('Failed to load customer sources (${res.statusCode})');
  }
}


