import 'package:flutter/material.dart';
import '../models/culture_chart.dart';
import '../services/chart_engine.dart';
import '../services/fixed_stars.dart';
import '../services/premium_service.dart';
import '../theme/cosmic_theme.dart';
import '../widgets/personality_radar.dart';
import '../widgets/premium_gate.dart';
import '../widgets/share_card.dart';
import '../widgets/sky_background.dart';

class PersonalityScreen extends StatelessWidget {
  final FullChart chart;
  const PersonalityScreen({super.key, required this.chart});

  @override
  Widget build(BuildContext context) {
    final p = chart.personality;
    final name = chart.context.personName ?? 'Your';

    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: CosmicColors.background,
                title: Text('${name}s Sky',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20)),
                leading: const BackButton(color: CosmicColors.textSecondary),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),
                    _HeadlineCard(profile: p),
                    const SizedBox(height: 20),
                    _RadarSection(profile: p),
                    const SizedBox(height: 20),
                    _CoreTraitsCard(profile: p),
                    const SizedBox(height: 20),
                    _CrossCultureSummary(chart: chart),
                    const SizedBox(height: 20),
                    _FixedStarsSection(chart: chart),
                    const SizedBox(height: 20),
                    PremiumGate(
                      feature: PremiumFeature.shareCard,
                      customLabel: 'Share Card',
                      child: ShareCardButton(chart: chart),
                    ),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeadlineCard extends StatelessWidget {
  final PersonalityProfile profile;
  const _HeadlineCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CosmicColors.neonLavender.withValues(alpha: 0.15),
            CosmicColors.neonCyan.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: CosmicColors.neonLavender.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(
            profile.headline,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: CosmicColors.neonLavender,
                  fontSize: 22,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            profile.summary,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: CosmicColors.textSecondary,
                  height: 1.7,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RadarSection extends StatelessWidget {
  final PersonalityProfile profile;
  const _RadarSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SectionTitle('Personality Constellation'),
        const SizedBox(height: 16),
        Center(child: PersonalityRadar(profile: profile, size: 280)),
        const SizedBox(height: 12),
        Text(
          'Synthesized from Western, Vedic, Chinese, Mayan, Egyptian & Celtic traditions',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CoreTraitsCard extends StatelessWidget {
  final PersonalityProfile profile;
  const _CoreTraitsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Core Traits'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: profile.coreTraits
              .map((t) => _TraitPill(t))
              .toList(),
        ),
      ],
    );
  }
}

class _TraitPill extends StatelessWidget {
  final String text;
  const _TraitPill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: CosmicColors.neonLavender.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: CosmicColors.neonLavender.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: CosmicColors.neonLavender, fontSize: 13, letterSpacing: 0.3),
      ),
    );
  }
}

class _CrossCultureSummary extends StatelessWidget {
  final FullChart chart;
  const _CrossCultureSummary({required this.chart});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Sky Through Many Eyes'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: CosmicColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CosmicColors.divider),
          ),
          child: Column(
            children: [
              for (int i = 0; i < chart.charts.length; i++) ...[
                _CultureRow(
                  cultureChart: chart.charts[i],
                ),
                if (i < chart.charts.length - 1)
                  Divider(
                      height: 1,
                      color: CosmicColors.divider.withValues(alpha: 0.5)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CultureRow extends StatelessWidget {
  final CultureChart cultureChart;
  const _CultureRow({required this.cultureChart});

  @override
  Widget build(BuildContext context) {
    final accent = cultureChart.id.accentColor;
    final sun = cultureChart.sunSign;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(cultureChart.id.emoji,
              style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cultureChart.id.displayName,
                    style: TextStyle(
                        color: accent, fontSize: 13, fontWeight: FontWeight.w600)),
                if (sun != null)
                  Text(sun,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 12)),
              ],
            ),
          ),
          if (cultureChart.keyInsights.isNotEmpty)
            Expanded(
              flex: 2,
              child: Text(
                cultureChart.keyInsights.first,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 11, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}

class _FixedStarsSection extends StatelessWidget {
  final FullChart chart;
  const _FixedStarsSection({required this.chart});

  @override
  Widget build(BuildContext context) {
    final stars = chart.prominentStars;
    if (stars.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Fixed Stars at Birth'),
        const SizedBox(height: 4),
        Text(
          'Ancient stars that touched your planets when you were born',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 12),
        for (final entry in stars.take(5))
          _StarCard(star: entry.$1, orb: entry.$2),
      ],
    );
  }
}

class _StarCard extends StatelessWidget {
  final FixedStar star;
  final double orb;
  const _StarCard({required this.star, required this.orb});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CosmicColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: CosmicColors.neonYellow.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('★ ',
                  style: TextStyle(color: CosmicColors.neonYellow, fontSize: 14)),
              Text(star.name,
                  style: const TextStyle(
                      color: CosmicColors.neonYellow,
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(width: 8),
              Text('(${star.constellation})',
                  style: const TextStyle(
                      color: CosmicColors.textMuted, fontSize: 11)),
              const Spacer(),
              Text('${orb.toStringAsFixed(1)}° orb',
                  style: const TextStyle(
                      color: CosmicColors.textMuted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 4),
          Text(star.keywords,
              style: const TextStyle(
                  color: CosmicColors.neonLavender, fontSize: 11)),
          const SizedBox(height: 6),
          Text(star.mythology,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12, height: 1.5,
                    color: CosmicColors.textSecondary)),
          if (star.behenian && star.stone != null) ...[
            const SizedBox(height: 6),
            Text('Behenian star — Stone: ${star.stone}  •  Herb: ${star.herb}',
                style: const TextStyle(
                    color: CosmicColors.textMuted, fontSize: 10)),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: CosmicColors.neonLavender, letterSpacing: 2, fontSize: 11),
    );
  }
}
