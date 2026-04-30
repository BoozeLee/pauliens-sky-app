import 'dart:math' as math;

enum Planet { sun, moon, mercury, venus, mars, jupiter, saturn, uranus, neptune, pluto }

class PlanetPosition {
  final Planet planet;
  final double eclipticLongitude; // 0–360°
  final double eclipticLatitude;
  final double distance; // AU

  const PlanetPosition({
    required this.planet,
    required this.eclipticLongitude,
    required this.eclipticLatitude,
    required this.distance,
  });

  String get signName {
    const signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
    ];
    return signs[(eclipticLongitude ~/ 30) % 12];
  }

  double get degreeInSign => eclipticLongitude % 30;
}

class AstroSnapshot {
  final Map<Planet, PlanetPosition> positions;
  final double ascendant; // ecliptic longitude rising on the eastern horizon
  final double midheaven;
  final double siderealOffset; // ayanamsha (tropical - sidereal), ~24° currently
  final double lunarPhase; // 0–360°, 0=new, 180=full

  const AstroSnapshot({
    required this.positions,
    required this.ascendant,
    required this.midheaven,
    required this.siderealOffset,
    required this.lunarPhase,
  });

  PlanetPosition? operator [](Planet p) => positions[p];

  double get lunarIllumination {
    final angle = lunarPhase * math.pi / 180;
    return (1 - math.cos(angle)) / 2;
  }

  String get moonPhaseName {
    if (lunarPhase < 22.5) return 'New Moon';
    if (lunarPhase < 67.5) return 'Waxing Crescent';
    if (lunarPhase < 112.5) return 'First Quarter';
    if (lunarPhase < 157.5) return 'Waxing Gibbous';
    if (lunarPhase < 202.5) return 'Full Moon';
    if (lunarPhase < 247.5) return 'Waning Gibbous';
    if (lunarPhase < 292.5) return 'Last Quarter';
    if (lunarPhase < 337.5) return 'Waning Crescent';
    return 'New Moon';
  }
}
