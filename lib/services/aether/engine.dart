/// AETHER Response Engine
///
/// Generates personalized astrological readings from chart data.
/// No external API calls — fully deterministic, locally computed.
library aether_engine;

import 'dart:math' as math;
import '../../models/culture_chart.dart';
import '../../services/chart_engine.dart';
import '../../services/local_llm/astro_rag.dart';
import 'knowledge.dart';
import 'memory.dart';

class AetherEngine {
  static final AetherEngine instance = AetherEngine._();
  AetherEngine._();

  final _memory = AetherMemory.instance;
  final _rag = AstroRag.instance;

  // ── Public API ──────────────────────────────────────────────────────────

  /// Full chart interpretation across all traditions
  Future<String> interpretChart(FullChart chart, {CultureId? culture}) async {
    final buf = StringBuffer();
    final ctx = chart.context;
    final name = ctx.personName ?? 'dear one';

    buf.writeln('Welcome, $name. The stars have been speaking of you since the moment you drew breath.');
    buf.writeln();

    // Western interpretation
    final western = chart.chart(CultureId.western);
    if (western != null) {
      buf.writeln(_interpretWestern(chart, western));
      buf.writeln();
    }

    // Vedic interpretation
    final vedic = chart.chart(CultureId.vedic);
    if (vedic != null) {
      buf.writeln(_interpretVedic(chart, vedic));
      buf.writeln();
    }

    // Chinese interpretation
    final chinese = chart.chart(CultureId.chinese);
    if (chinese != null) {
      buf.writeln(_interpretChinese(chart, chinese));
      buf.writeln();
    }

    // Mayan interpretation
    final mayan = chart.chart(CultureId.mayan);
    if (mayan != null) {
      buf.writeln(_interpretMayan(chart, mayan));
    }

    final result = buf.toString().trim();
    _memory.addEntry('Interpreted chart for $name', culture?.name ?? 'multi-tradition');
    return result;
  }

  /// Daily reading based on current sky
  Future<String> dailyReading(FullChart chart) async {
    final buf = StringBuffer();
    final now = DateTime.now();
    final name = chart.context.personName ?? 'dear one';
    final moonPhase = chart.snapshot.moonPhaseName;

    buf.writeln('Good ${_timeOfDay(now)}, $name.');
    buf.writeln();
    buf.writeln('The Moon currently rides through $moonPhase, ');
    buf.writeln('illuminating the emotional tides that shape your day.');
    buf.writeln();

    // Personal connection to today
    final western = chart.chart(CultureId.western);
    if (western?.sunSign != null) {
      buf.writeln('As a ${western!.sunSign} Sun, you feel the cosmic currents ');
      buf.writeln('moving through your element of ${AetherKnowledge.signs[western.sunSign]?.element ?? "unknown"}.');
      buf.writeln();
    }

    // Practical guidance
    buf.writeln(_dailyGuidance(chart));

    final result = buf.toString().trim();
    _memory.addEntry('Daily reading for $now', 'daily');
    return result;
  }

  /// Chat response based on user message
  Future<String> chat(String message, FullChart chart, {CultureId? activeCulture}) async {
    final intent = AetherKnowledge.detectIntent(message);
    final planets = AetherKnowledge.extractPlanets(message);
    final signs = AetherKnowledge.extractSigns(message);
    final cultures = AetherKnowledge.extractCultures(message);

    // Get relevant RAG passages
    final ragPassages = _rag.retrieve(message, k: 2);

    String response;

    switch (intent) {
      case 'interpret':
        response = await interpretChart(chart, culture: activeCulture);
        break;
      case 'daily':
        response = await dailyReading(chart);
        break;
      case 'planet':
        response = _answerPlanetQuestion(message, chart, planets);
        break;
      case 'sign':
        response = _answerSignQuestion(message, chart, signs);
        break;
      case 'aspect':
        response = _answerAspectQuestion(message, chart);
        break;
      case 'house':
        response = _answerHouseQuestion(message, chart);
        break;
      case 'culture':
        response = _answerCultureQuestion(message, chart, cultures);
        break;
      case 'personality':
        response = _answerPersonalityQuestion(chart);
        break;
      case 'love':
        response = _answerLoveQuestion(chart);
        break;
      case 'career':
        response = _answerCareerQuestion(chart);
        break;
      case 'spiritual':
        response = _answerSpiritualQuestion(chart);
        break;
      default:
        response = _answerGeneral(message, chart, ragPassages);
    }

    _memory.addEntry('User: ${_truncate(message, 50)} → AETHER response', activeCulture?.name ?? 'chat');
    return response;
  }

