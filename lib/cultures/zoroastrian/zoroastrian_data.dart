// Zoroastrian astrology data — Avestan calendar, Yazatas, Amesha Spentas
// Based on the Fasli (seasonal) calendar aligned to the tropical year (Nowruz = ~Mar 20)

class ZoroastrianData {
  // ── 12 Avestan months (Fasli calendar) ───────────────────────────────────
  // Each entry: (name, yazata guardian, gregorian start [month, day], meaning, color)

  static const months = [
    ZMonth('Farvardin',  'Fravashis', 3, 20, 'Guardian spirits of the righteous', '🌱'),
    ZMonth('Ordibehesht','Asha Vahishta', 4, 20, 'Best Truth — law of the cosmos', '🔥'),
    ZMonth('Khordad',    'Haurvata',   5, 21, 'Wholeness — the divine ideal of health', '💧'),
    ZMonth('Tir',        'Tishtrya',   6, 21, 'The star Sirius — rain, abundance, hope', '⭐'),
    ZMonth('Amordad',    'Ameretat',   7, 23, 'Immortality — eternal life and plants', '🌿'),
    ZMonth('Shahrivar',  'Khshathra Vairya', 8, 23, 'Divine Kingdom — power over metal and sky', '⚔'),
    ZMonth('Mehr',       'Mithra',     9, 23, 'Covenant, friendship, the unblinking sun', '☀'),
    ZMonth('Aban',       'Anahita',   10, 23, 'Sacred waters — purification and fertility', '🌊'),
    ZMonth('Azar',       'Atar',       11, 22, 'Holy fire — the divine flame', '🔥'),
    ZMonth('Dey',        'Ahura Mazda',12, 22, 'Ahura Mazda himself — the Wise Lord', '✨'),
    ZMonth('Bahman',     'Vohu Manah', 1, 20, 'Good Mind — divine intelligence', '🧠'),
    ZMonth('Esfand',     'Spenta Armaiti', 2, 19, 'Holy Devotion — earth, patience, love', '🌍'),
  ];

  // ── 30 Avestan day names (repeat every month) ────────────────────────────
  static const dayYazatas = [
    ZDayYazata('Ohrmazd',      'Ahura Mazda — the Wise Lord',                  'Wisdom & divine light'),
    ZDayYazata('Vohuman',      'Vohu Manah — Good Mind',                       'Gentle intellect, good thoughts'),
    ZDayYazata('Ardibehest',   'Asha Vahishta — Best Truth',                   'Righteousness, cosmic law'),
    ZDayYazata('Shahrivar',    'Khshathra Vairya — Wished-for Kingdom',        'Power, dominion, courage'),
    ZDayYazata('Sepandarmaz',  'Spenta Armaiti — Holy Devotion',               'Patient love, the fertile earth'),
    ZDayYazata('Khordad',      'Haurvata — Wholeness',                         'Healing, completion, water'),
    ZDayYazata('Amordad',      'Ameretat — Immortality',                       'Plants, resilience, eternal life'),
    ZDayYazata('Dae-pa-Adar',  'Ahura Mazda (Day Lord)',                       'Creative fire, initiation'),
    ZDayYazata('Azar',         'Atar — Fire',                                  'Sacred flame, purification'),
    ZDayYazata('Aban',         'Anahita — Waters',                             'Fertility, cleansing, beauty'),
    ZDayYazata('Khorshed',     'Hvare-khshaeta — Sun',                         'Radiance, visibility, solar will'),
    ZDayYazata('Mah',          'Mah — Moon',                                   'Reflection, tides, inner rhythm'),
    ZDayYazata('Tir',          'Tishtrya — Star Sirius',                       'Rain-bringer, hope against drought'),
    ZDayYazata('Gosh',         'Geush Urvan — Soul of the Primordial Bull',    'Animal world, creation, nourishment'),
    ZDayYazata('Dae-pa-Mehr',  'Ahura Mazda (Day Lord)',                       'Covenant, middle path, balance'),
    ZDayYazata('Mehr',         'Mithra — Covenant & Sun',                      'Friendship, oath-keeping, justice'),
    ZDayYazata('Sorush',       'Sraosha — Holy Obedience',                     'Listening, discipline, divine word'),
    ZDayYazata('Rashn',        'Rashnu — Righteous Judge',                     'Truth-weighing, fairness, karma'),
    ZDayYazata('Farvardin',    'Fravashi — Guardian Spirits',                  'Ancestral wisdom, protection'),
    ZDayYazata('Behram',       'Verethragna — Victory',                        'Triumph over obstacles, warrior energy'),
    ZDayYazata('Ram',          'Ram — Joy & Air',                              'Freedom, breath, life energy'),
    ZDayYazata('Bad',          'Vayu-Vata — Wind',                             'Speed, change, invisible force'),
    ZDayYazata('Dae-pa-Din',   'Ahura Mazda (Day Lord)',                       'Inner law, conscience'),
    ZDayYazata('Din',          'Daena — Divine Law / Inner Religion',          'Personal faith, inner vision'),
    ZDayYazata('Ard',          'Ashi — Righteousness & Fortune',               'Abundance through right action'),
    ZDayYazata('Ashtad',       'Arshtat — Rectitude',                          'Integrity, straight path'),
    ZDayYazata('Asman',        'Asman — Sky / Heaven',                         'Vast mind, cosmic perspective'),
    ZDayYazata('Zamyad',       'Zam — Earth',                                  'Groundedness, physical strength'),
    ZDayYazata('Mahraspand',   'Mathra Spenta — Holy Word',                    'Sacred speech, mantras, meaning'),
    ZDayYazata('Aneran',       'Anagra Raocha — Endless Light',                'Infinite luminosity, eternity'),
  ];

