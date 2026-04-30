import '../../models/birth_context.dart';
import '../../models/astro_snapshot.dart';
import '../../models/culture_chart.dart';
import '../culture_module.dart';
import 'celtic_data.dart';

class CelticModule implements CultureModule {
  @override
  CultureId get id => CultureId.celtic;

  @override
  CultureChart buildChart(BirthContext ctx, AstroSnapshot snapshot) {
    final month = ctx.utcTime.month;
    final day = ctx.utcTime.day;

    final treeSign = _treeSign(month, day);
    final animalSign = _animalSign(month, day);
    final ogham = CelticData.ogham[treeSign['tree'] as String] ?? '';

    final entries = <CultureEntry>[
      CultureEntry(
        label: 'Celtic Tree Sign',
        value: treeSign['tree']!,
        description: treeSign['description'],
      ),
      CultureEntry(
        label: 'Ogham Letter',
        value: ogham,
        description: 'Ancient Celtic alphabet carved on standing stones',
      ),
      CultureEntry(
        label: 'Celtic Animal',
        value: animalSign['animal']!,
        description: animalSign['description'],
      ),
      CultureEntry(
        label: 'Ruling Deity',
        value: treeSign['deity']!,
      ),
      CultureEntry(
        label: 'Sacred Element',
        value: treeSign['element']!,
      ),
      CultureEntry(
        label: 'Closest Sabbat',
        value: _sabbat(month, day),
      ),
      CultureEntry(
        label: 'Key Qualities',
        value: treeSign['keywords']!,
      ),
    ];

    return CultureChart(
      id: id,
      entries: entries,
      sunSign: treeSign['tree'],
      keyInsights: [
        '${treeSign['tree']} — ${treeSign['keywords']}',
        'Animal totem: ${animalSign['animal']} — ${animalSign['keywords']}',
        'Deity: ${treeSign['deity']} — guardian of your tree month',
        _sabbat(month, day),
      ],
    );
  }

  Map<String, String> _treeSign(int month, int day) {
    const treeDates = [
      (m: 12, d: 24, tree: 'Birch'),
      (m: 1, d: 21, tree: 'Rowan'),
      (m: 2, d: 18, tree: 'Ash'),
      (m: 3, d: 18, tree: 'Alder'),
      (m: 4, d: 15, tree: 'Willow'),
      (m: 5, d: 13, tree: 'Hawthorn'),
      (m: 6, d: 10, tree: 'Oak'),
      (m: 7, d: 8, tree: 'Holly'),
      (m: 8, d: 5, tree: 'Hazel'),
      (m: 9, d: 2, tree: 'Vine'),
      (m: 9, d: 30, tree: 'Ivy'),
      (m: 10, d: 28, tree: 'Reed'),
      (m: 11, d: 25, tree: 'Elder'),
    ];

    final dayOfYear = _dayOfYear(month, day);
    String treeName = 'Oak';

    for (int i = 0; i < treeDates.length; i++) {
      final start = _dayOfYear(treeDates[i].m, treeDates[i].d);
      final end = i + 1 < treeDates.length
          ? _dayOfYear(treeDates[i + 1].m, treeDates[i + 1].d) - 1
          : 366;
      if (dayOfYear >= start && dayOfYear <= end) {
        treeName = treeDates[i].tree;
        break;
      }
    }

    return CelticData.trees[treeName] ?? CelticData.trees['Oak']!;
  }

  Map<String, String> _animalSign(int month, int day) {
    final index = (_dayOfYear(month, day) ~/ 28) % CelticData.animals.length;
    return CelticData.animals[index];
  }

  String _sabbat(int month, int day) {
    final doy = _dayOfYear(month, day);
    if (doy >= 314 || doy < 11) return 'Samhain (Oct 31) — Veil is thinnest';
    if (doy < 52) return 'Winter Solstice / Yule (Dec 21)';
    if (doy < 72) return 'Imbolc (Feb 2) — Return of light';
    if (doy < 101) return 'Spring Equinox (Mar 20)';
    if (doy < 132) return 'Beltane (May 1) — Fire of life';
    if (doy < 172) return 'Summer Solstice / Litha (Jun 21)';
    if (doy < 213) return 'Lughnasadh (Aug 1) — First harvest';
    if (doy < 265) return 'Autumn Equinox (Sep 22)';
    return 'Samhain (Oct 31) — Veil thins';
  }

  int _dayOfYear(int month, int day) {
    const daysInMonth = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
    return daysInMonth[month - 1] + day;
  }
}