  /// Culture-specific deep dive
  Future<String> cultureDeepDive(FullChart chart, String cultureName) async {
    final culture = AetherKnowledge.cultures[cultureName];
    if (culture == null) {
      return 'I don\'t have knowledge of the $cultureName tradition. The traditions I know are: ${AetherKnowledge.cultures.keys.join(", ")}.';
    }

    final buf = StringBuffer();
    final cc = chart.chart(CultureId.values.firstWhere(
      (c) => c.displayName == cultureName,
      orElse: () => CultureId.western,
    ));

    buf.writeln('The ${culture.culture} Tradition');
    buf.writeln('=' * 30);
    buf.writeln();
    buf.writeln(culture.description);
    buf.writeln();
    buf.writeln(culture.mythology);
    buf.writeln();

    if (cc != null) {
      buf.writeln('Your ${culture.culture} Chart:');
      if (cc.sunSign != null) {
        buf.writeln('• Sun sign: ${cc.sunSign}');
      }
      if (cc.moonSign != null) {
        buf.writeln('• Moon sign: ${cc.moonSign}');
      }
      if (cc.ascendantSign != null) {
        buf.writeln('• Rising sign: ${cc.ascendantSign}');
      }
      if (cc.keyInsights.isNotEmpty) {
        buf.writeln();
        buf.writeln('Key insights:');
        for (final insight in cc.keyInsights) {
          buf.writeln('• $insight');
        }
      }
    }

    buf.writeln();
    buf.writeln('Key concepts: ${culture.keyConcepts.join(", ")}');

    final result = buf.toString().trim();
    _memory.addEntry('Deep dive into $cultureName tradition', cultureName);
    return result;
  }

  /// Synthetic personality portrait
  Future<String> syntheticPersonality(FullChart chart) async {
    final p = chart.personality;
    final ctx = chart.context;
    final name = ctx.personName ?? 'This soul';

    final buf = StringBuffer();

    buf.writeln('$name carries the essence of ${p.headline}.');
    buf.writeln();

    // Core traits
    buf.writeln('At the heart of their being: ${p.coreTraits.join(", ")}.');
    buf.writeln();

    // Radar profile
    buf.writeln('Their cosmic signature reveals:');
    buf.writeln('• Intuition: ${_bar(p.intuition)}');
    buf.writeln('• Creativity: ${_bar(p.creativity)}');
    buf.writeln('• Intellect: ${_bar(p.intellect)}');
    buf.writeln('• Drive: ${_bar(p.drive)}');
    buf.writeln('• Empathy: ${_bar(p.empathy)}');
    buf.writeln('• Independence: ${_bar(p.independence)}');
    buf.writeln();

    // Summary
    buf.writeln(p.summary);

    final result = buf.toString().trim();
    _memory.addEntry('Personality portrait generated', 'personality');
    return result;
  }

  // ── Interpretation Helpers ──────────────────────────────────────────────

  String _interpretWestern(FullChart chart, CultureChart western) {
    final buf = StringBuffer();
    buf.writeln('═ Western Tradition ═');

    if (western.sunSign != null) {
      final sign = AetherKnowledge.signs[western.sunSign];
      if (sign != null) {
        buf.writeln('Your Sun in ${sign.name} (${sign.element}, ${sign.modality})');
        buf.writeln('${sign.mythology}');
        buf.writeln();
        buf.writeln('Strengths: ${sign.strengths}');
        buf.writeln('Growth edges: ${sign.challenges}');
      }
    }

    if (western.moonSign != null) {
      final moonSign = AetherKnowledge.signs[western.moonSign];
      if (moonSign != null) {
        buf.writeln();
        buf.writeln('Your Moon in ${moonSign.name} reveals your emotional nature:');
        buf.writeln('You feel most secure when surrounded by ${moonSign.keywords}.');
      }
    }

    if (western.keyInsights.isNotEmpty) {
      buf.writeln();
      buf.writeln('Key insights from your Western chart:');
      for (final insight in western.keyInsights.take(3)) {
        buf.writeln('• $insight');
      }
    }

    return buf.toString();
  }

