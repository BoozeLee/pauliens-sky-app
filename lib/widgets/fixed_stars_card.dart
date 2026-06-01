import 'package:flutter/material.dart';
import '../services/fixed_stars.dart';
import '../theme/cosmic_theme.dart';

class FixedStarsCard extends StatelessWidget {
  final List<(FixedStar, double)> stars;
  const FixedStarsCard({super.key, required this.stars});

  @override
  Widget build(BuildContext context) {
    if (stars.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CosmicColors.neonYellow.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: CosmicColors.neonYellow.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('★ ',
                  style: TextStyle(
                      color: CosmicColors.neonYellow, fontSize: 14)),
              Text(
                'FIXED STARS AT BIRTH',
                style: TextStyle(
                    color: CosmicColors.neonYellow,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final (star, orb) in stars) ...[
            _StarRow(star: star, orb: orb),
            if (star != stars.last.$1)
              const Divider(
                  color: CosmicColors.divider,
                  height: 16,
                  thickness: 0.5),
          ],
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final FixedStar star;
  final double orb;
  const _StarRow({required this.star, required this.orb});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      dense: true,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 8),
      title: Row(
        children: [
          Expanded(
            child: Text(
              star.name,
              style: TextStyle(
                  color: star.behenian
                      ? CosmicColors.neonYellow
                      : CosmicColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ),
          if (star.behenian)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: CosmicColors.neonYellow.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: CosmicColors.neonYellow.withValues(alpha: 0.4)),
              ),
              child: const Text('Behenian',
                  style: TextStyle(
                      color: CosmicColors.neonYellow,
                      fontSize: 9,
                      letterSpacing: 0.5)),
            ),
          const SizedBox(width: 8),
          Text('${orb.toStringAsFixed(1)}°',
              style: const TextStyle(
                  color: CosmicColors.textMuted, fontSize: 11)),
        ],
      ),
      subtitle: Text(
        star.keywords,
        style: const TextStyle(
            color: CosmicColors.textSecondary, fontSize: 11),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                star.mythology,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.6, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _InfoChip('Nature: ${star.nature}',
                      CosmicColors.neonCyan),
                  if (star.stone != null)
                    _InfoChip('Stone: ${star.stone!}',
                        CosmicColors.neonLavender),
                  if (star.herb != null)
                    _InfoChip('Herb: ${star.herb!}',
                        CosmicColors.neonGreen),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 10)),
    );
  }
}
