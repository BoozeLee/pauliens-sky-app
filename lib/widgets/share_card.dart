import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../models/culture_chart.dart';
import '../services/chart_engine.dart';
import '../theme/cosmic_theme.dart';

class ShareCardButton extends StatefulWidget {
  final FullChart chart;
  const ShareCardButton({super.key, required this.chart});

  @override
  State<ShareCardButton> createState() => _ShareCardButtonState();
}

class _ShareCardButtonState extends State<ShareCardButton> {
  final _cardKey = GlobalKey();
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Hidden render target (offscreen in a 0-height clip)
        SizedBox(
          height: 0,
          child: OverflowBox(
            alignment: Alignment.topCenter,
            maxHeight: 900,
            child: RepaintBoundary(
              key: _cardKey,
              child: _ShareCardContent(chart: widget.chart),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _exporting ? null : _export,
            icon: _exporting
                ? const SizedBox(
                    width: 14, height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: CosmicColors.background))
                : const Icon(Icons.download_outlined, size: 16),
            label: Text(_exporting ? 'Saving…' : 'Save Share Card'),
          ),
        ),
      ],
    );
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final boundary = _cardKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final dir = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final name = widget.chart.context.personName ?? 'chart';
      final file = File(
          '${dir.path}/${name.toLowerCase().replaceAll(' ', '_')}_sky_card.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Saved to ${file.path}'),
          backgroundColor: CosmicColors.surface,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Open',
            textColor: CosmicColors.neonCyan,
            onPressed: () => Process.run('xdg-open', [dir.path]),
          ),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: CosmicColors.surface,
        ));
      }
    }
    if (mounted) setState(() => _exporting = false);
  }
}

// ── Card content rendered for export ──────────────────────────────────────

class _ShareCardContent extends StatelessWidget {
  final FullChart chart;
  const _ShareCardContent({required this.chart});

  @override
  Widget build(BuildContext context) {
    final western = chart.charts.first;
    final chinese =
        chart.charts.where((c) => c.id == CultureId.chinese).firstOrNull;
    final vedic =
        chart.charts.where((c) => c.id == CultureId.vedic).firstOrNull;
    final mayan =
        chart.charts.where((c) => c.id == CultureId.mayan).firstOrNull;
    final stars = chart.prominentStars
        .where((t) => t.$1.behenian)
        .take(3)
        .toList();

    return Container(
      width: 390,
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0520), Color(0xFF1A0840), Color(0xFF0A1520)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App brand
          const Row(
            children: [
              Text('✦ ',
                  style: TextStyle(
                      color: CosmicColors.neonLavender, fontSize: 18)),
              Text(
                "PAULIEN'S SKY",
                style: TextStyle(
                    color: CosmicColors.neonLavender,
                    fontSize: 13,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Name
          Text(
            chart.context.personName ?? 'Birth Chart',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5),
          ),
          Text(
            '${chart.context.utcTime.day} '
            '${_monthName(chart.context.utcTime.month)} '
            '${chart.context.utcTime.year}  •  '
            '${chart.context.locationName ?? ''}',
            style: const TextStyle(
                color: CosmicColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 24),

          // Headline
          Text(
            chart.personality.headline,
            style: const TextStyle(
                color: CosmicColors.neonLavender,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.4),
          ),
          const SizedBox(height: 20),

          // Culture signs grid
          _SignsGrid(signs: [
            ('☉ Western', western.sunSign ?? '', CosmicColors.neonCyan),
            ('☽ Moon', western.moonSign ?? '', CosmicColors.textSecondary),
            ('龍 Chinese', chinese?.sunSign ?? '', CosmicColors.neonPink),
            ('🕉 Vedic', vedic?.sunSign ?? '', CosmicColors.vedic),
            ('☀ Mayan', mayan?.sunSign ?? '', CosmicColors.neonYellow),
            ('⬡ Celtic',
                chart.charts
                        .where((c) => c.id == CultureId.celtic)
                        .firstOrNull
                        ?.sunSign ??
                    '',
                CosmicColors.celtic),
          ]),

          // Stars
          if (stars.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('★  FIXED STARS',
                style: TextStyle(
                    color: CosmicColors.neonYellow,
                    fontSize: 10,
                    letterSpacing: 2)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: stars.map((t) {
                final s = t.$1;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        CosmicColors.neonYellow.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: CosmicColors.neonYellow
                            .withValues(alpha: 0.4)),
                  ),
                  child: Text('${s.name} · ${s.keywords.split(',').first}',
                      style: const TextStyle(
                          color: CosmicColors.neonYellow, fontSize: 11)),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 24),
          const Divider(color: CosmicColors.divider),
          const SizedBox(height: 8),
          const Text(
            'Generated with Paulien\'s Sky • One sky, many traditions',
            style: TextStyle(
                color: CosmicColors.textMuted,
                fontSize: 10,
                letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  String _monthName(int m) => const [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ][m];
}

class _SignsGrid extends StatelessWidget {
  final List<(String, String, Color)> signs;
  const _SignsGrid({required this.signs});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: signs.where((s) => s.$2.isNotEmpty).map((s) {
        final (label, value, color) = s;
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 9,
                      letterSpacing: 1)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
