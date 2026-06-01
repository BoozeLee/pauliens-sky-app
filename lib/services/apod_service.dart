/// NASA APOD — Astronomy Picture of the Day
/// API: https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY
/// Rate limit: 1000 req/hr with DEMO_KEY. Cached daily.
library apod_service;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApodData {
  final String title;
  final String url;
  final String hdurl;
  final String explanation;
  final String mediaType; // 'image' | 'video'
  final String date;
  final String? copyright;

  const ApodData({
    required this.title,
    required this.url,
    required this.hdurl,
    required this.explanation,
    required this.mediaType,
    required this.date,
    this.copyright,
  });

  factory ApodData.fromJson(Map<String, dynamic> j) => ApodData(
    title:       j['title']       as String? ?? '',
    url:         j['url']         as String? ?? '',
    hdurl:       j['hdurl']       as String? ?? j['url'] as String? ?? '',
    explanation: j['explanation'] as String? ?? '',
    mediaType:   j['media_type']  as String? ?? 'image',
    date:        j['date']        as String? ?? '',
    copyright:   j['copyright']   as String?,
  );

  Map<String, dynamic> toJson() => {
    'title': title, 'url': url, 'hdurl': hdurl,
    'explanation': explanation, 'media_type': mediaType,
    'date': date, if (copyright != null) 'copyright': copyright,
  };

  String get thumbnailUrl => mediaType == 'video'
      ? _youtubeThumbnail(url)
      : url;

  static String _youtubeThumbnail(String videoUrl) {
    final re = RegExp(r'(?:v=|youtu\.be/)([A-Za-z0-9_-]{11})');
    final m  = re.firstMatch(videoUrl);
    return m != null
        ? 'https://img.youtube.com/vi/${m.group(1)}/hqdefault.jpg'
        : videoUrl;
  }
}

class ApodService {
  static const _apiUrl  = 'https://api.nasa.gov/planetary/apod';
  static const _apiKey  = 'DEMO_KEY';
  static const _cacheKey = 'apod_cache';
  static const _dateKey  = 'apod_date';

  static ApodService? _instance;
  static ApodService get instance => _instance ??= ApodService._();
  ApodService._();

  ApodData? _cached;

  /// Returns today's APOD. Checks in-memory cache, then disk, then network.
  Future<ApodData?> fetchToday() async {
    final today = _todayStr();
    if (_cached != null && _cached!.date == today) return _cached;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_dateKey) == today) {
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        try {
          _cached = ApodData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
          return _cached;
        } catch (_) {}
      }
    }

    try {
      final uri = Uri.parse(_apiUrl).replace(
          queryParameters: {'api_key': _apiKey, 'thumbs': 'true'});
      final resp = await http.get(uri).timeout(const Duration(seconds: 10));
      if (resp.statusCode != 200) return null;
      final data = ApodData.fromJson(
          jsonDecode(resp.body) as Map<String, dynamic>);
      _cached = data;
      await prefs.setString(_dateKey,  today);
      await prefs.setString(_cacheKey, jsonEncode(data.toJson()));
      return data;
    } catch (_) {
      return null;
    }
  }

  String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
  }
}