  // ── Four Season Stars (Ratu stars, cardinal guardians) ───────────────────
  static const seasonStars = [
    ZSeasonStar('Tishtrya',    'Sirius',     'East',  'Spring (Mar–Jun)',
        'The brightest star, ruler of the East. Tishtrya battles the demon of drought every year, bringing the rains that sustain life. Born under Tishtrya: a soul who transforms scarcity into abundance, whose presence calls forth what was withheld.'),
    ZSeasonStar('Vanant',      'Vega',       'South', 'Summer (Jun–Sep)',
        'The star of the South, vanquisher of darkness. Vanant shines with fierce victory over the forces of chaos. Born under Vanant: a soul of summer intensity who defeats obstacles through sheer luminous will.'),
    ZSeasonStar('Satavaesa',   'Fomalhaut',  'West',  'Autumn (Sep–Dec)',
        'The deep ocean star of the West, guardian of sacred waters. Satavaesa governs the mysterious currents beneath all things. Born under Satavaesa: a soul with oceanic depth, intuitive knowledge of what lies beneath the surface.'),
    ZSeasonStar('Hapto-iringa','Ursa Major', 'North', 'Winter (Dec–Mar)',
        'The Seven Stars of the North, eternal navigators who never set below the horizon. Hapto-iringa guides sailors and wanderers home across the dark. Born under Hapto-iringa: a soul who endures, navigates, and leads others through the longest nights.'),
  ];

  // ── 6 Amesha Spentas (Holy Immortals) ────────────────────────────────────
  static const ameshaSpenta = [
    ZSpenta('Vohuman',      'Good Mind',       'cattle/gentle life',  'compassion, intellectual clarity, gentle strength'),
    ZSpenta('Ardibehesht',  'Best Truth',      'fire',                'unwavering righteousness, cosmic law, inner fire'),
    ZSpenta('Shahrivar',    'Divine Kingdom',  'sky/metal',           'sovereign power, protection, building lasting order'),
    ZSpenta('Spendarmad',   'Holy Devotion',   'earth',               'patient love, faithful service, grounded wisdom'),
    ZSpenta('Khordad',      'Wholeness',       'water',               'healing, restoration, the completeness of being'),
    ZSpenta('Amordad',      'Immortality',     'plants',              'nurturing resilience, growth through all seasons'),
  ];

