import 'package:flutter/material.dart';
import '../theme/cosmic_theme.dart';
import '../widgets/sky_background.dart';
import 'settings_screen.dart';

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});

  static const _v2Features = [
    ('🔥', 'Zoroastrian Astrology', 'Avestan months, 30 day Yazatas, Season Stars, Amesha Spentas & sacred fire types'),
    ('🗂', 'JSON-Driven UI', 'Entire visual language driven from ui_schema.json — zero hardcode'),
    ('👥', 'Multi-Profile V2', 'Paulien, Nurse & Bernd — all 7 traditions for each person'),
    ('✦', '7 Traditions', 'Western, Vedic, Chinese, Mayan, Egyptian, Celtic + Zoroastrian'),
    ('⭐', 'Fixed Star Analysis', '18 Behenian stars with mythology, herbs & stones'),
    ('🧠', 'AI Astro Chat', 'Claude & Gemini with penta-layer chart context'),
    ('🌅', 'Local AI (AETHER)', 'On-device llama.cpp inference — no cloud needed'),
    ('🎨', 'Tradition Hero Art', 'Per-tradition star-field backgrounds via ImageMagick'),
    ('🌍', 'EN / NL', 'Full Dutch & English throughout'),
  ];

  static const _roadmap = [
    ('🪐', 'JPL Horizons API', 'Sub-arcsecond planetary positions from NASA'),
    ('📡', 'NASA APOD', 'Daily cosmic image on the home screen'),
    ('⏱', 'IERS Delta-T', 'Precise UTC→TT correction for birth charts'),
    ('🌟', 'HYG Star Catalog', '119k stars replacing hardcoded BSC table'),
    ('🔮', 'Prokerala / AstrologyAPI', 'House systems, aspects, transits'),
    ('📊', 'Personality Radar V2', 'Cross-tradition trait synthesis chart'),
    ('📤', 'Share Cards', 'Export any tradition card as PNG'),
    ('🌙', 'Daily Reading Widget', 'Fresh AI reading cached per sunrise'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: CosmicColors.background,
                leading: BackButton(color: CosmicColors.textSecondary),
                title: Text("Paulien's Sky V2",
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(fontSize: 20)),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Hero banner ──────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            CosmicColors.neonLavender.withValues(alpha: 0.18),
                            CosmicColors.neonCyan.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: CosmicColors.neonLavender
                                .withValues(alpha: 0.5)),
                      ),
                      child: Column(children: [
                        const Text('✦', style: TextStyle(fontSize: 32,
                            color: CosmicColors.neonLavender)),
                        const SizedBox(height: 10),
                        Text("Paulien's Sky V2",
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(color: CosmicColors.neonLavender)),
                        const SizedBox(height: 6),
                        const Text('Everything freemium.\nOne sky. Seven traditions.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: CosmicColors.textSecondary,
                                fontSize: 13,
                                height: 1.6)),
                      ]),
                    ),

                    const SizedBox(height: 24),

                    // ── What's new ───────────────────────────────────────
                    _SectionLabel("WHAT'S IN V2"),
                    const SizedBox(height: 12),
                    ..._v2Features.map((f) => _FeatureRow(
                        emoji: f.$1, title: f.$2, desc: f.$3)),

                    const SizedBox(height: 24),

                    // ── AI key CTA ───────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CosmicColors.neonGreen.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: CosmicColors.neonGreen.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Enable AI Features',
                              style: TextStyle(
                                  color: CosmicColors.neonGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          const Text(
                            'Add your Anthropic or Gemini API key in Settings '
                            'to activate Claude & Gemini readings. Free keys available at console.anthropic.com.',
                            style: TextStyle(
                                color: CosmicColors.textSecondary,
                                fontSize: 12,
                                height: 1.5),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: CosmicColors.neonGreen
                                        .withValues(alpha: 0.5)),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => const SettingsScreen()));
                              },
                              child: const Text('Add API Key → Settings',
                                  style: TextStyle(
                                      color: CosmicColors.neonGreen)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Roadmap ──────────────────────────────────────────
                    _SectionLabel('COMING NEXT'),
                    const SizedBox(height: 12),
                    ..._roadmap.map((f) => _FeatureRow(
                        emoji: f.$1, title: f.$2, desc: f.$3,
                        muted: true)),

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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: CosmicColors.textMuted,
          fontSize: 10,
          letterSpacing: 2,
          fontWeight: FontWeight.w600));
}

class _FeatureRow extends StatelessWidget {
  final String emoji, title, desc;
  final bool muted;
  const _FeatureRow(
      {required this.emoji,
      required this.title,
      required this.desc,
      this.muted = false});

  @override
  Widget build(BuildContext context) {
    final accent =
        muted ? CosmicColors.textMuted : CosmicColors.neonLavender;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: muted
                            ? CosmicColors.textSecondary
                            : CosmicColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(desc,
                    style: TextStyle(
                        color: muted
                            ? CosmicColors.textMuted
                            : CosmicColors.textSecondary,
                        fontSize: 11,
                        height: 1.4)),
              ],
            ),
          ),
          if (!muted)
            const Icon(Icons.check_circle_outline,
                color: CosmicColors.neonGreen, size: 16),
          if (muted)
            const Icon(Icons.radio_button_unchecked,
                color: CosmicColors.textMuted, size: 16),
        ],
      ),
    );
  }
}
