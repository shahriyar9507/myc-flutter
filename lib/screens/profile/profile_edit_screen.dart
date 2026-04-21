import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/api.dart';
import '../../config/theme.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/media_helpers.dart';
import '../../services/secure_storage.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _bio = TextEditingController();
  final _status = TextEditingController();
  String _emoji = '😊';
  String? _avatar;
  bool _saving = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final r = await ApiClient.instance.profileGet();
    final u = (r['data']?['user'] as Map?) ?? {};
    _name.text = u['name']?.toString() ?? u['full_name']?.toString() ?? '';
    _username.text = u['username']?.toString() ?? '';
    _email.text = u['email']?.toString() ?? '';
    _phone.text = u['phone']?.toString() ?? '';
    _bio.text = u['bio']?.toString() ?? '';
    _status.text = u['status_text']?.toString() ?? u['status']?.toString() ?? '';
    _emoji = u['status_emoji']?.toString() ?? '😊';
    _avatar = u['avatar']?.toString() ?? u['avatar_url']?.toString();
    if (mounted) setState(() {});
  }

  Future<void> _pickAvatar() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x == null) return;
    final raw = await x.readAsBytes();
    final bytes = await MediaHelpers.compressImage(raw);
    final token = await SecureStorage.readToken();
    final req = http.MultipartRequest('POST', Uri.parse(ApiConfig.uploadAvatar));
    if (token != null) req.headers['Authorization'] = 'Bearer $token';
    req.files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'avatar.jpg'));
    final resp = await http.Response.fromStream(await req.send());
    if (resp.statusCode == 200) {
      await _load();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avatar upload failed')));
    }
  }

  Future<void> _save() async {
    if (_bio.text.length > 500) return _snack('Bio must be ≤ 500 chars');
    if (_status.text.length > 150) return _snack('Status must be ≤ 150 chars');
    setState(() => _saving = true);
    final ok = await ApiClient.instance.profileUpdate({
      'name': _name.text.trim(),
      'username': _username.text.trim(),
      'email': _email.text.trim(),
      'phone': _phone.text.trim(),
      'bio': _bio.text,
      'status_text': _status.text,
      'status_emoji': _emoji,
    });
    setState(() => _saving = false);
    if (!mounted) return;
    if (ok['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
      Navigator.pop(context, true);
    } else {
      _snack(ok['error']?.toString() ?? 'Save failed');
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyCColors.darkBg,
      appBar: AppBar(
        backgroundColor: MyCColors.darkBg,
        title: Text('Edit profile', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : Text('Save', style: GoogleFonts.inter(color: MyCColors.accent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(child: GestureDetector(
            onTap: _pickAvatar,
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _avatar != null && _avatar!.isNotEmpty ? NetworkImage(_avatar!) : null,
              backgroundColor: MyCColors.accent.withValues(alpha: 0.3),
              child: _avatar == null || _avatar!.isEmpty
                  ? Text(_name.text.isNotEmpty ? _name.text[0] : '?', style: const TextStyle(color: Colors.white, fontSize: 36))
                  : null,
            ),
          )),
          const SizedBox(height: 8),
          Center(child: TextButton(onPressed: _pickAvatar, child: const Text('Change photo'))),
          const SizedBox(height: 16),
          _field('Full name', _name),
          _field('Username', _username),
          _field('Email', _email, keyboard: TextInputType.emailAddress),
          _field('Phone', _phone, keyboard: TextInputType.phone),
          _field('Bio', _bio, maxLength: 500, maxLines: 3),
          Row(children: [
            SizedBox(width: 60, child: TextField(
              controller: TextEditingController(text: _emoji),
              onChanged: (v) => _emoji = v.isEmpty ? '😊' : v,
              style: const TextStyle(color: Colors.white, fontSize: 24),
              decoration: const InputDecoration(labelText: 'Emoji', labelStyle: TextStyle(color: Colors.white54)),
            )),
            const SizedBox(width: 12),
            Expanded(child: _field('Status', _status, maxLength: 150)),
          ]),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController c, {int? maxLength, int maxLines = 1, TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: c,
        maxLength: maxLength,
        maxLines: maxLines,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: MyCColors.accent)),
        ),
      ),
    );
  }
}
