import 'package:flutter/material.dart';
import '../models/culture_chart.dart';
import '../theme/cosmic_theme.dart';

class CultureCard extends StatelessWidget {
  final CultureChart chart;
  final VoidCallback? onTap;
  final bool expanded;

  const CultureCard({
    super.key,
    required this.chart,
    this.onTap,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = chart.id.accentColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: CosmicColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.4), width: 1),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.08),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(chart: chart, accent: accent),
            if (chart.sunSign != null || chart.moonSign != null)
              _SignRow(chart: chart, accent: accent),
            if (expanded) _EntryList(chart: chart, accent: accent),
            if (!expanded && chart.keyInsights.isNotEmpty)
              _InsightPreview(chart: chart, accent: accent),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final CultureChart chart;
  final Color accent;
  const _Header({required this.chart, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: accent.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.15),
              border: Border.all(color: accent.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: Text(chart.id.emoji,
                  style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            chart.id.displayName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: accent, fontSize: 15, letterSpacing: 1.5),
          ),
          const Spacer(),
          Icon(Icons.chevron_right, color: accent.withValues(alpha: 0.5), size: 18),
        ],
      ),
    );
  }
}

class _SignRow extends StatelessWidget {
  final CultureChart chart;
  final Color accent;
  const _SignRow({required this.chart, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          if (chart.sunSign != null)
            _Chip(label: '☉ ${chart.sunSign}', accent: accent),
          if (chart.moonSign != null)
            _Chip(label: '☽ ${chart.moonSign}', accent: accent),
          if (chart.ascendantSign != null)
            _Chip(label: '↑ ${chart.ascendantSign}', accent: accent),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color accent;
  const _Chip({required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(color: accent, fontSize: 11, letterSpacing: 0.5)),
    );
  }
}

class _InsightPreview extends StatelessWidget {
  final CultureChart chart;
  final Color accent;
  const _InsightPreview({required this.chart, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Text(
        chart.keyInsights.first,
        style: Theme.of(context).textTheme.bodyMedium,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _EntryList extends StatelessWidget {
  final CultureChart chart;
  final Color accent;
  const _EntryList({required this.chart, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        children: [
          for (final entry in chart.entries) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(entry.label,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.value,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: accent)),
                        if (entry.description != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              entry.description!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontSize: 11),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1, color: CosmicColors.divider.withValues(alpha: 0.5)),
          ],
        ],
      ),
    );
  }
}
