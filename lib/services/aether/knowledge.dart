/// AETHER Knowledge Base
/// 
/// Comprehensive astrological knowledge for deterministic readings.
/// Covers: zodiac signs, planets, aspects, houses, cultural traditions.

class SignProfile {
  final String name;
  final String element;
  final String modality;
  final String ruler;
  final String keywords;
  final String strengths;
  final String challenges;
  final String bodyPart;
  final String mythology;

  const SignProfile({
    required this.name,
    required this.element,
    required this.modality,
    required this.ruler,
    required this.keywords,
    required this.strengths,
    required this.challenges,
    required this.bodyPart,
    required this.mythology,
  });
}

class PlanetProfile {
  final String name;
  final String function;
  final String keywords;
  final String glyph;
  final String mythology;
  final String positiveExpression;
  final String challengingExpression;

  const PlanetProfile({
    required this.name,
    required this.function,
    required this.keywords,
    required this.glyph,
    required this.mythology,
    required this.positiveExpression,
    required this.challengingExpression,
  });
}

class AspectProfile {
  final String name;
  final double angle;
  final String nature;
  final String keywords;
  final String description;

  const AspectProfile({
    required this.name,
    required this.angle,
    required this.nature,
    required this.keywords,
    required this.description,
  });
}

class HouseProfile {
  final int number;
  final String name;
  final String keywords;
  final String ruler;
  final String description;

  const HouseProfile({
    required this.number,
    required this.name,
    required this.keywords,
    required this.ruler,
    required this.description,
  });
}

class CultureKnowledge {
  final String culture;
  final String description;
  final Map<String, String> signMeanings;
  final List<String> keyConcepts;
  final String mythology;

  const CultureKnowledge({
    required this.culture,
    required this.description,
    required this.signMeanings,
    required this.keyConcepts,
    required this.mythology,
  });
}

// ── Main Knowledge Base ──────────────────────────────────────────────────

class AetherKnowledge {
  static final AetherKnowledge instance = AetherKnowledge._();
  AetherKnowledge._();

  // ── Zodiac Signs ────────────────────────────────────────────────────────

