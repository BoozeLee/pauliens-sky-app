import '../../models/birth_context.dart';
import '../../models/astro_snapshot.dart';
import '../../models/culture_chart.dart';
import '../culture_module.dart';
import 'zoroastrian_data.dart';

class ZoroastrianModule implements CultureModule {
  @override
  CultureId get id => CultureId.zoroastrian;

  @override
  CultureChart buildChart(BirthContext ctx, AstroSnapshot snapshot) {
    final monthIdx = _avMonthIndex(ctx.utcTime);
    final dayNum   = _avDayNumber(ctx.utcTime, monthIdx);
    final month    = ZoroastrianData.months[monthIdx];
    final dayYaz   = ZoroastrianData.dayYazatas[(dayNum - 1).clamp(0, 29)];
    final star     = _seasonStar(ctx.utcTime);
    final spentaIdx= ZoroastrianData.monthAmesha[monthIdx];
    final spenta   = ZoroastrianData.ameshaSpenta[spentaIdx];
    final fireIdx  = ZoroastrianData.fireTypeIndex(dayNum);
    final fire     = ZoroastrianData.fireTypes[fireIdx];

    final entries = <CultureEntry>[
      CultureEntry(
        label: 'Avestan Month',
        value: '${month.symbol} ${month.name}',
        description: '${month.yazata} — ${month.meaning}',
      ),
      CultureEntry(
        label: 'Day Yazata',
        value: '${dayYaz.name} (day $dayNum)',
        description: dayYaz.fullName,
      ),
      CultureEntry(
        label: 'Day Keywords',
        value: dayYaz.keywords,
      ),
      CultureEntry(
        label: 'Season Star',
        value: '${star.name} (${star.star})',
        description: '${star.direction} guardian — ${star.season}',
      ),
      CultureEntry(
        label: 'Amesha Spenta',
        value: spenta.name,
        description: '${spenta.meaning} — domain: ${spenta.domain}',
      ),
      CultureEntry(
        label: 'Divine Gifts',
        value: spenta.gifts,
      ),
      CultureEntry(
        label: 'Sacred Fire',
        value: fire.$1,
        description: fire.$2,
      ),
      CultureEntry(
        label: 'Fravashi Archetype',
        value: _fravashiArchetype(star.name),
        description: _fravashiDescription(star.name),
      ),
      CultureEntry(
        label: 'Month Ruling Planet',
        value: _rulingPlanet(monthIdx),
      ),
      CultureEntry(
        label: 'Karmic Virtue',
        value: _karmicVirtue(dayYaz.name, spenta.name),
      ),
    ];

    final monthDesc = ZoroastrianData.monthDescriptions[month.name] ?? '';

    final insights = [
      '${month.symbol} ${month.name} — ${monthDesc}',
      '${star.name}: ${star.mythology}',
      '${spenta.name} (${spenta.meaning}): your guiding immortal bestows ${spenta.gifts}.',
      'Day of ${dayYaz.name}: your birth day yazata carries ${dayYaz.keywords}.',
      'Sacred flame: ${fire.$1} — ${fire.$2.split('—').last.trim()}',
    ];

    return CultureChart(
      id: id,
      entries: entries,
      sunSign: month.name,
      moonSign: dayYaz.name,
      keyInsights: insights,
    );
  }

  // ── Fasli calendar helpers ───────────────────────────────────────────────

  // Returns 0-based month index (0=Farvardin … 11=Esfand)
  int _avMonthIndex(DateTime dt) {
    // Month start dates (Gregorian): month, day
    const starts = [
      (3, 20), (4, 20), (5, 21), (6, 21), (7, 23), (8, 23),
      (9, 23), (10, 23), (11, 22), (12, 22), (1, 20), (2, 19),
    ];
     for (int i = starts.length - 1; i >= 0; i--) {
       final (sm, sd) = starts[i];
       // Handle year wrap: Bahman (Jan) and Esfand (Feb) need same year as input
       // Dey (Dec) starts in same year as input date if Dec; else prior year
       final candidate = sm >= 3
           ? DateTime.utc(dt.year, sm, sd)
           : DateTime.utc(dt.month <= 2 ? dt.year : dt.year + 1, sm, sd);
       if (!dt.isBefore(candidate)) return i;
     }
    return 11; // Esfand fallback
  }

