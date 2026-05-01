import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/birth_context.dart';
import '../models/culture_chart.dart';
import '../services/chart_engine.dart';
import '../theme/cosmic_theme.dart';
import '../services/fixed_stars.dart';
import '../widgets/culture_card.dart';
import '../widgets/fixed_stars_card.dart';
import '../widgets/sky_background.dart';
import '../widgets/zodiac_wheel.dart';
import 'personality_screen.dart';

class ChartScreen extends StatefulWidget {
  final BirthContext birthContext;
  final int initialTab;
  const ChartScreen({super.key, required this.birthContext, this.initialTab = 0});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen>
    with SingleTickerProviderStateMixin {
  late FullChart _chart;
  late TabController _tabController;
  int _selectedCultureIndex = 0;

  static const _tabs = [
    CultureId.western,
    CultureId.chinese,
    CultureId.vedic,
    CultureId.mayan,
    CultureId.egyptian,
    CultureId.celtic,
    CultureId.zoroastrian,
  ];

  @override
  void initState() {
    super.initState();
    _chart = ChartEngine().compute(widget.birthContext);
    _tabController = TabController(
        length: _tabs.length,
        vsync: this,
        initialIndex: widget.initialTab.clamp(0, _tabs.length - 1));
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.selectionClick();
      }
      setState(() => _selectedCultureIndex = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.birthContext.personName;
    final accent = _tabs[_selectedCultureIndex].accentColor;

    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (ctx, _) => [
              SliverAppBar(
                pinned: true,
                backgroundColor: CosmicColors.background,
                expandedHeight: 320,
                leading: BackButton(color: CosmicColors.textSecondary),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person_search_outlined,
                        color: CosmicColors.neonLavender),
                    tooltip: 'Personality Profile',
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => PersonalityScreen(chart: _chart))),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _WheelHeader(
                    chart: _chart,
                    name: name,
                    accent: accent,
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: accent,
                  labelColor: accent,
                  unselectedLabelColor: CosmicColors.textMuted,
                  labelStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1),
                  tabs: _tabs
                      .map((id) => Tab(text: id.displayName))
                      .toList(),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: _tabs.map((id) {
                final cultureChart = _chart.chart(id);
                if (cultureChart == null) {
                  return const Center(
                      child: Text('No data',
                          style: TextStyle(color: CosmicColors.textMuted)));
                }
                return _CultureDetailView(
                  chart: cultureChart,
                  prominentStars: id == CultureId.western
                      ? _chart.prominentStars
                      : const [],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _WheelHeader extends StatelessWidget {
  final FullChart chart;
  final String? name;
  final Color accent;
  const _WheelHeader({required this.chart, this.name, required this.accent});

  @override
  Widget build(BuildContext context) {
    final ctx = chart.context;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        if (name != null)
          Text(
            name!,
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(color: CosmicColors.neonLavender, fontSize: 18),
          ),
        Text(
          '${ctx.utcTime.day.toString().padLeft(2, '0')} '
          '${_monthName(ctx.utcTime.month)} '
          '${ctx.utcTime.year}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        ZodiacWheel(snapshot: chart.snapshot, size: 200),
        const SizedBox(height: 4),
        Text(
          '${chart.snapshot.moonPhaseName}  •  '
          '${ctx.locationName ?? ''}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  String _monthName(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ][m];
}

class _CultureDetailView extends StatelessWidget {
  final CultureChart chart;
  final List<(FixedStar, double)> prominentStars;
  const _CultureDetailView(
      {required this.chart, this.prominentStars = const []});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CultureCard(chart: chart, expanded: true),
        if (chart.keyInsights.isNotEmpty) ...[
          const SizedBox(height: 16),
          _InsightsBlock(
              insights: chart.keyInsights, accent: chart.id.accentColor),
        ],
        if (prominentStars.isNotEmpty) ...[
          const SizedBox(height: 16),
          FixedStarsCard(stars: prominentStars),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _InsightsBlock extends StatelessWidget {
  final List<String> insights;
  final Color accent;
  const _InsightsBlock({required this.insights, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KEY INSIGHTS',
            style: TextStyle(
                color: accent,
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          for (final insight in insights)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ',
                      style: TextStyle(color: accent, fontSize: 14)),
                  Expanded(
                    child: Text(insight,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(height: 1.5)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