  static const Map<String, SignProfile> signs = {
    'Aries': SignProfile(
      name: 'Aries',
      element: 'Fire',
      modality: 'Cardinal',
      ruler: 'Mars',
      keywords: 'initiative, courage, leadership, independence, pioneering spirit',
      strengths: 'natural leader, brave, enthusiastic, optimistic, honest',
      challenges: 'impatient, impulsive, aggressive, self-centered, short-tempered',
      bodyPart: 'head, face',
      mythology: 'The Ram — Aries represents the golden ram of Greek mythology that carried Phrixus to safety. It symbolizes new beginnings, the first spark of spring, and the courage to start anew.',
    ),
    'Taurus': SignProfile(
      name: 'Taurus',
      element: 'Earth',
      modality: 'Fixed',
      ruler: 'Venus',
      keywords: 'stability, sensuality, patience, determination, material comfort',
      strengths: 'reliable, patient, practical, devoted, responsible, stable',
      challenges: 'stubborn, possessive, uncompromising, materialistic',
      bodyPart: 'throat, neck',
      mythology: 'The Bull — Taurus is the sacred bull of ancient Mesopotamia, associated with fertility and the earth. In Greek myth, Zeus took the form of a bull to abduct Europa, symbolizing the power of desire and beauty.',
    ),
    'Gemini': SignProfile(
      name: 'Gemini',
      element: 'Air',
      modality: 'Mutable',
      ruler: 'Mercury',
      keywords: 'communication, versatility, curiosity, duality, intellectual agility',
      strengths: 'gentle, affectionate, curious, adaptable, quick learner',
      challenges: 'nervous, inconsistent, indecisive, superficial',
      bodyPart: 'arms, hands, lungs',
      mythology: 'The Twins — Gemini represents Castor and Pollux, the Dioscuri of Greek mythology. One twin was mortal, the other divine, symbolizing the duality of human nature and the bridge between the physical and spiritual worlds.',
    ),
    'Cancer': SignProfile(
      name: 'Cancer',
      element: 'Water',
      modality: 'Cardinal',
      ruler: 'Moon',
      keywords: 'nurturing, emotional depth, protection, intuition, home and family',
      strengths: 'tenacious, highly imaginative, loyal, emotional, sympathetic, persuasive',
      challenges: 'moody, pessimistic, suspicious, manipulative, insecure',
      bodyPart: 'chest, breasts, stomach',
      mythology: 'The Crab — Cancer is the crab that Hera sent to distract Hercules during his battle with the Hydra. Though crushed, it was placed among the stars for its loyalty. Cancer represents the protective shell we build around our tender inner world.',
    ),
    'Leo': SignProfile(
      name: 'Leo',
      element: 'Fire',
      modality: 'Fixed',
      ruler: 'Sun',
      keywords: 'creativity, generosity, warmth, leadership, dramatic flair, loyalty',
      strengths: 'creative, passionate, generous, warm-hearted, cheerful, humorous',
      challenges: 'arrogant, stubborn, self-centered, lazy, inflexible',
      bodyPart: 'heart, spine',
      mythology: 'The Lion — Leo is the Nemean Lion slain by Hercules as his first labor. Its hide was impenetrable, symbolizing the strength and invincibility of the Sun-ruled. Leo represents the radiant, creative force at the center of the solar system.',
    ),
    'Virgo': SignProfile(
      name: 'Virgo',
      element: 'Earth',
      modality: 'Mutable',
      ruler: 'Mercury',
      keywords: 'analysis, service, purity, health, attention to detail, humility',
      strengths: 'loyal, analytical, kind, hardworking, practical, methodical',
      challenges: 'shy, worried, overly critical, harsh, perfectionist',
      bodyPart: 'intestines, digestive system',
      mythology: 'The Maiden — Virgo is associated with Demeter, goddess of the harvest, and with the Vestal Virgins who tended the sacred flame. She represents discernment, the ability to separate wheat from chaff, and the sacred duty of service.',
    ),
    'Libra': SignProfile(
      name: 'Libra',
      element: 'Air',
      modality: 'Cardinal',
      ruler: 'Venus',
      keywords: 'balance, harmony, justice, partnership, beauty, diplomacy',
      strengths: 'cooperative, diplomatic, gracious, fair-minded, social',
      challenges: 'indecisive, avoids confrontation, self-pity, codependent',
      bodyPart: 'kidneys, lower back',
      mythology: 'The Scales — Libra is the only zodiac sign represented by an inanimate object. Associated with Themis, goddess of justice, and Ma\'at, who weighs the heart of the dead. Libra represents the eternal quest for balance between opposites.',
    ),
    'Scorpio': SignProfile(
      name: 'Scorpio',
      element: 'Water',
      modality: 'Fixed',
      ruler: 'Pluto',
      keywords: 'transformation, intensity, depth, power, regeneration, mystery',
      strengths: 'resourceful, brave, passionate, stubborn, a true friend',
      challenges: 'distrusting, jealous, secretive, violent, manipulative',
      bodyPart: 'reproductive organs',
      mythology: 'The Scorpion — Scorpio is the scorpion that slew Orion, placed among the stars by the gods. It represents the transformative power of death and rebirth, the alchemical process of turning lead into gold through the intensity of experience.',
    ),
    'Sagittarius': SignProfile(
      name: 'Sagittarius',
      element: 'Fire',
      modality: 'Mutable',
      ruler: 'Jupiter',
      keywords: 'freedom, philosophy, exploration, optimism, higher learning, truth',
      strengths: 'generous, idealistic, great sense of humor, adventurous, enthusiastic',
      challenges: 'promises more than can deliver, impatient, tactless, restless',
      bodyPart: 'hips, thighs, liver',
      mythology: 'The Archer — Sagittarius is the centaur Chiron, the wise teacher and healer of Greek mythology. His arrow points toward the galactic center, symbolizing the eternal quest for meaning, truth, and the expansion of consciousness.',
    ),
    'Capricorn': SignProfile(
      name: 'Capricorn',
      element: 'Earth',
      modality: 'Cardinal',
      ruler: 'Saturn',
      keywords: 'ambition, discipline, structure, responsibility, mastery, time',
      strengths: 'responsible, disciplined, self-controlled, good managers, patient',
      challenges: 'know-it-all, unforgiving, condescending, pessimistic, cold',
      bodyPart: 'knees, bones, skin',
      mythology: 'The Sea-Goat — Capricorn is the Sumerian god Enki (Ea), who emerged from the primordial waters bearing the gifts of civilization. The sea-goat climbs from the depths of the ocean to the mountain peak, symbolizing the ascent from unconsciousness to mastery.',
    ),
    'Aquarius': SignProfile(
      name: 'Aquarius',
      element: 'Air',
      modality: 'Fixed',
      ruler: 'Uranus',
      keywords: 'innovation, humanitarianism, independence, eccentricity, future vision',
      strengths: 'progressive, original, independent, humanitarian, intellectual',
      challenges: 'runs from emotional expression, aloof, uncompromising, detached',
      bodyPart: 'ankles, circulatory system',
      mythology: 'The Water Bearer — Aquarius pours the waters of knowledge upon the earth. Associated with Ganymede, the cupbearer of the gods, and with Prometheus who stole fire for humanity. Aquarius represents the revolutionary spirit that brings new knowledge to the collective.',
    ),
    'Pisces': SignProfile(
      name: 'Pisces',
      element: 'Water',
      modality: 'Mutable',
      ruler: 'Neptune',
      keywords: 'intuition, compassion, dreams, spirituality, dissolution, unity',
      strengths: 'compassionate, artistic, intuitive, gentle, wise, musical',
      challenges: 'fearful, overly trusting, sad, desire to escape reality, victim mentality',
      bodyPart: 'feet, immune system',
      mythology: 'The Fish — Pisces represents the two fish of Aphrodite and Eros, who transformed themselves to escape the monster Typhon. They are tied together by a cord, symbolizing the connection between the conscious and unconscious, the seen and unseen worlds.',
    ),
  };