  // Day number 1–30 within the Avestan month
  int _avDayNumber(DateTime dt, int monthIdx) {
    const starts = [
      (3, 20), (4, 20), (5, 21), (6, 21), (7, 23), (8, 23),
      (9, 23), (10, 23), (11, 22), (12, 22), (1, 20), (2, 19),
    ];
    final (sm, sd) = starts[monthIdx];
    final yr = (sm >= 3) ? dt.year : (dt.month <= 2 ? dt.year : dt.year + 1);
    final start = DateTime.utc(yr, sm, sd);
    final diff = dt.difference(start).inDays + 1;
    return diff.clamp(1, 30);
  }

  // Season star based on birth date
  ZSeasonStar _seasonStar(DateTime dt) {
    final m = dt.month;
    if (m >= 3 && m <= 5) return ZoroastrianData.seasonStars[0]; // Tishtrya spring
    if (m == 6 || (m == 7) || (m == 8)) return ZoroastrianData.seasonStars[1]; // Vanant summer
    if (m >= 9 && m <= 11) return ZoroastrianData.seasonStars[2]; // Satavaesa autumn
    return ZoroastrianData.seasonStars[3]; // Hapto-iringa winter
  }

  String _rulingPlanet(int monthIdx) {
    const planets = [
      'Mars (Bahram)', 'Venus (Anahita-Tir)', 'Mercury (Tir)', 'Moon (Mah)',
      'Sun (Khorshed)', 'Mercury (Tir)', 'Sun (Khorshed)', 'Venus (Anahita)',
      'Jupiter (Ohrmazd)', 'Saturn (Kevan)', 'Jupiter (Ohrmazd)', 'Saturn (Kevan)',
    ];
    return planets[monthIdx];
  }

  String _fravashiArchetype(String starName) => switch (starName) {
    'Tishtrya'    => 'Storm Fravashi — Bringer of Rain',
    'Vanant'      => 'Victory Fravashi — Conqueror of Darkness',
    'Satavaesa'   => 'Ocean Fravashi — Keeper of Deep Currents',
    'Hapto-iringa'=> 'Seven-Star Fravashi — Navigator of the Dark',
    _             => 'Cosmic Fravashi',
  };

  String _fravashiDescription(String starName) => switch (starName) {
    'Tishtrya'    => 'Your guardian spirit transforms scarcity into abundance, arriving like the first rain after a long drought.',
    'Vanant'      => 'Your guardian spirit fights with concentrated light. Obstacles dissolve before your patient, burning focus.',
    'Satavaesa'   => 'Your guardian spirit moves like water — outwardly still, inwardly current. You sense what others cannot see.',
    'Hapto-iringa'=> 'Your guardian spirit is eternal, never setting. Even in darkness, you orient others toward home.',
    _             => 'Your guardian spirit carries ancient cosmic purpose.',
  };

  String _karmicVirtue(String dayYazata, String spenta) {
    if (dayYazata.contains('Ardibehest') || spenta == 'Ardibehesht') {
      return 'Asha — walk in truth, let no false word pass your lips';
    }
    if (dayYazata.contains('Mehr') || spenta == 'Vohuman') {
      return 'Mithra — honour every covenant you make, great or small';
    }
    if (dayYazata.contains('Farvardin') || dayYazata.contains('Ard')) {
      return 'Ashi — righteous action generates its own reward, invisibly';
    }
    if (spenta == 'Spendarmad' || dayYazata.contains('Sepandarmaz')) {
      return 'Armaiti — love the earth and serve without condition';
    }
    if (spenta == 'Khordad' || dayYazata.contains('Khordad')) {
      return 'Haurvata — pursue wholeness, heal what is fragmented';
    }
    if (spenta == 'Amordad' || dayYazata.contains('Amordad')) {
      return 'Ameretat — tend living things, your resilience is your legacy';
    }
    return 'Vohu Manah — guard the quality of your thoughts, all else follows';
  }
}
