import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../services/ai_orchestrator.dart';
import '../services/local_llm/device_profile.dart';
import '../services/local_llm/llama_service.dart';
import '../theme/cosmic_theme.dart';
import '../widgets/sky_background.dart';

class _ModelSpec {
  final String id;
  final String name;
  final String description;
  final String url;
  final String filename;
  final int sizeBytes;
  final int ramMb;
  final String deviceTarget;

  const _ModelSpec({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    required this.filename,
    required this.sizeBytes,
    required this.ramMb,
    required this.deviceTarget,
  });

  String get sizeLabel {
    final gb = sizeBytes / (1024 * 1024 * 1024);
    return '${gb.toStringAsFixed(1)} GB';
  }
}

const _models = [
  _ModelSpec(
    id: 'phi3-mini',
    name: 'Phi-3 Mini 4K',
    description: 'Microsoft\'s compact powerhouse. Best balance of '
        'quality and speed for mobile and laptop. Recommended.',
    url: 'https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf'
        '/resolve/main/Phi-3-mini-4k-instruct-q4.gguf',
    filename: 'phi-3-mini-4k-instruct.Q4_K_M.gguf',
    sizeBytes: 2_200_000_000,
    ramMb: 2800,
    deviceTarget: 'Mobile + laptop',
  ),
  _ModelSpec(
    id: 'mistral-7b',
    name: 'Mistral 7B Instruct v0.3',
    description: 'Higher quality responses, deeper astrological reasoning. '
        'Best on laptop. Too large for most phones.',
    url: 'https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF'
        '/resolve/main/mistral-7b-instruct-v0.2.Q4_K_M.gguf',
    filename: 'mistral-7b-instruct-v0.3.Q4_K_M.gguf',
    sizeBytes: 4_100_000_000,
    ramMb: 5200,
    deviceTarget: 'Laptop / desktop only',
  ),
  _ModelSpec(
    id: 'gemma-2b',
    name: 'Gemma 2B Instruct',
    description: 'Google\'s lightest model. Fast on low-end devices. '
        'Less nuanced but surprisingly capable for short readings.',
    url: 'https://huggingface.co/google/gemma-2-2b-it-GGUF'
        '/resolve/main/gemma-2-2b-it-Q4_K_M.gguf',
    filename: 'gemma-2-2b-it-Q4_K_M.gguf',
    sizeBytes: 1_600_000_000,
    ramMb: 2000,
    deviceTarget: 'Low-end mobile',
  ),
];

class ModelManagerScreen extends StatefulWidget {
  const ModelManagerScreen({super.key});

  @override
  State<ModelManagerScreen> createState() => _ModelManagerScreenState();
}

class _ModelManagerScreenState extends State<ModelManagerScreen> {
  final _downloading = <String, double>{};  // modelId → 0.0–1.0
  final _errors      = <String, String>{};
  Set<String>        _present = {};
  String?            _loadingId;

  @override
  void initState() {
    super.initState();
    _refreshPresent();
  }

  Future<void> _refreshPresent() async {
    final files = await LlamaService.listModels();
    // Also scan ~/.local/share/pauliens_sky/models
    final home = Platform.environment['HOME'] ?? '';
    final sysDir = Directory('$home/.local/share/pauliens_sky/models');
    if (await sysDir.exists()) {
      files.addAll(sysDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.gguf')));
    }
    final names = files.map((f) => f.uri.pathSegments.last).toSet();
    setState(() {
      _present = _models
          .where((m) => names.contains(m.filename))
          .map((m) => m.id)
          .toSet();
    });
  }

  Future<void> _download(_ModelSpec spec) async {
    setState(() {
      _downloading[spec.id] = 0.0;
      _errors.remove(spec.id);
    });

    try {
      final dir = await LlamaService.modelsDir();
      final dest = File('${dir.path}/${spec.filename}');

      final request = http.Request('GET', Uri.parse(spec.url));
      final response = await request.send();
      final total = response.contentLength ?? spec.sizeBytes;
      var received = 0;

      final sink = dest.openWrite();
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (mounted) {
          setState(() => _downloading[spec.id] = received / total);
        }
      }
      await sink.flush();
      await sink.close();

      setState(() => _downloading.remove(spec.id));
      await _refreshPresent();
    } catch (e) {
      setState(() {
        _downloading.remove(spec.id);
        _errors[spec.id] = e.toString();
      });
    }
  }

