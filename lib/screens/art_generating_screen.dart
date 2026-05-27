import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../theme/cosmic_theme.dart';
import '../widgets/art_background.dart';
import '../services/ai_service.dart';
import '../services/premium_service.dart';
import '../state/app_state.dart';
import 'ai_screen.dart';

class ArtGeneratingScreen extends StatefulWidget {
  const ArtGeneratingScreen({super.key});

  @override
  State<ArtGeneratingScreen> createState() => _ArtGeneratingScreenState();
}

class _ArtGeneratingScreenState extends State<ArtGeneratingScreen> {
  late TextEditingController _promptController;
  late ScrollController _scrollController;
  final List<_ArtMessage> _messages = [];
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _generateArt() {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _messages.add(_ArtMessage(role: 'user', text: prompt));
      _generating = true;
    });
    _promptController.clear();
    _scrollToBottom();

    // Get premium service
    final premium = PremiumService.instance;

    // Check if user has API keys or server proxy
    if (!premium.hasAnyKey && !AiService.hasServerProxy) {
      setState(() {
        _messages.add(_ArtMessage(
          role: 'error',
          text: 'No AI service available. Please add an API key in Settings or ensure server proxy is enabled.',
        ));
        _generating = false;
      });
      _scrollToBottom();
      return;
    }

    // Check quota
    premium.consumeAiCall().then((allowed) {
      if (!mounted) return;
      if (!allowed) {
        setState(() {
          _messages.add(_ArtMessage(
            role: 'error',
            text: 'Daily limit reached. Free users get 3 AI readings per day. Add your own API key for unlimited access.',
          ));
          _generating = false;
        });
        _scrollToBottom();
        return;
      }

      // Generate art using AI service
      final ai = premium.aiService;
      final artPrompt = 'Cosmic astrology-themed art: $prompt. '
          'Celestial scene with zodiac symbols, cosmic colors, mystical elements, '
          'neon accents, and celestial formations. Professional digital art style.';

      // First generate image, then add description
      ai.generateArtImage(artPrompt).then((imageUrl) {
        if (mounted) {
          setState(() {
            _messages.add(_ArtMessage(
              role: 'assistant',
              text: '✨ Cosmic Art Generated!\n\n'
                  'Your celestial masterpiece has been created based on your prompt: "$prompt"\n\n'
                  '🎨 **Art Style**: Cosmic astrology theme\n'
                  '🌟 **Elements**: Zodiac symbols, celestial formations\n'
                  '🌌 **Colors**: Cosmic palette with mystical accents\n\n'
                  '**Image URL**: $imageUrl\n\n'
                  'The AI has created a unique cosmic artwork inspired by your birth chart and imagination!',
              imageUrl: imageUrl,
            ));
            _generating = false;
          });
          _scrollToBottom();
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _messages.add(_ArtMessage(
              role: 'error',
              text: 'Failed to generate art image: ${error.toString()}',
            ));
            _generating = false;
          });
          _scrollToBottom();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ArtBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Text(
                      'Art Generator',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontSize: 20,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Chat messages
              Expanded(
                child: _messages.isEmpty
                    ? const _ArtEmptyState()
                    : CosmicScrollbar(
                        controller: _scrollController,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length +
                              (_generating ? 1 : 0),
                          itemBuilder: (_, i) {
                            if (i == _messages.length) {
                              return const _ArtThinkingIndicator();
                            }
                            return _ArtBubbleWidget(
                              bubble: _messages[i],
                            );
                          },
                        ),
                      ),
              ),
              // Input area
              _ArtInput(
                controller: _promptController,
                onSend: _generateArt,
                generating: _generating,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArtMessage {
  final String role;
  final String text;
  final String? imageUrl;
  const _ArtMessage({required this.role, required this.text, this.imageUrl});
}

class _ArtEmptyState extends StatelessWidget {
  const _ArtEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎨', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Cosmic Art Generator',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Describe your cosmic vision and the AI will generate '
              'actual cosmic artwork images using DALL-3 based on your birth chart.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CosmicColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CosmicColors.divider),
              ),
              child: Text(
                'Examples: "Cosmic owl with zodiac wings", '
                '"Nebula in the shape of my rising sign", '
                '"Planetary dance in sunset colors"',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtBubbleWidget extends StatelessWidget {
  final _ArtMessage bubble;
  const _ArtBubbleWidget({required this.bubble});

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bubble.imageUrl != null && bubble.role == 'assistant')
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: bubble.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: CosmicColors.neonCyan.withValues(alpha: 0.1),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: CosmicColors.neonCyan,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: CosmicColors.neonCyan.withValues(alpha: 0.05),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.image_not_supported,
                            color: CosmicColors.neonCyan,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Image failed to load',
                            style: TextStyle(
                              color: CosmicColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            Text(
              bubble.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isError
                        ? CosmicColors.textPrimary
                        : CosmicColors.textPrimary,
                    height: 1.6,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtThinkingIndicator extends StatelessWidget {
  const _ArtThinkingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CosmicColors.neonCyan.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: CosmicColors.neonCyan.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: CosmicColors.neonCyan.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Creating cosmic art with AI...',
              style: TextStyle(color: CosmicColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool generating;

  const _ArtInput({
    required this.controller,
    required this.onSend,
    required this.generating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: CosmicColors.surface,
        border: Border(top: BorderSide(color: CosmicColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onSend(),
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Describe your cosmic vision...',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: const TextStyle(
                color: CosmicColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: generating ? null : onSend,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CosmicColors.neonLavender.withValues(alpha: 0.2),
                border: Border.all(
                  color: CosmicColors.neonLavender.withValues(alpha: 0.5),
                ),
              ),
              child: Icon(
                Icons.send_rounded,
                color: generating
                    ? CosmicColors.textMuted
                    : CosmicColors.neonLavender,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}