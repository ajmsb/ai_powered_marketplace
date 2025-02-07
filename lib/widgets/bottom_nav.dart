import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  BottomNavBar({required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left-side icons (Home & Love)
          Row(
            children: [
              navIcon(Icons.home, 0),
              navIcon(Icons.favorite, 1),
            ],
          ),
          SizedBox(width: 80), // Space for the FAB
          // Right-side icons (Email & Profile)
          Row(
            children: [
              navIcon(Icons.email, 2),
              navIcon(Icons.person, 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget navIcon(IconData icon, int index) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