  Future<void> _loadModel(_ModelSpec spec) async {
    setState(() => _loadingId = spec.id);
    try {
      // Try app dir first, then system dir
      final appDir = await LlamaService.modelsDir();
      final appFile = File('${appDir.path}/${spec.filename}');
      final home = Platform.environment['HOME'] ?? '';
      final sysFile = File(
          '$home/.local/share/pauliens_sky/models/${spec.filename}');

      final path = appFile.existsSync()
          ? appFile.path
          : sysFile.existsSync()
              ? sysFile.path
              : '';

      if (path.isEmpty) {
        throw Exception('Model file not found');
      }

      final ok = await LlamaService.instance.loadModel(path);
      if (ok) {
        AiOrchestrator.instance.refreshProvider();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'AETHER loaded: ${LlamaService.instance.loadedModelName}'),
            backgroundColor: CosmicColors.surface,
          ));
        }
      } else {
        throw Exception('Model failed to load (check RAM)');
      }
    } catch (e) {
      setState(() => _errors[spec.id] = e.toString());
    }
    if (mounted) setState(() => _loadingId = null);
  }

  Future<void> _delete(_ModelSpec spec) async {
    final dir = await LlamaService.modelsDir();
    final f   = File('${dir.path}/${spec.filename}');
    if (await f.exists()) await f.delete();
    await _refreshPresent();
  }

  @override
  Widget build(BuildContext context) {
    final profile = DeviceProfile.detect();

    return Scaffold(
      body: SkyBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: CosmicColors.background,
                leading: BackButton(color: CosmicColors.textSecondary),
                title: Text('AETHER Local AI',
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(fontSize: 20)),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _DeviceCard(profile: profile),
                    const SizedBox(height: 16),
                    _StatusCard(),
                    const SizedBox(height: 20),
                    _SectionHeader('AVAILABLE MODELS'),
                    const SizedBox(height: 12),
                    for (final spec in _models) ...[
                      _ModelCard(
                        spec: spec,
                        isPresent: _present.contains(spec.id),
                        isLoaded: LlamaService.instance.isModelLoaded &&
                            LlamaService.instance.loadedModelName
                                .contains(spec.filename.split('.').first),
                        isLoading: _loadingId == spec.id,
                        downloadProgress: _downloading[spec.id],
                        error: _errors[spec.id],
                        onDownload: () => _download(spec),
                        onLoad: () => _loadModel(spec),
                        onDelete: () => _delete(spec),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _ManualPathCard(),
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

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _DeviceCard extends StatelessWidget {
  final DeviceProfile profile;
  const _DeviceCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CosmicColors.neonCyan.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CosmicColors.neonCyan.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.memory, color: CosmicColors.neonCyan, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Device: ${profile.deviceLabel}',
                    style: const TextStyle(
                        color: CosmicColors.neonCyan,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                Text(
                    '${profile.nThreads} threads · ${profile.nCtx} ctx · '
                    '~${profile.estimatedToksPerSec.toStringAsFixed(1)} tok/s est.',
                    style: const TextStyle(
                        color: CosmicColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final llama  = LlamaService.instance;
    final orch   = AiOrchestrator.instance;
    final loaded = llama.isModelLoaded;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: loaded
            ? CosmicColors.neonGreen.withValues(alpha: 0.08)
            : CosmicColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: loaded
                ? CosmicColors.neonGreen.withValues(alpha: 0.3)
                : CosmicColors.divider),
      ),
      child: Row(
        children: [
          Icon(
            loaded ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            color: loaded ? CosmicColors.neonGreen : CosmicColors.textMuted,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loaded
                      ? 'AETHER active — ${llama.loadedModelName}'
                      : 'No local model loaded',
                  style: TextStyle(
                      color: loaded
                          ? CosmicColors.neonGreen
                          : CosmicColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
                Text('Active provider: ${orch.providerLabel}',
                    style: const TextStyle(
                        color: CosmicColors.textMuted, fontSize: 11)),
                if (loaded && llama.lastToksPerSec > 0)
                  Text(
                      '${llama.lastToksPerSec.toStringAsFixed(1)} tok/s last run',
                      style: const TextStyle(
                          color: CosmicColors.textMuted, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final _ModelSpec spec;
  final bool isPresent, isLoaded, isLoading;
  final double? downloadProgress;
  final String? error;
  final VoidCallback onDownload, onLoad, onDelete;

  const _ModelCard({
    required this.spec,
    required this.isPresent,
    required this.isLoaded,
    required this.isLoading,
    required this.downloadProgress,
    required this.error,
    required this.onDownload,
    required this.onLoad,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDownloading = downloadProgress != null;
    final color = isLoaded
        ? CosmicColors.neonGreen
        : isPresent
            ? CosmicColors.neonLavender
            : CosmicColors.textMuted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CosmicColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(spec.name,
                            style: TextStyle(
                                color: color,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                        if (isLoaded) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: CosmicColors.neonGreen
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('ACTIVE',
                                style: TextStyle(
                                    color: CosmicColors.neonGreen,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${spec.sizeLabel} · ${spec.ramMb} MB RAM · ${spec.deviceTarget}',
                        style: const TextStyle(
                            color: CosmicColors.textMuted, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(spec.description,
              style: const TextStyle(
                  color: CosmicColors.textSecondary,
                  fontSize: 12, height: 1.4)),

          if (error != null) ...[
            const SizedBox(height: 8),
            Text('Error: $error',
                style: const TextStyle(
                    color: Color(0xFFFF4444), fontSize: 11)),
          ],

          if (isDownloading) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: downloadProgress,
                backgroundColor: CosmicColors.divider,
                valueColor: const AlwaysStoppedAnimation(
                    CosmicColors.neonLavender),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
                '${(downloadProgress! * 100).toStringAsFixed(1)}%  of ${spec.sizeLabel}',
                style: const TextStyle(
                    color: CosmicColors.textMuted, fontSize: 10)),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              if (!isPresent && !isDownloading)
                _ActionButton(
                  label: 'Download',
                  icon: Icons.download_outlined,
                  color: CosmicColors.neonLavender,
                  onTap: onDownload,
                ),
              if (isPresent && !isLoaded)
                _ActionButton(
                  label: isLoading ? 'Loading…' : 'Load Model',
                  icon: Icons.play_circle_outline,
                  color: CosmicColors.neonGreen,
                  onTap: isLoading ? null : onLoad,
                ),
              if (isPresent) ...[
                const SizedBox(width: 8),
                _ActionButton(
                  label: 'Delete',
                  icon: Icons.delete_outline,
                  color: CosmicColors.textMuted,
                  onTap: onDelete,
                  outline: true,
                ),
              ],
              if (isDownloading)
                const Text('Downloading…',
                    style: TextStyle(
                        color: CosmicColors.neonLavender, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool outline;
  const _ActionButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap,
      this.outline = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: outline ? 0.3 : 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ManualPathCard extends StatefulWidget {
  @override
  State<_ManualPathCard> createState() => _ManualPathCardState();
}

class _ManualPathCardState extends State<_ManualPathCard> {
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CosmicColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CosmicColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Load Custom GGUF Path',
              style: TextStyle(
                  color: CosmicColors.textSecondary,
                  fontSize: 11, letterSpacing: 1)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(
                    hintText: '/home/user/models/my-model.gguf',
                  ),
                  style: const TextStyle(
                      color: CosmicColors.textPrimary, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final path = _ctrl.text.trim();
                  if (path.isEmpty) return;
                  final ok = await LlamaService.instance.loadModel(path);
                  if (ok) AiOrchestrator.instance.refreshProvider();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(ok ? 'Loaded!' : 'Failed to load'),
                      backgroundColor: CosmicColors.surface,
                    ));
                  }
                },
                child: const Text('Load'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: CosmicColors.neonLavender,
          fontSize: 11, letterSpacing: 2,
          fontWeight: FontWeight.w600));
}
