import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:checkinn/widgets/checkinn_logo.dart';

class AppbarWidget extends StatefulWidget implements PreferredSizeWidget {
  final IconData appbarLeadingIcon;
  final void Function()? onPressed;

  const AppbarWidget({
    super.key,
    required this.appbarLeadingIcon,
    required this.onPressed,
  });

  @override
  State<AppbarWidget> createState() => _AppbarWidgetState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppbarWidgetState extends State<AppbarWidget> {
  int notificationCount = 5;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final double titleSize = screenWidth * 0.07;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(widget.appbarLeadingIcon, color: const Color(0xFF1F2937)),
        onPressed: widget.onPressed,
      ),
      centerTitle: true,
      title: CheckInnLogo(
        iconSize: 32,
        fontSize: screenWidth * 0.045,
        textColor: const Color(0xFF6B7280),
        alignment: MainAxisAlignment.center,
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Color(0xFF1F2937)),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            if (notificationCount > 0)
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
      ],
    );
  }
}
