import 'package:flutter/material.dart';
import '../models/culture_chart.dart';
import '../models/synastry_chart.dart';
import '../services/chart_engine.dart';
import '../services/synastry_engine.dart';
import '../state/app_state.dart';
import '../theme/cosmic_theme.dart';
import '../widgets/sky_background.dart';

class ProfileComparisonScreen extends StatefulWidget {
  final AppState appState;
  const ProfileComparisonScreen({super.key, required this.appState});

  @override
  State<ProfileComparisonScreen> createState() =>
      _ProfileComparisonScreenState();
}

class _ProfileComparisonScreenState extends State<ProfileComparisonScreen> {
  late String _idA;
  late String _idB;
  final _engine = ChartEngine();
  final _synastry = SynastryEngine();

  @override
  void initState() {
    super.initState();
    final profiles = widget.appState.profiles;
    _idA = widget.appState.activeProfile.id;
    _idB = profiles.firstWhere((p) => p.id != _idA,
            orElse: () => profiles.first)
        .id;
  }

  FullChart _chartFor(String id) {
    final profile =
        widget.appState.profiles.firstWhere((p) => p.id == id);
    return widget.appState.chartFor(profile.id) ??
        _engine.compute(profile.birthContext);
  }

  @override
  Widget build(BuildContext context) {
    final profiles = widget.appState.profiles;
    final chartA = _chartFor(_idA);
    final chartB = _chartFor(_idB);

    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverAppBar(
                backgroundColor: Colors.transparent,
                title: Text('Profile Comparison'),
                floating: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _ProfilePickers(
                      profiles: profiles,
                      idA: _idA,
                      idB: _idB,
                      onA: (v) => setState(() => _idA = v),
                      onB: (v) => setState(() => _idB = v),
                    ),
                    const SizedBox(height: 24),
                    _SignsRow(chartA: chartA, chartB: chartB),
                    const SizedBox(height: 24),
                    _SharedTraitsCard(chartA: chartA, chartB: chartB),
                    const SizedBox(height: 24),
                    _RadarCompare(chartA: chartA, chartB: chartB),
                    const SizedBox(height: 24),
                    _TraditionsCompare(chartA: chartA, chartB: chartB),
                    const SizedBox(height: 24),
                    _SynastrySection(
                      synastry: _synastry.compute(chartA, chartB),
                      colorA: CosmicColors.neonLavender,
                      colorB: CosmicColors.neonCyan,
                    ),
                    const SizedBox(height: 40),
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

// ── Profile pickers ─────────────────────────────────────────────────────────

class _ProfilePickers extends StatelessWidget {
  final List profiles;
  final String idA, idB;
  final ValueChanged<String> onA, onB;
  const _ProfilePickers(
      {required this.profiles,
      required this.idA,
      required this.idB,
      required this.onA,
      required this.onB});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Picker(profiles: profiles, value: idA, onChanged: onA,
            color: CosmicColors.neonLavender)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.compare_arrows,
              color: CosmicColors.neonPink, size: 20),
        ),
        Expanded(child: _Picker(profiles: profiles, value: idB, onChanged: onB,
            color: CosmicColors.neonCyan)),
      ],
    );
  }
}

