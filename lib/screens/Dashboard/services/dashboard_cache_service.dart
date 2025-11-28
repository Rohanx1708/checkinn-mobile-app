import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to cache and retrieve dashboard data for instant loading
class DashboardCacheService {
  static const String _cacheKey = 'dashboard_cache';
  static const String _cacheTimestampKey = 'dashboard_cache_timestamp';
  static const Duration _cacheExpiry = Duration(hours: 24); // Cache valid for 24 hours

  /// Save dashboard data to cache
  static Future<void> saveDashboardData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert DateTime objects in calendarBookings to ISO strings for JSON serialization
      final dataToSave = Map<String, dynamic>.from(data);
      if (dataToSave['calendarBookings'] != null) {
        final calendarBookings = dataToSave['calendarBookings'] as List<dynamic>;
        dataToSave['calendarBookings'] = calendarBookings.map((booking) {
          final bookingMap = Map<String, dynamic>.from(booking);
          if (bookingMap['date'] is DateTime) {
            bookingMap['date'] = (bookingMap['date'] as DateTime).toIso8601String();
          }
          return bookingMap;
        }).toList();
      }
      
      await prefs.setString(_cacheKey, jsonEncode(dataToSave));
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
      print('💾 Dashboard data cached');
    } catch (e) {
      print('❌ Error caching dashboard data: $e');
    }
  }

  /// Load dashboard data from cache
  static Future<Map<String, dynamic>?> loadDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      final timestamp = prefs.getInt(_cacheTimestampKey);

      if (cachedData == null || timestamp == null) {
        return null;
      }

      // Check if cache is expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      if (now.difference(cacheTime) > _cacheExpiry) {
        // Cache expired, clear it
        await clearCache();
        return null;
      }

      final data = jsonDecode(cachedData) as Map<String, dynamic>;
      print('📦 Dashboard data loaded from cache');
      return data;
    } catch (e) {
      print('❌ Error loading cached dashboard data: $e');
      return null;
    }
  }

  /// Clear dashboard cache
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimestampKey);
      print('🧹 Dashboard cache cleared');
    } catch (e) {
      print('❌ Error clearing dashboard cache: $e');
    }
  }

  /// Check if cache exists and is valid
  static Future<bool> hasValidCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      final timestamp = prefs.getInt(_cacheTimestampKey);

      if (cachedData == null || timestamp == null) {
        return false;
      }

      // Check if cache is expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      return now.difference(cacheTime) <= _cacheExpiry;
    } catch (e) {
      return false;
    }
  }
}