  // ── Planets ─────────────────────────────────────────────────────────────

  static const Map<String, PlanetProfile> planets = {
    'sun': PlanetProfile(
      name: 'Sun',
      function: 'Core identity, ego, vitality, life purpose, conscious self',
      keywords: 'self, identity, will, creativity, authority, father',
      glyph: '☉',
      mythology: 'Helios drives his golden chariot across the sky each day. The Sun is the center of our solar system and the center of the natal chart — it represents who you are becoming.',
      positiveExpression: 'radiant confidence, creative leadership, authentic self-expression',
      challengingExpression: 'ego inflation, need for validation, domineering tendencies',
    ),
    'moon': PlanetProfile(
      name: 'Moon',
      function: 'Emotions, instincts, subconscious, nurturing, mother, inner world',
      keywords: 'feelings, intuition, memory, home, security, cycles',
      glyph: '☽',
      mythology: 'Selene drives her silver chariot across the night sky. The Moon rules the tides and the feminine mysteries — she represents the ever-changing emotional landscape within.',
      positiveExpression: 'emotional intelligence, nurturing warmth, intuitive wisdom',
      challengingExpression: 'mood swings, clinginess, fear of abandonment',
    ),
    'mercury': PlanetProfile(
      name: 'Mercury',
      function: 'Communication, intellect, learning, travel, commerce, messenger',
      keywords: 'mind, speech, writing, analysis, connection, trickster',
      glyph: '☿',
      mythology: 'Hermes, the messenger god, moves between worlds with winged sandals. Mercury governs how we think, speak, and connect the dots of experience.',
      positiveExpression: 'quick wit, eloquent speech, versatile intelligence',
      challengingExpression: 'restlessness, gossip, scattered thinking, deception',
    ),
    'venus': PlanetProfile(
      name: 'Venus',
      function: 'Love, beauty, values, harmony, pleasure, attraction, art',
      keywords: 'love, beauty, art, harmony, desire, magnetism',
      glyph: '♀',
      mythology: 'Aphrodite rises from the sea foam, embodiment of love and beauty. Venus rules what we find beautiful, what we value, and how we give and receive love.',
      positiveExpression: 'graceful charm, artistic talent, capacity for deep love',
      challengingExpression: 'vanity, jealousy, excessive pleasure-seeking, codependency',
    ),
    'mars': PlanetProfile(
      name: 'Mars',
      function: 'Action, desire, energy, aggression, courage, sexuality, drive',
      keywords: 'action, drive, passion, conflict, courage, warrior',
      glyph: '♂',
      mythology: 'Ares, god of war, embodies the raw force of action and desire. Mars shows how we assert ourselves, pursue our goals, and handle conflict.',
      positiveExpression: 'courageous action, passionate energy, healthy assertiveness',
      challengingExpression: 'aggression, impulsivity, anger issues, recklessness',
    ),
    'jupiter': PlanetProfile(
      name: 'Jupiter',
      function: 'Expansion, wisdom, luck, growth, philosophy, abundance, teaching',
      keywords: 'growth, wisdom, abundance, faith, generosity, expansion',
      glyph: '♃',
      mythology: 'Zeus, king of the gods, rules from Mount Olympus. Jupiter expands whatever it touches — bringing growth, wisdom, and the grace of good fortune.',
      positiveExpression: 'generous wisdom, abundant faith, inspiring leadership',
      challengingExpression: 'excess, overconfidence, dogmatism, wastefulness',
    ),
    'saturn': PlanetProfile(
      name: 'Saturn',
      function: 'Structure, discipline, responsibility, time, karma, mastery, limits',
      keywords: 'discipline, structure, time, boundaries, maturity, teacher',
      glyph: '♄',
      mythology: 'Kronos, god of time, devours his children and is eventually overthrown by them. Saturn represents the great teacher — through limitation, discipline, and time, we achieve mastery.',
      positiveExpression: 'wise discipline, patient mastery, responsible authority',
      challengingExpression: 'fear, rigidity, excessive control, isolation, depression',
    ),
    'uranus': PlanetProfile(
      name: 'Uranus',
      function: 'Innovation, revolution, awakening, sudden change, originality, freedom',
      keywords: 'change, revolution, awakening, freedom, eccentricity, genius',
      glyph: '⛢',
      mythology: 'Ouranos, the sky god, was overthrown by his son Kronos. Uranus represents the sudden flash of insight, the revolutionary impulse that breaks old patterns and liberates.',
      positiveExpression: 'brilliant innovation, humanitarian vision, authentic freedom',
      challengingExpression: 'rebellion without cause, instability, detachment from tradition',
    ),
    'neptune': PlanetProfile(
      name: 'Neptune',
      function: 'Dreams, spirituality, illusion, compassion, dissolution, transcendence',
      keywords: 'dreams, intuition, illusion, spirituality, compassion, art',
      glyph: '♆',
      mythology: 'Poseidon rules the vast oceans — the realm of the unconscious, dreams, and the dissolution of boundaries. Neptune dissolves what Saturn builds, opening us to the infinite.',
      positiveExpression: 'divine inspiration, transcendent compassion, mystical vision',
      challengingExpression: 'confusion, escapism, deception, addiction, loss of boundaries',
    ),
    'pluto': PlanetProfile(
      name: 'Pluto',
      function: 'Transformation, power, death/rebirth, deep psyche, regeneration, secrets',
      keywords: 'transformation, power, death, rebirth, depth, shadows',
      glyph: '♇',
      mythology: 'Hades rules the underworld, the realm of the dead and hidden treasures. Pluto represents the process of death and rebirth — the composting of the old to make way for new growth.',
      positiveExpression: 'profound transformation, regenerative power, healing depth',
      challengingExpression: 'obsession, control, destruction, manipulation, fear of vulnerability',
    ),
  };