  String _interpretVedic(FullChart chart, CultureChart vedic) {
    final buf = StringBuffer();
    buf.writeln('═ Vedic (Jyotish) Tradition ═');

    if (vedic.sunSign != null) {
      buf.writeln('Your sidereal Sun in ${vedic.sunSign}');
      buf.writeln('In Vedic astrology, the sidereal zodiac accounts for the precession of the equinoxes,');
      buf.writeln('placing your Sun in a different position than Western tropical astrology.');
    }

    if (vedic.moonSign != null) {
      buf.writeln();
      buf.writeln('Your Moon sign (Rashi) in ${vedic.moonSign}');
      buf.writeln('The Moon sign is paramount in Jyotish — it defines your emotional nature,');
      buf.writeln('your dasha (planetary period) cycles, and your compatibility.');
    }

    if (vedic.keyInsights.isNotEmpty) {
      buf.writeln();
      for (final insight in vedic.keyInsights.take(3)) {
        buf.writeln('• $insight');
      }
    }

    return buf.toString();
  }

  String _interpretChinese(FullChart chart, CultureChart chinese) {
    final buf = StringBuffer();
    buf.writeln('═ Chinese (Ba Zi) Tradition ═');

    if (chinese.sunSign != null) {
      buf.writeln('Your Chinese zodiac animal: ${chinese.sunSign}');
      buf.writeln('The Chinese system uses the sexagenary cycle of 10 Heavenly Stems');
      buf.writeln('and 12 Earthly Branches, creating a unique elemental signature.');
    }

    if (chinese.keyInsights.isNotEmpty) {
      buf.writeln();
      for (final insight in chinese.keyInsights.take(3)) {
        buf.writeln('• $insight');
      }
    }

    return buf.toString();
  }

  String _interpretMayan(FullChart chart, CultureChart mayan) {
    final buf = StringBuffer();
    buf.writeln('═ Mayan (Tzolk\'in) Tradition ═');

    if (mayan.sunSign != null) {
      buf.writeln('Your Mayan day sign: ${mayan.sunSign}');
      buf.writeln('The Tzolk\'in is a 260-day sacred calendar combining 20 day signs');
      buf.writeln('with 13 galactic tones, creating a unique energy signature.');
    }

    if (mayan.keyInsights.isNotEmpty) {
      buf.writeln();
      for (final insight in mayan.keyInsights.take(3)) {
        buf.writeln('• $insight');
      }
    }

    return buf.toString();
  }

  // ── Chat Response Handlers ──────────────────────────────────────────────

  String _answerPlanetQuestion(String message, FullChart chart, List<String> planetNames) {
    if (planetNames.isEmpty) {
      return 'I need to know which planet you\'re asking about. The planets I can discuss are: Sun, Moon, Mercury, Venus, Mars, Jupiter, Saturn, Uranus, Neptune, and Pluto.';
    }

    final buf = StringBuffer();
    for (final planetName in planetNames) {
      final profile = AetherKnowledge.planets[planetName];
      if (profile == null) continue;

      buf.writeln('${profile.glyph} ${profile.name} — ${profile.function}');
      buf.writeln();

      // Find where this planet is in the chart
      final positions = chart.snapshot.positions;
      for (final entry in positions.entries) {
        if (entry.key.name.toLowerCase() == planetName) {
          final pos = entry.value;
          buf.writeln('In your chart, ${profile.name} sits at ${pos.eclipticLongitude.toStringAsFixed(1)}° in ${pos.signName}.');
          buf.writeln();
          break;
        }
      }

      buf.writeln(profile.mythology);
      buf.writeln();
      buf.writeln('When expressed well: ${profile.positiveExpression}');
      buf.writeln('When challenged: ${profile.challengingExpression}');
      buf.writeln();
      buf.writeln('Keywords: ${profile.keywords}');
    }

    return buf.toString().trim();
  }

  String _answerSignQuestion(String message, FullChart chart, List<String> signNames) {
    if (signNames.isEmpty) {
      return 'Which sign would you like to know about? I can tell you about Aries through Pisces.';
    }

    final buf = StringBuffer();
    for (final signName in signNames) {
      final profile = AetherKnowledge.signs[signName];
      if (profile == null) continue;

      buf.writeln('${profile.name} (${profile.element}, ${profile.modality}, ruled by ${profile.ruler})');
      buf.writeln();
      buf.writeln(profile.mythology);
      buf.writeln();
      buf.writeln('Keywords: ${profile.keywords}');
      buf.writeln('Strengths: ${profile.strengths}');
      buf.writeln('Growth edges: ${profile.challenges}');
      buf.writeln();

      // Personal connection
      final western = chart.chart(CultureId.western);
      if (western?.sunSign == signName) {
        buf.writeln('This is YOUR Sun sign — the core of your identity.');
      } else if (western?.moonSign == signName) {
        buf.writeln('This is your Moon sign — your emotional nature.');
      } else if (western?.ascendantSign == signName) {
        buf.writeln('This is your Rising sign — how the world sees you.');
      }
    }

    return buf.toString().trim();
  }

