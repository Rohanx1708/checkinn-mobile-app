import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  static String? _tokenCache;
  static Map<String, dynamic>? _userCache;

  // Store authentication token
  static Future<void> storeToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      // Fallback for early lifecycle/hot restart channel issues
      // ignore
    }
    _tokenCache = token;
    print('🔑 Token saved');
  }

  // Get authentication token
  static Future<String?> getToken() async {
    if (_tokenCache != null) return _tokenCache;
    try {
      final prefs = await SharedPreferences.getInstance();
      _tokenCache = prefs.getString(_tokenKey);
      return _tokenCache;
    } catch (e) {
      // During hot restarts, return in-memory value if available
      return _tokenCache;
    }
  }

  // Store user data
  static Future<void> storeUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(userData));
    } catch (e) {
      // ignore channel/setup issues
    }
    _userCache = userData;
    print('👤 User data saved');
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    if (_userCache != null) return _userCache;
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_userKey);
      if (str == null) return null;
      _userCache = jsonDecode(str) as Map<String, dynamic>;
      return _userCache;
    } catch (e) {
      // Fallback if preferences are unavailable
      return _userCache;
    }
  }

  // Clear authentication data
  static Future<void> clearAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      // ignore
    }
    _tokenCache = null;
    _userCache = null;
    print('🧹 Auth data cleared');
  }

  // Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
