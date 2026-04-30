import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/birth_context.dart';
import '../models/culture_chart.dart';
import '../services/chart_engine.dart';

enum AiProvider { anthropic, gemini }

class AiMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  const AiMessage({required this.role, required this.content});
  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class AiService {
  static const _anthropicBase = 'https://api.anthropic.com/v1';
  static const _geminiBase =
      'https://generativelanguage.googleapis.com/v1beta';
  static const _anthropicModel = 'claude-opus-4-7';
  static const _geminiModel = 'gemini-2.0-flash';

  final String? anthropicKey;
  final String? geminiKey;

  const AiService({this.anthropicKey, this.geminiKey});

  bool get hasAnthropic => anthropicKey != null && anthropicKey!.isNotEmpty;
  bool get hasGemini => geminiKey != null && geminiKey!.isNotEmpty;
  bool get hasAny => hasAnthropic || hasGemini;

  // ── System prompt shared by all astrology calls ──────────────────────────

  static String _systemPrompt(FullChart chart) {
    final ctx = chart.context;
    final western = chart.charts.firstOrNull;
    final chinese = chart.charts.where((c) => c.id.displayName == 'Chinese').firstOrNull;
    final mayan   = chart.charts.where((c) => c.id.displayName == 'Mayan').firstOrNull;
    final vedic   = chart.charts.where((c) => c.id.displayName == 'Vedic').firstOrNull;

    return '''You are a wise, warm astrologer who blends scholarly depth with accessible language.
You speak with poetic precision — never vague fortune-cookie platitudes.
You always ground interpretations in the actual planetary positions provided.

BIRTH DATA:
- Name: ${ctx.personName ?? 'the querent'}
- Date: ${ctx.utcTime.day}/${ctx.utcTime.month}/${ctx.utcTime.year}
- Location: ${ctx.locationName ?? 'unknown'}
- Birth time: ${chart.context.utcTime.hour == 11 && chart.context.utcTime.minute == 0 ? 'UNKNOWN — using synthetic noon; time-sensitive placements (Ascendant, Moon house) are approximate' : 'provided'}

PLANETARY POSITIONS (tropical ecliptic):
${chart.snapshot.positions.entries.map((e) => '- ${e.key.name}: ${e.value.eclipticLongitude.toStringAsFixed(1)}° (${e.value.signName})').join('\n')}
- Ascendant: ${chart.snapshot.ascendant.toStringAsFixed(1)}°
- Moon phase: ${chart.snapshot.moonPhaseName}

CULTURAL CHART SUMMARY:
- Western Sun: ${western?.sunSign ?? '?'}, Moon: ${western?.moonSign ?? '?'}
- Vedic Sun: ${vedic?.sunSign ?? '?'}
- Chinese: ${chinese?.sunSign ?? '?'}
- Mayan day sign: ${mayan?.sunSign ?? '?'}

Personality archetype: ${chart.personality.headline}

Rules:
- Be specific to these positions, never generic
- Max 3 short paragraphs unless asked for more
- If birth time is unknown, note that Ascendant/houses are approximate
- Tone: warm, insightful, never fatalistic
- This is a BETA app — remind user they can update their birth time in Settings for more accuracy''';
  }

  // ── Public API ────────────────────────────────────────────────────────────

  Future<String> interpretChart(FullChart chart, {AiProvider? prefer}) async {
    final prompt =
        'Give a rich, multi-cultural interpretation of this birth chart, '
        'weaving together the Western, Vedic, Chinese, and Mayan perspectives '
        'into a cohesive portrait. Highlight the most striking themes.';
    return _call(prompt, chart, prefer: prefer);
  }

  Future<String> dailyReading(FullChart chart, {AiProvider? prefer}) async {
    final now = DateTime.now();
    final prompt =
        'Today is ${now.day}/${now.month}/${now.year}. '
        'Give a concise daily reading (3–5 sentences) for this chart, '
        'connecting the current sky to the natal chart\'s key themes.';
    return _call(prompt, chart, prefer: prefer);
  }

  Future<String> cultureDeepDive(
      FullChart chart, String culture, {AiProvider? prefer}) async {
    final prompt =
        'Give a deep-dive interpretation of the $culture perspective for this chart. '
        'Include historical context of the $culture tradition, '
        'then apply it specifically to these birth positions.';
    return _call(prompt, chart, prefer: prefer);
  }

  Future<String> chat(
    String userMessage,
    FullChart chart,
    List<AiMessage> history, {
    AiProvider? prefer,
  }) async {
    return _callWithHistory(userMessage, chart, history, prefer: prefer);
  }

  Future<String> syntheticPersonality(FullChart chart, {AiProvider? prefer}) async {
    final prompt =
        'Write a 2-paragraph personality portrait for ${chart.context.personName ?? "this person"} '
        'based on all the astrological traditions in their chart. '
        'Be specific, warm, and insightful. Reference concrete placements.';
    return _call(prompt, chart, prefer: prefer);
  }

  // ── Internal routing ──────────────────────────────────────────────────────

  Future<String> _call(
    String prompt,
    FullChart chart, {
    AiProvider? prefer,
    List<AiMessage>? history,
  }) async {
    final provider = _pickProvider(prefer);
    if (provider == null) throw Exception('No AI API key configured');

    final system = _systemPrompt(chart);
    final messages = [
      ...?history,
      AiMessage(role: 'user', content: prompt),
    ];

    return provider == AiProvider.anthropic
        ? _callAnthropic(system, messages)
        : _callGemini(system, messages);
  }

  Future<String> _callWithHistory(
    String userMessage,
    FullChart chart,
    List<AiMessage> history, {
    AiProvider? prefer,
  }) => _call(userMessage, chart, prefer: prefer, history: history);

  AiProvider? _pickProvider(AiProvider? prefer) {
    if (prefer == AiProvider.anthropic && hasAnthropic) return AiProvider.anthropic;
    if (prefer == AiProvider.gemini && hasGemini) return AiProvider.gemini;
    if (hasAnthropic) return AiProvider.anthropic;
    if (hasGemini) return AiProvider.gemini;
    return null;
  }

  // ── Anthropic Claude ──────────────────────────────────────────────────────

  Future<String> _callAnthropic(
      String system, List<AiMessage> messages) async {
    final response = await http.post(
      Uri.parse('$_anthropicBase/messages'),
      headers: {
        'x-api-key': anthropicKey!,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': _anthropicModel,
        'max_tokens': 1024,
        'system': system,
        'messages': messages.map((m) => m.toJson()).toList(),
      }),
    );

    if (response.statusCode != 200) {
      final err = jsonDecode(response.body);
      throw Exception('Anthropic error: ${err['error']?['message'] ?? response.statusCode}');
    }
    final data = jsonDecode(response.body);
    return data['content'][0]['text'] as String;
  }

  // ── Google Gemini ─────────────────────────────────────────────────────────

  Future<String> _callGemini(String system, List<AiMessage> messages) async {
    // Convert history to Gemini format
    final contents = <Map<String, dynamic>>[];

    // Gemini uses 'model' for assistant, 'user' for user
    // Prefix system prompt into first user turn
    final firstUserIdx = messages.indexWhere((m) => m.role == 'user');
    for (int i = 0; i < messages.length; i++) {
      final m = messages[i];
      String text = m.content;
      if (i == firstUserIdx) text = '$system\n\n$text';
      contents.add({
        'role': m.role == 'assistant' ? 'model' : 'user',
        'parts': [{'text': text}],
      });
    }

    final response = await http.post(
      Uri.parse(
          '$_geminiBase/models/$_geminiModel:generateContent?key=$geminiKey'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'contents': contents,
        'generationConfig': {
          'maxOutputTokens': 1024,
          'temperature': 0.85,
        },
      }),
    );

    if (response.statusCode != 200) {
      final err = jsonDecode(response.body);
      throw Exception(
          'Gemini error: ${err['error']?['message'] ?? response.statusCode}');
    }
    final data = jsonDecode(response.body);
    return data['candidates'][0]['content']['parts'][0]['text'] as String;
  }
}
