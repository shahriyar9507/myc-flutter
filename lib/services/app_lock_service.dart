import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'secure_storage.dart';

/// Manages the PIN / biometric lock state. PIN is stored in the platform
/// keystore via SecureStorage; preferences and auto-lock timer are stored
/// in SharedPreferences because they aren't secret.
class AppLockService extends ChangeNotifier {
  static const _kEnabled = 'lock_enabled';
  static const _kBiometric = 'lock_biometric';
  static const _kAutolockSec = 'lock_autolock_sec';

  bool _enabled = false;
  bool _biometric = false;
  int _autolockSec = 60;
  DateTime? _lastActive;
  bool _unlocked = false;

  bool get enabled => _enabled;
  bool get biometric => _biometric;
  int get autolockSec => _autolockSec;
  bool get unlocked => _unlocked || !_enabled;

  final _auth = LocalAuthentication();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_kEnabled) ?? false;
    _biometric = prefs.getBool(_kBiometric) ?? false;
    _autolockSec = prefs.getInt(_kAutolockSec) ?? 60;
    notifyListeners();
  }

  Future<void> enablePin(String pin) async {
    await SecureStorage.writePin(pin);
    _enabled = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, true);
    notifyListeners();
  }

  Future<void> disable() async {
    await SecureStorage.deletePin();
    _enabled = false;
    _biometric = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, false);
    await prefs.setBool(_kBiometric, false);
    notifyListeners();
  }

  Future<void> setBiometric(bool v) async {
    _biometric = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kBiometric, v);
    notifyListeners();
  }

  Future<void> setAutolockSec(int sec) async {
    _autolockSec = sec;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kAutolockSec, sec);
    notifyListeners();
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await SecureStorage.readPin();
    final ok = stored != null && stored == pin;
    if (ok) { _unlocked = true; notifyListeners(); }
    return ok;
  }

  Future<bool> tryBiometric() async {
    if (!_biometric) return false;
    try {
      final can = await _auth.canCheckBiometrics;
      if (!can) return false;
      final ok = await _auth.authenticate(
        localizedReason: 'Unlock MyC',
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true),
      );
      if (ok) { _unlocked = true; notifyListeners(); }
      return ok;
    } catch (_) { return false; }
  }

  void markActive() { _lastActive = DateTime.now(); }
  void markBackgrounded() { _lastActive = DateTime.now(); }

  /// Called on app resume; returns true if lock must be shown.
  bool shouldLockOnResume() {
    if (!_enabled) return false;
    if (_lastActive == null) return true;
    final diff = DateTime.now().difference(_lastActive!).inSeconds;
    if (diff >= _autolockSec) { _unlocked = false; notifyListeners(); return true; }
    return false;
  }

  void lock() { _unlocked = false; notifyListeners(); }
}
