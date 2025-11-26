class ApiConfig {
  static const String baseUrl = 'https://checkinn.club/api';
  
  // API endpoints
  static const String login = '$baseUrl/v1/login';
  static const String register = '$baseUrl/v1/register';
  static const String bookings = '$baseUrl/v1/bookings';
  static const String rooms = '$baseUrl/v1/rooms';
  static const String roomTypes = '$baseUrl/v1/room-types';
  static const String properties = '$baseUrl/v1/properties';
  static const String employees = '$baseUrl/v1/employees';
  static const String reports = '$baseUrl/v1/reports';
  static const String reportsTopRoomTypes = '$baseUrl/v1/reports/top-room-types';
  static const String reportsMonthlyBookings = '$baseUrl/v1/reports/monthly-bookings';
  static const String amenities = '$baseUrl/v1/amenities';
  static const String notifications = '$baseUrl/v1/notifications';
  static const String profile = '$baseUrl/v1/profile';
  static const String uploadPropertyLogo = '$baseUrl/v1/properties/upload-logo';
  static const String uploadPropertyImages = '$baseUrl/v1/properties/upload-images';
  static const String uploadRoomTypeImages = '$baseUrl/v1/room-types/upload-images';
  
  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> get multipartHeaders => {
    'Accept': 'application/json',
  };
  
  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
  
  static Map<String, String> getAuthMultipartHeaders(String token) => {
    ...multipartHeaders,
    'Authorization': 'Bearer $token',
  };
}
