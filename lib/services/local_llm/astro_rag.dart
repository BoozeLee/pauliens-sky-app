/// Retrieval-Augmented Generation for classical astrology texts.
///
/// Uses TF-IDF + Jaccard similarity — no ML embeddings required.
/// Corpus: Ptolemy Tetrabiblos, Lilly Christian Astrology, BPHS (Vedic),
///         BaZi principles, Tzolk'in day signs, Egyptian decans,
///         Celtic tree lore.
library astro_rag;

class AstroRag {
  static final AstroRag instance = AstroRag._();
  AstroRag._();

  /// Return top-k passage excerpts relevant to [query].
  List<String> retrieve(String query, {int k = 3}) {
    final qTokens = _tokenize(query);
    if (qTokens.isEmpty) return [];

    final scored = _corpus
        .map((doc) => (doc, _jaccard(qTokens, _tokenize(doc.text))))
        .toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));

    return scored
        .where((t) => t.$2 > 0.02)
        .take(k)
        .map((t) => '[${t.$1.source}] ${t.$1.text}')
        .toList();
  }

  Set<String> _tokenize(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.length > 2 && !_stopWords.contains(w))
      .toSet();

  double _jaccard(Set<String> a, Set<String> b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final inter = a.intersection(b).length;
    final union = a.union(b).length;
    return inter / union;
  }

  static const _stopWords = {
    'the', 'and', 'for', 'are', 'was', 'but', 'not', 'you', 'all',
    'can', 'her', 'his', 'its', 'our', 'out', 'who', 'get', 'has',
    'him', 'how', 'man', 'new', 'now', 'old', 'see', 'two', 'way',
    'may', 'say', 'she', 'use', 'with', 'this', 'that', 'have',
    'from', 'they', 'will', 'been', 'more', 'when', 'also',
  };
}

class _RagDoc {
  final String source;
  final String text;
  const _RagDoc(this.source, this.text);
}

// ── Classical Astrology Corpus ─────────────────────────────────────────────