  // ── Aspects ─────────────────────────────────────────────────────────────

  static const Map<String, AspectProfile> aspects = {
    'conjunction': AspectProfile(
      name: 'Conjunction',
      angle: 0,
      nature: 'neutral',
      keywords: 'fusion, intensity, new beginning, concentration',
      description: 'When two planets conjoin, their energies fuse into a single powerful force. This is the most intense aspect — a new cycle begins.',
    ),
    'sextile': AspectProfile(
      name: 'Sextile',
      angle: 60,
      nature: 'harmonious',
      keywords: 'opportunity, talent, ease, cooperation',
      description: 'The sextile brings natural talent and opportunity. The planets cooperate easily, creating gifts that can be developed with conscious effort.',
    ),
    'square': AspectProfile(
      name: 'Square',
      angle: 90,
      nature: 'challenging',
      keywords: 'tension, growth, action, friction, breakthrough',
      description: 'Squares create productive tension that demands action. They are the engine of growth — uncomfortable but necessary for evolution.',
    ),
    'trine': AspectProfile(
      name: 'Trine',
      angle: 120,
      nature: 'harmonious',
      keywords: 'flow, grace, talent, ease, blessing',
      description: 'Trines are gifts from the universe — natural talents and easy flow. They represent areas of grace where things come naturally.',
    ),
    'opposition': AspectProfile(
      name: 'Opposition',
      angle: 180,
      nature: 'challenging',
      keywords: 'awareness, polarity, relationship, projection, integration',
      description: 'Oppositions create awareness through polarity. They force us to integrate opposite qualities and see ourselves through others.',
    ),
  };

