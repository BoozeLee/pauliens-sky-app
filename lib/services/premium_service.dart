import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'ai_service.dart';

enum PremiumTier { free, premium }

class PremiumFeature {
  static const String allCultures      = 'all_cultures';
  static const String aiInterpretation = 'ai_interpretation';
  static const String aiChat           = 'ai_chat';
  static const String dailyReading     = 'daily_reading';
  static const String personalityRadar = 'personality_radar';
  static const String fixedStars       = 'fixed_stars';
  static const String shareCard        = 'share_card';
  static const String multipleProfiles = 'multiple_profiles';
  static const String unlimitedAi      = 'unlimited_ai';
}

class PremiumService {
  static const _tierKey       = 'premium_tier';
  static const _anthropicKey  = 'anthropic_api_key';
  static const _geminiKey     = 'gemini_api_key';
  static const _openAiKey     = 'openai_api_key';
  static const _aiCallsToday  = 'ai_calls_today';
  static const _aiCallsDate   = 'ai_calls_date';
  static const _freeAiLimit   = 999; // V2: all features freemium

  static PremiumService? _instance;
  static PremiumService get instance => _instance!;

  final SharedPreferences _prefs;

  // Secure storage: Android Keystore / iOS Keychain on mobile; SharedPrefs on Linux/desktop
  static bool get _useSecure =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  PremiumService._(this._prefs);

