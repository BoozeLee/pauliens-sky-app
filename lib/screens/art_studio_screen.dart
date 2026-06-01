import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../services/art_generation_service.dart';
import '../services/download_helper.dart';
import '../services/premium_service.dart';
import '../state/app_state.dart';
import '../theme/cosmic_theme.dart';
import '../widgets/sky_background.dart';

class ArtStudioScreen extends StatefulWidget {
  const ArtStudioScreen({super.key});
  @override
  State<ArtStudioScreen> createState() => _ArtStudioScreenState();
}

class _ArtStudioScreenState extends State<ArtStudioScreen> {
  final _promptCtrl = TextEditingController();
  String _selectedStyle = 'astrological';
  bool _generating = false;
  ArtGenerationResult? _result;
  String? _error;

  @override
  void dispose() {
    _promptCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final state = context.read<AppState>();
    final chart = state.chart;
    if (chart == null) {
      setState(() => _error = 'Compute a chart first on the Chart tab');
      return;
    }
    final premium = PremiumService.instance;
    if (!premium.hasAnyKey) { _showNoKeySheet(); return; }
    setState(() { _generating = true; _error = null; _result = null; });
    try {
      final western = chart.charts.firstOrNull;
      final sun = western?.sunSign ?? 'unknown';
      final moon = western?.moonSign ?? 'unknown';
      final asc = western?.ascendantSign ?? 'unknown';
      final prompt = ArtGenerationService.buildPrompt(
        culture: 'Western', sunSign: sun, moonSign: moon, risingSign: asc,
        userDescription: _promptCtrl.text.isNotEmpty ? _promptCtrl.text : null,
        birthDate: '${chart.context.utcTime.day}/${chart.context.utcTime.month}/${chart.context.utcTime.year}',
        birthPlace: chart.context.locationName,
      );
      final result = await ArtGenerationService.generate(prompt: prompt, style: _selectedStyle);
      setState(() { _result = result; _generating = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _generating = false; });
    }
  }

  void _downloadArt() {
    final bytes = _result?.bytes;
    if (bytes == null) return;
    downloadFile(bytes, 'pauliens-sky-art.png');
  }

  void _showNoKeySheet() {
    showModalBottomSheet(context: context, builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.psychology, size: 48, color: CosmicColors.neonPink),
        const SizedBox(height: 16),
        Text('AI art not available', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Configure API keys in Settings to generate art.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),
        FilledButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
      ]),
    ));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SkyBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    child: _buildBody(),
                  ),
                ),
              ),
              _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(children: [
        Icon(Icons.brush, color: CosmicColors.neonCyan, size: 20),
        const SizedBox(width: 8),
        Text('Art Studio', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: CosmicColors.textPrimary, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildBody() {
    if (_generating) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        CircularProgressIndicator(color: CosmicColors.neonLavender),
        const SizedBox(height: 16),
        Text('Creating your cosmic art…', style: TextStyle(color: CosmicColors.textSecondary)),
      ]));
    }
    if (_error != null) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, size: 48, color: CosmicColors.neonOrange),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: CosmicColors.neonOrange)),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: _generate, child: const Text('Try Again')),
        ]),
      ));
    }
    if (_result != null) {
      final svgStr = _result!.svgString;
      final Widget display = svgStr.isNotEmpty
          ? SvgPicture.string(svgStr, fit: BoxFit.contain)
          : Image.memory(_result!.bytes, fit: BoxFit.contain);
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(16), child: display),
            Positioned(
              top: 8,
              right: 8,
              child: _DownloadButton(
                onDownload: () => _downloadArt(),
                onRegenerate: () => _generate(),
              ),
            ),
          ],
        ),
      );
    }
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.auto_awesome, size: 64, color: CosmicColors.neonPink.withAlpha(128)),
        const SizedBox(height: 16),
        Text('Describe your cosmic vision', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: CosmicColors.textSecondary)),
        const SizedBox(height: 8),
        Text('Enter a prompt below\nto generate astrological art.', textAlign: TextAlign.center, style: TextStyle(color: CosmicColors.textMuted, fontSize: 13)),
      ]),
    ));
  }

  Widget _buildControls() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: CosmicColors.surface.withAlpha(230),
        border: Border(top: BorderSide(color: CosmicColors.divider, width: 0.5)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ArtGenerationService.styles.map((style) {
              final selected = style == _selectedStyle;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(ArtGenerationService.styleLabels[style] ?? style, style: TextStyle(fontSize: 12, color: selected ? Colors.white : CosmicColors.textSecondary)),
                  selected: selected,
                  selectedColor: CosmicColors.neonCyan.withAlpha(60),
                  backgroundColor: CosmicColors.surface,
                  side: BorderSide(color: selected ? CosmicColors.neonCyan : CosmicColors.divider, width: selected ? 1.5 : 0.5),
                  onSelected: (v) => setState(() => _selectedStyle = style),
                  visualDensity: VisualDensity.compact,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _promptCtrl,
              style: TextStyle(color: CosmicColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. "a cosmic phoenix"',
                hintStyle: TextStyle(color: CosmicColors.textMuted, fontSize: 13),
                filled: true,
                fillColor: CosmicColors.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 42,
            child: FilledButton.icon(
              onPressed: _generating ? null : _generate,
              icon: Icon(_generating ? Icons.hourglass_top : Icons.auto_awesome, size: 18),
              label: const Text('Generate', style: TextStyle(fontSize: 13)),
              style: FilledButton.styleFrom(
                backgroundColor: CosmicColors.neonCyan.withAlpha(50),
                foregroundColor: CosmicColors.neonCyan,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: CosmicColors.neonCyan.withAlpha(100))),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  final VoidCallback onDownload;
  final VoidCallback onRegenerate;
  const _DownloadButton({required this.onDownload, required this.onRegenerate});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _iconBtn(Icons.download, 'Download', onDownload),
        const SizedBox(width: 6),
        _iconBtn(Icons.refresh, 'Regenerate', onRegenerate),
      ],
    );
  }

  Widget _iconBtn(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: CosmicColors.surface.withAlpha(200),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CosmicColors.divider, width: 0.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(icon, color: CosmicColors.textSecondary, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}
