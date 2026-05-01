import 'dart:convert';
import 'package:flutter/services.dart';

class FixedStars {
  // Fallback catalog: 15 Behenian stars + 3 key Pisces-region stars (hardcoded lore).
  // Replaced at startup by loadCatalog() which merges HYG 518-star data.
  static List<FixedStar> _catalog = all;

  static Future<void> loadCatalog() async {
    try {
      final raw =
          await rootBundle.loadString('assets/data/bright_stars.json');
      final data = json.decode(raw) as Map<String, dynamic>;
      final entries =
          (data['stars'] as List).cast<Map<String, dynamic>>();

      // Name → Behenian lore lookup; "Alcyone (Pleiades)" also keys on "Alcyone"
      final lore = <String, FixedStar>{};
      for (final s in all) {
        lore[s.name] = s;
        final base = s.name.split(' (').first;
        if (base != s.name) lore[base] = s;
      }

      _catalog = entries.map((j) {
        final hyg = FixedStar._fromHyg(j);
        final b = lore[hyg.name];
        if (b != null) {
          // Overlay precise HYG longitude onto the curated Behenian entry
          return FixedStar(
            name: b.name,
            constellation: b.constellation,
            longitude: hyg.longitude,
            magnitude: hyg.magnitude,
            nature: b.nature,
            keywords: b.keywords,
            mythology: b.mythology,
            behenian: b.behenian,
            herb: b.herb,
            stone: b.stone,
          );
        }
        return hyg;
      }).toList();
    } catch (_) {
      // fall back to the hardcoded 18 stars
    }
  }

  // Returns stars within orb degrees of a given longitude.
  static List<(FixedStar, double)> nearPlanet(double longitude,
      {double orb = 1.5}) {
    return _catalog
        .map((s) {
          final diff = (s.longitude - longitude).abs() % 360;
          final dist = diff > 180 ? 360 - diff : diff;
          return (s, dist);
        })
        .where((t) => t.$2 <= orb)
        .toList()
      ..sort((a, b) => a.$2.compareTo(b.$2));
  }

  // Pre-computed Paulien (13 Mar 1996): tropical Sun ~352.5° Pisces
  static List<FixedStar> get paulienSunStars =>
      nearPlanet(352.5, orb: 2.5).map((t) => t.$1).toList();

