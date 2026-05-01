import '../models/birth_context.dart';
import '../models/astro_snapshot.dart';
import '../models/culture_chart.dart';
import '../cultures/western/western_module.dart';
import '../cultures/vedic/vedic_module.dart';
import '../cultures/chinese/chinese_module.dart';
import '../cultures/mayan/mayan_module.dart';
import '../cultures/egyptian/egyptian_module.dart';
import '../cultures/celtic/celtic_module.dart';
import '../cultures/zoroastrian/zoroastrian_module.dart';
import 'ephemeris_service.dart';
import 'fixed_stars.dart';

class FullChart {
  final BirthContext context;
  final AstroSnapshot snapshot;
  final List<CultureChart> charts;
  final List<(FixedStar, double)> prominentStars;
  final PersonalityProfile personality;

  const FullChart({
    required this.context,
    required this.snapshot,
    required this.charts,
    required this.prominentStars,
    required this.personality,
  });

  CultureChart? chart(CultureId id) =>
      charts.where((c) => c.id == id).firstOrNull;
}

class PersonalityProfile {
  // Radar chart dimensions — 0.0–1.0 scores
  final double intuition;
  final double creativity;
  final double intellect;
  final double drive;
  final double empathy;
  final double independence;
  final List<String> coreTraits;
  final String headline;
  final String summary;

  const PersonalityProfile({
    required this.intuition,
    required this.creativity,
    required this.intellect,
    required this.drive,
    required this.empathy,
    required this.independence,
    required this.coreTraits,
    required this.headline,
    required this.summary,
  });
}

class ChartEngine {
  final EphemerisService _ephemeris = EphemerisService();

  final _modules = [
    WesternModule(),
    VedicModule(),
    ChineseModule(),
    MayanModule(),
    EgyptianModule(),
    CelticModule(),
    ZoroastrianModule(),
  ];

  FullChart compute(BirthContext ctx) {
    final snapshot = _ephemeris.compute(ctx);

    final charts = _modules
        .map((m) => m.buildChart(ctx, snapshot))
        .toList();

    final sunLon = snapshot[Planet.sun]!.eclipticLongitude;
    final moonLon = snapshot[Planet.moon]!.eclipticLongitude;
    final prominentStars = [
      ...FixedStars.nearPlanet(sunLon, orb: 2.0),
      ...FixedStars.nearPlanet(moonLon, orb: 2.0),
      ...FixedStars.nearPlanet(snapshot.ascendant, orb: 2.0),
    ];

    final personality = _buildPersonality(charts, snapshot);

    return FullChart(
      context: ctx,
      snapshot: snapshot,
      charts: charts,
      prominentStars: prominentStars,
      personality: personality,
    );
  }

