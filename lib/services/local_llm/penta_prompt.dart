/// AETHER Penta-Layer System Prompt
///
/// Five concentric layers of context, innermost injected last:
///   1. COSMOS     — raw astronomical facts (ephemeris)
///   2. TRADITION  — active culture's symbolic vocabulary
///   3. PERSONA    — birth chart identity + personality profile
///   4. PSYCHE     — session memory + RAG knowledge passages
///   5. ORACLE     — response style and format contract
///
/// This architecture ensures the model never hallucinates planetary
/// positions — they are hard-coded into the prompt frame.

import '../../models/culture_chart.dart';
import '../../services/chart_engine.dart';
import 'memory_journal.dart';

import '../../models/astro_snapshot.dart';
class PentaPrompt {
  static String build({
    required FullChart chart,
    required String userQuery,
    List<String> ragPassages = const [],
    List<MemoryEntry> recentMemory = const [],
    CultureId? activeCulture,
    String? sessionContext,
  }) {
    final buf = StringBuffer();

    buf.writeln(_cosmos(chart));
    buf.writeln();
    buf.writeln(_tradition(chart, activeCulture));
    buf.writeln();
    buf.writeln(_persona(chart));
    buf.writeln();
    buf.writeln(_psyche(ragPassages, recentMemory, sessionContext));
    buf.writeln();
    buf.writeln(_oracle());
    buf.writeln();
    buf.writeln('USER: $userQuery');
    buf.writeln('AETHER:');

    return buf.toString();
  }

  // ── Layer 1: COSMOS ────────────────────────────────────────────────────────

  static String _cosmos(FullChart chart) {
    final snap = chart.snapshot;
    final pos  = snap.positions;
    final buf  = StringBuffer();

    buf.writeln('=== COSMOS: BIRTH SKY (VSOP87 ephemeris) ===');

    for (final entry in pos.entries) {
      final p   = entry.value;
      final lon = p.eclipticLongitude.toStringAsFixed(2);
      buf.writeln(
          '  ${_planetSym(entry.key)} ${entry.key.name.toUpperCase()}: '
          '${p.signName} ${p.degreeInSign.toStringAsFixed(1)}°  (λ=${lon}°)');
    }

    final sidereal = snap.siderealOffset;
    buf.writeln('  AYANAMSHA (Lahiri): ${sidereal.toStringAsFixed(2)}°');
    buf.writeln('  ASCENDANT: ${snap.ascendant.toStringAsFixed(2)}°');
    buf.writeln('  MIDHEAVEN: ${snap.midheaven.toStringAsFixed(2)}°');
    buf.writeln('  LUNAR PHASE: ${snap.moonPhaseName} '
        '(${snap.lunarPhase.toStringAsFixed(1)}°)');

    // Fixed stars present at birth
    if (chart.prominentStars.isNotEmpty) {
      buf.writeln('  PROMINENT FIXED STARS:');
      for (final (star, orb) in chart.prominentStars.take(4)) {
        buf.writeln('    ${star.name} (${star.constellation}) '
            'orb ${orb.toStringAsFixed(1)}° — ${star.keywords}');
      }
    }

    return buf.toString();
  }

  // ── Layer 2: TRADITION ─────────────────────────────────────────────────────

  static String _tradition(FullChart chart, CultureId? active) {
    final culture = active ?? CultureId.western;
    final cc = chart.chart(culture);
    final buf = StringBuffer();

    buf.writeln('=== TRADITION: ${culture.displayName.toUpperCase()} ===');

    if (cc != null) {
      if (cc.sunSign != null)
        buf.writeln("  Sun sign: ${cc.sunSign}");
      if (cc.moonSign != null)
        buf.writeln("  Moon sign: ${cc.moonSign}");
      if (cc.ascendantSign != null)
        buf.writeln("  Rising/Ascendant: ${cc.ascendantSign}");
      if (cc.entries.isNotEmpty && cc.entries.first.description != null && cc.entries.first.description!.isNotEmpty)
        buf.writeln("  Core reading: ${cc.entries.first.description}");

      for (final insight in cc.keyInsights.take(3)) {
        buf.writeln("  • $insight");
      }
    }

    buf.writeln(_traditionVocab(culture));
    return buf.toString();
  }

