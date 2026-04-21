import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/theme.dart';
import '../../config/api.dart';
import '../../services/chat_service.dart';
import '../chat_thread/chat_thread_screen.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _performSearch(_searchController.text);
      } else {
        setState(() => _searchResults = []);
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.profileSearch}?q=$query'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final resData = data['data'] ?? {};
          setState(() {
            _searchResults = List<Map<String, dynamic>>.from(resData['results'] ?? []);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('API Error: ${data['error'] ?? 'Unknown'}')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('HTTP ${response.statusCode}: ${response.body}')));
      }
    } catch (e) {
      debugPrint('Search error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Network Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startChat(Map<String, dynamic> user) async {
    final service = Provider.of<ChatService>(context, listen: false);
    final userId = user['id'].toString();
    final name = user['username'] ?? 'User';
    
    // Default to aurora theme for new chats
    final chatId = await service.createChat(userId, 'aurora');
    
    if (chatId != null && mounted) {
      // Replace the NewChatScreen with the new ChatThreadScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatThreadScreen(
            chatId: chatId,
            name: name,
            themeId: 'aurora',
            online: true,
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to start chat')));
    }
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('This feature is coming in Phase 5!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.inter(color: Colors.white, fontSize: 16)),
        ),
        leadingWidth: 80,
        title: Text('New Chat', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)))),
            child: Row(
              children: [
                Text('To: ', style: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 16)),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Search by username...',
                      hintStyle: TextStyle(color: Colors.white24),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Quick actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(onTap: _showComingSoon, child: _actionBtn(Icons.group_add, 'New Group', const [MyCColors.accent, MyCColors.pink])),
                GestureDetector(onTap: _showComingSoon, child: _actionBtn(Icons.campaign, 'Broadcast', const [MyCColors.gold, MyCColors.pink])),
                GestureDetector(onTap: _showComingSoon, child: _actionBtn(Icons.link, 'Invite Link', const [MyCColors.teal, MyCColors.accent])),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(_searchController.text.isEmpty ? 'SUGGESTED' : 'SEARCH RESULTS', style: GoogleFonts.inter(color: MyCColors.darkMuted, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
          
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: MyCColors.accent))
                : _searchResults.isEmpty && _searchController.text.isNotEmpty
                    ? Center(child: Text('No users found', style: GoogleFonts.inter(color: Colors.white54)))
                    : ListView.builder(
                        itemCount: _searchResults.isEmpty ? 3 : _searchResults.length,
                        itemBuilder: (context, index) {
                          if (_searchController.text.isEmpty) {
                            // Show mock suggestions if empty search
                            final mocks = [
                              {'username': 'Maya', 'id': 'mock1'},
                              {'username': 'Kai', 'id': 'mock2'},
                              {'username': 'Jordan', 'id': 'mock3'},
                            ];
                            return _contactRow(mocks[index]['username']!, false, () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('These are mock suggestions. Please search for a real username!')));
                            });
                          }
                          
                          final user = _searchResults[index];
                          return _contactRow(user['username'] ?? 'Unknown', true, () => _startChat(user));
                        },
                      ),
          )
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, List<Color> colors) {
    return Column(
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: colors)),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _contactRow(String name, bool online, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
        child: Center(child: Text(name[0], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
      ),
      title: Text(name, style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      subtitle: Text(online ? 'Online' : 'Offline', style: GoogleFonts.inter(color: online ? MyCColors.online : MyCColors.darkMuted, fontSize: 13)),
    );
  }
}