  // ── Houses ──────────────────────────────────────────────────────────────

  static const Map<int, HouseProfile> houses = {
    1: HouseProfile(number: 1, name: 'House of Self', keywords: 'identity, appearance, first impressions, body', ruler: 'Aries/Mars', description: 'The Ascendant and first house describe how you present yourself to the world and your approach to new beginnings.'),
    2: HouseProfile(number: 2, name: 'House of Resources', keywords: 'money, possessions, values, self-worth', ruler: 'Taurus/Venus', description: 'The second house governs your relationship with money, possessions, and what you truly value.'),
    3: HouseProfile(number: 3, name: 'House of Communication', keywords: 'siblings, short trips, learning, daily life', ruler: 'Gemini/Mercury', description: 'The third house rules communication, learning, siblings, and the immediate environment.'),
    4: HouseProfile(number: 4, name: 'House of Home', keywords: 'family, roots, foundation, private life', ruler: 'Cancer/Moon', description: 'The fourth house is the foundation of the chart — your roots, family, and the deepest part of yourself.'),
    5: HouseProfile(number: 5, name: 'House of Creativity', keywords: 'children, romance, pleasure, self-expression', ruler: 'Leo/Sun', description: 'The fifth house is the house of joy — creativity, romance, play, and the expression of your unique self.'),
    6: HouseProfile(number: 6, name: 'House of Service', keywords: 'health, work, daily routines, service', ruler: 'Virgo/Mercury', description: 'The sixth house governs health, daily work, and the routines that support your wellbeing.'),
    7: HouseProfile(number: 7, name: 'House of Partnership', keywords: 'marriage, partnership, open enemies, contracts', ruler: 'Libra/Venus', description: 'The seventh house is the house of partnership — marriage, business partners, and open enemies.'),
    8: HouseProfile(number: 8, name: 'House of Transformation', keywords: 'death, rebirth, shared resources, intimacy', ruler: 'Scorpio/Pluto', description: 'The eighth house is the house of transformation — death, rebirth, shared resources, and deep intimacy.'),
    9: HouseProfile(number: 9, name: 'House of Philosophy', keywords: 'higher education, travel, philosophy, publishing', ruler: 'Sagittarius/Jupiter', description: 'The ninth house governs higher learning, long-distance travel, and the search for meaning.'),
    10: HouseProfile(number: 10, name: 'House of Career', keywords: 'career, reputation, public image, authority', ruler: 'Capricorn/Saturn', description: 'The Midheaven and tenth house describe your public life, career, and the legacy you build.'),
    11: HouseProfile(number: 11, name: 'House of Community', keywords: 'friends, groups, hopes, wishes, humanitarian', ruler: 'Aquarius/Uranus', description: 'The eleventh house is the house of community — friends, groups, and your vision for the future.'),
    12: HouseProfile(number: 12, name: 'House of the Unconscious', keywords: 'spirituality, isolation, hidden enemies, karma', ruler: 'Pisces/Neptune', description: 'The twelfth house is the house of the unconscious — dreams, spirituality, and what lies beyond the veil.'),
  };

