// curved_bottom_nav_bar.dart
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class CurvedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CurvedBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: const Color(0xFFF3E5F5),
      color: Colors.deepPurple,
      buttonBackgroundColor: Colors.orange,
      animationDuration: const Duration(milliseconds: 300),
      height: 60,
      index: currentIndex,
      items: const [
        Icon(Icons.event_note, size: 30, color: Colors.white), // 0 - Bookings
        Icon(Icons.home, size: 30, color: Colors.white),      // 1 - Home
        Icon(Icons.search, size: 30, color: Colors.white),    // 2 - Search
        Icon(Icons.swap_horiz, size: 30, color: Colors.white),// 3 - Switch Role
      ],
      onTap: onTap,
    );
  }
}
