import 'package:flutter/material.dart';
import '../screens/settings_screen.dart';
import '../screens/upgrade_screen.dart';
import '../services/premium_service.dart';
import '../theme/cosmic_theme.dart';

class PremiumGate extends StatelessWidget {
  final String feature;
  final Widget child;
  final String? customLabel;

  const PremiumGate({
    super.key,
    required this.feature,
    required this.child,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final premium = PremiumService.instance;
    if (premium.canUse(feature)) return child;

    return Stack(
      children: [
        // Blurred/dimmed child
        Opacity(opacity: 0.25, child: IgnorePointer(child: child)),
        // Lock overlay
        Positioned.fill(
          child: GestureDetector(
            onTap: () => _showUpgradeSheet(context),
            child: Container(
              decoration: BoxDecoration(
                color: CosmicColors.background.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: CosmicColors.neonLavender.withValues(alpha: 0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline,
                      color: CosmicColors.neonLavender, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    customLabel ?? 'Premium Feature',
                    style: const TextStyle(
                        color: CosmicColors.neonLavender,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to unlock',
                    style: const TextStyle(
                        color: CosmicColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showUpgradeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: CosmicColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => const _UpgradeSheet(),
    );
  }
}

class _UpgradeSheet extends StatelessWidget {
  const _UpgradeSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: CosmicColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text('Unlock Premium',
              style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 8),
          Text(
            'Add your own API key or subscribe to unlock all traditions, '
            'unlimited AI readings, and the full Paulien\'s Sky experience.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          for (final entry in PremiumService.premiumFeatures.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  const Text('✦ ',
                      style: TextStyle(
                          color: CosmicColors.neonLavender, fontSize: 12)),
                  Expanded(
                    child: Text(entry.key,
                        style: const TextStyle(
                            color: CosmicColors.textPrimary, fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const UpgradeScreen(),
                ));
              },
              child: const Text('UPGRADE TO PREMIUM'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ));
              },
              child: const Text('Add API Key — Unlock Free'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
