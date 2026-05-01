import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/apod_service.dart';
import '../theme/cosmic_theme.dart';

class ApodCard extends StatefulWidget {
  const ApodCard({super.key});

  @override
  State<ApodCard> createState() => _ApodCardState();
}

class _ApodCardState extends State<ApodCard> {
  ApodData? _data;
  bool _loading = true;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await ApodService.instance.fetchToday();
    if (mounted) setState(() { _data = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _Shell(child: const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator(
          strokeWidth: 1.5, color: CosmicColors.neonCyan)),
      ));
    }
    if (_data == null) return const SizedBox.shrink();

    final apod = _data!;
    return _Shell(
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Label(),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: apod.thumbnailUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 180,
                  color: CosmicColors.card,
                  child: const Center(child: CircularProgressIndicator(
                    strokeWidth: 1.5, color: CosmicColors.neonCyan)),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 180, color: CosmicColors.card,
                  child: const Icon(Icons.image_not_supported,
                      color: CosmicColors.textMuted),
                ),
              ),
            ),
            if (apod.mediaType == 'video')
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(children: [
                  const Icon(Icons.play_circle_outline,
                      size: 14, color: CosmicColors.neonCyan),
                  const SizedBox(width: 4),
                  Text('Video (YouTube)', style: Theme.of(context)
                      .textTheme.labelSmall
                      ?.copyWith(color: CosmicColors.neonCyan)),
                ]),
              ),
            const SizedBox(height: 10),
            Text(apod.title,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontSize: 14, color: CosmicColors.neonLavender)),
            const SizedBox(height: 6),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Text(
                apod.explanation,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme.bodyMedium?.copyWith(height: 1.55),
              ),
              secondChild: Text(
                apod.explanation,
                style: Theme.of(context)
                    .textTheme.bodyMedium?.copyWith(height: 1.55),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (apod.copyright != null) ...[
                  Text('© ${apod.copyright}',
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: CosmicColors.textMuted)),
                  const Spacer(),
                ],
                Text(_expanded ? 'Show less ↑' : 'Read more ↓',
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: CosmicColors.neonCyan)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Shell extends StatelessWidget {
  final Widget child;
  const _Shell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CosmicColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CosmicColors.divider),
      ),
      child: child,
    );
  }
}

class _Label extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Text('🌌 ', style: TextStyle(fontSize: 14)),
      Text('ASTRONOMY PICTURE OF THE DAY',
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: CosmicColors.textMuted, letterSpacing: 1.5)),
      const Spacer(),
      Text('NASA', style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: CosmicColors.neonCyan)),
    ]);
  }
}
