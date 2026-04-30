import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/birth_context.dart';
import '../models/profile.dart';
import '../services/chart_engine.dart';
import '../services/premium_service.dart';

class AppState extends ChangeNotifier {
  static const _profilesKey   = 'profiles_list';
  static const _activeIdKey   = 'active_profile_id';

  List<Profile> _profiles = [Profile.paulien];
  String _activeId = 'paulien';
  FullChart? _chart;
  bool _loading = false;
  String? _error;

  Profile get activeProfile =>
      _profiles.firstWhere((p) => p.id == _activeId,
          orElse: () => _profiles.first);

  // Alias for backwards-compat with SettingsScreen
  Profile get profile => activeProfile;
  List<Profile> get profiles => List.unmodifiable(_profiles);
  FullChart? get chart => _chart;
  bool get loading => _loading;
  String? get error => _error;
  bool get isReady => _chart != null;

  Future<void> init() async {
    await _loadProfiles();
    _computeChart();
  }

  Future<void> _loadProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_profilesKey);
      if (json != null) {
        final list = jsonDecode(json) as List<dynamic>;
        _profiles = list
            .map((e) => Profile.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      _activeId = prefs.getString(_activeIdKey) ?? _profiles.first.id;
    } catch (_) {}
  }

  Future<void> _saveProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _profilesKey, jsonEncode(_profiles.map((p) => p.toJson()).toList()));
      await prefs.setString(_activeIdKey, _activeId);
    } catch (_) {}
  }

  void _computeChart() {
    _loading = true;
    notifyListeners();
    try {
      _chart = ChartEngine().compute(activeProfile.birthContext);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> updateProfile(Profile updated) async {
    final idx = _profiles.indexWhere((p) => p.id == updated.id);
    if (idx >= 0) {
      _profiles[idx] = updated;
    } else {
      _profiles.add(updated);
    }
    if (_activeId == updated.id) _computeChart();
    await _saveProfiles();
    notifyListeners();
  }

  Future<void> addProfile(Profile profile) async {
    if (_profiles.length >= 8) return; // reasonable limit
    _profiles.add(profile);
    await _saveProfiles();
    notifyListeners();
  }

  Future<void> removeProfile(String id) async {
    if (_profiles.length <= 1) return;
    _profiles.removeWhere((p) => p.id == id);
    if (_activeId == id) {
      _activeId = _profiles.first.id;
      _computeChart();
    }
    await _saveProfiles();
    notifyListeners();
  }

  Future<void> switchProfile(String id) async {
    if (_activeId == id) return;
    _activeId = id;
    _computeChart();
    await _saveProfiles();
  }

  Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profilesKey);
    await prefs.remove(_activeIdKey);
    _profiles = [Profile.paulien];
    _activeId = 'paulien';
    _computeChart();
  }
}