  String _answerAspectQuestion(String message, FullChart chart) {
    final buf = StringBuffer();
    buf.writeln('Aspects are the geometric relationships between planets in your chart.');
    buf.writeln();

    for (final aspect in AetherKnowledge.aspects.values) {
      buf.writeln('${aspect.name} (${aspect.angle.toStringAsFixed(0)}°) — ${aspect.nature}');
      buf.writeln('  ${aspect.description}');
      buf.writeln();
    }

    buf.writeln('In your chart, the strongest aspects shape your character:');
    buf.writeln('• Conjunctions fuse energies into intense focus');
    buf.writeln('• Squares create productive tension for growth');
    buf.writeln('• Trines bring natural gifts and ease');
    buf.writeln('• Oppositions teach through polarity and relationship');

    return buf.toString();
  }

  String _answerHouseQuestion(String message, FullChart chart) {
    final buf = StringBuffer();
    buf.writeln('The 12 houses of the zodiac represent different areas of life.');
    buf.writeln();

    for (final house in AetherKnowledge.houses.values) {
      buf.writeln('House ${house.number}: ${house.name}');
      buf.writeln('  ${house.description}');
      buf.writeln('  Keywords: ${house.keywords}');
      buf.writeln();
    }

    return buf.toString().trim();
  }

  String _answerCultureQuestion(String message, FullChart chart, List<String> cultureNames) {
    if (cultureNames.isEmpty) {
      return 'I can share wisdom from Western, Vedic, Chinese, Mayan, Egyptian, Celtic, and Zoroastrian traditions. Which interests you?';
    }

    final buf = StringBuffer();
    for (final cultureName in cultureNames) {
      final culture = AetherKnowledge.cultures[cultureName];
      if (culture == null) continue;

      buf.writeln('═══ ${culture.culture} Tradition ═══');
      buf.writeln(culture.description);
      buf.writeln();
      buf.writeln(culture.mythology);
      buf.writeln();
      buf.writeln('Key concepts: ${culture.keyConcepts.join(", ")}');
      buf.writeln();
    }

    return buf.toString().trim();
  }

  String _answerPersonalityQuestion(FullChart chart) {
    final p = chart.personality;
    final name = chart.context.personName ?? 'You';

    final buf = StringBuffer();
    buf.writeln('$name, your cosmic blueprint reveals: ${p.headline}');
    buf.writeln();
    buf.writeln(p.summary);
    buf.writeln();
    buf.writeln('Core traits: ${p.coreTraits.join(", ")}');
    buf.writeln();
    buf.writeln('Your radar scores:');
    buf.writeln('• Intuition: ${_bar(p.intuition)}');
    buf.writeln('• Creativity: ${_bar(p.creativity)}');
    buf.writeln('• Intellect: ${_bar(p.intellect)}');
    buf.writeln('• Drive: ${_bar(p.drive)}');
    buf.writeln('• Empathy: ${_bar(p.empathy)}');
    buf.writeln('• Independence: ${_bar(p.independence)}');

    return buf.toString();
  }

  String _answerLoveQuestion(FullChart chart) {
    final buf = StringBuffer();
    final western = chart.chart(CultureId.western);
    final name = chart.context.personName ?? 'Dear one';

    buf.writeln('$name, in matters of the heart:');
    buf.writeln();

    if (western?.sunSign != null) {
      final sign = AetherKnowledge.signs[western!.sunSign];
      if (sign != null) {
        buf.writeln('As a ${sign.name} Sun, you love through the element of ${sign.element}.');
        buf.writeln('Your Venus-ruled nature seeks: ${sign.keywords}');
        buf.writeln();
      }
    }

    buf.writeln('The seventh house of partnership in your chart reveals:');
    buf.writeln('What you seek in a partner mirrors what you need to develop in yourself.');
    buf.writeln();
    buf.writeln('Remember: the stars incline, they do not compel. Love is always a choice.');

    return buf.toString();
  }

