import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../services/premium_service.dart';
import '../services/supabase_service.dart';
import '../state/app_state.dart';
import '../theme/cosmic_theme.dart';
import '../widgets/sky_background.dart';
import 'art_generating_screen.dart';

class CosmicScrollbar extends StatelessWidget {
  final Widget child;
  final ScrollController controller;

  const CosmicScrollbar({required this.child, required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: controller,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      thickness: 12.0,
      child: child,
    );
  }
}

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> with TickerProviderStateMixin {
  late TabController _tabs;
  final _chatCtrl = TextEditingController();
  final _scrollCtrl1 = ScrollController();
  final _scrollCtrl2 = ScrollController();
  final _scrollCtrl3 = ScrollController();
  final List<_ChatBubble> _messages = [];
  bool _thinking = false;
  AiProvider _provider = AiProvider.anthropic;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _provider = PremiumService.instance.hasAnthropicKey
        ? AiProvider.anthropic
        : AiProvider.openai;
  }

  @override
  void dispose() {
    _tabs.dispose();
    _chatCtrl.dispose();
    _scrollCtrl1.dispose();
    _scrollCtrl2.dispose();
    _scrollCtrl3.dispose();
    // No _scrollCtrl4 needed for Art tab yet
    super.dispose();
  }

  Future<void> _sendQuickAction(String type) async {
    final state = context.read<AppState>();
    final premium = PremiumService.instance;
    if (!premium.hasAnyKey && !AiService.hasServerProxy) {
      _showNoKeySheet();
      return;
    }

    final allowed = await premium.consumeAiCall();
    if (!allowed) {
      _showQuotaSheet();
      return;
    }

    setState(() => _thinking = true);
    try {
      final ai = premium.aiService;
      String result;
      switch (type) {
        case 'interpret':
          result = await ai.interpretChart(state.chart!, prefer: _provider);
        case 'daily':
          result = await ai.dailyReading(state.chart!, prefer: _provider);
        case 'personality':
          result =
              await ai.syntheticPersonality(state.chart!, prefer: _provider);
        default:
          result = '';
      }
      setState(() {
        _messages.add(_ChatBubble(role: 'assistant', text: result));
        _thinking = false;
      });
      await SupabaseService.instance.saveAiMessage(
        conversationId: 'quick-$type',
        role: 'assistant',
        content: result,
        metadata: {'type': type, 'provider': _provider.name},
      );
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(_ChatBubble(role: 'error', text: e.toString()));
        _thinking = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _chatCtrl.text.trim();
    if (text.isEmpty) return;

    final premium = PremiumService.instance;
    if (!premium.hasAnyKey && !AiService.hasServerProxy) {
      _showNoKeySheet();
      return;
    }
    final allowed = await premium.consumeAiCall();
    if (!mounted) return;
    if (!allowed) {
      _showQuotaSheet();
      return;
    }

    final state = context.read<AppState>();
    setState(() {
      _messages.add(_ChatBubble(role: 'user', text: text));
      _thinking = true;
    });
    await SupabaseService.instance.saveAiMessage(
      conversationId: 'chat',
      role: 'user',
      content: text,
      metadata: {'provider': _provider.name},
    );
    _chatCtrl.clear();
    _scrollToBottom();

    try {
      final history = _messages
          .where((m) => m.role != 'error')
          .map((m) => AiMessage(role: m.role, content: m.text))
          .toList();
      final reply = await premium.aiService
          .chat(text, state.chart!, history, prefer: _provider);
      setState(() {
        _messages.add(_ChatBubble(role: 'assistant', text: reply));
        _thinking = false;
      });
      await SupabaseService.instance.saveAiMessage(
        conversationId: 'chat',
        role: 'assistant',
        content: reply,
        metadata: {'provider': _provider.name},
      );
    } catch (e) {
      setState(() {
        _messages.add(_ChatBubble(role: 'error', text: e.toString()));
        _thinking = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = switch (_tabs.index) {
        0 => _scrollCtrl1,
        1 => _scrollCtrl2,
        2 => _scrollCtrl3,
        _ => null,
      };

      if (ctrl != null && ctrl.hasClients) {
        ctrl.animateTo(
          ctrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showNoKeySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CosmicColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Add an API Key',
              style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 12),
          Text(
            'No server AI route is configured for this build. Go to Settings and '
            'add your Anthropic, Gemini, or OpenAI API key.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('GO TO SETTINGS'),
            ),
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  void _showQuotaSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CosmicColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Daily Limit Reached',
              style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 12),
          Text(
            'Free users get 3 AI readings per day. '
            'Add your own API key to get unlimited access.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ADD API KEY'),
            ),
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final premium = PremiumService.instance;

    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'AI Astrologer',
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(fontSize: 20),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.palette_outlined, size: 22),
                      tooltip: 'Art Generator',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ArtGeneratingScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    _ProviderToggle(
                      current: _provider,
                      hasClaude: premium.hasAnthropicKey,
                      hasGemini: premium.hasGeminiKey,
                      hasOpenAi: premium.hasOpenAiKey,
                      serverProxy: AiService.hasServerProxy,
                      onChanged: (p) => setState(() => _provider = p),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                child: _AiStatusRow(premium: premium),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: _AiEnvironmentBanner(
                  hasServerProxy: AiService.hasServerProxy,
                  hasAnyKey: premium.hasAnyKey,
                ),
              ),
              const SizedBox(height: 12),
              // Quick action tabs
              TabBar(
                controller: _tabs,
                indicatorColor: CosmicColors.neonLavender,
                labelColor: CosmicColors.neonLavender,
                unselectedLabelColor: CosmicColors.textMuted,
                labelStyle: const TextStyle(fontSize: 12, letterSpacing: 0.5),
                tabs: const [
                  Tab(text: 'Chart Reading'),
                  Tab(text: 'Daily'),
                  Tab(text: 'Chat'),
                  Tab(text: 'Art'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _QuickTab(
                      label: 'Full Chart Reading',
                      description:
                          'A deep multi-cultural interpretation of your entire birth chart — '
                          'weaving Western, Vedic, Chinese, and Mayan perspectives.',
                      actionLabel: 'READ MY CHART',
                      icon: '✦',
                      onAction: () => _sendQuickAction('interpret'),
                      messages: _messages,
                      thinking: _thinking,
                      scrollCtrl: _scrollCtrl1,
                    ),
                    _QuickTab(
                      label: 'Today\'s Reading',
                      description:
                          'What the current sky is saying to your natal chart right now.',
                      actionLabel: 'GET TODAY\'S READING',
                      icon: '☽',
                      onAction: () => _sendQuickAction('daily'),
                      messages: _messages,
                      thinking: _thinking,
                      scrollCtrl: _scrollCtrl2,
                    ),
                    _ChatTab(
                      messages: _messages,
                      thinking: _thinking,
                      ctrl: _chatCtrl,
                      scrollCtrl: _scrollCtrl3,
                      onSend: _sendMessage,
                    ),
                    const ArtGeneratingScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderToggle extends StatelessWidget {
  final AiProvider current;
  final bool hasClaude;
  final bool hasGemini;
  final bool hasOpenAi;
  final bool serverProxy;
  final ValueChanged<AiProvider> onChanged;

  const _ProviderToggle({
    required this.current,
    required this.hasClaude,
    required this.hasGemini,
    required this.hasOpenAi,
    required this.serverProxy,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: CosmicColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CosmicColors.divider),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _chip('Claude', AiProvider.anthropic, hasClaude || serverProxy, '🤖'),
        _chip('Gemini', AiProvider.gemini, hasGemini || serverProxy, '✨'),
        _chip('GPT', AiProvider.openai, hasOpenAi || serverProxy, '⚡'),
      ]),
    );
  }

  Widget _chip(String label, AiProvider p, bool available, String emoji) {
    final selected = current == p;
    return GestureDetector(
      onTap: available ? () => onChanged(p) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected && available
              ? CosmicColors.neonLavender.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          '$emoji $label',
          style: TextStyle(
            fontSize: 11,
            color: available
                ? (selected
                    ? CosmicColors.neonLavender
                    : CosmicColors.textSecondary)
                : CosmicColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _QuickTab extends StatelessWidget {
  final String label;
  final String description;
  final String actionLabel;
  final String icon;
  final VoidCallback onAction;
  final List<_ChatBubble> messages;
  final bool thinking;
  final ScrollController scrollCtrl;

  const _QuickTab({
    required this.label,
    required this.description,
    required this.actionLabel,
    required this.icon,
    required this.onAction,
    required this.messages,
    required this.thinking,
    required this.scrollCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: messages.isEmpty
            ? _EmptyState(icon: icon, label: label, description: description)
            : _MessageList(
                messages: messages, thinking: thinking, ctrl: scrollCtrl),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: thinking ? null : onAction,
            child: thinking
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black))
                : Text(actionLabel),
          ),
        ),
      ),
    ]);
  }
}

class _ChatTab extends StatelessWidget {
  final List<_ChatBubble> messages;
  final bool thinking;
  final TextEditingController ctrl;
  final ScrollController scrollCtrl;
  final VoidCallback onSend;

  const _ChatTab({
    required this.messages,
    required this.thinking,
    required this.ctrl,
    required this.scrollCtrl,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: messages.isEmpty
            ? const _EmptyState(
                icon: '💬',
                label: 'Astrology Chat',
                description: 'Ask anything about your chart — '
                    'planetary aspects, compatibility, timing, life themes.',
              )
            : _MessageList(
                messages: messages, thinking: thinking, ctrl: scrollCtrl),
      ),
      _ChatInput(ctrl: ctrl, thinking: thinking, onSend: onSend),
    ]);
  }
}

