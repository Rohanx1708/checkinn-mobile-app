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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavIcon(
                icon: Icons.home_rounded,
                label: 'Home',
                active: _index == 0,
                onTap: () {
                  setState(() => _index = 0);
                  if (widget.child != null) {
                    Navigator.of(context).pushReplacementNamed('/dashboard');
                  }
                },
              ),
              _NavIcon(
                icon: Icons.event_note_rounded,
                label: 'Bookings',
                active: _index == 1,
                onTap: () {
                  setState(() => _index = 1);
                  if (widget.child != null) {
                    Navigator.of(context).pushReplacementNamed('/bookings');
                  }
                },
              ),
              _CenterAddButton(onTap: _showAddBookingSheet),
              _NavIcon(
                icon: Icons.calendar_today_rounded,
                label: 'Calendar',
                active: _index == 2,
                onTap: () {
                  setState(() => _index = 2);
                  if (widget.child != null) {
                    Navigator.of(context).pushReplacementNamed('/calendar');
                  }
                },
              ),
              _NavIcon(
                icon: Icons.person_rounded,
                label: 'Profile',
                active: _index == 3,
                onTap: () {
                  setState(() => _index = 3);
                  if (widget.child != null) {
                    Navigator.of(context).pushReplacementNamed('/profile');
                  }
                },
              ),
            ],
          ),
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
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFF1F2937);
    const Color inactiveColor = Color(0xFF6B7280);
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: active ? activeColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: active ? activeColor : inactiveColor,
            ),
          ),
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
        margin: const EdgeInsets.only(top: 12,bottom: 12),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1F2937).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}



