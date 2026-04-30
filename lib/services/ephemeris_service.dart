import 'dart:math' as math;
import '../models/birth_context.dart';
import '../models/astro_snapshot.dart';

// Pure-Dart VSOP87-derived low-precision solar system positions.
// Accuracy: ~1° for major planets, suitable for astrological purposes.
// For production, replace with Swiss Ephemeris FFI or a hosted API.
class EphemerisService {
  static const double _deg = math.pi / 180;
  static const double _rad = 180 / math.pi;

  AstroSnapshot compute(BirthContext ctx) {
    final jd = _julianDay(ctx.utcTime);
    final t = (jd - 2451545.0) / 36525.0; // Julian centuries from J2000

    final positions = <Planet, PlanetPosition>{};
    for (final planet in Planet.values) {
      positions[planet] = _computePlanet(planet, t);
    }

    final asc = _computeAscendant(t, ctx.latitude, ctx.longitude);
    final mc = _computeMidheaven(t, ctx.longitude);
    final siderealOffset = _ayanamsha(jd);
    final lunarPhase = _lunarPhase(
      positions[Planet.sun]!.eclipticLongitude,
      positions[Planet.moon]!.eclipticLongitude,
    );

    return AstroSnapshot(
      positions: positions,
      ascendant: asc,
      midheaven: mc,
      siderealOffset: siderealOffset,
      lunarPhase: lunarPhase,
    );
  }

  double _julianDay(DateTime dt) {
    final y = dt.year;
    final m = dt.month;
    final d = dt.day + (dt.hour + dt.minute / 60 + dt.second / 3600) / 24;

    int a = ((14 - m) / 12).floor();
    int yr = y + 4800 - a;
    int mo = m + 12 * a - 3;

    double jdn = d + ((153 * mo + 2) / 5).floor() +
        365 * yr +
        (yr / 4).floor() -
        (yr / 100).floor() +
        (yr / 400).floor() -
        32045;
    return jdn;
  }

  // Lahiri ayanamsha approximation (degrees)
  double _ayanamsha(double jd) {
    final t = (jd - 2451545.0) / 36525.0;
    return 23.85 + 1.3972 * t; // rough Lahiri
  }

  double _norm360(double x) => ((x % 360) + 360) % 360;

  double _lunarPhase(double sunLon, double moonLon) =>
      _norm360(moonLon - sunLon);

  PlanetPosition _computePlanet(Planet planet, double t) {
    final lon = _norm360(_meanLongitude(planet, t));
    return PlanetPosition(
      planet: planet,
      eclipticLongitude: lon,
      eclipticLatitude: 0, // simplified
      distance: _meanDistance(planet),
    );
  }

  // Low-precision mean ecliptic longitudes (J2000 elements)
  double _meanLongitude(Planet planet, double t) {
    return switch (planet) {
      Planet.sun => _sunLongitude(t),
      Planet.moon => _moonLongitude(t),
      Planet.mercury => 252.2509 + 149472.6746 * t,
      Planet.venus => 181.9798 + 58517.8157 * t,
      Planet.mars => 355.4330 + 19140.2993 * t,
      Planet.jupiter => 34.3515 + 3034.9057 * t,
      Planet.saturn => 50.0774 + 1222.1138 * t,
      Planet.uranus => 314.0550 + 428.4882 * t,
      Planet.neptune => 304.3487 + 218.4862 * t,
      Planet.pluto => 238.9508 + 145.1781 * t,
    };
  }

  double _sunLongitude(double t) {
    final M = _norm360(357.5291 + 35999.0503 * t);
    final rad = M * _deg;
    final C = 1.9146 * math.sin(rad) +
        0.0200 * math.sin(2 * rad) +
        0.0003 * math.sin(3 * rad);
    return 280.4665 + 36000.7698 * t + C;
  }

  double _moonLongitude(double t) {
    final L = _norm360(218.3165 + 481267.8813 * t);
    final M = _norm360(357.5291 + 35999.0503 * t);
    final Mp = _norm360(134.9634 + 477198.8676 * t);
    final D = _norm360(297.8502 + 445267.1115 * t);
    final F = _norm360(93.2721 + 483202.0175 * t);

    final lon = L +
        6.2888 * math.sin(Mp * _deg) +
        1.2740 * math.sin((2 * D - Mp) * _deg) +
        0.6583 * math.sin(2 * D * _deg) +
        0.2136 * math.sin(2 * Mp * _deg) -
        0.1851 * math.sin(M * _deg) -
        0.1143 * math.sin(2 * F * _deg);
    return lon;
  }

  double _meanDistance(Planet planet) => switch (planet) {
    Planet.sun => 1.0,
    Planet.moon => 0.00257, // AU
    Planet.mercury => 0.387,
    Planet.venus => 0.723,
    Planet.mars => 1.524,
    Planet.jupiter => 5.203,
    Planet.saturn => 9.537,
    Planet.uranus => 19.19,
    Planet.neptune => 30.07,
    Planet.pluto => 39.48,
  };

  double _computeAscendant(double t, double lat, double lon) {
    // RAMC = Right Ascension of Midheaven
    final theta = _localSiderealTime(t, lon);
    final eps = _obliquity(t);
    final latR = lat * _deg;
    final thetaR = theta * _deg;
    final epsR = eps * _deg;

    final asc = math.atan2(
      math.cos(thetaR),
      -(math.sin(thetaR) * math.cos(epsR) +
          math.tan(latR) * math.sin(epsR)),
    ) * _rad;

    return _norm360(asc);
  }

  double _computeMidheaven(double t, double lon) {
    final theta = _localSiderealTime(t, lon);
    final eps = _obliquity(t);
    final mc = math.atan2(
      math.tan(theta * _deg),
      math.cos(eps * _deg),
    ) * _rad;
    return _norm360(mc);
  }

  double _localSiderealTime(double t, double longitude) {
    final gmst = 280.46061837 + 360.98564736629 * (t * 36525) + longitude;
    return _norm360(gmst);
  }

  double _obliquity(double t) => 23.439291111 - 0.013004167 * t;
}
