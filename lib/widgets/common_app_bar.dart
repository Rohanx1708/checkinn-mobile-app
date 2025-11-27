import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:checkinn/widgets/checkinn_logo.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingPressed;
  final List<Widget>? actions;
  final bool showNotifications;
  final int? notificationCount;
  final VoidCallback? onNotificationPressed;
  final bool showBackButton;
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;
  final double? elevation;

  const AppBarWidget({
    super.key,
    this.title,
    this.leadingIcon,
    this.onLeadingPressed,
    this.actions,
    this.showNotifications = true,
    this.notificationCount,
    this.onNotificationPressed,
    this.showBackButton = false,
    this.showMenuButton = false,
    this.onMenuPressed,
    this.backgroundColor = Colors.white,
    this.foregroundColor = const Color(0xFF1F2937),
    this.centerTitle = true,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      leading: _buildLeading(context, screenWidth),
      title: _buildTitle(context, screenWidth),
      actions: _buildActions(context),
    );
  }

  Widget? _buildLeading(BuildContext context, double screenWidth) {
    // Priority 1: Menu button (for dashboard screens)
    if (showMenuButton) {
      return IconButton(
        icon: const Icon(Icons.menu, color: Color(0xFF1F2937)),
        onPressed: onMenuPressed ?? () {
          // Try to find the Scaffold in the widget tree
          final scaffoldState = context.findAncestorStateOfType<ScaffoldState>();
          if (scaffoldState != null) {
            scaffoldState.openDrawer();
          } else {
            // Fallback: try Scaffold.of(context)
            try {
              Scaffold.of(context).openDrawer();
            } catch (e) {
              // Error opening drawer
            }
          }
        },
      );
    }

    // Priority 2: Custom leading icon
    if (leadingIcon != null && onLeadingPressed != null) {
      return IconButton(
        icon: Icon(leadingIcon, color: foregroundColor),
        onPressed: onLeadingPressed,
      );
    }

    // Priority 3: Back button
    if (showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
        onPressed: () => Navigator.of(context).pop(),
      );
    }

    return null;
  }

  Widget _buildTitle(BuildContext context, double screenWidth) {
    if (title != null) {
      return Text(
        title!,
        style: GoogleFonts.inter(
          fontSize: screenWidth * 0.05,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1F2937),
        ),
      );
    }

    // Default CheckInn logo
    return CheckInnLogo(
      iconSize: 32,
      fontSize: screenWidth * 0.045,
      textColor: const Color(0xFF6B7280),
      alignment: MainAxisAlignment.center,
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    List<Widget> actionWidgets = [];

    // Add custom actions
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    // Add notification button
    if (showNotifications) {
      actionWidgets.add(
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Color(0xFF1F2937)),
              onPressed: onNotificationPressed ?? () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            if (notificationCount != null && notificationCount! > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    '$notificationCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Return empty list if no actions
    if (actionWidgets.isEmpty) {
      return null;
    }

    return actionWidgets;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Convenience constructors for common use cases
class CommonAppBar {
  // Dashboard app bar with menu button
  static PreferredSizeWidget dashboard({
    VoidCallback? onMenuPressed,
    int? notificationCount,
    VoidCallback? onNotificationPressed,
  }) {
    return AppBarWidget(
      showMenuButton: true,
      onMenuPressed: onMenuPressed,
      showNotifications: true,
      notificationCount: notificationCount,
      onNotificationPressed: onNotificationPressed,
    );
  }

  // Back button app bar with custom title
  static PreferredSizeWidget withBackButton({
    required String title,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    int? notificationCount,
    VoidCallback? onNotificationPressed,
  }) {
    return AppBarWidget(
      title: title,
      showBackButton: true,
      onLeadingPressed: onBackPressed,
      actions: actions,
      showNotifications: true,
      notificationCount: notificationCount,
      onNotificationPressed: onNotificationPressed,
    );
  }

  // Custom app bar with specific leading icon
  static PreferredSizeWidget withCustomLeading({
    required IconData leadingIcon,
    required VoidCallback onLeadingPressed,
    String? title,
    List<Widget>? actions,
    int? notificationCount,
    VoidCallback? onNotificationPressed,
  }) {
    return AppBarWidget(
      title: title,
      leadingIcon: leadingIcon,
      onLeadingPressed: onLeadingPressed,
      actions: actions,
      showNotifications: true,
      notificationCount: notificationCount,
      onNotificationPressed: onNotificationPressed,
    );
  }

  // Simple app bar with just title and back button
  static PreferredSizeWidget simple({
    required String title,
    VoidCallback? onBackPressed,
  }) {
    return AppBarWidget(
      title: title,
      showBackButton: true,
      onLeadingPressed: onBackPressed,
      showNotifications: false,
    );
  }

  // Logo-only app bar (for main screens)
  static PreferredSizeWidget logoOnly({
    VoidCallback? onMenuPressed,
    int? notificationCount,
    VoidCallback? onNotificationPressed,
  }) {
    return AppBarWidget(
      showMenuButton: true,
      onMenuPressed: onMenuPressed,
      showNotifications: true,
      notificationCount: notificationCount,
      onNotificationPressed: onNotificationPressed,
    );
  }
}
