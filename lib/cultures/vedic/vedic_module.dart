import '../../models/birth_context.dart';
import '../../models/astro_snapshot.dart';
import '../../models/culture_chart.dart';
import '../culture_module.dart';
import 'vedic_data.dart';

class VedicModule implements CultureModule {
  @override
  CultureId get id => CultureId.vedic;

  @override
  CultureChart buildChart(BirthContext ctx, AstroSnapshot snapshot) {
    final ayanamsha = snapshot.siderealOffset;

    double sidereal(double lon) => ((lon - ayanamsha) % 360 + 360) % 360;

    final sunLon = sidereal(snapshot[Planet.sun]!.eclipticLongitude);
    final moonLon = sidereal(snapshot[Planet.moon]!.eclipticLongitude);
    final ascLon = sidereal(snapshot.ascendant);

    final sunRasi = _rasiAt(sunLon);
    final moonRasi = _rasiAt(moonLon);
    final ascRasi = _rasiAt(ascLon);
    final moonNakshatra = _nakshatraAt(moonLon);
    final sunNakshatra = _nakshatraAt(sunLon);
    final ascNakshatra = _nakshatraAt(ascLon);

    final entries = <CultureEntry>[
      CultureEntry(
        label: 'Sun (Ravi) in Rasi',
        value: sunRasi,
        description: VedicData.rasiDescriptions[sunRasi],
      ),
      CultureEntry(label: 'Sun Nakshatra', value: sunNakshatra),
      CultureEntry(
        label: 'Moon (Chandra) in Rasi',
        value: moonRasi,
        description: VedicData.rasiDescriptions[moonRasi],
      ),
      CultureEntry(
        label: 'Moon Nakshatra (Janma)',
        value: moonNakshatra,
        description: VedicData.nakshatraKeywords[moonNakshatra],
      ),
      CultureEntry(label: 'Lagna (Ascendant)', value: '$ascRasi ($ascNakshatra)'),
      CultureEntry(label: 'Ayanamsha', value: '${ayanamsha.toStringAsFixed(2)}° (Lahiri)'),
      for (final planet in Planet.values)
        CultureEntry(
          label: '${_sanskritName(planet)} in',
          value: _rasiAt(sidereal(snapshot[planet]!.eclipticLongitude)),
        ),
    ];

    return CultureChart(
      id: id,
      entries: entries,
      sunSign: sunRasi,
      moonSign: moonRasi,
      ascendantSign: ascRasi,
      keyInsights: [
        'Sidereal Sun in $sunRasi — your soul purpose in Jyotish',
        'Janma Nakshatra: $moonNakshatra — ${VedicData.nakshatraKeywords[moonNakshatra] ?? ''}',
        'Lagna $ascRasi shapes your physical form and life path',
        'Note: Vedic positions are ~${ayanamsha.toStringAsFixed(0)}° behind Western tropical signs',
      ],
    );
  }

  String _rasiAt(double lon) {
    const rasis = [
      'Mesha (Aries)', 'Vrishabha (Taurus)', 'Mithuna (Gemini)',
      'Karka (Cancer)', 'Simha (Leo)', 'Kanya (Virgo)',
      'Tula (Libra)', 'Vrischika (Scorpio)', 'Dhanu (Sagittarius)',
      'Makara (Capricorn)', 'Kumbha (Aquarius)', 'Meena (Pisces)',
    ];
    return rasis[(lon ~/ 30) % 12];
  }

  String _nakshatraAt(double lon) {
    final index = (lon * 27 / 360).floor() % 27;
    return VedicData.nakshatras[index];
  }

  String _sanskritName(Planet p) => switch (p) {
    Planet.sun => 'Surya',
    Planet.moon => 'Chandra',
    Planet.mercury => 'Budha',
    Planet.venus => 'Shukra',
    Planet.mars => 'Mangala',
    Planet.jupiter => 'Brihaspati',
    Planet.saturn => 'Shani',
    Planet.uranus => 'Uranus',
    Planet.neptune => 'Neptune',
    Planet.pluto => 'Pluto',
  };
}
