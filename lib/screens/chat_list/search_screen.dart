import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        autofocus: true,
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Search messages, people...',
                          hintStyle: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 15),
                          prefixIcon: const Icon(Icons.search, color: MyCColors.darkMuted, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(bottom: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, color: MyCColors.darkMuted.withValues(alpha: 0.5), size: 64),
                    const SizedBox(height: 16),
                    Text('No recent searches', style: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