  // Month → Amesha Spenta index (0-based, matching ameshaSpenta list)
  static const monthAmesha = [
    0, // Farvardin → Vohuman
    1, // Ordibehesht → Ardibehesht
    4, // Khordad → Khordad (index 4 = Khordad)
    5, // Tir → Amordad
    4, // Amordad → Khordad
    2, // Shahrivar → Shahrivar
    1, // Mehr → Ardibehesht
    3, // Aban → Spendarmad
    2, // Azar → Shahrivar
    0, // Dey → Vohuman
    1, // Bahman → Ardibehesht
    3, // Esfand → Spendarmad
  ];

  // ── Sacred Fire types ─────────────────────────────────────────────────────
  static const fireTypes = [
    ('Atash Bahram',  'Victorious Fire — the highest consecrated flame, harbinger of triumph'),
    ('Atash Adaran',  'Fire of Fires — the communal flame that unites artisans and seekers'),
    ('Atash Dadgah',  'Household Fire — the intimate flame of personal devotion and daily life'),
  ];

  // Day number 1–30 → fire type index
  static int fireTypeIndex(int day) {
    if (day <= 10) return 0; // Atash Bahram (cosmic force days)
    if (day <= 20) return 1; // Atash Adaran (celestial force days)
    return 2;                // Atash Dadgah (earthly/devotional days)
  }

  // ── Descriptions for month yazatas ────────────────────────────────────────
  static const monthDescriptions = {
    'Farvardin':   'You are born when the guardian spirits of all righteous souls walk the earth. Farvardin souls carry ancestral memory and act as bridges between living and departed wisdom.',
    'Ordibehesht': 'You are born in the month of Asha — Best Truth. This is the most sacred month, when the fire of cosmic righteousness burns most clearly. Ordibehesht souls are drawn to purity and cannot abide deception.',
    'Khordad':     'You are born in the month of Wholeness. Khordad souls have a natural drive toward healing, completion, and the restoration of what is broken — in themselves and in the world.',
    'Tir':         'You are born in the month of Tishtrya, the rain-star. Tir souls battle invisible droughts — of creativity, love, or meaning — and ultimately bring the rains that end them.',
    'Amordad':     'You are born in the month of Immortality. Amordad souls outlast what tries to diminish them. Like plants, they return after winter, stronger each cycle.',
    'Shahrivar':   'You are born in the month of Divine Kingdom. Shahrivar souls have a natural authority — they protect, they build, they govern. The sky and metal are their domains.',
    'Mehr':        'You are born in the month of Mithra, the great covenant-keeper. Mehr souls are fiercely loyal and hold others to their word. They see the sun in every relationship.',
    'Aban':        'You are born in the month of Anahita, goddess of sacred waters. Aban souls carry the power of rivers — purifying, life-giving, irresistible in their patient flow.',
    'Azar':        'You are born in the month of Atar, holy fire. Azar souls are the flame itself — they illuminate, they transform, and they warm all who come near.',
    'Dey':         'You are born in the month of Ahura Mazda directly. Dey souls bear a special weight of divine awareness — they sense the larger pattern behind everyday events.',
    'Bahman':      'You are born in the month of Good Mind. Bahman souls think differently from others — their intelligence is not cold logic but warm understanding. They are the counselors.',
    'Esfand':      'You are born in the month of Spenta Armaiti — Holy Devotion, the spirit of the sacred earth. Esfand souls love with a patience that outlasts stone. They are the ones who remain.',
  };
}

// ── Internal data classes ─────────────────────────────────────────────────

class ZMonth {
  final String name;
  final String yazata;
  final int startMonth;
  final int startDay;
  final String meaning;
  final String symbol;
  const ZMonth(this.name, this.yazata, this.startMonth, this.startDay, this.meaning, this.symbol);
}

class ZDayYazata {
  final String name;
  final String fullName;
  final String keywords;
  const ZDayYazata(this.name, this.fullName, this.keywords);
}

class ZSeasonStar {
  final String name;
  final String star;
  final String direction;
  final String season;
  final String mythology;
  const ZSeasonStar(this.name, this.star, this.direction, this.season, this.mythology);
}

class ZSpenta {
  final String name;
  final String meaning;
  final String domain;
  final String gifts;
  const ZSpenta(this.name, this.meaning, this.domain, this.gifts);
}
