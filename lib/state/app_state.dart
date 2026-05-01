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

  List<Profile> _profiles = [Profile.paulien, Profile.nurse, Profile.bernd, Profile.kiliaan];
  String _activeId = 'paulien';
  FullChart? _chart;
  final _chartCache = <String, FullChart>{};
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

  /// Returns cached chart for any profile id (computes lazily if needed).
  FullChart? chartFor(String id) {
    if (_chartCache.containsKey(id)) return _chartCache[id];
    try {
      final profile = _profiles.firstWhere((p) => p.id == id);
      final c = ChartEngine().compute(profile.birthContext);
      _chartCache[id] = c;
      return c;
    } catch (_) {
      return null;
    }
  }

  Future<void> init() async {
    await _loadProfiles();
    _computeChart();
  }

  // Canonical defaults — always present regardless of saved state
  static final _defaults = [Profile.paulien, Profile.nurse, Profile.bernd, Profile.kiliaan];

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
      // Merge in any default profiles that are missing (e.g. Bernd added in V2)
      for (final def in _defaults) {
        if (!_profiles.any((p) => p.id == def.id)) {
          _profiles.add(def);
        }
      }
      // Always start on Paulien
      _activeId = prefs.getString(_activeIdKey) ?? 'paulien';
      if (!_profiles.any((p) => p.id == _activeId)) {
        _activeId = _profiles.first.id;
      }
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
    final engine = ChartEngine();
    try {
      final computed = engine.compute(activeProfile.birthContext);
      _chart = computed;
      _chartCache[_activeId] = computed;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
    // Upgrade in background with JPL Horizons positions (if network available)
    final id = _activeId;
    engine.computeAsync(activeProfile.birthContext).then((upgraded) {
      if (_activeId == id && mounted) {
        _chart = upgraded;
        _chartCache[id] = upgraded;
        notifyListeners();
      }
    }).catchError((_) {}); // silent — VSOP87 version stays
  }

  bool get mounted => true; // ChangeNotifier lifecycle guard

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
