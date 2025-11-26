import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../config/api_config.dart';
import '../../../../services/auth_service.dart';

// Riverpod provider for meta options
final bookingMetaProvider = FutureProvider<BookingMetaOptions>((ref) async {
  final helper = BookingMetaHelper();
  return await helper.fetchMetaOptions();
});

class BookingMetaOptions {
  final List<String> paymentStatuses;
  final List<String> bookingStatuses;
  final List<String> sources;
  const BookingMetaOptions({
    required this.paymentStatuses,
    required this.bookingStatuses,
    required this.sources,
  });
}

class BookingMetaHelper {
  Future<BookingMetaOptions> fetchMetaOptions() async {
    try {
      final token = await AuthService.getToken();
      final headers = token != null ? ApiConfig.getAuthHeaders(token) : ApiConfig.defaultHeaders;
      final metaUris = <Uri>[
        Uri.parse('${ApiConfig.baseUrl}/v1/bookings/meta'),
        Uri.parse('${ApiConfig.baseUrl}/v1/bookings/options'),
      ];

      List<String>? payment;
      List<String>? sources;
      List<String>? statuses;

      for (final uri in metaUris) {
        try {
          final res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
          if (res.statusCode >= 200 && res.statusCode < 300 && res.body.isNotEmpty) {
            final decoded = jsonDecode(res.body);
            final Map<String, dynamic> meta = (decoded is Map && decoded['data'] is Map)
                ? (decoded['data'] as Map).cast<String, dynamic>()
                : (decoded is Map ? decoded.cast<String, dynamic>() : <String, dynamic>{});
            final psDyn = meta['payment_statuses'] ?? meta['paymentStatuses'] ?? meta['payment-statuses'] ?? meta['payments'] ?? [];
            final srcDyn = meta['sources'] ?? meta['booking_sources'] ?? meta['bookingSources'] ?? [];
            final bsDyn = meta['booking_statuses'] ?? meta['bookingStatuses'] ?? meta['statuses'] ?? [];
            if (psDyn is List) payment = psDyn.map((e) => e.toString()).toList();
            if (srcDyn is List) sources = srcDyn.map((e) => e.toString()).toList();
            if (bsDyn is List) statuses = bsDyn.map((e) => e.toString()).toList();
          }
        } catch (_) {}
        if (payment != null || sources != null || statuses != null) break;
      }

      if (sources == null) {
        try {
          final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/v1/bookings/sources'), headers: headers).timeout(const Duration(seconds: 20));
          if (res.statusCode >= 200 && res.statusCode < 300) {
            final decoded = jsonDecode(res.body);
            final list = (decoded['data'] ?? decoded['sources'] ?? decoded);
            if (list is List) sources = list.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }
      if (statuses == null) {
        try {
          final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/v1/bookings/statuses'), headers: headers).timeout(const Duration(seconds: 20));
          if (res.statusCode >= 200 && res.statusCode < 300) {
            final decoded = jsonDecode(res.body);
            final list = (decoded['data'] ?? decoded['statuses'] ?? decoded);
            if (list is List) statuses = list.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }

      return BookingMetaOptions(
        paymentStatuses: payment ?? const ['pending','paid','partial','refunded','failed'],
        bookingStatuses: statuses ?? const ['confirmed','checked-in','checked-out','pending','cancelled'],
        sources: sources ?? const ['direct','website','walk-in','phone','ota','agent'],
      );
    } catch (_) {
      return const BookingMetaOptions(
        paymentStatuses: ['pending','paid','partial','refunded','failed'],
        bookingStatuses: ['confirmed','checked-in','checked-out','pending','cancelled'],
        sources: ['direct','website','walk-in','phone','ota','agent'],
      );
    }
  }
}

