import '../models/astro_snapshot.dart';
import '../models/synastry_chart.dart';
import 'chart_engine.dart';

class SynastryEngine {
  static const _planets = Planet.values;

  SynastryChart compute(FullChart chartA, FullChart chartB) {
    final points = <({double lon, String label, Planet? planet})>[];

    // Collect points for person A
    for (final p in _planets) {
      final pos = chartA.snapshot[p];
      if (pos != null) {
        points.add((lon: pos.eclipticLongitude, label: _label(p), planet: p));
      }
    }
    points.add((lon: chartA.snapshot.ascendant, label: 'ASC', planet: null));

    final pointsB = <({double lon, String label, Planet? planet})>[];
    for (final p in _planets) {
      final pos = chartB.snapshot[p];
      if (pos != null) {
        pointsB.add((lon: pos.eclipticLongitude, label: _label(p), planet: p));
      }
    }
    pointsB.add((lon: chartB.snapshot.ascendant, label: 'ASC', planet: null));

    final aspects = <SynastryAspect>[];

    for (final a in points) {
      for (final b in pointsB) {
        final aspect = _findAspect(a.lon, b.lon);
        if (aspect != null) {
          aspects.add(SynastryAspect(
            planetA: a.planet,
            pointLabelA: a.label,
            planetB: b.planet,
            pointLabelB: b.label,
            type: aspect.$1,
            orb: aspect.$2,
          ));
        }
      }
    }

    // Sort by strength descending
    aspects.sort((x, y) => y.strength.compareTo(x.strength));

    return SynastryChart(
      nameA: chartA.context.personName ?? 'A',
      nameB: chartB.context.personName ?? 'B',
      aspects: aspects,
    );
  }

  // Returns the tightest aspect within orb, or null if none
  (AspectType, double)? _findAspect(double lonA, double lonB) {
    final diff = _angleDiff(lonA, lonB);

    (AspectType, double)? best;
    for (final type in AspectType.values) {
      final target = _aspectAngle(type);
      final orb = (diff - target).abs();
      if (orb <= type.maxOrb) {
        if (best == null || orb < best.$2) {
          best = (type, orb);
        }
      }
    }
    return best;
  }

  double _angleDiff(double a, double b) {
    final d = ((a - b).abs()) % 360;
    return d > 180 ? 360 - d : d;
  }

  double _aspectAngle(AspectType t) {
    switch (t) {
      case AspectType.conjunction: return 0;
      case AspectType.sextile: return 60;
      case AspectType.square: return 90;
      case AspectType.trine: return 120;
      case AspectType.opposition: return 180;
    }
  }

  static String _label(Planet p) {
    switch (p) {
      case Planet.sun: return 'Sun';
      case Planet.moon: return 'Moon';
      case Planet.mercury: return 'Mercury';
      case Planet.venus: return 'Venus';
      case Planet.mars: return 'Mars';
      case Planet.jupiter: return 'Jupiter';
      case Planet.saturn: return 'Saturn';
      case Planet.uranus: return 'Uranus';
      case Planet.neptune: return 'Neptune';
      case Planet.pluto: return 'Pluto';
    }
  }
}