class _EmptyState extends StatelessWidget {
  final String icon;
  final String label;
  final String description;

  const _EmptyState({
    required this.icon,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 16),
          Text(label,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(description,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CosmicColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CosmicColors.divider),
            ),
            child: Text(
              'Demo agent: server routed\nOwn key: direct provider chat',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ]),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  final List<_ChatBubble> messages;
  final bool thinking;
  final ScrollController ctrl;

  const _MessageList({
    required this.messages,
    required this.thinking,
    required this.ctrl,
  });

  @override
  Widget build(BuildContext context) {
    return CosmicScrollbar(
      controller: ctrl,
      child: ListView.builder(
        controller: ctrl,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: messages.length + (thinking ? 1 : 0),
        itemBuilder: (_, i) {
          if (i == messages.length) return const _ThinkingBubble();
          return _BubbleWidget(bubble: messages[i]);
        },
      ),
    );
  }
}

class _BubbleWidget extends StatelessWidget {
  final _ChatBubble bubble;
  const _BubbleWidget({required this.bubble});

  @override
  Widget build(BuildContext context) {
    final isUser = bubble.role == 'user';
    final isError = bubble.role == 'error';
    final color = isError
        ? const Color(0xFFFF4444)
        : isUser
            ? CosmicColors.neonLavender
            : CosmicColors.neonCyan;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isUser ? 0.18 : 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          bubble.text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isUser
                    ? CosmicColors.textPrimary
                    : CosmicColors.textPrimary,
                height: 1.6,
              ),
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CosmicColors.neonCyan.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: CosmicColors.neonCyan.withValues(alpha: 0.25)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: CosmicColors.neonCyan.withValues(alpha: 0.7)),
            ),
            const SizedBox(width: 10),
            const Text('Reading the stars…',
                style: TextStyle(color: CosmicColors.textMuted, fontSize: 12)),
          ]),
        ),
      );
}

