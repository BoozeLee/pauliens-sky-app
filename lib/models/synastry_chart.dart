import 'astro_snapshot.dart';

enum AspectType {
  conjunction,
  sextile,
  square,
  trine,
  opposition;

  String get symbol {
    switch (this) {
      case conjunction: return '☌';
      case sextile: return '⚹';
      case square: return '□';
      case trine: return '△';
      case opposition: return '☍';
    }
  }

  String get label {
    switch (this) {
      case conjunction: return 'Conjunction';
      case sextile: return 'Sextile';
      case square: return 'Square';
      case trine: return 'Trine';
      case opposition: return 'Opposition';
    }
  }

  // Positive = harmonious, lower = challenging
  double get harmony {
    switch (this) {
      case conjunction: return 1.0;
      case trine: return 0.9;
      case sextile: return 0.75;
      case opposition: return 0.4;
      case square: return 0.25;
    }
  }

  // Maximum allowed orb (degrees)
  double get maxOrb {
    switch (this) {
      case conjunction: return 8.0;
      case opposition: return 8.0;
      case trine: return 7.0;
      case square: return 7.0;
      case sextile: return 5.0;
    }
  }
}

// null planetKey means the point is ASC or MC (stored in pointLabel)
class SynastryAspect {
  final Planet? planetA;
  final String pointLabelA; // "Sun", "Moon", "ASC", etc.
  final Planet? planetB;
  final String pointLabelB;
  final AspectType type;
  final double orb; // actual degree difference from exact

  const SynastryAspect({
    required this.planetA,
    required this.pointLabelA,
    required this.planetB,
    required this.pointLabelB,
    required this.type,
    required this.orb,
  });

  // Tighter orb = stronger aspect (1.0 at 0°, 0.0 at maxOrb)
  double get strength => 1.0 - orb / type.maxOrb;
}

class SynastryChart {
  final String nameA;
  final String nameB;
  final List<SynastryAspect> aspects;

  const SynastryChart({
    required this.nameA,
    required this.nameB,
    required this.aspects,
  });

  // Overall compatibility 0.0–1.0
  double get score {
    if (aspects.isEmpty) return 0.5;
    double total = 0;
    double weight = 0;
    for (final a in aspects) {
      final w = _weight(a);
      total += a.type.harmony * a.strength * w;
      weight += w;
    }
    return weight == 0 ? 0.5 : (total / weight).clamp(0.0, 1.0);
  }

  List<SynastryAspect> get harmonious =>
      aspects.where((a) => a.type.harmony >= 0.75).toList()
        ..sort((a, b) => b.strength.compareTo(a.strength));

  List<SynastryAspect> get challenging =>
      aspects.where((a) => a.type.harmony < 0.75).toList()
        ..sort((a, b) => b.strength.compareTo(a.strength));

  double _weight(SynastryAspect a) {
    final key = _pairKey(a.pointLabelA, a.pointLabelB);
    const weights = {
      'Sun-Moon': 2.5, 'Moon-Sun': 2.5,
      'Sun-Sun': 1.5, 'Moon-Moon': 1.5,
      'Venus-Mars': 2.0, 'Mars-Venus': 2.0,
      'Sun-Venus': 1.5, 'Venus-Sun': 1.5,
      'Sun-Mars': 1.3, 'Mars-Sun': 1.3,
      'Moon-Venus': 1.4, 'Venus-Moon': 1.4,
      'Moon-Mars': 1.2, 'Mars-Moon': 1.2,
      'ASC-Sun': 1.5, 'Sun-ASC': 1.5,
      'ASC-Moon': 1.4, 'Moon-ASC': 1.4,
      'ASC-Venus': 1.3, 'Venus-ASC': 1.3,
    };
    return weights[key] ?? 1.0;
  }

  String _pairKey(String a, String b) => '$a-$b';
}
