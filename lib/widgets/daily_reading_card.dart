import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/chart_engine.dart';
import '../services/premium_service.dart';
import '../theme/cosmic_theme.dart';

class DailyReadingCard extends StatefulWidget {
  final FullChart chart;
  const DailyReadingCard({super.key, required this.chart});

  @override
  State<DailyReadingCard> createState() => _DailyReadingCardState();
}

class _DailyReadingCardState extends State<DailyReadingCard> {
  String? _reading;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _reading = PremiumService.instance.getCachedDailyReading();
    if (_reading == null &&
        PremiumService.instance.canUse(PremiumFeature.dailyReading)) {
      _fetchReading();
    }
  }

  Future<void> _fetchReading() async {
    setState(() => _loading = true);
    try {
      final svc = PremiumService.instance.aiService;
      final text = await svc.dailyReading(widget.chart);
      await PremiumService.instance.cacheDailyReading(text);
      if (mounted) setState(() => _reading = text);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dateLabel =
        '${today.day} ${_monthName(today.month)} ${today.year}';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CosmicColors.neonPink.withValues(alpha: 0.10),
            CosmicColors.neonLavender.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: CosmicColors.neonPink.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✦ ',
                  style: TextStyle(
                      color: CosmicColors.neonPink, fontSize: 13)),
              Text(
                'DAILY READING',
                style: const TextStyle(
                    color: CosmicColors.neonPink,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(dateLabel,
                  style: const TextStyle(
                      color: CosmicColors.textMuted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Row(
              children: [
                SizedBox(
                    width: 14, height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: CosmicColors.neonPink)),
                SizedBox(width: 10),
                Text('Reading the stars…',
                    style: TextStyle(
                        color: CosmicColors.textMuted,
                        fontSize: 13,
                        fontStyle: FontStyle.italic)),
              ],
            )
          else if (_reading != null)
            Text(_reading!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.7))
          else
            _LockedState(onTap: _fetchReading),
        ],
      ),
    );
  }

  String _monthName(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][m];
}

class _LockedState extends StatelessWidget {
  final VoidCallback onTap;
  const _LockedState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add an API key to unlock a fresh AI reading every morning.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: CosmicColors.textSecondary),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: CosmicColors.neonPink.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: CosmicColors.neonPink.withValues(alpha: 0.4)),
            ),
            child: const Text('Get Today\'s Reading',
                style: TextStyle(
                    color: CosmicColors.neonPink,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