class _Picker extends StatelessWidget {
  final List profiles;
  final String value;
  final ValueChanged<String> onChanged;
  final Color color;
  const _Picker(
      {required this.profiles,
      required this.value,
      required this.onChanged,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: CosmicColors.surface,
          style: TextStyle(color: color, fontSize: 14),
          icon: Icon(Icons.arrow_drop_down, color: color, size: 18),
          isExpanded: true,
          onChanged: (v) { if (v != null) onChanged(v); },
          items: profiles
              .map((p) => DropdownMenuItem<String>(
                    value: p.id as String,
                    child: Text(p.name as String,
                        style: TextStyle(color: color)),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ── Signs row ────────────────────────────────────────────────────────────────

class _SignsRow extends StatelessWidget {
  final FullChart chartA, chartB;
  const _SignsRow({required this.chartA, required this.chartB});

  @override
  Widget build(BuildContext context) {
    final wA = chartA.charts.first;
    final wB = chartB.charts.first;

    return Row(
      children: [
        Expanded(child: _SignChip(
            '☉ ${wA.sunSign ?? '?'}', CosmicColors.neonLavender)),
        Expanded(child: _SignChip(
            '☉ ${wB.sunSign ?? '?'}', CosmicColors.neonCyan)),
      ],
    );
  }
}

class _SignChip extends StatelessWidget {
  final String label;
  final Color color;
  const _SignChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(color: color, fontSize: 13,
              fontWeight: FontWeight.w600)),
    );
  }
}

// ── Shared traits ─────────────────────────────────────────────────────────────

class _SharedTraitsCard extends StatelessWidget {
  final FullChart chartA, chartB;
  const _SharedTraitsCard({required this.chartA, required this.chartB});

  @override
  Widget build(BuildContext context) {
    final traitsA = Set<String>.from(chartA.personality.coreTraits);
    final traitsB = Set<String>.from(chartB.personality.coreTraits);
    final shared = traitsA.intersection(traitsB).toList();
    final onlyA = traitsA.difference(traitsB).toList();
    final onlyB = traitsB.difference(traitsA).toList();

    final nameA = chartA.context.personName ?? 'A';
    final nameB = chartB.context.personName ?? 'B';

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('✦ Personality Resonance'),
          const SizedBox(height: 12),
          if (shared.isNotEmpty) ...[
            const _SubLabel('SHARED'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: shared
                  .map((t) => _TraitChip(t, CosmicColors.neonPink))
                  .toList(),
            ),
            const SizedBox(height: 12),
          ] else
            Text('No overlapping core traits — complementary natures.',
                style: Theme.of(context)
                    .textTheme.bodyMedium
                    ?.copyWith(color: CosmicColors.textMuted)),
          if (onlyA.isNotEmpty) ...[
            _SubLabel('UNIQUE TO $nameA'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: onlyA
                  .map((t) => _TraitChip(t, CosmicColors.neonLavender))
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],
          if (onlyB.isNotEmpty) ...[
            _SubLabel('UNIQUE TO $nameB'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: onlyB
                  .map((t) => _TraitChip(t, CosmicColors.neonCyan))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _TraitChip extends StatelessWidget {
  final String label;
  final Color color;
  const _TraitChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 11)),
    );
  }
}

// ── Radar compare ─────────────────────────────────────────────────────────────

class _RadarCompare extends StatelessWidget {
  final FullChart chartA, chartB;
  const _RadarCompare({required this.chartA, required this.chartB});

  @override
  Widget build(BuildContext context) {
    final pA = chartA.personality;
    final pB = chartB.personality;
    final nameA = chartA.context.personName ?? 'A';
    final nameB = chartB.context.personName ?? 'B';

    final dims = [
      ('Intuition', pA.intuition, pB.intuition),
      ('Creativity', pA.creativity, pB.creativity),
      ('Intellect', pA.intellect, pB.intellect),
      ('Drive', pA.drive, pB.drive),
      ('Empathy', pA.empathy, pB.empathy),
      ('Independence', pA.independence, pB.independence),
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('◎ Trait Comparison'),
          const SizedBox(height: 8),
          Row(children: [
            const _Dot(CosmicColors.neonLavender), const SizedBox(width: 4),
            Text(nameA, style: const TextStyle(
                color: CosmicColors.neonLavender, fontSize: 11)),
            const SizedBox(width: 12),
            const _Dot(CosmicColors.neonCyan), const SizedBox(width: 4),
            Text(nameB, style: const TextStyle(
                color: CosmicColors.neonCyan, fontSize: 11)),
          ]),
          const SizedBox(height: 14),
          ...dims.map((d) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TraitBar(d.$1, d.$2, d.$3),
          )),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);

  @override
  Widget build(BuildContext context) => Container(
    width: 8, height: 8,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

class _TraitBar extends StatelessWidget {
  final String label;
  final double valA, valB;
  const _TraitBar(this.label, this.valA, this.valB);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 90,
              child: Text(label,
                  style: Theme.of(context)
                      .textTheme.labelSmall
                      ?.copyWith(color: CosmicColors.textSecondary)),
            ),
            Expanded(
              child: Stack(children: [
                Container(height: 6, decoration: BoxDecoration(
                    color: CosmicColors.card,
                    borderRadius: BorderRadius.circular(3))),
                FractionallySizedBox(
                  widthFactor: valA,
                  child: Container(height: 6, decoration: BoxDecoration(
                      color: CosmicColors.neonLavender.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(3))),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment(valB * 2 - 1, 0),
                    child: Container(
                      width: 3, height: 10,
                      decoration: BoxDecoration(
                        color: CosmicColors.neonCyan,
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Traditions compare ────────────────────────────────────────────────────────

class _TraditionsCompare extends StatelessWidget {
  final FullChart chartA, chartB;
  const _TraditionsCompare({required this.chartA, required this.chartB});

  @override
  Widget build(BuildContext context) {
    final nameA = chartA.context.personName ?? 'A';
    final nameB = chartB.context.personName ?? 'B';

    final rows = <_TradRow>[];
    for (final cA in chartA.charts) {
      final cB = chartB.charts.where((c) => c.id == cA.id).firstOrNull;
      if (cB == null) continue;
      rows.add(_TradRow(
        id: cA.id,
        sunA: cA.sunSign,
        moonA: cA.moonSign,
        sunB: cB.sunSign,
        moonB: cB.moonSign,
      ));
    }

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('◈ Signs by Tradition'),
          const SizedBox(height: 8),
          Row(children: [
            const SizedBox(width: 80),
            Expanded(child: Text(nameA, textAlign: TextAlign.center,
                style: const TextStyle(
                    color: CosmicColors.neonLavender, fontSize: 11))),
            Expanded(child: Text(nameB, textAlign: TextAlign.center,
                style: const TextStyle(
                    color: CosmicColors.neonCyan, fontSize: 11))),
          ]),
          const SizedBox(height: 8),
          ...rows.map((r) => _TraditionRow(row: r)),
        ],
      ),
    );
  }
}

class _TradRow {
  final CultureId id;
  final String? sunA, moonA, sunB, moonB;
  const _TradRow(
      {required this.id,
      this.sunA,
      this.moonA,
      this.sunB,
      this.moonB});
}

class _TraditionRow extends StatelessWidget {
  final _TradRow row;
  const _TraditionRow({required this.row});

  String _icon(CultureId id) {
    switch (id) {
      case CultureId.western: return '☉';
      case CultureId.vedic: return '🕉';
      case CultureId.chinese: return '龍';
      case CultureId.mayan: return '☀';
      case CultureId.egyptian: return '𓂀';
      case CultureId.celtic: return '🌿';
      case CultureId.zoroastrian: return '🔥';
      case CultureId.babylonian: return '𒀭';
    }
  }

  String _name(CultureId id) {
    switch (id) {
      case CultureId.western: return 'Western';
      case CultureId.vedic: return 'Vedic';
      case CultureId.chinese: return 'Chinese';
      case CultureId.mayan: return 'Mayan';
      case CultureId.egyptian: return 'Egyptian';
      case CultureId.celtic: return 'Celtic';
      case CultureId.zoroastrian: return 'Zoroas.';
      case CultureId.babylonian: return 'Babylon.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(
          width: 80,
          child: Text('${_icon(row.id)} ${_name(row.id)}',
              style: Theme.of(context)
                  .textTheme.labelSmall
                  ?.copyWith(color: CosmicColors.textMuted)),
        ),
        Expanded(
          child: Text(row.sunA ?? '—',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: CosmicColors.neonLavender, fontSize: 12)),
        ),
        Expanded(
          child: Text(row.sunB ?? '—',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: CosmicColors.neonCyan, fontSize: 12)),
        ),
      ]),
    );
  }
}

// ── Synastry section ─────────────────────────────────────────────────────────

class _SynastrySection extends StatelessWidget {
  final SynastryChart synastry;
  final Color colorA, colorB;
  const _SynastrySection(
      {required this.synastry, required this.colorA, required this.colorB});

  @override
  Widget build(BuildContext context) {
    final pct = (synastry.score * 100).round();
    final harmonic = synastry.harmonious.take(8).toList();
    final tense = synastry.challenging.take(5).toList();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('♃ Synastry — Celestial Compatibility'),
          const SizedBox(height: 14),
          // Score bar
          Row(children: [
            Text('$pct%',
                style: TextStyle(
                    color: _scoreColor(synastry.score),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: synastry.score,
                      minHeight: 8,
                      backgroundColor: CosmicColors.card,
                      valueColor: AlwaysStoppedAnimation(
                          _scoreColor(synastry.score)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_scoreLabel(synastry.score),
                      style: TextStyle(
                          color: _scoreColor(synastry.score),
                          fontSize: 11,
                          letterSpacing: 1)),
                ],
              ),
            ),
          ]),
          if (harmonic.isNotEmpty) ...[
            const SizedBox(height: 16),
            const _SubLabel('HARMONIOUS ASPECTS'),
            const SizedBox(height: 8),
            ...harmonic.map((a) => _AspectRow(a, colorA, colorB,
                color: CosmicColors.neonGreen)),
          ],
          if (tense.isNotEmpty) ...[
            const SizedBox(height: 12),
            const _SubLabel('DYNAMIC TENSIONS'),
            const SizedBox(height: 8),
            ...tense.map((a) => _AspectRow(a, colorA, colorB,
                color: CosmicColors.neonPink)),
          ],
          if (synastry.aspects.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'No exact aspects found within standard orbs.',
                style: Theme.of(context)
                    .textTheme.bodyMedium
                    ?.copyWith(color: CosmicColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score >= 0.75) return CosmicColors.neonGreen;
    if (score >= 0.55) return CosmicColors.neonYellow;
    if (score >= 0.4) return CosmicColors.neonCyan;
    return CosmicColors.neonPink;
  }

  String _scoreLabel(double score) {
    if (score >= 0.80) return 'HIGHLY RESONANT';
    if (score >= 0.65) return 'STRONGLY COMPATIBLE';
    if (score >= 0.50) return 'HARMONIOUS';
    if (score >= 0.38) return 'DYNAMIC';
    return 'TRANSFORMATIVE TENSION';
  }
}

class _AspectRow extends StatelessWidget {
  final SynastryAspect aspect;
  final Color colorA, colorB, color;
  const _AspectRow(this.aspect, this.colorA, this.colorB,
      {required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        // Aspect symbol
        Container(
          width: 28,
          alignment: Alignment.center,
          child: Text(aspect.type.symbol,
              style: TextStyle(color: color, fontSize: 14)),
        ),
        const SizedBox(width: 6),
        // Person A planet
        Text(aspect.pointLabelA,
            style: TextStyle(color: colorA, fontSize: 12,
                fontWeight: FontWeight.w500)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(aspect.type.label,
              style: const TextStyle(
                  color: CosmicColors.textMuted, fontSize: 10)),
        ),
        // Person B planet
        Text(aspect.pointLabelB,
            style: TextStyle(color: colorB, fontSize: 12,
                fontWeight: FontWeight.w500)),
        const Spacer(),
        // Orb
        Text('${aspect.orb.toStringAsFixed(1)}°',
            style: const TextStyle(
                color: CosmicColors.textMuted, fontSize: 11)),
        // Strength bar
        const SizedBox(width: 6),
        SizedBox(
          width: 36,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: aspect.strength,
              minHeight: 4,
              backgroundColor: CosmicColors.divider,
              valueColor: AlwaysStoppedAnimation(
                  color.withValues(alpha: 0.7)),
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: CosmicColors.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: CosmicColors.divider),
    ),
    child: child,
  );
}

class _CardTitle extends StatelessWidget {
  final String text;
  const _CardTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: Theme.of(context)
          .textTheme.headlineMedium
          ?.copyWith(fontSize: 14, color: CosmicColors.neonLavender));
}

class _SubLabel extends StatelessWidget {
  final String text;
  const _SubLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: Theme.of(context)
          .textTheme.labelSmall
          ?.copyWith(color: CosmicColors.textMuted, letterSpacing: 1.5));
}
