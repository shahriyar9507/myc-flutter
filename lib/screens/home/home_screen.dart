import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../calls/calls_screen.dart';
import '../stories/stories_screen.dart';
import '../profile/profile_screen.dart';
import '../chat_list/chat_list_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = [
    const ChatListScreen(),
    const CallsScreen(),
    const StoriesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      body: Stack(
        children: [
          _screens[_currentIndex],
          
          // Bottom Navigation Bar (Glassmorphism)
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 80 + MediaQuery.of(context).padding.bottom,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _navItem(0, Icons.chat_bubble_outline, Icons.chat_bubble, 'Chats'),
                      _navItem(1, Icons.phone_outlined, Icons.phone, 'Calls'),
                      _navItem(2, Icons.auto_awesome_outlined, Icons.auto_awesome, 'Stories'),
                      _navItem(3, Icons.person_outline, Icons.person, 'You'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData outline, IconData solid, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? solid : outline,
            color: isSelected ? MyCColors.accent : MyCColors.darkMuted,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? MyCColors.accent : MyCColors.darkMuted,
            ),
          ),
          const SizedBox(height: 10), // Padding for safe area
        ],
      ),
    );
  }
}


