import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/checkinn_logo.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {

    // Get current route to determine which item should be active
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '/dashboard';
    
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer header with logo
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo section
                  const CheckInnLogo(
                    iconSize: 56,
                    fontSize: 28,
                    alignment: MainAxisAlignment.start,
                    textColor: Color(0xFF1F2937),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            _buildDrawerItem(
              context,
              icon: Icons.dashboard,
              title: 'Dashboard',
              route: '/dashboard',
              isActive: currentRoute == '/dashboard',
            ),
            
            _buildDrawerItem(
              context,
              icon: Icons.business,
              title: 'PMS (Property Management)',
              route: '/pms',
              isActive: currentRoute == '/pms',
            ),
            
            _buildDrawerItem(
              context,
              icon: Icons.meeting_room,
              title: 'Room Management',
              route: '/rooms',
              isActive: currentRoute == '/rooms',
            ),
            
            _buildDrawerItem(
              context,
              icon: Icons.people,
              title: 'Agents',
              route: '/agent',
              isActive: currentRoute == '/agent',
            ),

            _buildDrawerItem(
              context,
              icon: Icons.badge,
              title: 'Employees',
              route: '/employees',
              isActive: currentRoute == '/employees',
            ),
            
            _buildDrawerItem(
              context,
              icon: Icons.calendar_today,
              title: 'Calendar',
              route: '/calendar',
              isActive: currentRoute == '/calendar',
            ),
            
            _buildDrawerItem(
              context,
              icon: Icons.book_online,
              title: 'Bookings',
              route: '/bookings',
              isActive: currentRoute == '/bookings',
            ),
            
            _buildDrawerItem(
              context,
              icon: Icons.bar_chart,
              title: 'Reports',
              route: '/reports',
              isActive: currentRoute == '/reports',
            ),

            _buildDrawerItem(
              context,
              icon: Icons.people_outline,
              title: 'CRM',
              route: '/crm',
              isActive: currentRoute == '/crm',
            ),
            
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFFE2E8F0),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Logout button with special styling
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFECACA),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    'Logout',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFEF4444),
                      fontSize: 14,
                    ),
                  ),
                  onTap: () => _showLogoutDialog(context),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1F2937).withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(color: const Color(0xFF1F2937).withOpacity(0.2), width: 1)
              : null,
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF1F2937)
                  : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isActive
                  ? Colors.white
                  : const Color(0xFF1F2937),
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              color: isActive
                  ? const Color(0xFF1F2937)
                  : const Color(0xFF1F2937),
              fontSize: 14,
            ),
          ),
          trailing: isActive
              ? Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F2937),
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () {
            Navigator.pop(context);
            _navigateToRoute(context, route);
          },
        ),
      ),
    );
  }

  void _navigateToRoute(BuildContext context, String route) {
    // Add a small delay for better UX
    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.pushNamed(context, route);
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout,
                  color: Color(0xFFEF4444),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.inter(
              color: const Color(0xFF6B7280),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFEF4444),
                    const Color(0xFFDC2626),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close drawer
                  
                  // Navigate to login screen and remove all previous routes
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                child: Text(
                  'Logout',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
