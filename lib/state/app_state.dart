import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/birth_context.dart';
import '../models/profile.dart';
import '../services/chart_engine.dart';
import '../services/premium_service.dart';

class AppState extends ChangeNotifier {
  static const _profileKey = 'saved_profile';

  Profile _profile = Profile.paulien;
  FullChart? _chart;
  bool _loading = false;
  String? _error;

  Profile get profile => _profile;
  FullChart? get chart => _chart;
  bool get loading => _loading;
  String? get error => _error;
  bool get isReady => _chart != null;

  Future<void> init() async {
    await _loadSavedProfile();
    _computeChart();
  }

  Future<void> _loadSavedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_profileKey);
      if (json != null) {
        _profile = Profile.fromJson(jsonDecode(json) as Map<String, dynamic>);
      }
    } catch (_) {
      // First launch — use Paulien default
    }
  }

  void _computeChart() {
    _loading = true;
    notifyListeners();
    try {
      _chart = ChartEngine().compute(_profile.birthContext);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> updateProfile(Profile newProfile) async {
    _profile = newProfile;
    _computeChart();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileKey, jsonEncode(newProfile.toJson()));
    } catch (_) {}
  }

  Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    _profile = Profile.paulien;
    _computeChart();
  }
}
