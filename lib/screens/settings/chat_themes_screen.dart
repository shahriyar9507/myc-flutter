import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/theme.dart';
import '../../../themes/theme_engine.dart';

class ChatThemesScreen extends StatelessWidget {
  const ChatThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themes = ['rain', 'snow', 'confetti', 'bubbles', 'aurora', 'fireflies', 'sakura', 'starfield', 'lava', 'matrix', 'ocean'];

    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('Default Theme', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Text(
              'This theme will be used for all new chats by default. You can still customize individual chats later.',
              style: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 14),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.8
              ),
              itemCount: themes.length,
              itemBuilder: (context, i) {
                final id = themes[i];
                final isSelected = id == 'aurora'; // Hardcoded default for UI
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? MyCColors.accent : Colors.white10, width: isSelected ? 3 : 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AnimatedChatTheme(themeId: id),
                        if (isSelected)
                          Container(
                            color: Colors.black38,
                            child: const Center(child: Icon(Icons.check_circle, color: MyCColors.accent, size: 40)),
                          ),
                        Positioned(
                          bottom: 12, left: 0, right: 0,
                          child: Text(
                            id[0].toUpperCase() + id.substring(1),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