  static String _traditionVocab(CultureId id) => switch (id) {
    CultureId.western =>
        '  [Vocabulary: signs, houses, aspects, transits, natal/synastry]',
    CultureId.vedic =>
        '  [Vocabulary: rashi, nakshatra, lagna, dasha, yoga, graha, bhava]',
    CultureId.chinese =>
        '  [Vocabulary: heavenly stems, earthly branches, five elements, '
        'yin/yang, ba zi, day master, luck pillars]',
    CultureId.mayan =>
        '  [Vocabulary: tzolk\'in, day sign, galactic tone, haab, '
        'uinal, kin, trecena]',
    CultureId.egyptian =>
        '  [Vocabulary: decans, decan rulers, 36 faces, Nut\'s body, '
        'rising decan, heliacal star]',
    CultureId.celtic =>
        '  [Vocabulary: tree signs, ogham, lunar months, animal totems, '
        'sacred groves, Druidic seasons]',
    _ => '',
  };

  // ── Layer 3: PERSONA ───────────────────────────────────────────────────────

  static String _persona(FullChart chart) {
    final ctx = chart.context;
    final p   = chart.personality;
    final buf = StringBuffer();

    buf.writeln('=== PERSONA: BIRTH CHART IDENTITY ===');
    buf.writeln('  Name: ${ctx.personName ?? 'querent'}');
    buf.writeln('  Born: ${ctx.utcTime.day} '
        '${_monthName(ctx.utcTime.month)} ${ctx.utcTime.year}');
    buf.writeln('  Place: ${ctx.locationName ?? 'unknown'} '
        '(${ctx.latitude.toStringAsFixed(2)}°N '
        '${ctx.longitude.toStringAsFixed(2)}°E)');
    buf.writeln('  Headline: ${p.headline}');
    buf.writeln('  Summary: ${p.summary}');
    buf.writeln('  Core traits: ${p.coreTraits.join(', ')}');
    buf.writeln('  Radar scores — '
        'Intuition:${(p.intuition * 10).round()} '
        'Creativity:${(p.creativity * 10).round()} '
        'Intellect:${(p.intellect * 10).round()} '
        'Drive:${(p.drive * 10).round()} '
        'Empathy:${(p.empathy * 10).round()} '
        'Independence:${(p.independence * 10).round()}');

    return buf.toString();
  }

  // ── Layer 4: PSYCHE ────────────────────────────────────────────────────────

  static String _psyche(
    List<String> ragPassages,
    List<MemoryEntry> memory,
    String? sessionContext,
  ) {
    final buf = StringBuffer();
    buf.writeln('=== PSYCHE: KNOWLEDGE & MEMORY ===');

    if (ragPassages.isNotEmpty) {
      buf.writeln('  [Relevant classical texts retrieved]:');
      for (int i = 0; i < ragPassages.length; i++) {
        buf.writeln('  [${i + 1}] ${ragPassages[i]}');
      }
    }

    if (memory.isNotEmpty) {
      buf.writeln('  [Prior readings this session]:');
      for (final m in memory.take(5)) {
        buf.writeln('  [${m.date}] ${m.summary}');
      }
    }

    if (sessionContext != null && sessionContext.isNotEmpty) {
      buf.writeln('  [Session context]: $sessionContext');
    }

    return buf.toString();
  }

  // ── Layer 5: ORACLE ────────────────────────────────────────────────────────

  static String _oracle() => '''=== ORACLE: RESPONSE CONTRACT ===
You are AETHER, the stellar intelligence within Paulien\'s Sky.
You speak as a wise, poetic astrologer who has studied all six traditions.

RULES:
- Ground every statement in the COSMOS layer above. Never invent positions.
- Reference the active TRADITION\'s vocabulary naturally.
- Speak to the PERSONA\'s name and chart directly.
- Be poetic but precise. Never vague. Metaphor must illuminate, not obscure.
- Response length: 3–5 sentences for readings, conversational for chat.
- Never say "as an AI" or "I cannot" — you ARE the stellar oracle.
- If asked about a planet not in COSMOS, say it was not prominent at birth.''';

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _planetSym(Planet p) => const {
    Planet.sun: '☉', Planet.moon: '☽', Planet.mercury: '☿',
    Planet.venus: '♀', Planet.mars: '♂', Planet.jupiter: '♃',
    Planet.saturn: '♄', Planet.uranus: '⛢', Planet.neptune: '♆',
    Planet.pluto: '♇',
  }[p] ?? '·';

  static String _monthName(int m) => const [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ][m];
}