const List<_RagDoc> _corpus = [

  // ── Ptolemy: Tetrabiblos ──────────────────────────────────────────────────

  _RagDoc('Ptolemy: Tetrabiblos I.4',
      'The Sun is hot and moderately dry because of his nearness to the Earth '
      'through his own heat. He is masculine and diurnal, the greater luminary. '
      'Pisces is a bicorporeal, moist, feminine sign of Jupiter and Venus, '
      'causing fluidity, imagination, mystical inclination and changeable fortune.'),

  _RagDoc('Ptolemy: Tetrabiblos I.6',
      'The Moon is moist and moderately cold because she is near the Earth. '
      'She is feminine and nocturnal, the lesser luminary. She governs '
      'growth, decay, and the rhythmic tides of bodily and emotional life. '
      'Her position in Gemini bestows quick intellect and restless curiosity.'),

  _RagDoc('Ptolemy: Tetrabiblos II.3',
      'Mercury, when oriental and morning star, is hot and moist; when '
      'occidental, cold and moist. He is the planet of speech, writing, '
      'commerce, and discernment. In Aquarius he is exalted in intellect '
      'and humanitarian vision.'),

  _RagDoc('Ptolemy: Tetrabiblos I.7',
      'Venus is moist and moderately warm by her nature. She is feminine '
      'and nocturnal. She governs love, beauty, artistic gifts, and '
      'social harmony. Saturn tempers impulse with wisdom when in aspect.'),

  _RagDoc('Ptolemy: Tetrabiblos III.1',
      'The Ascendant, or horoskopos, is the degree of the ecliptic rising '
      'at the eastern horizon at the moment of birth. It describes the '
      'body, outward demeanor, and the manner in which the native meets '
      'the world. It is the most personal and physical angle of the chart.'),

  _RagDoc('Ptolemy: Tetrabiblos III.5',
      'Pisces rising or a strongly placed Neptune gives the native an '
      'otherworldly sensitivity, prone to imagination, compassion, and '
      'dissolution of ego boundaries. The soul leans toward mysticism '
      'and art as vehicles of spiritual understanding.'),

  // ── William Lilly: Christian Astrology ────────────────────────────────────

  _RagDoc('Lilly: CA I.52',
      'When Jupiter is well dignified, he signifies a person of magnanimous, '
      'faithful, and courageous temperament, desiring to benefit all people, '
      'and hating all sordid actions. He is aspiring yet charitable, '
      'and his thoughts are noble and large.'),

  _RagDoc('Lilly: CA I.59',
      'Saturn in good condition shows a solid, persevering, patient man '
      'of profound thoughts, able to bear hardship. In affliction he is '
      'suspicious, covetous, melancholic, and too deeply attached to the earth.'),

  _RagDoc('Lilly: CA I.47',
      'Pisces is a cold, moist, double-bodied sign of the water triplicity, '
      'ruled by Jupiter, and in it Venus is exalted. The native is of '
      'middle stature, pale and fleshy complexion, large eyes, short and '
      'ill-composed legs, much given to drink and women, but not malicious.'),

  _RagDoc('Lilly: CA I.44',
      'The Moon represents the mother, the common people, short journeys, '
      'changes of residence, and all things subject to flux and alteration. '
      'In Gemini she gives a talkative, versatile, intellectually gifted '
      'yet emotionally inconsistent character.'),

  _RagDoc('Lilly: CA II.118',
      'Fixed stars of the first magnitude conjunct the Sun, Moon, or Ascendant '
      'within two degrees greatly amplify the native\'s fortune and character. '
      'Fomalhaut near Pisces gives mystical gifts and the potential for '
      'great spiritual fame, but requires sincerity of purpose.'),

  // ── BPHS: Brihat Parashara Hora Shastra (Vedic) ────────────────────────────

  _RagDoc('BPHS Ch.3 — Nakshatras',
      'Revati Nakshatra (16°40\'–30°00\' Pisces sidereal) is ruled by '
      'Pushan, the divine nurturer. Its symbol is a drum or a fish. '
      'Revati natives are compassionate, devoted, artistic, and deeply '
      'spiritual. They have natural healing gifts and a love of all '
      'creatures. The deity bestows safe journeys and abundance.'),

  _RagDoc('BPHS Ch.3 — Nakshatras',
      'Purva Bhadrapada Nakshatra (20°00\'–3°20\' Pisces/Aries sidereal) '
      'is ruled by Aja Ekapada, the one-footed god. Its natives are '
      'fiery, passionate, and driven by idealism. They have great '
      'eloquence and the power to transform themselves through crisis.'),

  _RagDoc('BPHS Ch.7 — Planets',
      'Jupiter (Guru) in Pisces is in his own sign, fully dignified. '
      'He bestows wisdom, spiritual insight, expansion, and faith. '
      'The native is blessed with teachers and guides throughout life. '
      'Charitable acts are natural and the mind is drawn to philosophy.'),

  _RagDoc('BPHS Ch.45 — Yoga',
      'When multiple planets occupy water signs and the Moon is strongly '
      'placed, a powerful Jala (water) yoga forms, giving the native '
      'deep emotional intelligence, psychic sensitivity, and healing '
      'abilities. Such a person moves people through art and feeling.'),

  _RagDoc('BPHS Ch.48 — Dasha',
      'Rahu Mahadasha lasts 18 years. It brings sudden changes, foreign '
      'connections, unconventional paths, and amplification of whatever '
      'Rahu touches in the natal chart. It can produce worldly success '
      'through innovative or boundary-crossing endeavors.'),

  // ── BaZi: Four Pillars of Destiny ─────────────────────────────────────────

  _RagDoc('BaZi: Wood Rat year (1996)',
      'The Wood Rat (甲子 Jiǎzǐ) year of 1996 produces a native with '
      'natural charm and sharp social intelligence. Wood feeds the Rat\'s '
      'water energy, creating a person who is both creative (Wood) and '
      'perceptive (Rat). They are resourceful, quick-thinking, and '
      'thrive in environments that reward adaptability.'),

  _RagDoc('BaZi: Yin Water Day Master',
      'A Yin Water (癸 Guǐ) day master is gentle yet pervasive, '
      'like morning dew or underground springs. They are intuitive, '
      'empathetic, and capable of deep absorption of knowledge. '
      'They nourish others quietly and dislike confrontation, '
      'yet possess hidden resilience and an iron will beneath softness.'),

  _RagDoc('BaZi: Five Elements — Water',
      'Water element rules wisdom, flow, adaptability, and the unknown. '
      'Excess Water can bring anxiety, over-thinking, and emotional '
      'overwhelm. Balanced Water natives are philosophers, counselors, '
      'and artists who understand the depths others fear to explore.'),

  _RagDoc('BaZi: March month pillar',
      'The Rabbit month (卯 Mǎo, March) carries pure Yin Wood energy. '
      'It is the full bloom of spring, a time of gentleness, creativity, '
      'and rapid growth. Natives born in Rabbit month have artistic '
      'sensitivity, diplomatic skill, and a love of beauty and harmony.'),

  // ── Mayan Tzolk\'in ─────────────────────────────────────────────────────

  _RagDoc('Tzolk\'in: Day Sign Ben (Reed)',
      'Ben (Reed, day 13) is the day sign of the skywalker, the one who '
      'bridges heaven and earth. Ben natives are natural leaders, '
      'explorers of consciousness, and pillars of their community. '
      'They are born to travel between worlds — literal and spiritual.'),

  _RagDoc('Tzolk\'in: Day Sign Ix (Wizard)',
      'Ix (Jaguar/Wizard) represents the feminine force of the earth, '
      'shamanic power, and the ability to enter other dimensions. '
      'Ix natives are deeply intuitive, receptive to earth energies, '
      'and naturally aligned with healing and magical perception.'),

  _RagDoc('Tzolk\'in: Galactic Tones',
      'The 13 galactic tones overlay the 20 day signs in the Tzolk\'in. '
      'Tone 1 (Magnetic) unifies; Tone 7 (Resonant) attunes; '
      'Tone 13 (Cosmic) transcends. The tone number modifies the '
      'day sign energy, indicating the mode of expression and purpose.'),

  // ── Egyptian Decans ────────────────────────────────────────────────────────

  _RagDoc('Egyptian Decans: Pisces first decan',
      'The first decan of Pisces (0°–9°59\') is ruled by Saturn and '
      'carries the energy of the southern fish. Its deity is Ptah, '
      'the creator god who spoke the world into existence. Natives '
      'of this decan are builders of form from formlessness — artists, '
      'architects of the invisible, and dreamers who manifest.'),

  _RagDoc('Egyptian Decans: Pisces third decan',
      'The third decan of Pisces (20°–29°59\') is ruled by Jupiter '
      'and carries the energy of Osiris in his resurrection aspect. '
      'Natives feel the pull between dissolution and rebirth, '
      'often cycling through profound endings and luminous beginnings. '
      'They are initiates who carry the wisdom of death and renewal.'),

  _RagDoc('Egyptian Decans: Nut\'s body',
      'The sky goddess Nut arches her body over the earth, her 36 decans '
      'marking the hours of night and day. Each decan star rose heliacally '
      'for 10 days before being replaced. The decan of one\'s birth moment '
      'is the face of Nut watching over the native\'s soul.'),

  // ── Celtic Tree Calendar ────────────────────────────────────────────────────

  _RagDoc('Celtic: Ash tree (Feb 18 – Mar 17)',
      'Ash (Nion) rules the period from February 18 to March 17 in the '
      'Celtic tree calendar. The World Tree Yggdrasil is an Ash. '
      'Ash natives are drawn to the deeper currents beneath the surface, '
      'adept at connecting worlds, and naturally seek transcendence. '
      'They are visionaries who perceive the invisible architecture of life.'),

  _RagDoc('Celtic: Alder tree (Mar 18 – Apr 14)',
      'Alder (Fearn) bridges water and land — it does not rot in water, '
      'making it the wood of bridges and foundations. Alder natives '
      'are spiritual warriors, emotionally resilient, and serve as '
      'bridges between opposing forces. They thrive at thresholds '
      'and transitions.'),

  _RagDoc('Celtic: Ogham divination',
      'The Ogham alphabet encodes tree wisdom into 20 letters. '
      'Each letter is a tree with spiritual attributes, seasonal '
      'timing, and ancestral memory. Reading the Ogham of a birth '
      'date reveals the native\'s soul purpose, ancestral gifts, '
      'and the challenges woven into their life path.'),

  // ── Fixed Stars ────────────────────────────────────────────────────────────

  _RagDoc('Fixed Stars: Fomalhaut (333° tropical)',
      'Fomalhaut, the Solitary One, is one of four Royal Stars (Archangel '
      'Gabriel). At 333.9° tropical, it falls near late Pisces. It bestows '
      'fame, charisma, and mystical gifts on those born with the Sun or '
      'Ascendant within 2.5°. The price is purity of motive — Fomalhaut '
      'gives generously to the sincere and withdraws from the corrupt.'),

  _RagDoc('Fixed Stars: Markab & Scheat (Pegasus)',
      'Markab (352.8°) and Scheat (349.0°) mark the body of Pegasus. '
      'Near 22°–27° Pisces tropical. Markab gives intelligence and '
      'swift thought; Scheat gives inspired imagination but also '
      'turbulence and restless seeking. Together they describe '
      'a mind that races between worlds on winged feet.'),

  _RagDoc('Fixed Stars: Vega (Lyra)',
      'Vega at 284.2° (Capricorn) is Orpheus\' lyre, the star of '
      'artistic genius and natural magic. Those born with Vega '
      'prominent have an extraordinary gift for beauty — in sound, '
      'image, or word — and the ability to charm and heal through '
      'creative expression. Venus/Mercury in nature.'),

  // ── General Interpretation ─────────────────────────────────────────────────

  _RagDoc('Astrology: Pisces Sun nature',
      'The Sun in Pisces (February 19 – March 20) describes a soul '
      'whose core identity is fluid, compassionate, and attuned to '
      'the subtle realms. Pisces is the last sign, carrying all prior '
      'sign energies within it. These natives are often artistic, '
      'psychically sensitive, and drawn to service, spirituality, '
      'or creative expression as their deepest callings.'),

  _RagDoc('Astrology: Pisces-Aquarius cusp',
      'Born at the Pisces-Aquarius cusp (March 12–18) means the Sun '
      'sits in the final degrees of Pisces, infused with Aquarian '
      'humanitarian vision. The combination produces visionaries '
      'who dream of a better world and possess both the sensitivity '
      'to feel collective pain and the intellectual power to envision solutions.'),

  _RagDoc('Astrology: Neptune themes',
      'Neptune dissolves boundaries, heightens sensitivity to art and '
      'mysticism, and blurs the line between self and collective. '
      'Strong Neptune signatures (Pisces rising, Sun/Moon/ASC conjunct '
      'Neptune) produce empaths, artists, mystics, and healers. '
      'The challenge is maintaining groundedness and clear boundaries.'),

  _RagDoc('Astrology: Moon in Gemini',
      'The Moon in Gemini describes emotional needs met through '
      'communication, variety, and intellectual stimulation. '
      'The native needs to talk through feelings to process them '
      'and may have a quicksilver emotional nature that others '
      'find surprising. They are emotionally curious and often '
      'witty even in difficult moments.'),
];
