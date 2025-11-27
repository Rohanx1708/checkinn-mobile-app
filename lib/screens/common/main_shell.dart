import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/routes.dart';
import '../bookings/widgets/add_booking_sheet.dart';
import '../Dashboard/dashboard_ui.dart';
import '../bookings/ui/bookings_ui.dart';
import '../new_booking/new_booking_ui.dart';
import '../calendar/ui/calendar_ui.dart';
import '../profile/ui/profile_ui.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  final Widget? child;
  const MainShell({super.key, this.initialIndex = 0, this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;

  final List<Widget> _screens = const [
    DashboardUi(),
    BookingsUi(),
    CalendarUi(),
    ProfileUi(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child ?? _screens[_index],
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BottomAppBar(
      elevation: 8,
      color: Colors.white,
      child: SizedBox
        (
        height: 72,
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavIcon(
                    icon: Icons.home_rounded,
                    active: _index == 0,
                    onTap: () {
                      setState(() => _index = 0);
                      // Navigate to dashboard if coming from a child screen
                      if (widget.child != null) {
                        Navigator.of(context).pushReplacementNamed('/dashboard');
                      }
                    },
                  ),
                  _NavIcon(
                    icon: Icons.event_note_rounded,
                    active: _index == 1,
                    onTap: () {
                      setState(() => _index = 1);
                      // Navigate to bookings if coming from a child screen
                      if (widget.child != null) {
                        Navigator.of(context).pushReplacementNamed('/bookings');
                      }
                    },
                  ),
                ],
              ),
            ),
            _CenterAddButton(onTap: _showAddBookingSheet),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NavIcon(
                    icon: Icons.calendar_today_rounded,
                    active: _index == 2,
                    onTap: () {
                      setState(() => _index = 2);
                      // Navigate to calendar if coming from a child screen
                      if (widget.child != null) {
                        Navigator.of(context).pushReplacementNamed('/calendar');
                      }
                    },
                  ),
                  _NavIcon(
                    icon: Icons.person_rounded,
                    active: _index == 3,
                    onTap: () {
                      setState(() => _index = 3);
                      // Navigate to profile if coming from a child screen
                      if (widget.child != null) {
                        Navigator.of(context).pushReplacementNamed('/profile');
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddBookingSheet() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NewBookingUi(),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = const Color(0xFFEC4899);
    final Color inactiveColor = const Color(0xFF6B7280);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Icon(
          icon,
          size: 24,
          color: active ? activeColor : inactiveColor,
        ),
      ),
    );
  }
}

class _CenterAddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CenterAddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          width: 90,
          height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFFEC4899),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC4899).withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.add, color: Colors.white, size: 52),
        ),
      ),
    );
  }
}



