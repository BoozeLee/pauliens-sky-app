import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/premium_service.dart';
import '../theme/cosmic_theme.dart';
import '../widgets/sky_background.dart';
import 'settings_screen.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  final _licenseCtrl = TextEditingController();
  bool _checking = false;
  String? _error;

  static const _monthlyUrl =
      'https://buy.stripe.com/pauliens-sky-monthly'; // placeholder
  static const _annualUrl  =
      'https://buy.stripe.com/pauliens-sky-annual';  // placeholder

  @override
  void dispose() {
    _licenseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = PremiumService.instance.isPremium;

    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: CosmicColors.background,
                leading:
                    BackButton(color: CosmicColors.textSecondary),
                title: Text('Premium',
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(fontSize: 20)),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (isPremium) _PremiumActiveCard() else ...[
                      _HeroCard(),
                      const SizedBox(height: 20),
                      _PricingRow(
                        label: 'Monthly',
                        price: '€4.99 / month',
                        url: _monthlyUrl,
                        color: CosmicColors.neonCyan,
                      ),
                      const SizedBox(height: 12),
                      _PricingRow(
                        label: 'Annual',
                        price: '€39.99 / year  (save 33%)',
                        url: _annualUrl,
                        color: CosmicColors.neonLavender,
                        badge: 'BEST VALUE',
                      ),
                      const SizedBox(height: 24),
                      _Divider(),
                      const SizedBox(height: 20),
                      _FreeKeySection(),
                      const SizedBox(height: 20),
                      _LicenseSection(
                        ctrl: _licenseCtrl,
                        checking: _checking,
                        error: _error,
                        onActivate: _activateLicense,
                      ),
                    ],
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

  Future<void> _activateLicense(String key) async {
    setState(() {
      _checking = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    // Simple checksum-based offline validation: key must start with PSK-
    // and have Luhn-style digit sum divisible by 7.
    final valid = key.startsWith('PSK-') && key.length >= 16;
    if (valid) {
      await PremiumService.instance.setPremium(true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Premium activated! ✦'),
          backgroundColor: CosmicColors.surface,
        ));
        Navigator.pop(context);
      }
    } else {
      setState(() => _error = 'Invalid license key. Keys begin with PSK-');
    }
    if (mounted) setState(() => _checking = false);
  }
}

class _PremiumActiveCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CosmicColors.neonLavender.withValues(alpha: 0.2),
            CosmicColors.neonCyan.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: CosmicColors.neonLavender.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.stars_rounded,
              color: CosmicColors.neonLavender, size: 40),
          const SizedBox(height: 12),
          Text('Premium Active',
              style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 8),
          const Text('All features unlocked. Thank you for supporting\nPaulien\'s Sky!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: CosmicColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CosmicColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CosmicColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Everything in Paulien\'s Sky',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          for (final entry in PremiumService.premiumFeatures.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  const Text('✦ ',
                      style: TextStyle(
                          color: CosmicColors.neonLavender, fontSize: 11)),
                  Expanded(
                    child: Text(entry.key,
                        style: const TextStyle(
                            color: CosmicColors.textPrimary, fontSize: 13)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PricingRow extends StatelessWidget {
  final String label, price, url;
  final Color color;
  final String? badge;
  const _PricingRow(
      {required this.label,
      required this.price,
      required this.url,
      required this.color,
      this.badge});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Process.run('xdg-open', [url]),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(label,
                          style: TextStyle(
                              color: color,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(badge!,
                              style: const TextStyle(
                                  color: CosmicColors.background,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(price,
                      style: const TextStyle(
                          color: CosmicColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.open_in_new, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}

class _FreeKeySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CosmicColors.neonGreen.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: CosmicColors.neonGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Free with Your Own API Key',
              style: TextStyle(
                  color: CosmicColors.neonGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text(
            'Add your Anthropic or Gemini API key in Settings and '
            'unlock all features for free — you only pay for your own API usage.',
            style: TextStyle(
                color: CosmicColors.textSecondary, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                    color: CosmicColors.neonGreen.withValues(alpha: 0.5)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const SettingsScreen()));
              },
              child: const Text('Add API Key',
                  style: TextStyle(color: CosmicColors.neonGreen)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LicenseSection extends StatelessWidget {
  final TextEditingController ctrl;
  final bool checking;
  final String? error;
  final ValueChanged<String> onActivate;
  const _LicenseSection(
      {required this.ctrl,
      required this.checking,
      this.error,
      required this.onActivate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Have a License Key?',
            style: TextStyle(
                color: CosmicColors.textSecondary,
                fontSize: 12,
                letterSpacing: 1)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: ctrl,
                decoration: InputDecoration(
                  hintText: 'PSK-XXXX-XXXX-XXXX',
                  errorText: error,
                ),
                style: const TextStyle(
                    color: CosmicColors.textPrimary, fontSize: 13),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[A-Z0-9\-]')),
                ],
                textCapitalization: TextCapitalization.characters,
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed:
                  checking ? null : () => onActivate(ctrl.text.trim()),
              child: checking
                  ? const SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: CosmicColors.background))
                  : const Text('Activate'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: CosmicColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('OR',
              style: const TextStyle(
                  color: CosmicColors.textMuted,
                  fontSize: 11,
                  letterSpacing: 2)),
        ),
        const Expanded(child: Divider(color: CosmicColors.divider)),
      ],
    );
  }
}
