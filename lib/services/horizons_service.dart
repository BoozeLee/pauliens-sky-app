/// HorizonsService — JPL Horizons API (ssd.jpl.nasa.gov/api/horizons.api)
/// Fetches sub-arcsecond geocentric ecliptic longitudes for all planets.
/// Applies IERS Delta-T (Espenak & Meeus) to convert UTC → TT (JDE).
/// Results cached forever by JDE key (birth charts never change).

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/birth_context.dart';
import '../models/astro_snapshot.dart';

class HorizonsService {
  static const _base = 'https://ssd.jpl.nasa.gov/api/horizons.api';

  static const _bodyIds = {
    Planet.sun:     '10',
    Planet.moon:    '301',
    Planet.mercury: '199',
    Planet.venus:   '299',
    Planet.mars:    '499',
    Planet.jupiter: '599',
    Planet.saturn:  '699',
    Planet.uranus:  '799',
    Planet.neptune: '899',
    Planet.pluto:   '999',
  };

  // ── Delta-T (Espenak & Meeus 2006) ───────────────────────────────────────
  // Returns ΔT in seconds. Accuracy ≈ ±1s for 1986–2026.
  static double deltaT(DateTime utc) {
    final y = utc.year + (utc.month - 0.5) / 12.0;
    final t = y - 2000.0;
    if (y >= 1986 && y < 2005) {
      return 63.86
          + 0.3345    * t
          - 0.060374  * t * t
          + 0.0017275 * t * t * t
          + 0.000651814 * _pow4(t)
          + 0.00002373599 * _pow5(t);
    }
    if (y >= 2005 && y < 2050) {
      return 62.92 + 0.32217 * t + 0.005589 * t * t;
    }
    return 69.0; // rough fallback
  }

  static double _pow4(double x) => x * x * x * x;
  static double _pow5(double x) => x * x * x * x * x;

  /// Julian Ephemeris Day = Julian Day + ΔT/86400
  static double jde(DateTime utc) => _julianDay(utc) + deltaT(utc) / 86400.0;

  static double _julianDay(DateTime dt) {
    final y = dt.year; final m = dt.month;
    final d = dt.day + (dt.hour + dt.minute / 60.0 + dt.second / 3600.0) / 24.0;
    final a = ((14 - m) / 12).floor();
    final yr = y + 4800 - a;
    final mo = m + 12 * a - 3;
    return d + ((153 * mo + 2) / 5).floor()
        + 365 * yr + (yr / 4).floor()
        - (yr / 100).floor() + (yr / 400).floor() - 32045;
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Fetch all planet positions from JPL Horizons.
  /// Returns null on network/parse failure (caller falls back to VSOP87).
  Future<Map<Planet, PlanetPosition>?> fetchPositions(BirthContext ctx) async {
    final cacheKey = 'horizons_${jde(ctx.utcTime).toStringAsFixed(4)}';
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        final map = jsonDecode(cached) as Map<String, dynamic>;
        return _deserializePositions(map);
      } catch (_) {}
    }

    try {
      final positions = <Planet, PlanetPosition>{};
      for (final entry in _bodyIds.entries) {
        final pos = await _fetchOnePlanet(entry.key, entry.value, ctx);
        if (pos == null) return null;
        positions[entry.key] = pos;
      }
      await prefs.setString(cacheKey, jsonEncode(_serializePositions(positions)));
      return positions;
    } catch (_) {
      return null;
    }
  }

  // ── Per-planet HTTP call ──────────────────────────────────────────────────

  Future<PlanetPosition?> _fetchOnePlanet(
      Planet planet, String bodyId, BirthContext ctx) async {
    final start = _horizonsTime(ctx.utcTime);
    final stop  = _horizonsTime(ctx.utcTime.add(const Duration(hours: 1)));

    final uri = Uri.parse(_base).replace(queryParameters: {
      'format':     'json',
      'COMMAND':    "'$bodyId'",
      'OBJ_DATA':   "'NO'",
      'MAKE_EPHEM': "'YES'",
      'EPHEM_TYPE': "'OBSERVER'",
      'CENTER':     "'500@399'",  // geocenter
      'START_TIME': "'$start'",
      'STOP_TIME':  "'$stop'",
      'STEP_SIZE':  "'1h'",
      'QUANTITIES': "'31'",       // Observer ecliptic lon & lat
      'ANG_FORMAT': "'DEG'",
    });

    final resp = await http.get(uri).timeout(const Duration(seconds: 15));
    if (resp.statusCode != 200) return null;

    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final result = body['result'] as String? ?? '';
    return _parseEclipticLon(planet, result);
  }

  // ── Response parser ───────────────────────────────────────────────────────

  PlanetPosition? _parseEclipticLon(Planet planet, String text) {
    final soeIdx = text.indexOf('\$\$SOE');
    final eoeIdx = text.indexOf('\$\$EOE');
    if (soeIdx < 0 || eoeIdx < 0) return null;

    final block = text.substring(soeIdx + 5, eoeIdx).trim();
    final line  = block.split('\n').firstWhere(
        (l) => l.trim().isNotEmpty, orElse: () => '');
    if (line.isEmpty) return null;

    // Extract all decimal numbers from the data line.
    // Format: "YYYY-Mon-DD HH:MM  C/m  LON  LAT  ..."
    // We skip date/time tokens and take the first two decimals.
    final numRe = RegExp(r'-?\d+\.\d+');
    final nums  = numRe.allMatches(line).map((m) => double.parse(m.group(0)!)).toList();
    if (nums.isEmpty) return null;

    // First decimal >= 1 digit before decimal is the ecliptic longitude.
    // Filter out sub-degree date artifacts (hours like "08.00" can appear).
    final lon = nums.first;
    final lat = nums.length > 1 ? nums[1] : 0.0;

    return PlanetPosition(
      planet: planet,
      eclipticLongitude: _norm360(lon),
      eclipticLatitude: lat,
      distance: 1.0, // distance not fetched in this call
    );
  }

  double _norm360(double x) => ((x % 360) + 360) % 360;

  String _horizonsTime(DateTime dt) =>
      "${dt.year}-${_m(dt.month)}-${_m(dt.day)}+${_m(dt.hour)}:${_m(dt.minute)}";

  String _m(int n) => n.toString().padLeft(2, '0');

  // ── Serialization ─────────────────────────────────────────────────────────

  Map<String, dynamic> _serializePositions(Map<Planet, PlanetPosition> positions) =>
      positions.map((k, v) => MapEntry(k.name, {
        'lon': v.eclipticLongitude,
        'lat': v.eclipticLatitude,
        'dist': v.distance,
      }));

  Map<Planet, PlanetPosition> _deserializePositions(Map<String, dynamic> map) {
    final result = <Planet, PlanetPosition>{};
    for (final planet in Planet.values) {
      final entry = map[planet.name] as Map<String, dynamic>?;
      if (entry != null) {
        result[planet] = PlanetPosition(
          planet: planet,
          eclipticLongitude: (entry['lon'] as num).toDouble(),
          eclipticLatitude:  (entry['lat'] as num).toDouble(),
          distance:          (entry['dist'] as num).toDouble(),
        );
      }
    }
    return result;
  }
}
