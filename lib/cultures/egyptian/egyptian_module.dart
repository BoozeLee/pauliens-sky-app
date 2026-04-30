import '../../models/birth_context.dart';
import '../../models/astro_snapshot.dart';
import '../../models/culture_chart.dart';
import '../culture_module.dart';
import 'egyptian_data.dart';

class EgyptianModule implements CultureModule {
  @override
  CultureId get id => CultureId.egyptian;

  @override
  CultureChart buildChart(BirthContext ctx, AstroSnapshot snapshot) {
    final sunLon = snapshot[Planet.sun]!.eclipticLongitude;
    final moonLon = snapshot[Planet.moon]!.eclipticLongitude;
    final ascLon = snapshot.ascendant;

    final sunDecan = _decanAt(sunLon);
    final moonDecan = _decanAt(moonLon);
    final ascDecan = _decanAt(ascLon);

    final entries = <CultureEntry>[
      CultureEntry(
        label: 'Rising Decan (Ascendant)',
        value: '${ascDecan['deity']} Decan',
        description: ascDecan['description'],
      ),
      CultureEntry(
        label: 'Sun Decan',
        value: '${sunDecan['deity']} — ${sunDecan['sign']} ${sunDecan['decanNum']}',
        description: sunDecan['quality'],
      ),
      CultureEntry(
        label: 'Moon Decan',
        value: '${moonDecan['deity']} — ${moonDecan['sign']} ${moonDecan['decanNum']}',
      ),
      CultureEntry(
        label: 'Sun\'s Egyptian God',
        value: sunDecan['deity']!,
        description: sunDecan['mythology'],
      ),
      CultureEntry(
        label: 'Egyptian Year Animal',
        value: _yearSign(ctx.utcTime),
      ),
      CultureEntry(
        label: 'Lucky Protective God',
        value: sunDecan['protector']!,
      ),
    ];

    return CultureChart(
      id: id,
      entries: entries,
      sunSign: sunDecan['deity'],
      moonSign: moonDecan['deity'],
      ascendantSign: ascDecan['deity'],
      keyInsights: [
        'Rising decan: ${ascDecan['deity']} — ${ascDecan['quality']}',
        'Sun aligned with ${sunDecan['deity']} — ${sunDecan['mythology']}',
        'The 36 decans divided the Egyptian sky into 10° segments of divine influence',
        'Each decan rose heliacally once per year, marking time\'s passage',
      ],
    );
  }

  Map<String, String> _decanAt(double lon) {
    final index = (lon ~/ 10) % 36;
    return EgyptianData.decans[index];
  }

  String _yearSign(DateTime date) {
    const signs = [
      'The Nile', 'Amon-Ra', 'Mut', 'Geb', 'Osiris',
      'Isis', 'Thoth', 'Horus', 'Anubis', 'Seth', 'Bastet', 'Sekhmet',
    ];
    final idx = (date.year - 1) % 12;
    return signs[idx];
  }
}