class _ChatInput extends StatelessWidget {
  final TextEditingController ctrl;
  final bool thinking;
  final VoidCallback onSend;

  const _ChatInput({
    required this.ctrl,
    required this.thinking,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: CosmicColors.surface,
        border: Border(top: BorderSide(color: CosmicColors.divider)),
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: ctrl,
            onSubmitted: (_) => onSend(),
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Ask about your chart…',
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style:
                const TextStyle(color: CosmicColors.textPrimary, fontSize: 14),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: thinking ? null : onSend,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CosmicColors.neonLavender.withValues(alpha: 0.2),
              border: Border.all(
                  color: CosmicColors.neonLavender.withValues(alpha: 0.5)),
            ),
            child: Icon(
              Icons.send_rounded,
              color:
                  thinking ? CosmicColors.textMuted : CosmicColors.neonLavender,
              size: 18,
            ),
          ),
        ),
      ]),
    );
  }
}

class _ChatBubble {
  final String role;
  final String text;
  const _ChatBubble({required this.role, required this.text});
}

// ── AI status indicator ────────────────────────────────────────────────────

class _AiStatusRow extends StatelessWidget {
  final PremiumService premium;
  const _AiStatusRow({required this.premium});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatusDot(
          label: 'BSL',
          tooltip: 'Server neuromorphic agent with LangSmith tracing',
          active: AiService.hasServerProxy,
          color: CosmicColors.neonCyan,
        ),
        const SizedBox(width: 8),
        _StatusDot(
          label: 'Claude',
          tooltip: premium.hasAnthropicKey
              ? 'Anthropic API key set ✓'
              : 'Add Anthropic key in Settings',
          active: premium.hasAnthropicKey,
          color: CosmicColors.neonLavender,
        ),
        const SizedBox(width: 8),
        _StatusDot(
          label: 'Gemini',
          tooltip: premium.hasGeminiKey
              ? 'Google Gemini key set ✓'
              : 'Add Gemini key in Settings',
          active: premium.hasGeminiKey,
          color: CosmicColors.neonPink,
        ),
        const SizedBox(width: 8),
        _StatusDot(
          label: 'GPT',
          tooltip: premium.hasOpenAiKey
              ? 'OpenAI key set ✓'
              : 'Add OpenAI key in Settings',
          active: premium.hasOpenAiKey,
          color: CosmicColors.neonGreen,
        ),
      ],
    );
  }
}

class _AiEnvironmentBanner extends StatelessWidget {
  final bool hasServerProxy;
  final bool hasAnyKey;

  const _AiEnvironmentBanner({
    required this.hasServerProxy,
    required this.hasAnyKey,
  });

  @override
  Widget build(BuildContext context) {
    final (label, body, color) = hasServerProxy
        ? (
            'Demo agent online',
            'The app can route chat through the server-side neuromorphic agent when local keys are missing.',
            CosmicColors.neonGreen,
          )
        : hasAnyKey
            ? (
                'Bring-your-own-key mode',
                'Server proxy is off, so chat uses locally configured provider keys only.',
                CosmicColors.neonCyan,
              )
            : (
                'AI unavailable',
                'Add a provider key in Settings or enable the server proxy to restore chat.',
                CosmicColors.neonYellow,
              );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: CosmicColors.textSecondary, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String label;
  final String tooltip;
  final bool active;
  final Color color;
  const _StatusDot(
      {required this.label,
      required this.tooltip,
      required this.active,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? color : CosmicColors.textMuted,
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                color: active ? color : CosmicColors.textMuted,
                letterSpacing: 0.5)),
      ]),
    );
  }
}
