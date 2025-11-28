import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Generic cache service for any screen data
class GenericCacheService {
  static const Duration _defaultCacheExpiry = Duration(hours: 24); // Default 24 hours

  /// Save data to cache with a specific key
  static Future<void> saveData(String cacheKey, Map<String, dynamic> data, {Duration? expiry}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampKey = '${cacheKey}_timestamp';
      final expiryDuration = expiry ?? _defaultCacheExpiry;
      
      // Convert DateTime objects to ISO strings for JSON serialization
      final dataToSave = _serializeData(data);
      
      await prefs.setString(cacheKey, jsonEncode(dataToSave));
      await prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
      await prefs.setInt('${cacheKey}_expiry', expiryDuration.inMilliseconds);
      print('💾 Data cached for key: $cacheKey');
    } catch (e) {
      print('❌ Error caching data for key $cacheKey: $e');
    }
  }

  /// Load data from cache
  static Future<Map<String, dynamic>?> loadData(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(cacheKey);
      final timestampKey = '${cacheKey}_timestamp';
      final timestamp = prefs.getInt(timestampKey);
      final expiryMs = prefs.getInt('${cacheKey}_expiry') ?? _defaultCacheExpiry.inMilliseconds;

      if (cachedData == null || timestamp == null) {
        return null;
      }

      // Check if cache is expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final expiry = Duration(milliseconds: expiryMs);
      
      if (now.difference(cacheTime) > expiry) {
        // Cache expired, clear it
        await clearCache(cacheKey);
        return null;
      }

      final data = jsonDecode(cachedData) as Map<String, dynamic>;
      print('📦 Data loaded from cache for key: $cacheKey');
      return _deserializeData(data);
    } catch (e) {
      print('❌ Error loading cached data for key $cacheKey: $e');
      return null;
    }
  }

  /// Clear cache for a specific key
  static Future<void> clearCache(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(cacheKey);
      await prefs.remove('${cacheKey}_timestamp');
      await prefs.remove('${cacheKey}_expiry');
      print('🧹 Cache cleared for key: $cacheKey');
    } catch (e) {
      print('❌ Error clearing cache for key $cacheKey: $e');
    }
  }

  /// Check if cache exists and is valid
  static Future<bool> hasValidCache(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(cacheKey);
      final timestamp = prefs.getInt('${cacheKey}_timestamp');

      if (cachedData == null || timestamp == null) {
        return false;
      }

      final expiryMs = prefs.getInt('${cacheKey}_expiry') ?? _defaultCacheExpiry.inMilliseconds;
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final expiry = Duration(milliseconds: expiryMs);
      
      return now.difference(cacheTime) <= expiry;
    } catch (e) {
      return false;
    }
  }

  /// Serialize data - convert DateTime objects to ISO strings
  static Map<String, dynamic> _serializeData(Map<String, dynamic> data) {
    final serialized = Map<String, dynamic>.from(data);
    
    // Handle lists that might contain DateTime objects
    if (serialized.containsKey('items') && serialized['items'] is List) {
      serialized['items'] = (serialized['items'] as List).map((item) {
        if (item is Map<String, dynamic>) {
          return _serializeMap(item);
        }
        return item;
      }).toList();
    }
    
    // Handle data arrays
    if (serialized.containsKey('data') && serialized['data'] is List) {
      serialized['data'] = (serialized['data'] as List).map((item) {
        if (item is Map<String, dynamic>) {
          return _serializeMap(item);
        }
        return item;
      }).toList();
    }
    
    return serialized;
  }

  /// Serialize a map - convert DateTime to ISO string
  static Map<String, dynamic> _serializeMap(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      if (value is DateTime) {
        result[key] = value.toIso8601String();
      } else if (value is Map) {
        result[key] = _serializeMap(Map<String, dynamic>.from(value));
      } else if (value is List) {
        result[key] = value.map((item) {
          if (item is Map) {
            return _serializeMap(Map<String, dynamic>.from(item));
          } else if (item is DateTime) {
            return item.toIso8601String();
          }
          return item;
        }).toList();
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  /// Deserialize data - convert ISO strings back to DateTime
  static Map<String, dynamic> _deserializeData(Map<String, dynamic> data) {
    final deserialized = Map<String, dynamic>.from(data);
    
    // Handle lists
    if (deserialized.containsKey('items') && deserialized['items'] is List) {
      deserialized['items'] = (deserialized['items'] as List).map((item) {
        if (item is Map<String, dynamic>) {
          return _deserializeMap(item);
        }
        return item;
      }).toList();
    }
    
    if (deserialized.containsKey('data') && deserialized['data'] is List) {
      deserialized['data'] = (deserialized['data'] as List).map((item) {
        if (item is Map<String, dynamic>) {
          return _deserializeMap(item);
        }
        return item;
      }).toList();
    }
    
    return deserialized;
  }

  /// Deserialize a map - convert ISO string to DateTime
  static Map<String, dynamic> _deserializeMap(Map<String, dynamic> map) {
    final result = <String, dynamic>{};
    map.forEach((key, value) {
      if (value is String && _isIso8601Date(value)) {
        final date = DateTime.tryParse(value);
        if (date != null) {
          result[key] = date;
        } else {
          result[key] = value;
        }
      } else if (value is Map) {
        result[key] = _deserializeMap(Map<String, dynamic>.from(value));
      } else if (value is List) {
        result[key] = value.map((item) {
          if (item is Map) {
            return _deserializeMap(Map<String, dynamic>.from(item));
          } else if (item is String && _isIso8601Date(item)) {
            final date = DateTime.tryParse(item);
            return date ?? item;
          }
          return item;
        }).toList();
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  /// Check if string is an ISO 8601 date
  static bool _isIso8601Date(String value) {
    if (value.length < 10) return false;
    try {
      DateTime.parse(value);
      return true;
    } catch (e) {
      return false;
    }
  }
}

