import 'package:flutter/material.dart';
import '../models/culture_chart.dart';
import '../models/profile.dart';
import '../services/chart_engine.dart';
import '../theme/cosmic_theme.dart';
import '../widgets/sky_background.dart';
import 'birth_input_screen.dart';
import 'chart_screen.dart';
import 'personality_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FullChart _paulienChart;

  @override
  void initState() {
    super.initState();
    _paulienChart = ChartEngine().compute(Profile.paulien.birthContext);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(child: _Header()),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _PaulienCard(chart: _paulienChart),
                    const SizedBox(height: 24),
                    _SectionLabel('READ A NEW SKY'),
                    const SizedBox(height: 12),
                    _NewReadingButton(),
                    const SizedBox(height: 24),
                    _SectionLabel('TRADITIONS'),
                    const SizedBox(height: 12),
                    _TraditionsGrid(),
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

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Paulien's Sky",
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'One sky. Many traditions.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _PaulienCard extends StatelessWidget {
  final FullChart chart;
  const _PaulienCard({required this.chart});

  @override
  Widget build(BuildContext context) {
    final western = chart.charts.first;
    final chinese = chart.charts
        .where((c) => c.id == CultureId.chinese)
        .firstOrNull;
    final mayan = chart.charts
        .where((c) => c.id == CultureId.mayan)
        .firstOrNull;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ChartScreen(birthContext: chart.context))),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              CosmicColors.neonLavender.withValues(alpha: 0.18),
              CosmicColors.neonCyan.withValues(alpha: 0.06),
              CosmicColors.neonPink.withValues(alpha: 0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: CosmicColors.neonLavender.withValues(alpha: 0.5), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('✦ ',
                    style: TextStyle(
                        color: CosmicColors.neonLavender, fontSize: 16)),
                Text(
                  'Paulien  •  13 March 1996',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: CosmicColors.neonLavender, fontSize: 16),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => PersonalityScreen(chart: chart))),
                  child: const Text('Profile →',
                      style: TextStyle(
                          color: CosmicColors.neonCyan, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SignBadge('☉ Pisces', CosmicColors.neonCyan),
                _SignBadge(
                    '☽ ${western.moonSign ?? ''}', CosmicColors.textSecondary),
                _SignBadge(
                    '龍 ${chinese?.sunSign ?? 'Fire Rat'}',
                    CosmicColors.neonPink),
                _SignBadge(
                    '☀ ${mayan?.sunSign ?? 'Ben'}',
                    CosmicColors.neonYellow),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              chart.personality.headline,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: CosmicColors.neonLavender,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              chart.personality.summary.split('.').first + '.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SignBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _SignBadge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(text,
          style: TextStyle(color: color, fontSize: 12, letterSpacing: 0.3)),
    );
  }
}

class _NewReadingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const BirthInputScreen())),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: CosmicColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CosmicColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CosmicColors.neonCyan.withValues(alpha: 0.12),
                border: Border.all(
                    color: CosmicColors.neonCyan.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.add, color: CosmicColors.neonCyan, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New Chart',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text('Enter a birth date, time & place',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: CosmicColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _TraditionsGrid extends StatelessWidget {
  static const _traditions = [
    ('Western', '♈', CosmicColors.western, 'Tropical zodiac, houses, planets'),
    ('Chinese', '龍', CosmicColors.chinese, 'Ba Zi, animals, five elements'),
    ('Vedic', '🕉', CosmicColors.vedic, 'Sidereal, nakshatras, Jyotish'),
    ('Mayan', '☀', CosmicColors.mayan, 'Tzolk\'in, day signs, tones'),
    ('Egyptian', '𓂀', CosmicColors.egyptian, '36 decans, deity rulers'),
    ('Celtic', '🌿', CosmicColors.celtic, 'Tree calendar, ogham, animals'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: _traditions.length,
      itemBuilder: (ctx, i) {
        final (name, emoji, color, desc) = _traditions[i];
        return GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ChartScreen(
              birthContext:
                  ChartEngine().compute(Profile.paulien.birthContext).context,
            ),
          )),
          child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CosmicColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const Spacer(),
              Text(name,
                  style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(desc,
                  style: const TextStyle(
                      color: CosmicColors.textMuted, fontSize: 10),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: CosmicColors.textMuted, letterSpacing: 2),
    );
  }
}