  static Future<PremiumService> init() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = PremiumService._(prefs);
    if (_useSecure) await _instance!._migrateKeysToSecureStorage();
    return _instance!;
  }

  // Migrate any keys previously stored in SharedPreferences to secure storage
  Future<void> _migrateKeysToSecureStorage() async {
    for (final k in [_anthropicKey, _geminiKey, _openAiKey]) {
      final legacyVal = _prefs.getString(k);
      if (legacyVal != null && legacyVal.isNotEmpty) {
        await _secure.write(key: k, value: legacyVal);
        await _prefs.remove(k);
      }
    }
  }

  // ── Tier — V2: all features freemium ─────────────────────────────────────

  PremiumTier get tier => PremiumTier.premium; // V2: open for everyone

  bool get isPremium => true;

  Future<void> setPremium(bool value) async {
    await _prefs.setString(_tierKey, value ? 'premium' : 'free');
  }

  // ── API Keys — stored in OS secure enclave (Keystore/Keychain) ──────────────

  // Sync accessors (fast for UI display — empty until async load completes)
  String _cachedAnthropicKey = '';
  String _cachedGeminiKey    = '';
  String _cachedOpenAiKey    = '';

  String get anthropicApiKey => _cachedAnthropicKey;
  String get geminiApiKey    => _cachedGeminiKey;
  String get openAiApiKey    => _cachedOpenAiKey;
  bool   get hasAnthropicKey => _cachedAnthropicKey.isNotEmpty;
  bool   get hasGeminiKey    => _cachedGeminiKey.isNotEmpty;
  bool   get hasOpenAiKey    => _cachedOpenAiKey.isNotEmpty;
  bool   get hasAnyKey       => hasAnthropicKey || hasGeminiKey || hasOpenAiKey || AiService.proxyUrl.isNotEmpty;

  // Call once after init() to populate the in-memory cache
  Future<void> loadApiKeys() async {
    if (_useSecure) {
      _cachedAnthropicKey = await _secure.read(key: _anthropicKey) ?? '';
      _cachedGeminiKey    = await _secure.read(key: _geminiKey)    ?? '';
      _cachedOpenAiKey    = await _secure.read(key: _openAiKey)    ?? '';
    } else {
      _cachedAnthropicKey = _prefs.getString(_anthropicKey) ?? '';
      _cachedGeminiKey    = _prefs.getString(_geminiKey)    ?? '';
      _cachedOpenAiKey    = _prefs.getString(_openAiKey)    ?? '';
    }
  }

  Future<void> setAnthropicKey(String key) async {
    _cachedAnthropicKey = key.trim();
    if (_useSecure) {
      await _secure.write(key: _anthropicKey, value: key.trim());
    } else {
      await _prefs.setString(_anthropicKey, key.trim());
    }
  }

  Future<void> setGeminiKey(String key) async {
    _cachedGeminiKey = key.trim();
    if (_useSecure) {
      await _secure.write(key: _geminiKey, value: key.trim());
    } else {
      await _prefs.setString(_geminiKey, key.trim());
    }
  }

  Future<void> clearAnthropicKey() async {
    _cachedAnthropicKey = '';
    if (_useSecure) {
      await _secure.delete(key: _anthropicKey);
    } else {
      await _prefs.remove(_anthropicKey);
    }
  }

  Future<void> clearGeminiKey() async {
    _cachedGeminiKey = '';
    if (_useSecure) {
      await _secure.delete(key: _geminiKey);
    } else {
      await _prefs.remove(_geminiKey);
    }
  }

  Future<void> setOpenAiKey(String key) async {
    _cachedOpenAiKey = key.trim();
    if (_useSecure) {
      await _secure.write(key: _openAiKey, value: key.trim());
    } else {
      await _prefs.setString(_openAiKey, key.trim());
    }
  }

  Future<void> clearOpenAiKey() async {
    _cachedOpenAiKey = '';
    if (_useSecure) {
      await _secure.delete(key: _openAiKey);
    } else {
      await _prefs.remove(_openAiKey);
    }
  }

  AiService get aiService => AiService(
    anthropicKey: hasAnthropicKey ? anthropicApiKey : null,
    geminiKey:    hasGeminiKey    ? geminiApiKey    : null,
    openAiKey:    hasOpenAiKey    ? openAiApiKey    : null,
  );

  // ── Feature gates — V2: everything unlocked ───────────────────────────────

  bool canUse(String feature) => true;

  bool isLocked(String feature) => false;

  // ── Free AI call quota ────────────────────────────────────────────────────

  int get _freeAiCallsRemaining {
    final today = _todayString;
    final savedDate = _prefs.getString(_aiCallsDate) ?? '';
    if (savedDate != today) return _freeAiLimit;
    final used = _prefs.getInt(_aiCallsToday) ?? 0;
    return (_freeAiLimit - used).clamp(0, _freeAiLimit);
  }

  int get freeAiCallsRemaining => isPremium ? 999 : _freeAiCallsRemaining;

  Future<bool> consumeAiCall() async {
    if (isPremium) return true;
    if (_freeAiCallsRemaining <= 0) return false;
    final today = _todayString;
    final savedDate = _prefs.getString(_aiCallsDate) ?? '';
    final current = savedDate == today ? (_prefs.getInt(_aiCallsToday) ?? 0) : 0;
    await _prefs.setString(_aiCallsDate, today);
    await _prefs.setInt(_aiCallsToday, current + 1);
    return true;
  }

  String get _todayString {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  // ── Daily reading cache ───────────────────────────────────────────────────

  static const _dailyReadingKey  = 'daily_reading_text';
  static const _dailyReadingDate = 'daily_reading_date';
  static const _readingHistKey   = 'daily_reading_history'; // JSON list

  String? getCachedDailyReading() {
    final today = _todayString;
    if (_prefs.getString(_dailyReadingDate) != today) return null;
    return _prefs.getString(_dailyReadingKey);
  }

  Future<void> cacheDailyReading(String text) async {
    final today = _todayString;
    await _prefs.setString(_dailyReadingDate, today);
    await _prefs.setString(_dailyReadingKey, text);

    // Append to history (last 7 entries)
    final raw = _prefs.getString(_readingHistKey);
    final history = raw != null
        ? List<Map<String, dynamic>>.from(jsonDecode(raw) as List)
        : <Map<String, dynamic>>[];
    history.removeWhere((e) => e['date'] == today);
    history.insert(0, {'date': today, 'text': text});
    if (history.length > 7) history.removeLast();
    await _prefs.setString(_readingHistKey, jsonEncode(history));
  }

  List<Map<String, dynamic>> getDailyReadingHistory() {
    final raw = _prefs.getString(_readingHistKey);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw) as List);
  }

  // ── Free tier feature list ────────────────────────────────────────────────

  static const Map<String, String> freeFeatures = {
    'Western Chart': 'Full tropical zodiac chart',
    'Basic Profile': 'Paulien\'s Sky overview',
    'Traditions Guide': 'Learn about all 6 traditions',
    'AI Readings (3/day)': 'Three AI readings per day',
  };

  static const Map<String, String> premiumFeatures = {
    'All 7 Culture Charts': 'Western, Vedic, Chinese, Mayan, Egyptian, Celtic, Zoroastrian',
    'Unlimited AI Readings': 'Powered by Claude & Gemini',
    'AI Astro Chat': 'Ask anything about your chart',
    'Personality Radar': 'Multi-tradition trait synthesis',
    'Fixed Star Analysis': '18 Behenian stars at your birth',
    'Daily AI Reading': 'Fresh insight every morning',
    'Share Card': 'Export your sky to share',
    'Multiple Profiles': 'Paulien, Nurse, Bernd — all traditions',
    'Local AI (AETHER)': 'On-device llama.cpp, no cloud needed',
    'Bring Your Own API Key': 'Use your Anthropic or Gemini key',
  };
}

