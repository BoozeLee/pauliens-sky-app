/// AI Orchestrator — routes between AETHER (local), Claude, and Gemini.
///
/// Priority:
///   1. Local AETHER model (llama.cpp) — if loaded
///   2. Anthropic Claude (if key present)
///   3. Google Gemini (if key present)
///   4. OpenAI GPT-4o-mini (if key present)
///   5. AETHER built-in astrology engine (always available)
///   6. Error state (no AI available)

import 'package:flutter/foundation.dart';
import '../services/ai_service.dart';
import '../services/local_llm/llama_service.dart';
import '../services/local_llm/penta_prompt.dart';
import '../services/local_llm/astro_rag.dart';
import '../services/local_llm/memory_journal.dart';
import '../services/premium_service.dart';
import '../services/chart_engine.dart';
import '../models/culture_chart.dart';
import '../services/aether/engine.dart';

enum AiProvider { local, claude, gemini, openai, aether, none }

class AiOrchestrator extends ChangeNotifier {
  static final AiOrchestrator instance = AiOrchestrator._();
  AiOrchestrator._();

  AiProvider _active = AiProvider.none;
  bool _localInitDone = false;

  AiProvider get activeProvider => _active;
  bool get hasLocal  => LlamaService.instance.isModelLoaded;
  bool get hasClaude => PremiumService.instance.hasAnthropicKey;
  bool get hasGemini => PremiumService.instance.hasGeminiKey;
  bool get hasOpenAi => PremiumService.instance.hasOpenAiKey;
  bool get hasProxy  => AiService.proxyUrl.isNotEmpty;
  bool get hasAether => true; // AETHER built-in engine is always available
  bool get hasAny    => hasLocal || hasClaude || hasGemini || hasOpenAi || hasProxy || hasAether;

  String get providerLabel => switch (_active) {
    AiProvider.local  => '⬡ AETHER (local)',
    AiProvider.claude => '✦ Claude',
    AiProvider.gemini => '✨ Gemini',
    AiProvider.openai => '⚡ GPT-4o-mini',
    AiProvider.aether => '◇ AETHER',
    AiProvider.none   => '○ No AI',
  };

  String get providerShort => switch (_active) {
    AiProvider.local  => 'AETHER',
    AiProvider.claude => 'Claude',
    AiProvider.gemini => 'Gemini',
    AiProvider.openai => 'OpenAI',
    AiProvider.aether => 'AETHER',
    AiProvider.none   => 'None',
  };

  /// Call once at startup to init local model if available.
  Future<void> init() async {
    if (_localInitDone) return;
    _localInitDone = true;

    final ok = await LlamaService.instance.init();
    if (ok) {
      final path = await LlamaService.defaultModelsPath();
      if (path.isNotEmpty) {
        final loaded = await LlamaService.instance.loadModel(path);
        if (loaded) {
          _active = AiProvider.local;
          notifyListeners();
          return;
        }
      }
    }

    _active = _bestCloudProvider();
    notifyListeners();
  }

  void refreshProvider() {
    if (hasLocal) {
      _active = AiProvider.local;
    } else {
      _active = _bestCloudProvider();
    }
    notifyListeners();
  }

  AiProvider _bestCloudProvider() {
    if (hasClaude) return AiProvider.claude;
    if (hasGemini) return AiProvider.gemini;
    if (hasOpenAi) return AiProvider.openai;
    if (hasProxy) return AiProvider.claude;
    return AiProvider.aether; // AETHER is always available
  }

  void forceProvider(AiProvider p) {
    _active = p;
    notifyListeners();
  }

  // ── Chat ─────────────────────────────────────────────────────────────────