  // ── Cultural Knowledge ──────────────────────────────────────────────────

  static const Map<String, CultureKnowledge> cultures = {
    'Western': CultureKnowledge(
      culture: 'Western',
      description: 'The Hellenistic tradition of tropical zodiac, houses, and planetary aspects',
      signMeanings: {},
      keyConcepts: ['tropical zodiac', 'natal chart', 'houses', 'aspects', 'transits', 'progressions', 'solar returns'],
      mythology: 'Western astrology traces its roots to Babylonian stargazers, refined by Greek philosophers like Ptolemy. It uses the tropical zodiac aligned with the seasons.',
    ),
    'Vedic': CultureKnowledge(
      culture: 'Vedic',
      description: 'The sidereal system of Jyotish from India, using nakshatras and dashas',
      signMeanings: {},
      keyConcepts: ['rashi', 'nakshatra', 'lagna', 'dasha', 'yoga', 'graha', 'bhava', 'muhurta'],
      mythology: 'Vedic astrology (Jyotish) is the "science of light" from ancient India. It uses the sidereal zodiac, 27 nakshatras (lunar mansions), and predictive dasha systems.',
    ),
    'Chinese': CultureKnowledge(
      culture: 'Chinese',
      description: 'The system of Ba Zi (Four Pillars) and the Five Elements',
      signMeanings: {},
      keyConcepts: ['ba zi', 'heavenly stems', 'earthly branches', 'five elements', 'day master', 'luck pillars', 'feng shui'],
      mythology: 'Chinese astrology uses the sexagenary cycle of 10 Heavenly Stems and 12 Earthly Branches. The Four Pillars of Destiny (Ba Zi) map the moment of birth to elemental energies.',
    ),
    'Mayan': CultureKnowledge(
      culture: 'Mayan',
      description: 'The Tzolk\'in sacred calendar of 260 days',
      signMeanings: {},
      keyConcepts: ['tzolk\'in', 'day sign', 'galactic tone', 'haab', 'uinal', 'kin', 'trecena'],
      mythology: 'The Mayan Tzolk\'in is a 260-day sacred calendar combining 20 day signs with 13 galactic tones. Each day has a unique energy signature used for divination and ceremony.',
    ),
    'Egyptian': CultureKnowledge(
      culture: 'Egyptian',
      description: 'The decan system of 36 faces based on star risings',
      signMeanings: {},
      keyConcepts: ['decans', 'decan rulers', '36 faces', 'heliacal rising', 'Nut\'s body', 'Denderah zodiac'],
      mythology: 'Egyptian astrology uses the 36 decans — star groups whose heliacal rising marked 10-day periods. The sky goddess Nut arches over the earth, her body adorned with these stellar markers.',
    ),
    'Celtic': CultureKnowledge(
      culture: 'Celtic',
      description: 'The Ogham tree calendar and Druidic star lore',
      signMeanings: {},
      keyConcepts: ['tree calendar', 'ogham', 'lunar months', 'animal totems', 'Druidic seasons', 'sacred groves'],
      mythology: 'Celtic astrology uses the Ogham tree alphabet — 20 trees marking lunar months. Each tree carries spiritual attributes, seasonal timing, and ancestral memory.',
    ),
    'Zoroastrian': CultureKnowledge(
      culture: 'Zoroastrian',
      description: 'Avestan calendar and the cosmic struggle between light and darkness',
      signMeanings: {},
      keyConcepts: ['Avestan months', 'Yazatas', 'Amesha Spentas', 'sacred fire', 'Nowruz', 'Fravashi'],
      mythology: 'Zoroastrian cosmology sees the universe as a battleground between Ahura Mazda (light) and Angra Mainyu (darkness). Each person\'s Fravashi (guardian spirit) guides them through this cosmic drama.',
    ),
  };