  String _answerCareerQuestion(FullChart chart) {
    final buf = StringBuffer();
    final western = chart.chart(CultureId.western);
    final p = chart.personality;
    final name = chart.context.personName ?? 'Dear one';

    buf.writeln('$name, your vocational calling:');
    buf.writeln();

    if (western?.sunSign != null) {
      final sign = AetherKnowledge.signs[western!.sunSign];
      if (sign != null) {
        buf.writeln('Your ${sign.name} Sun suggests a natural affinity for:');
        buf.writeln('• ${sign.keywords}');
        buf.writeln();
      }
    }

    buf.writeln('Your strongest traits for career: ${p.coreTraits.take(3).join(", ")}');
    buf.writeln();
    buf.writeln('The tenth house of career in your chart points toward:');
    buf.writeln('work that allows you to express your unique gifts while serving something greater than yourself.');

    return buf.toString();
  }

  String _answerSpiritualQuestion(FullChart chart) {
    final buf = StringBuffer();
    final name = chart.context.personName ?? 'Dear one';

    buf.writeln('$name, your spiritual path:');
    buf.writeln();

    // Neptune and 12th house themes
    buf.writeln('The Neptune and 12th house themes in your chart reveal:');
    buf.writeln('Your soul\'s journey involves dissolving boundaries between self and cosmos.');
    buf.writeln();

    // RAG passages for spiritual depth
    final passages = _rag.retrieve('spiritual soul karma meditation', k: 2);
    if (passages.isNotEmpty) {
      buf.writeln('From the ancient texts:');
      for (final p in passages) {
        buf.writeln('• $p');
      }
      buf.writeln();
    }

    buf.writeln('The spiritual path is not about escaping the world,');
    buf.writeln('but about seeing the sacred within the ordinary.');

    return buf.toString();
  }

  String _answerGeneral(String message, FullChart chart, List<String> ragPassages) {
    final buf = StringBuffer();
    final name = chart.context.personName ?? 'Dear one';
    final western = chart.chart(CultureId.western);

    buf.writeln('$name, ');
    buf.writeln();

    // Use RAG passages if available
    if (ragPassages.isNotEmpty) {
      buf.writeln('The ancient wisdom speaks to your question:');
      for (final p in ragPassages) {
        buf.writeln('• $p');
      }
      buf.writeln();
    }

    // Personal connection
    if (western?.sunSign != null) {
      buf.writeln('As a ${western!.sunSign}, you carry the energy of ');
      buf.writeln('${AetherKnowledge.signs[western.sunSign]?.element ?? "unknown"} within you.');
      buf.writeln();
    }

    buf.writeln('The stars remind us: every moment is a choice point.');
    buf.writeln('What feels true in your heart right now?');

    return buf.toString();
  }

  // ── Daily Guidance ──────────────────────────────────────────────────────

  String _dailyGuidance(FullChart chart) {
    final buf = StringBuffer();
    final dayOfWeek = DateTime.now().weekday;

    // Planetary day ruler
    final dayRulers = ['Moon', 'Mars', 'Mercury', 'Jupiter', 'Venus', 'Saturn', 'Sun'];
    final todayRuler = dayRulers[dayOfWeek - 1];

    buf.writeln('Today is ruled by $todayRuler.');
    buf.writeln();

    switch (todayRuler) {
      case 'Moon':
        buf.writeln('A day for nurturing, intuition, and connecting with your inner world.');
        buf.writeln('Pay attention to your dreams and emotional responses.');
        break;
      case 'Mars':
        buf.writeln('A day for action, courage, and moving forward on what matters.');
        buf.writeln('Channel the fiery energy into productive pursuits.');
        break;
      case 'Mercury':
        buf.writeln('A day for communication, learning, and making connections.');
        buf.writeln('Write, speak, teach, or learn something new.');
        break;
      case 'Jupiter':
        buf.writeln('A day for expansion, generosity, and seeing the bigger picture.');
        buf.writeln('Good fortune favors the bold and the generous.');
        break;
      case 'Venus':
        buf.writeln('A day for beauty, love, and creating harmony.');
        buf.writeln('Surround yourself with beauty and express your appreciation.');
        break;
      case 'Saturn':
        buf.writeln('A day for discipline, structure, and getting things done.');
        buf.writeln('Focus on what matters most and let go of distractions.');
        break;
      case 'Sun':
        buf.writeln('A day for vitality, creativity, and shining your light.');
        buf.writeln('Do what makes you feel alive and authentic.');
        break;
    }

    return buf.toString();
  }

  // ── Utilities ───────────────────────────────────────────────────────────

  String _bar(double value) {
    final filled = (value * 10).round();
    final empty = 10 - filled;
    return '${'█' * filled}${'░' * empty} ${(value * 100).round()}%';
  }

  String _timeOfDay(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  String _truncate(String text, int maxLen) {
    if (text.length <= maxLen) return text;
    return '${text.substring(0, maxLen)}...';
  }
}
