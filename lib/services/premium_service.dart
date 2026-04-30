import 'package:shared_preferences/shared_preferences.dart';
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
  static const _aiCallsToday  = 'ai_calls_today';
  static const _aiCallsDate   = 'ai_calls_date';
  static const _freeAiLimit   = 3; // free tier gets 3 AI calls/day

  static PremiumService? _instance;
  static PremiumService get instance => _instance!;

  final SharedPreferences _prefs;

  PremiumService._(this._prefs);

  static Future<PremiumService> init() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = PremiumService._(prefs);
    return _instance!;
  }

  // ── Tier ─────────────────────────────────────────────────────────────────

  PremiumTier get tier {
    // Auto-upgrade to premium if user has own API keys
    if (hasAnthropicKey || hasGeminiKey) return PremiumTier.premium;
    final saved = _prefs.getString(_tierKey);
    return saved == 'premium' ? PremiumTier.premium : PremiumTier.free;
  }

  bool get isPremium => tier == PremiumTier.premium;

  Future<void> setPremium(bool value) async {
    await _prefs.setString(_tierKey, value ? 'premium' : 'free');
  }

  // ── API Keys ──────────────────────────────────────────────────────────────

  String get anthropicApiKey => _prefs.getString(_anthropicKey) ?? '';
  String get geminiApiKey    => _prefs.getString(_geminiKey) ?? '';
  bool   get hasAnthropicKey => anthropicApiKey.isNotEmpty;
  bool   get hasGeminiKey    => geminiApiKey.isNotEmpty;
  bool   get hasAnyKey       => hasAnthropicKey || hasGeminiKey;

  Future<void> setAnthropicKey(String key) async =>
      _prefs.setString(_anthropicKey, key.trim());
  Future<void> setGeminiKey(String key) async =>
      _prefs.setString(_geminiKey, key.trim());
  Future<void> clearAnthropicKey() async => _prefs.remove(_anthropicKey);
  Future<void> clearGeminiKey() async    => _prefs.remove(_geminiKey);

  AiService get aiService => AiService(
    anthropicKey: hasAnthropicKey ? anthropicApiKey : null,
    geminiKey:    hasGeminiKey    ? geminiApiKey    : null,
  );

  // ── Feature gates ─────────────────────────────────────────────────────────

  bool canUse(String feature) {
    if (isPremium) return true;
    return switch (feature) {
      PremiumFeature.aiInterpretation => _freeAiCallsRemaining > 0,
      PremiumFeature.dailyReading     => _freeAiCallsRemaining > 0,
      // Always free:
      _ => false,
    };
  }

  bool isLocked(String feature) => !canUse(feature);

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

  // ── Free tier feature list ────────────────────────────────────────────────

  static const Map<String, String> freeFeatures = {
    'Western Chart': 'Full tropical zodiac chart',
    'Basic Profile': 'Paulien\'s Sky overview',
    'Traditions Guide': 'Learn about all 6 traditions',
    'AI Readings (3/day)': 'Three AI readings per day',
  };

  static const Map<String, String> premiumFeatures = {
    'All 6 Culture Charts': 'Western, Vedic, Chinese, Mayan, Egyptian, Celtic',
    'Unlimited AI Readings': 'Powered by Claude Opus & Gemini',
    'AI Astro Chat': 'Ask anything about your chart',
    'Personality Radar': 'Multi-tradition trait synthesis',
    'Fixed Star Analysis': '16 Behenian stars at your birth',
    'Daily AI Reading': 'Fresh insight every morning',
    'Share Card': 'Export your sky to share',
    'Multiple Profiles': 'Charts for family & friends',
    'Bring Your Own API Key': 'Use your Anthropic or Gemini key',
  };
}

