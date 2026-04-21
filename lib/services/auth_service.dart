import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';
import 'secure_storage.dart';
import 'realtime_service.dart';
import 'fcm_service.dart';

class AuthService extends ChangeNotifier {
  String? _token;
  int? _userId;
  Map<String, dynamic>? _user;
  bool _loading = false;

  String? get token => _token;
  int? get userId => _userId;
  Map<String, dynamic>? get user => _user;
  bool get isLoggedIn => _token != null;
  bool get loading => _loading;

  /// Load stored token on app start. Migrates legacy SharedPreferences
  /// values into secure storage on first launch after the upgrade.
  Future<void> loadStoredAuth() async {
    _token = await SecureStorage.readToken();
    _userId = await SecureStorage.readUserId();
    final userJson = await SecureStorage.readUser();
    if (userJson != null) _user = jsonDecode(userJson);

    if (_token == null) {
      final prefs = await SharedPreferences.getInstance();
      final legacyToken = prefs.getString('auth_token');
      if (legacyToken != null) {
        _token = legacyToken;
        _userId = prefs.getInt('user_id');
        final legacyUser = prefs.getString('user_data');
        if (legacyUser != null) _user = jsonDecode(legacyUser);
        await SecureStorage.writeToken(legacyToken);
        if (_userId != null) await SecureStorage.writeUserId(_userId!);
        if (legacyUser != null) await SecureStorage.writeUser(legacyUser);
        await prefs.remove('auth_token');
        await prefs.remove('user_id');
        await prefs.remove('user_data');
      }
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String name,
    required String password,
    String? email,
    String? phone,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      final body = {
        'username': username,
        'name': name,
        'password': password,
        'device': 'MyC Flutter',
        'platform': 'android',
      };
      if (email != null && email.isNotEmpty) body['email'] = email;
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;

      final res = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        await _saveAuth(data['data']);
        await _initPostLogin();
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'error': data['error'] ?? 'Registration failed'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    _loading = true;
    notifyListeners();
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': identifier,
          'password': password,
          'device': 'MyC Flutter',
          'platform': 'android',
        }),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        await _saveAuth(data['data']);
        await _initPostLogin();
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'error': data['error'] ?? 'Login failed'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> checkUsername(String username) async {
    try {
      final res = await http.get(Uri.parse('${ApiConfig.checkUsername}?username=$username'));
      final data = jsonDecode(res.body);
      return data['data']?['available'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> changePassword(String oldPw, String newPw) async {
    try {
      final res = await http.post(
        Uri.parse(ApiConfig.profileUpdate),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'old_password': oldPw, 'password': newPw}),
      );
      final data = jsonDecode(res.body);
      return {'success': data['success'] == true, 'error': data['error']};
    } catch (e) {
      return {'success': false, 'error': '$e'};
    }
  }

  Future<void> logout({bool allDevices = false}) async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse(allDevices ? ApiConfig.logoutAll : ApiConfig.logout),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        );
      }
    } catch (_) {}

    await RealtimeService.instance.signOut();
    _token = null;
    _userId = null;
    _user = null;
    await SecureStorage.clearAuth();
    notifyListeners();
  }

  Future<void> _saveAuth(Map<String, dynamic> data) async {
    _token = data['token'];
    _userId = data['user_id'] is int
        ? data['user_id']
        : int.tryParse('${data['user_id']}');
    _user = data['user'];
    await SecureStorage.writeToken(_token!);
    if (_userId != null) await SecureStorage.writeUserId(_userId!);
    if (_user != null) await SecureStorage.writeUser(jsonEncode(_user));
    notifyListeners();
  }

  Future<void> _initPostLogin() async {
    if (_token == null) return;
    await RealtimeService.instance.signIn(_token!);
    await FcmService.instance.registerWithBackend(_token!);
  }
}
