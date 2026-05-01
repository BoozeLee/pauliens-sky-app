import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/culture_chart.dart';
import '../models/profile.dart';
import '../services/chart_engine.dart';
import '../services/locale_service.dart';
import '../services/ui_schema.dart';
import '../state/app_state.dart';
import '../theme/cosmic_theme.dart';
import '../widgets/apod_card.dart';
import '../widgets/daily_reading_card.dart';
import '../widgets/schema_card.dart';
import '../widgets/sky_background.dart';
import 'birth_input_screen.dart';
import 'chart_screen.dart';
import 'personality_screen.dart';
import 'profile_comparison_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final chart = appState.chart;

    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: _Header(appState: appState),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (chart != null) ...[
                      _ProfileCard(appState: appState, chart: chart),
                      const SizedBox(height: 20),
                      DailyReadingCard(chart: chart),
                      const SizedBox(height: 12),
                      if (appState.profiles.length > 1)
                        _CompareButton(appState: appState),
                      const SizedBox(height: 24),
                    ],
                    _SectionLabel('READ A NEW SKY'),
                    const SizedBox(height: 12),
                    const _NewReadingButton(),
                    const SizedBox(height: 24),
                    _SectionLabel('TODAY IN THE COSMOS'),
                    const SizedBox(height: 12),
                    const ApodCard(),
                    const SizedBox(height: 24),
                    _SectionLabel('TRADITIONS'),
                    const SizedBox(height: 12),
                    _TraditionsGrid(chart: chart),
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

// ── Header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final AppState appState;
  const _Header({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
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
          ),
        ),
        // Profile switcher if premium + multiple profiles
        if (appState.profiles.length > 1)
          _ProfileSwitcher(appState: appState),
      ],
    );
  }
}

class _ProfileSwitcher extends StatelessWidget {
  final AppState appState;
  const _ProfileSwitcher({required this.appState});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: CosmicColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (id) => appState.switchProfile(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: CosmicColors.neonLavender.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: CosmicColors.neonLavender.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline,
                color: CosmicColors.neonLavender, size: 16),
            const SizedBox(width: 4),
            Text(
              appState.activeProfile.name,
              style: const TextStyle(
                  color: CosmicColors.neonLavender, fontSize: 12),
            ),
            const Icon(Icons.arrow_drop_down,
                color: CosmicColors.neonLavender, size: 16),
          ],
        ),
      ),
      itemBuilder: (_) => appState.profiles
          .map((p) => PopupMenuItem<String>(
                value: p.id,
                child: Row(
                  children: [
                    Icon(
                      p.id == appState.activeProfile.id
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: CosmicColors.neonLavender,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(p.name,
                        style: const TextStyle(
                            color: CosmicColors.textPrimary, fontSize: 13)),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

// ── Profile card ───────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final AppState appState;
  final FullChart chart;
  const _ProfileCard({required this.appState, required this.chart});

  @override
  Widget build(BuildContext context) {
    final western = chart.charts.first;
    final chinese = chart.charts
        .where((c) => c.id == CultureId.chinese)
        .firstOrNull;
    final mayan =
        chart.charts.where((c) => c.id == CultureId.mayan).firstOrNull;
    final profile = appState.activeProfile;

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
              color: CosmicColors.neonLavender.withValues(alpha: 0.5),
              width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('✦ ',
                    style: const TextStyle(
                        color: CosmicColors.neonLavender, fontSize: 16)),
                Expanded(
                  child: Text(
                    '${profile.name}  •  '
                    '${chart.context.utcTime.day} '
                    '${_monthName(chart.context.utcTime.month)} '
                    '${chart.context.utcTime.year}',
                    style:
                        Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: CosmicColors.neonLavender, fontSize: 15),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) =>
                              PersonalityScreen(chart: chart))),
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
                SchemaSignBadge('☉ ${western.sunSign ?? 'Pisces'}',
                    CosmicColors.neonCyan),
                SchemaSignBadge(
                    '☽ ${western.moonSign ?? ''}',
                    CosmicColors.textSecondary),
                SchemaSignBadge(
                    '龍 ${chinese?.sunSign ?? 'Wood Rat'}',
                    CosmicColors.neonPink),
                SchemaSignBadge(
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
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.6),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][m];
}

// ── Compare profiles button ────────────────────────────────────────────────

class _CompareButton extends StatelessWidget {
  final AppState appState;
  const _CompareButton({required this.appState});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ProfileComparisonScreen(appState: appState))),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: CosmicColors.neonPink.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: CosmicColors.neonPink.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.compare_arrows,
                color: CosmicColors.neonPink, size: 16),
            const SizedBox(width: 8),
            Text('Compare Profiles',
                style: const TextStyle(
                    color: CosmicColors.neonPink, fontSize: 13)),
            const SizedBox(width: 4),
            Text('(${appState.profiles.length})',
                style: const TextStyle(
                    color: CosmicColors.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ── New reading button ─────────────────────────────────────────────────────

class _NewReadingButton extends StatelessWidget {
  const _NewReadingButton();

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
              child: const Icon(Icons.add,
                  color: CosmicColors.neonCyan, size: 20),
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

// ── Traditions grid ────────────────────────────────────────────────────────

class _TraditionsGrid extends StatelessWidget {
  final FullChart? chart;
  const _TraditionsGrid({this.chart});

  @override
  Widget build(BuildContext context) {
    final isNl = context.watch<LocaleService>().isNl;
    final traditions = [...UiSchema.instance.traditions]
      ..sort((a, b) => a.tabIndex.compareTo(b.tabIndex));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemCount: traditions.length,
      itemBuilder: (ctx, i) {
        final trad = traditions[i];
        return TraditionCard(
          tradition: trad,
          label: isNl ? trad.labelNl : trad.labelEn,
          description: isNl ? trad.descriptionNl : trad.descriptionEn,
          onTap: () {
            final bc = chart?.context ?? Profile.paulien.birthContext;
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  ChartScreen(birthContext: bc, initialTab: trad.tabIndex),
            ));
          },
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