  PersonalityProfile _buildPersonality(
      List<CultureChart> charts, AstroSnapshot snapshot) {
    // Aggregate trait scores from multi-culture sign data
    final sunSign = charts.first.sunSign ?? '';
    final moonSign = charts.first.moonSign ?? '';

    // Water/Pisces → intuition, empathy; Fire → drive; Air → intellect; Earth → independence
    final moonElement = _element(snapshot[Planet.moon]!.eclipticLongitude);

    double intuition = 0.5;
    double creativity = 0.5;
    double intellect = 0.5;
    double drive = 0.5;
    double empathy = 0.5;
    double independence = 0.5;

    // Western Sun sign influence
    switch (sunSign) {
      case 'Pisces':
        intuition += 0.35; empathy += 0.3; creativity += 0.25; intellect -= 0.05;
      case 'Aquarius':
        intellect += 0.3; independence += 0.3; intuition += 0.1;
      case 'Aries':
        drive += 0.35; independence += 0.2;
      case 'Gemini':
        intellect += 0.35; creativity += 0.2;
      case 'Leo':
        creativity += 0.3; drive += 0.25;
      case 'Scorpio':
        intuition += 0.3; drive += 0.2; empathy += 0.1;
      case 'Cancer':
        empathy += 0.35; intuition += 0.2;
      case 'Sagittarius':
        independence += 0.3; drive += 0.2;
      default:
    }

    // Moon element influence
    switch (moonElement) {
      case 'Water': empathy += 0.15; intuition += 0.1;
      case 'Fire': drive += 0.15; creativity += 0.1;
      case 'Air': intellect += 0.15;
      case 'Earth': independence += 0.1;
      default:
    }

    // Chinese animal influence (year pillar)
    final chineseChart = charts.where((c) => c.id == CultureId.chinese).firstOrNull;
    if (chineseChart != null) {
      final animal = chineseChart.sunSign ?? '';
      switch (animal) {
        case 'Rat': intellect += 0.1; creativity += 0.1;
        case 'Dragon': drive += 0.15; creativity += 0.1;
        case 'Snake': intuition += 0.15; independence += 0.1;
        case 'Horse': independence += 0.15; drive += 0.1;
        case 'Monkey': intellect += 0.15; creativity += 0.15;
        default:
      }
    }

    // Clamp to 0–1
    double clamp(double v) => v.clamp(0.0, 1.0);

    final traits = _deriveTraits(sunSign, moonSign,
        chineseChart?.sunSign ?? '', intuition, creativity, drive, empathy);

    return PersonalityProfile(
      intuition: clamp(intuition),
      creativity: clamp(creativity),
      intellect: clamp(intellect),
      drive: clamp(drive),
      empathy: clamp(empathy),
      independence: clamp(independence),
      coreTraits: traits,
      headline: _headline(sunSign, chineseChart?.sunSign ?? ''),
      summary: _summary(sunSign, chineseChart?.sunSign ?? '', traits),
    );
  }

  String _element(double lon) {
    const elements = [
      'Fire', 'Earth', 'Air', 'Water', 'Fire', 'Earth',
      'Air', 'Water', 'Fire', 'Earth', 'Air', 'Water',
    ];
    return elements[(lon ~/ 30) % 12];
  }

  List<String> _deriveTraits(String sun, String moon, String animal,
      double intuition, double creativity, double drive, double empathy) {
    final traits = <String>[];
    if (intuition > 0.75) traits.add('Deeply intuitive');
    if (empathy > 0.7) traits.add('Empathic heart');
    if (creativity > 0.7) traits.add('Creative visionary');
    if (drive > 0.7) traits.add('Driven achiever');
    if (intuition > 0.6 && empathy > 0.6) traits.add('Emotionally intelligent');
    if (sun == 'Pisces') traits.addAll(['Spiritual seeker', 'Boundless imagination']);
    if (sun == 'Aquarius') traits.addAll(['Humanitarian', 'Original thinker']);
    if (animal == 'Rat') traits.add('Resourceful strategist');
    if (animal == 'Dragon') traits.add('Natural leader');
    if (traits.length < 4) traits.add('Bridge between worlds');
    return traits.take(6).toList();
  }

  String _headline(String sun, String animal) {
    if (sun == 'Pisces' && animal == 'Rat') {
      return 'The Dreaming Navigator';
    }
    if (sun == 'Pisces') return 'The Cosmic Empath';
    if (sun == 'Aquarius') return 'The Visionary Rebel';
    return 'The Sky Walker';
  }

  String _summary(String sun, String animal, List<String> traits) {
    if (sun == 'Pisces' && animal == 'Rat') {
      return 'A rare weaving of Pisces depth and Rat intelligence — the ability to '
          'dream vast and also navigate toward those dreams with precision. '
          'Where Pisces dissolves boundaries, the Rat provides the map. '
          'The result: an intuitive strategist who moves through the world like water, '
          'finding the path of least resistance while still arriving exactly where intended.';
    }
    return 'A soul shaped by ${traits.take(3).join(", ")} — '
        'carrying the $sun Sun\'s gifts into the world through $animal resourcefulness.';
  }
}
