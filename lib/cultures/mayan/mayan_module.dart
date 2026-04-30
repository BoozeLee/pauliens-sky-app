import '../../models/birth_context.dart';
import '../../models/astro_snapshot.dart';
import '../../models/culture_chart.dart';
import '../culture_module.dart';
import 'mayan_data.dart';

class MayanModule implements CultureModule {
  @override
  CultureId get id => CultureId.mayan;

  @override
  CultureChart buildChart(BirthContext ctx, AstroSnapshot snapshot) {
    final tzolkin = _gregorianToTzolkin(ctx.utcTime);
    final haab = _gregorianToHaab(ctx.utcTime);
    final lord = _nightLord(ctx.utcTime);

    final daySign = MayanData.dayNames[tzolkin.dayIndex];
    final tone = MayanData.tones[tzolkin.toneIndex];

    final entries = <CultureEntry>[
      CultureEntry(
        label: 'Tzolk\'in Day Sign',
        value: '${daySign['name']} (${daySign['glyph']})',
        description: daySign['description'],
      ),
      CultureEntry(
        label: 'Galactic Tone',
        value: '${tone['number']} — ${tone['name']}',
        description: tone['power'],
      ),
      CultureEntry(
        label: 'Tzolk\'in Date',
        value: '${tzolkin.toneIndex + 1} ${daySign['name']}',
      ),
      CultureEntry(
        label: 'Haab Date',
        value: haab,
        description: 'Solar year position (365-day cycle)',
      ),
      CultureEntry(
        label: 'Lord of the Night',
        value: lord['name']!,
        description: lord['quality'],
      ),
      CultureEntry(
        label: 'Direction',
        value: daySign['direction']!,
      ),
      CultureEntry(
        label: 'Element / Color',
        value: daySign['color']!,
      ),
      CultureEntry(
        label: 'Kin (Day Count)',
        value: _longCountKin(ctx.utcTime).toString(),
        description: 'Position in 260-day Tzolk\'in cycle',
      ),
    ];

    return CultureChart(
      id: id,
      entries: entries,
      sunSign: daySign['name'],
      keyInsights: [
        '${daySign['name']} — ${daySign['keywords']}',
        'Tone ${tzolkin.toneIndex + 1} (${tone['name']}) — ${tone['action']}',
        'Direction: ${daySign['direction']} — ${daySign['directionalEnergy']}',
        'Lord of the Night: ${lord['name']} — ${lord['quality']}',
      ],
    );
  }

  _Tzolkin _gregorianToTzolkin(DateTime date) {
    // Correlation constant (584283 GMT — most widely used)
    final jd = _jd(date);
    final kin = (jd - 584283) % 260;
    final dayIndex = kin.toInt() % 20;
    final toneIndex = kin.toInt() % 13;
    return _Tzolkin(dayIndex: dayIndex, toneIndex: toneIndex);
  }

  String _gregorianToHaab(DateTime date) {
    final jd = _jd(date);
    final haabElapsed = ((jd - 584283 + 348) % 365).toInt();
    final monthIndex = haabElapsed ~/ 20;
    final dayInMonth = haabElapsed % 20;
    const months = [
      'Pop', 'Wo', 'Sip', 'Sotz\'', 'Sek', 'Xul', 'Yaxk\'in',
      'Mol', 'Ch\'en', 'Yax', 'Sak', 'Keh', 'Mak', 'K\'ank\'in',
      'Muwan', 'Pax', 'K\'ayab', 'Kumk\'u', 'Wayeb',
    ];
    if (monthIndex >= months.length) return 'Unknown';
    return '$dayInMonth ${months[monthIndex]}';
  }

  Map<String, String> _nightLord(DateTime date) {
    final jd = _jd(date).toInt();
    final lords = MayanData.nightLords;
    return lords[jd % 9];
  }

  int _longCountKin(DateTime date) {
    return ((_jd(date) - 584283) % 260).toInt();
  }

  double _jd(DateTime date) {
    final y = date.year;
    final m = date.month;
    final d = date.day.toDouble();
    int a = ((14 - m) / 12).floor();
    int yr = y + 4800 - a;
    int mo = m + 12 * a - 3;
    return d + ((153 * mo + 2) / 5).floor() + 365 * yr +
        (yr / 4).floor() - (yr / 100).floor() + (yr / 400).floor() - 32045;
  }
}

class _Tzolkin {
  final int dayIndex;
  final int toneIndex;
  const _Tzolkin({required this.dayIndex, required this.toneIndex});
}