  // ── Intent Detection ────────────────────────────────────────────────────

  static String detectIntent(String query) {
    final q = query.toLowerCase();
    
    // Chart interpretation
    if (q.contains(RegExp(r'\b(interpret|reading|chart|natal|birth chart)\b'))) {
      return 'interpret';
    }
    
    // Daily reading
    if (q.contains(RegExp(r'\b(today|daily|current|transit|now)\b'))) {
      return 'daily';
    }
    
    // Planet questions
    if (q.contains(RegExp(r'\b(sun|moon|mercury|venus|mars|jupiter|saturn|uranus|neptune|pluto)\b'))) {
      return 'planet';
    }
    
    // Sign questions
    if (q.contains(RegExp(r'\b(aries|taurus|gemini|cancer|leo|virgo|libra|scorpio|sagittarius|capricorn|aquarius|pisces)\b'))) {
      return 'sign';
    }
    
    // Aspect questions
    if (q.contains(RegExp(r'\b(conjunction|sextile|square|trine|opposition|aspect)\b'))) {
      return 'aspect';
    }
    
    // House questions
    if (q.contains(RegExp(r'\b(house|1st|2nd|3rd|4th|5th|6th|7th|8th|9th|10th|11th|12th)\b'))) {
      return 'house';
    }
    
    // Cultural questions
    if (q.contains(RegExp(r'\b(vedic|chinese|mayan|egyptian|celtic|zoroastrian|western)\b'))) {
      return 'culture';
    }
    
    // Personality
    if (q.contains(RegExp(r'\b(personality|who am i|identity|self|traits)\b'))) {
      return 'personality';
    }
    
    // Love/relationship
    if (q.contains(RegExp(r'\b(love|relationship|partner|compatibility|synastry)\b'))) {
      return 'love';
    }
    
    // Career/purpose
    if (q.contains(RegExp(r'\b(career|purpose|vocation|work|path|calling)\b'))) {
      return 'career';
    }
    
    // Spiritual
    if (q.contains(RegExp(r'\b(spiritual|soul|karma|past life|meditation|growth)\b'))) {
      return 'spiritual';
    }
    
    return 'general';
  }

  /// Extract planet names from query
  static List<String> extractPlanets(String query) {
    final q = query.toLowerCase();
    return planets.keys.where((p) => q.contains(p)).toList();
  }

  /// Extract sign names from query
  static List<String> extractSigns(String query) {
    final q = query.toLowerCase();
    return signs.keys.where((s) => q.contains(s.toLowerCase())).toList();
  }

  /// Extract culture names from query
  static List<String> extractCultures(String query) {
    final q = query.toLowerCase();
    return cultures.keys.where((c) => q.contains(c.toLowerCase())).toList();
  }
}
