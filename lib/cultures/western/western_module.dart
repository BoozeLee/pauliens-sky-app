import '../../models/birth_context.dart';
import '../../models/astro_snapshot.dart';
import '../../models/culture_chart.dart';
import '../culture_module.dart';
import 'western_data.dart';

class WesternModule implements CultureModule {
  @override
  CultureId get id => CultureId.western;

  @override
  CultureChart buildChart(BirthContext ctx, AstroSnapshot snapshot) {
    final sun = snapshot[Planet.sun]!;
    final moon = snapshot[Planet.moon]!;
    final ascLon = snapshot.ascendant;

    final sunSign = _signAt(sun.eclipticLongitude);
    final moonSign = _signAt(moon.eclipticLongitude);
    final ascSign = _signAt(ascLon);
    final sunDecan = _decanAt(sun.eclipticLongitude);
    final sunDegree = sun.degreeInSign.toStringAsFixed(1);

    final entries = <CultureEntry>[
      CultureEntry(
        label: 'Sun Sign',
        value: sunSign,
        description: WesternData.signDescriptions[sunSign],
      ),
      CultureEntry(label: 'Sun Degree', value: '$sunDegree° $sunSign'),
      CultureEntry(
        label: 'Moon Sign',
        value: moonSign,
        description: WesternData.signDescriptions[moonSign],
      ),
      CultureEntry(label: 'Ascendant', value: ascSign),
      CultureEntry(label: 'Sun Decan', value: sunDecan),
      CultureEntry(label: 'Moon Phase', value: snapshot.moonPhaseName),
      CultureEntry(
        label: 'Element (Sun)',
        value: WesternData.signElements[sunSign] ?? '',
      ),
      CultureEntry(
        label: 'Modality (Sun)',
        value: WesternData.signModalities[sunSign] ?? '',
      ),
      for (final planet in Planet.values)
        CultureEntry(
          label: '${_planetName(planet)} in',
          value: _signAt(snapshot[planet]!.eclipticLongitude),
        ),
    ];

    return CultureChart(
      id: id,
      entries: entries,
      sunSign: sunSign,
      moonSign: moonSign,
      ascendantSign: ascSign,
      keyInsights: [
        'Sun in $sunSign — ${WesternData.signKeywords[sunSign] ?? ''}',
        'Moon in $moonSign — ${WesternData.signKeywords[moonSign] ?? ''}',
        'Rising $ascSign shapes your outward presence',
        'Moon phase: ${snapshot.moonPhaseName} (${(snapshot.lunarIllumination * 100).toStringAsFixed(0)}% illuminated)',
      ],
    );
  }

  String _signAt(double lon) {
    const signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
    ];
    return signs[(lon ~/ 30) % 12];
  }

  String _decanAt(double lon) {
    final signIndex = (lon ~/ 30) % 12;
    final degInSign = lon % 30;
    final decanNum = (degInSign ~/ 10) + 1;
    const signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
    ];
    return '${signs[signIndex]} Decan $decanNum';
  }

  String _planetName(Planet p) => switch (p) {
    Planet.sun => 'Sun',
    Planet.moon => 'Moon',
    Planet.mercury => 'Mercury',
    Planet.venus => 'Venus',
    Planet.mars => 'Mars',
    Planet.jupiter => 'Jupiter',
    Planet.saturn => 'Saturn',
    Planet.uranus => 'Uranus',
    Planet.neptune => 'Neptune',
    Planet.pluto => 'Pluto',
  };
}
