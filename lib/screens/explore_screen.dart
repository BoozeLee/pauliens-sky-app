import 'package:flutter/material.dart';
import '../theme/cosmic_theme.dart';
import '../widgets/sky_background.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  static const _traditions = [
    _TraditionInfo(
      name: 'Western Astrology',
      emoji: '♈',
      color: CosmicColors.western,
      summary:
          'The tropical zodiac divides the sky into 12 equal signs beginning at '
          'the vernal equinox. Planets in signs, houses, and their mutual aspects '
          'describe character, timing, and destiny.',
      keywords: ['Planets', 'Houses', 'Aspects', 'Tropical zodiac'],
    ),
    _TraditionInfo(
      name: 'Vedic / Jyotish',
      emoji: '🕉',
      color: CosmicColors.vedic,
      summary:
          'India\'s sidereal system aligns to the actual star background. '
          'Nakshatras (lunar mansions), Dashas (time lords), and divisional '
          'charts reveal karma, dharma, and moksha.',
      keywords: ['Nakshatras', 'Lagna', 'Dashas', 'Sidereal'],
    ),
    _TraditionInfo(
      name: 'Chinese Astrology',
      emoji: '龍',
      color: CosmicColors.chinese,
      summary:
          'Ba Zi ("Four Pillars") encodes year, month, day, and hour as pairs '
          'of Heavenly Stems and Earthly Branches. The interplay of Yin/Yang and '
          'five elements reveals luck cycles and destiny.',
      keywords: ['Ba Zi', 'Five Elements', 'Lunar Year', 'Heavenly Stems'],
    ),
    _TraditionInfo(
      name: 'Mayan Calendar',
      emoji: '☀',
      color: CosmicColors.mayan,
      summary:
          'The Tzolk\'in is a 260-day sacred cycle combining 20 day-signs with '
          '13 tones. Each birth day carries a unique glyph and number revealing '
          'purpose, gifts, and challenges.',
      keywords: ['Tzolk\'in', 'Day Signs', 'Tones', '260-day cycle'],
    ),
    _TraditionInfo(
      name: 'Egyptian Decans',
      emoji: '𓂀',
      color: CosmicColors.egyptian,
      summary:
          'Ancient Egypt divided the sky into 36 decans of 10° each. Each decan '
          'has a deity ruler and star cluster that rises at specific seasons, '
          'governing time, fate, and the underworld journey.',
      keywords: ['36 Decans', 'Decan Rulers', 'Fixed Stars', 'Nut\'s body'],
    ),
    _TraditionInfo(
      name: 'Celtic Tree Calendar',
      emoji: '🌿',
      color: CosmicColors.celtic,
      summary:
          'The Celtic Ogham calendar assigns sacred trees to 13 lunar months. '
          'Each tree carries spiritual qualities, Druidic wisdom, and connection '
          'to the land cycles of the British Isles.',
      keywords: ['Tree Signs', 'Ogham', 'Lunar months', 'Animal totems'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Explore',
                          style: Theme.of(context).textTheme.displayLarge),
                      const SizedBox(height: 4),
                      Text('Six traditions. One birth sky.',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _TraditionCard(tradition: _traditions[i]),
                    ),
                    childCount: _traditions.length,
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TraditionInfo {
  final String name, emoji, summary;
  final Color color;
  final List<String> keywords;
  const _TraditionInfo({
    required this.name,
    required this.emoji,
    required this.color,
    required this.summary,
    required this.keywords,
  });
}

class _TraditionCard extends StatelessWidget {
  final _TraditionInfo tradition;
  const _TraditionCard({required this.tradition});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CosmicColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: tradition.color.withValues(alpha: 0.35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(tradition.emoji,
                  style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tradition.name,
                  style: TextStyle(
                      color: tradition.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(tradition.summary,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.6)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: tradition.keywords.map((k) => _Chip(k, tradition.color)).toList(),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}