  /// Stream tokens for a chat query.
  /// Uses penta-layer prompt for local model; passes directly for cloud.
  Stream<String> chatStream({
    required String userMessage,
    required FullChart chart,
    CultureId? activeCulture,
    List<AiMessage> history = const [],
  }) async* {
    switch (_active) {
      case AiProvider.local:
        yield* _localStream(
          userMessage: userMessage,
          chart: chart,
          activeCulture: activeCulture,
        );
        break;

      case AiProvider.claude:
      case AiProvider.gemini:
      case AiProvider.openai:
        final svc = PremiumService.instance.aiService;
        final response = await svc.chat(userMessage, chart, history);
        // Emit word-by-word for consistent streaming feel
        final words = response.split(' ');
        for (int i = 0; i < words.length; i++) {
          yield i == 0 ? words[i] : ' ${words[i]}';
          await Future.delayed(const Duration(milliseconds: 18));
        }
        break;

      case AiProvider.aether:
        yield* _aetherStream(
          userMessage: userMessage,
          chart: chart,
          activeCulture: activeCulture,
        );
        break;

      case AiProvider.none:
        yield 'No AI available. Add an API key in Settings or download a local model.';
    }
  }

  Stream<String> _localStream({
    required String userMessage,
    required FullChart chart,
    CultureId? activeCulture,
  }) async* {
    final rag     = AstroRag.instance.retrieve(userMessage);
    final memory  = await MemoryJournal.instance.recents(limit: 5);

    final prompt = PentaPrompt.build(
      chart: chart,
      userQuery: userMessage,
      ragPassages: rag,
      recentMemory: memory,
      activeCulture: activeCulture,
    );

    String fullResponse = '';
    await for (final tok in LlamaService.instance.infer(
      prompt,
      maxTokens: 400,
      temperature: 0.78,
      topP: 0.9,
    )) {
      yield tok;
      fullResponse += tok;
    }

    // Persist to memory journal
    if (fullResponse.trim().isNotEmpty) {
      await MemoryJournal.instance.append(
        fullResponse.trim(),
        culture: activeCulture?.name ?? 'western',
      );
    }
  }

  Stream<String> _aetherStream({
    required String userMessage,
    required FullChart chart,
    CultureId? activeCulture,
  }) async* {
    final response = await AetherEngine.instance.chat(
      userMessage,
      chart,
      activeCulture: activeCulture,
    );

    // Emit word-by-word for consistent streaming feel
    final words = response.split(' ');
    for (int i = 0; i < words.length; i++) {
      yield i == 0 ? words[i] : ' ${words[i]}';
      await Future.delayed(const Duration(milliseconds: 18));
    }
  }

  // ── One-shot readings ─────────────────────────────────────────────────────

  Future<String> interpretChart(FullChart chart,
      {CultureId? culture}) async {
    final prompt = _chartReadingQuery(chart, culture);
    return _inferSync(prompt, chart, culture);
  }

  Future<String> dailyReading(FullChart chart) async {
    return _inferSync(
      'Give me a personal daily astrological reading for today, '
      'based on current planetary energies and my natal chart.',
      chart, null,
    );
  }

  Future<String> _inferSync(
    String query, FullChart chart, CultureId? culture) async {
    switch (_active) {
      case AiProvider.local:
        final rag    = AstroRag.instance.retrieve(query);
        final memory = await MemoryJournal.instance.recents();
        final prompt = PentaPrompt.build(
          chart: chart,
          userQuery: query,
          ragPassages: rag,
          recentMemory: memory,
          activeCulture: culture,
        );
        final result = await LlamaService.instance.inferSync(prompt);
        if (result.isNotEmpty) {
          await MemoryJournal.instance.append(result,
              culture: culture?.name ?? 'western');
        }
        return result;

      case AiProvider.claude:
      case AiProvider.gemini:
      case AiProvider.openai:
        final svc = PremiumService.instance.aiService;
        if (culture != null) {
          return svc.cultureDeepDive(chart, culture.displayName);
        }
        return svc.interpretChart(chart);

      case AiProvider.aether:
        if (culture != null) {
          return await AetherEngine.instance.cultureDeepDive(chart, culture.displayName);
        }
        return await AetherEngine.instance.interpretChart(chart);

      case AiProvider.none:
        return 'No AI configured. Add an API key or download AETHER local model.';
    }
  }

  String _chartReadingQuery(FullChart chart, CultureId? culture) =>
      culture != null
          ? 'Give me a deep ${culture.displayName} astrological reading of my birth chart.'
          : 'Interpret my complete birth chart across all traditions.';
}