  // ── Hardcoded lore catalog (18 stars) ──────────────────────────────────
  static const List<FixedStar> all = [
    FixedStar(
      name: 'Fomalhaut',
      constellation: 'Piscis Austrinus',
      longitude: 333.9,
      magnitude: 1.16,
      nature: 'Venus/Mercury',
      keywords: 'mysticism, fame, idealism, artistic vision',
      mythology:
          'The Solitary One — the brightest star of autumn, linked to Archangel Gabriel. Bestows charisma and spiritual gifts, but demands purity of intent.',
      behenian: true,
      herb: 'Chicory',
      stone: 'Sapphire',
    ),
    FixedStar(
      name: 'Scheat',
      constellation: 'Pegasus',
      longitude: 349.0,
      magnitude: 2.42,
      nature: 'Mars/Mercury',
      keywords: 'imagination, floods, restlessness, inspiration',
      mythology:
          'Scheat rides Pegasus — the winged horse of the Muses. Creative inspiration delivered in storms; a star of genius and turbulence alike.',
      behenian: false,
    ),
    FixedStar(
      name: 'Markab',
      constellation: 'Pegasus',
      longitude: 352.8,
      magnitude: 2.49,
      nature: 'Mars/Mercury',
      keywords: 'honors, intelligence, swift movement',
      mythology:
          'The Saddle of Pegasus — carries its rider swiftly between worlds. Gifts of eloquence and mental speed.',
      behenian: false,
    ),
    FixedStar(
      name: 'Achernar',
      constellation: 'Eridanus',
      longitude: 15.3,
      magnitude: 0.46,
      nature: 'Jupiter',
      keywords: 'success, royalty, nobility, brilliance',
      mythology:
          'End of the River — the river Eridanus flows from Orion\'s feet to the southern horizon. Achernar marks its outpouring, a star of pure abundance.',
      behenian: false,
    ),
    FixedStar(
      name: 'Algol',
      constellation: 'Perseus',
      longitude: 56.1,
      magnitude: 2.12,
      nature: 'Saturn/Jupiter',
      keywords: 'intensity, transformation, severing, power',
      mythology:
          'The Demon Star — the blinking eye of Medusa. Feared in antiquity, yet Medusa also embodied female creative power and the petrifying truth.',
      behenian: true,
      herb: 'Hellebore',
      stone: 'Diamond',
    ),
    FixedStar(
      name: 'Alcyone (Pleiades)',
      constellation: 'Taurus',
      longitude: 59.9,
      magnitude: 2.87,
      nature: 'Moon/Mars',
      keywords: 'vision, sorrow, wandering, mystical sight',
      mythology:
          'Heart of the Seven Sisters — the weeping Pleiades who fled Orion. Alcyone governs mystical sight and the grief that opens the third eye.',
      behenian: true,
      herb: 'Fennel',
      stone: 'Rock Crystal',
    ),
    FixedStar(
      name: 'Aldebaran',
      constellation: 'Taurus',
      longitude: 69.9,
      magnitude: 0.85,
      nature: 'Mars/Mercury/Jupiter/Venus',
      keywords: 'integrity, courage, leadership, the watcher of the East',
      mythology:
          'Follower of the Pleiades — one of the four Royal Stars (Watchers of Heaven). Archangel Michael\'s star: incorruptible courage and military honours.',
      behenian: true,
      herb: 'Milk Thistle',
      stone: 'Ruby',
    ),
    FixedStar(
      name: 'Rigel',
      constellation: 'Orion',
      longitude: 76.6,
      magnitude: 0.12,
      nature: 'Jupiter/Saturn',
      keywords: 'ambition, brilliance, technical genius, wealth',
      mythology:
          'Orion\'s left foot — the great hunter\'s foundation. Brings practical genius, ambition, and the ability to build lasting structures.',
      behenian: true,
      herb: 'Plantain',
      stone: 'Sapphire',
    ),
    FixedStar(
      name: 'Capella',
      constellation: 'Auriga',
      longitude: 81.6,
      magnitude: 0.08,
      nature: 'Mercury/Mars',
      keywords: 'curiosity, honor, the goat star, versatility',
      mythology:
          'The She-Goat whose golden fleece was worn by Zeus. Capella bestows insatiable curiosity, broad learning, and unexpected honour.',
      behenian: true,
      herb: 'Horehound',
      stone: 'Sapphire',
    ),
    FixedStar(
      name: 'Sirius',
      constellation: 'Canis Major',
      longitude: 104.1,
      magnitude: -1.46,
      nature: 'Jupiter/Mars',
      keywords: 'ambition, fame, loyalty, the brightest star',
      mythology:
          'The Dog Star — sacred to Isis in Egypt, its heliacal rising announced the Nile flood. Bestows brilliant gifts and sudden elevation.',
      behenian: true,
      herb: 'Juniper',
      stone: 'Beryl',
    ),
    FixedStar(
      name: 'Procyon',
      constellation: 'Canis Minor',
      longitude: 115.8,
      magnitude: 0.34,
      nature: 'Mercury/Mars',
      keywords: 'swiftness, cunning, sudden fame, restlessness',
      mythology:
          'Forerunner of the Dog — rises before Sirius, heralding the flood. Gifts of quick wit, commercial acumen, and popularity that can vanish as fast as it arrives.',
      behenian: true,
      herb: 'Marigold',
      stone: 'Agate',
    ),
    FixedStar(
      name: 'Algorab',
      constellation: 'Corvus',
      longitude: 193.4,
      magnitude: 2.95,
      nature: 'Saturn/Mars',
      keywords: 'subtlety, craftiness, greed, destructiveness',
      mythology:
          'The Crow — Apollo\'s raven who brought news of infidelity and was punished with eternal thirst. A star of cunning and sharp perception, wielded well or ill.',
      behenian: true,
      herb: 'Burdock',
      stone: 'Onyx',
    ),
    FixedStar(
      name: 'Regulus',
      constellation: 'Leo',
      longitude: 149.8,
      magnitude: 1.35,
      nature: 'Mars/Jupiter',
      keywords: 'royalty, nobility, power, the watcher of the North',
      mythology:
          'Heart of the Lion — the Little King, one of the four Watchers of Heaven (Archangel Raphael). Bestows royal favour and sudden reversal if honour is abandoned.',
      behenian: true,
      herb: 'Mugwort',
      stone: 'Granite',
    ),
    FixedStar(
      name: 'Spica',
      constellation: 'Virgo',
      longitude: 203.7,
      magnitude: 0.98,
      nature: 'Venus/Mars',
      keywords: 'gifts, grace, artistic talent, fortunate',
      mythology:
          'Virgo\'s sheaf of wheat — the most fortunate Behenian star. Bestows artistic gifts, renown, and a fortunate life when well-aspected.',
      behenian: true,
      herb: 'Sage',
      stone: 'Emerald',
    ),
    FixedStar(
      name: 'Arcturus',
      constellation: 'Boötes',
      longitude: 204.0,
      magnitude: -0.05,
      nature: 'Mars/Jupiter',
      keywords: 'pioneering, guiding, new paths, weather-watching',
      mythology:
          'Guardian of the Bear — the herdsman who drives the Great Bear around the pole. A star of trailblazers who guide others into new territory.',
      behenian: true,
      herb: 'Plantain',
      stone: 'Jasper',
    ),
    FixedStar(
      name: 'Antares',
      constellation: 'Scorpius',
      longitude: 249.9,
      magnitude: 0.91,
      nature: 'Mars/Jupiter',
      keywords: 'intensity, success, obsession, the watcher of the West',
      mythology:
          'Rival of Ares — the heart of the Scorpion, one of four Royal Stars. Archangel Uriel\'s star: extremes of success and ruin, passion without compromise.',
      behenian: true,
      herb: 'Birthwort',
      stone: 'Amethyst',
    ),
    FixedStar(
      name: 'Vega',
      constellation: 'Lyra',
      longitude: 284.2,
      magnitude: 0.03,
      nature: 'Venus/Mercury',
      keywords: 'artistic genius, charisma, magic, refinement',
      mythology:
          'The Falling Eagle — the lyre of Orpheus, whose music moved stones and charmed Hades. Vega gifts extraordinary beauty of expression and natural magic.',
      behenian: true,
      herb: 'Savory',
      stone: 'Chrysolite',
    ),
    FixedStar(
      name: 'Deneb Algedi',
      constellation: 'Capricornus',
      longitude: 302.8,
      magnitude: 2.85,
      nature: 'Saturn/Jupiter',
      keywords: 'law, sorrow, patience, karmic wisdom',
      mythology:
          'Tail of the Sea-Goat — a star associated with law and the suffering that produces wisdom. Judges, teachers, and long-suffering achievers.',
      behenian: true,
      herb: 'Mandrake',
      stone: 'Chalcedony',
    ),
  ];
}

class FixedStar {
  final String name;
  final String constellation;
  final double longitude; // tropical ecliptic J2000
  final double magnitude;
  final String nature;
  final String keywords;
  final String mythology;
  final bool behenian;
  final String? herb;
  final String? stone;

  const FixedStar({
    required this.name,
    required this.constellation,
    required this.longitude,
    required this.magnitude,
    required this.nature,
    required this.keywords,
    required this.mythology,
    required this.behenian,
    this.herb,
    this.stone,
  });

  factory FixedStar._fromHyg(Map<String, dynamic> json) {
    final mag = (json['mag'] as num).toDouble();
    final spect = (json['spect'] as String? ?? '').split(' ').first;
    return FixedStar(
      name: json['name'] as String,
      constellation: '',
      longitude: (json['lon'] as num).toDouble(),
      magnitude: mag,
      nature: spect.isEmpty ? '—' : spect,
      keywords: 'mag ${mag.toStringAsFixed(2)}',
      mythology: '',
      behenian: false,
    );
  }
}
