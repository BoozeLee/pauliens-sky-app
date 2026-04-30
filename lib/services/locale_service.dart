// Simple key-value localization. Extend as the UI grows.
// Switch locale via LocaleService.instance.setLocale(...)

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLocale { en, nl }

class LocaleService extends ChangeNotifier {
  static LocaleService? _instance;
  static LocaleService get instance => _instance!;

  static const _key = 'app_locale';

  AppLocale _locale = AppLocale.nl; // Default Dutch for Paulien

  AppLocale get locale => _locale;
  bool get isNl => _locale == AppLocale.nl;

  static Future<LocaleService> init() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = LocaleService._();
    final saved = prefs.getString(_key);
    if (saved == 'en') _instance!._locale = AppLocale.en;
    return _instance!;
  }

  LocaleService._();

  Future<void> setLocale(AppLocale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.name);
  }

  String t(String key) => (_locale == AppLocale.nl ? _nl : _en)[key] ?? key;

  // ─────────────────────────────────────────────────────────────────────────

  static const _en = {
    'app_name': "Paulien's Sky",
    'tagline': 'One sky. Many traditions.',
    'daily_reading': 'DAILY READING',
    'read_new_sky': 'READ A NEW SKY',
    'traditions': 'TRADITIONS',
    'new_chart': 'New Chart',
    'new_chart_sub': 'Enter a birth date, time & place',
    'profile': 'Profile →',
    'reading_stars': 'Reading the stars…',
    'unlock_premium': 'Unlock Premium',
    'add_api_key': 'ADD API KEY — UNLOCK FREE',
    'settings': 'Settings',
    'save': 'Save',
    'birth_date': 'Birth Date',
    'birth_time': 'Birth Time',
    'birth_place': 'Birth Place',
    'name': 'Name',
    'time_unknown': 'Birth time unknown (use noon)',
    'anthropic_key': 'Anthropic API Key',
    'gemini_key': 'Gemini API Key',
    'subscription': 'Subscription',
    'free_tier': 'Free Tier',
    'premium_tier': 'Premium',
    'ai_calls_today': 'AI calls today',
    'explore': 'Explore',
    'chart': 'Chart',
    'home': 'Home',
    'ai': 'AI',
    'key_insights': 'KEY INSIGHTS',
    'fixed_stars': 'FIXED STARS AT BIRTH',
    'behenian': 'Behenian',
    'nature': 'Nature',
    'stone': 'Stone',
    'herb': 'Herb',
    'get_daily_reading': "Get Today's Reading",
    'add_key_prompt':
        'Add an API key to unlock a fresh AI reading every morning.',
    'western': 'Western',
    'chinese': 'Chinese',
    'vedic': 'Vedic',
    'mayan': 'Mayan',
    'egyptian': 'Egyptian',
    'celtic': 'Celtic',
    'tropical': 'Tropical',
    'sidereal': 'Sidereal',
  };

  static const _nl = {
    'app_name': "Paulien's Hemel",
    'tagline': 'Één hemel. Vele tradities.',
    'daily_reading': 'DAGELIJKSE LEZING',
    'read_new_sky': 'NIEUW HEMELKAART LEZEN',
    'traditions': 'TRADITIES',
    'new_chart': 'Nieuw Kaart',
    'new_chart_sub': 'Voer geboortedatum, -tijd & -plaats in',
    'profile': 'Profiel →',
    'reading_stars': 'De sterren raadplegen…',
    'unlock_premium': 'Premium Ontgrendelen',
    'add_api_key': 'API-SLEUTEL TOEVOEGEN — GRATIS',
    'settings': 'Instellingen',
    'save': 'Opslaan',
    'birth_date': 'Geboortedatum',
    'birth_time': 'Geboortetijd',
    'birth_place': 'Geboorteplaats',
    'name': 'Naam',
    'time_unknown': 'Geboortetijd onbekend (gebruik 12:00)',
    'anthropic_key': 'Anthropic API-sleutel',
    'gemini_key': 'Gemini API-sleutel',
    'subscription': 'Abonnement',
    'free_tier': 'Gratis',
    'premium_tier': 'Premium',
    'ai_calls_today': 'AI-gesprekken vandaag',
    'explore': 'Ontdekken',
    'chart': 'Kaart',
    'home': 'Thuis',
    'ai': 'AI',
    'key_insights': 'KERNINZICHTEN',
    'fixed_stars': 'VASTE STERREN BIJ GEBOORTE',
    'behenian': 'Behenisch',
    'nature': 'Aard',
    'stone': 'Steen',
    'herb': 'Kruid',
    'get_daily_reading': 'Dagelijkse Lezing Ophalen',
    'add_key_prompt':
        'Voeg een API-sleutel toe voor een verse AI-lezing elke ochtend.',
    'western': 'Westers',
    'chinese': 'Chinees',
    'vedic': 'Vedisch',
    'mayan': 'Mayaans',
    'egyptian': 'Egyptisch',
    'celtic': 'Keltisch',
    'tropical': 'Tropisch',
    'sidereal': 'Siderisch',
  };
}
