import '../../models/birth_context.dart';
import '../../models/astro_snapshot.dart';
import '../../models/culture_chart.dart';
import '../culture_module.dart';
import 'chinese_data.dart';

class ChineseModule implements CultureModule {
  @override
  CultureId get id => CultureId.chinese;

  @override
  CultureChart buildChart(BirthContext ctx, AstroSnapshot snapshot) {
    final year = ctx.utcTime.year;
    final month = ctx.utcTime.month;
    final day = ctx.utcTime.day;
    final hour = ctx.utcTime.hour;

    // Four Pillars (Ba Zi)
    final yearPillar = _yearPillar(year, month, day);
    final monthPillar = _monthPillar(year, month, day);
    final dayPillar = _dayPillar(year, month, day);
    final hourPillar = _hourPillar(year, month, day, hour);

    final animal = ChineseData.animals[yearPillar.branchIndex];
    final element = ChineseData.elements[yearPillar.stemIndex ~/ 2];
    final polarity = yearPillar.stemIndex % 2 == 0 ? 'Yang' : 'Yin';

    final entries = <CultureEntry>[
      CultureEntry(
        label: 'Chinese Zodiac Year',
        value: '${animal['name']} (${animal['chinese']})',
        description: animal['description'] as String?,
      ),
      CultureEntry(label: 'Element', value: '$polarity $element'),
      CultureEntry(
        label: 'Year Pillar',
        value: yearPillar.name,
        description: '${yearPillar.stemName} ${yearPillar.branchName}',
      ),
      CultureEntry(label: 'Month Pillar', value: monthPillar.name),
      CultureEntry(label: 'Day Pillar', value: dayPillar.name),
      CultureEntry(label: 'Hour Pillar', value: hourPillar.name),
      CultureEntry(
        label: 'Day Animal',
        value: ChineseData.animals[dayPillar.branchIndex]['name'] as String,
      ),
      CultureEntry(
        label: 'Compatible Animals',
        value: (animal['compatible'] as List).join(', '),
      ),
      CultureEntry(
        label: 'Lucky Colors',
        value: (animal['luckyColors'] as List).join(', '),
      ),
    ];

    return CultureChart(
      id: id,
      entries: entries,
      sunSign: animal['name'] as String,
      moonSign: ChineseData.animals[monthPillar.branchIndex]['name'] as String,
      keyInsights: [
        '${animal['name']} — ${animal['keywords']}',
        '$polarity $element energy shapes your year pillar',
        'Day master: ${dayPillar.stemName} — your inner self',
        'Hour pillar ${hourPillar.name} — the hidden treasure',
      ],
    );
  }

  _Pillar _yearPillar(int year, int month, int day) {
    // Chinese New Year is roughly Feb 4; adjust if before that
    int adjustedYear = year;
    if (month == 1 || (month == 2 && day < 4)) adjustedYear -= 1;

    final stemIndex = (adjustedYear - 4) % 10;
    final branchIndex = (adjustedYear - 4) % 12;
    return _Pillar(stemIndex: stemIndex, branchIndex: branchIndex);
  }

  _Pillar _monthPillar(int year, int month, int day) {
    // Month stems cycle based on year stem
    final yearStem = (year - 4) % 10;
    final monthIndex = month - 1; // 0-based
    final baseOffset = (yearStem % 5) * 2;
    final stemIndex = (baseOffset + monthIndex) % 10;
    final branchIndex = (monthIndex + 2) % 12; // Yin (Tiger) = month 1
    return _Pillar(stemIndex: stemIndex, branchIndex: branchIndex);
  }

  _Pillar _dayPillar(int year, int month, int day) {
    // Simplified day pillar using Julian Day Number
    final jd = _julianDay(year, month, day);
    final stemIndex = (jd + 40) % 10;
    final branchIndex = (jd + 14) % 12;
    return _Pillar(stemIndex: stemIndex.toInt(), branchIndex: branchIndex.toInt());
  }

  _Pillar _hourPillar(int year, int month, int day, int hour) {
    final dayStem = _dayPillar(year, month, day).stemIndex;
    final branchIndex = (hour + 1) ~/ 2 % 12;
    final stemIndex = (dayStem % 5 * 2 + branchIndex) % 10;
    return _Pillar(stemIndex: stemIndex, branchIndex: branchIndex);
  }

  double _julianDay(int year, int month, int day) {
    int a = ((14 - month) / 12).floor();
    int y = year + 4800 - a;
    int m = month + 12 * a - 3;
    return day + ((153 * m + 2) / 5).floor() + 365 * y +
        (y / 4).floor() - (y / 100).floor() + (y / 400).floor() - 32045;
  }
}

class _Pillar {
  final int stemIndex;
  final int branchIndex;

  _Pillar({required this.stemIndex, required this.branchIndex});

  String get stemName => ChineseData.stems[stemIndex % 10];
  String get branchName => ChineseData.branches[branchIndex % 12];
  String get name => '$stemName $branchName';
}
