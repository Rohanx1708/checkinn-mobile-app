import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/login/ui/login_ui.dart';
import '../screens/login/ui/forgot_password_ui.dart';
import '../screens/Dashboard/dashboard_ui.dart';
import '../screens/rooms/ui/room_management_ui.dart';
import '../screens/PMS/ui/pms_ui.dart';
import '../screens/calendar/ui/calendar_ui.dart';
import '../screens/agent/ui/agent_ui.dart';
import '../screens/bookings/ui/bookings_ui.dart';
import '../screens/Reports/report_ui.dart';
import '../screens/CRM/ui/crm_ui.dart';
import '../screens/common/main_shell.dart';
import '../screens/notifications/notifications_ui.dart';
import '../screens/rooms/ui/rooms.dart';
import '../screens/rooms/models/room_models.dart';
import 'package:checkinn/screens/employees/ui/employees_ui.dart';

/// App Routes - Centralized route management
class AppRoutes {
  // Initial route
  static const String splash = '/';
  
  // Authentication routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main app routes
  static const String dashboard = '/dashboard';
  static const String shell = '/shell';
  static const String rooms = '/rooms';
  static const String events = '/events';
  static const String bookings = '/bookings';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String pms = '/pms';
  static const String calendar = '/calendar';
  static const String agent = '/agent';
  static const String reports = '/reports';
  static const String crm = '/crm';
  static const String notifications = '/notifications';
  static const String employees = '/employees';


  // Event management routes
  static const String createEvent = '/create-event';
  static const String eventDetails = '/event-details';

  // Room management routes
  static const String roomDetails = '/room-details';
  static const String addRoom = '/add-room';
  static const String roomTypes = '/room-types';

  // Booking management routes
  static const String createBooking = '/create-booking';
  static const String bookingDetails = '/booking-details';

  // Settings and profile routes
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
}

/// Route Generator - Handles navigation between screens
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    // Initial/Splash route
    case AppRoutes.splash:
      return _buildRoute(const SplashScreen(), settings);
    
    // Authentication routes
    case AppRoutes.login:
      return _buildRoute(const LoginUi(), settings);
    case AppRoutes.register:
      return _buildRoute(const Scaffold(body: Center(child: Text('Register Screen'))), settings);
    case AppRoutes.forgotPassword:
      return _buildRoute(const ForgotPasswordUi(), settings);

    // Main app routes
    case AppRoutes.shell:
      return _buildRoute(const MainShell(), settings);
    case AppRoutes.dashboard:
      return _buildRoute(const MainShell(), settings);
    case AppRoutes.rooms:
      return _buildRoute(const MainShell(child: RoomManagementUi()), settings);
    case AppRoutes.settings:
      return _buildRoute(const MainShell(child: Scaffold(body: Center(child: Text('Settings Screen')))), settings);
    case AppRoutes.pms:
      return _buildRoute(const MainShell(child: PmsUi()), settings);
    case AppRoutes.calendar:
      // Open shell with Calendar tab selected (index 1)
      return _buildRoute(const MainShell(initialIndex: 1), settings);
    case AppRoutes.agent:
      return _buildRoute(const MainShell(child: AgentUi()), settings);
  case AppRoutes.bookings:
  // Keep bookings accessible via shell if needed (now index 0=Home,1=Calendar,2=Agents,3=Profile)
  return _buildRoute(const MainShell(child: BookingsUi()), settings);
    case AppRoutes.reports:
      return _buildRoute(const MainShell(child: ReportsUi()), settings);
    case AppRoutes.crm:
      return _buildRoute(const MainShell(child: CrmUi()), settings);

    case AppRoutes.profile:
      return _buildRoute(const MainShell(initialIndex: 3), settings);

    case AppRoutes.employees:
      return _buildRoute(const MainShell(child: EmployeesUi()), settings);

    // Event management routes
    case AppRoutes.createEvent:
      return _buildRoute(const Scaffold(body: Center(child: Text('Create Event Screen'))), settings);
    case AppRoutes.eventDetails:
      return _buildRoute(const Scaffold(body: Center(child: Text('Event Details Screen'))), settings);

    // Room management routes
    case AppRoutes.roomDetails:
      return _buildRoute(const Scaffold(body: Center(child: Text('Room Details Screen'))), settings);
    case AppRoutes.addRoom:
      return _buildRoute(const Scaffold(body: Center(child: Text('Add Room Screen'))), settings);
    case AppRoutes.roomTypes:
      final args = settings.arguments as RouteArguments?;
      final data = args?.data ?? {};
      final category = data['category'] as String? ?? 'Rooms';
      final rooms = data['rooms'] as List? ?? const [];
      return _buildRoute(RoomTypesUi(categoryName: category, rooms: List<RoomEntity>.from(rooms as List)), settings);

    // Booking management routes
    case AppRoutes.createBooking:
      return _buildRoute(const Scaffold(body: Center(child: Text('Create Booking Screen'))), settings);
    case AppRoutes.bookingDetails:
      return _buildRoute(const Scaffold(body: Center(child: Text('Booking Details Screen'))), settings);

    // Settings and profile routes
    case AppRoutes.editProfile:
      return _buildRoute(const Scaffold(body: Center(child: Text('Edit Profile Screen'))), settings);
    case AppRoutes.changePassword:
      return _buildRoute(const Scaffold(body: Center(child: Text('Change Password Screen'))), settings);
    case AppRoutes.notifications:
      return _buildRoute(const MainShell(child: NotificationsUi()), settings);

    // Default route
    default:
      return _buildRoute(const SplashScreen(), settings);
  }
}

/// Builds a route with custom transition
Route<dynamic> _buildRoute(Widget screen, RouteSettings settings) {
  return MaterialPageRoute(
    builder: (context) => screen,
    settings: settings,
  );
}

/// Navigation Helper Class
class NavigationHelper {
  /// Navigate to a new screen
  static Future<T?> navigateTo<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Navigate and replace current screen
  static Future<T?> navigateAndReplace<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.of(context).pushReplacementNamed<T, void>(routeName, arguments: arguments);
  }

  /// Navigate and clear all previous routes
  static Future<T?> navigateAndClearStack<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Navigate back
  static void goBack<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  /// Navigate back to specific route
  static void goBackTo(BuildContext context, String routeName) {
    Navigator.of(context).popUntil((route) => route.settings.name == routeName);
  }

  /// Check if can go back
  static bool canGoBack(BuildContext context) {
    return Navigator.of(context).canPop();
  }
}

/// Route Arguments - Define data structures for route parameters
class RouteArguments {
  final Map<String, dynamic> data;

  const RouteArguments({this.data = const {}});

  T? get<T>(String key) => data[key] as T?;
  String? getString(String key) => data[key] as String?;
  int? getInt(String key) => data[key] as int?;
  bool? getBool(String key) => data[key] as bool?;
  Map<String, dynamic>? getMap(String key) => data[key] as Map<String, dynamic>?;
}

/// Example usage:
/// NavigationHelper.navigateTo(context, AppRoutes.eventDetails, arguments: RouteArguments(data: {'eventId': 123}));
/// NavigationHelper.navigateAndReplace(context, AppRoutes.dashboard);
/// NavigationHelper.navigateAndClearStack(context, AppRoutes.login);

/// Creates a custom slide route animation
Route createSlideRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
