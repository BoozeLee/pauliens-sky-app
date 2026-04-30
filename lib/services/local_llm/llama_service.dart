/// LlamaService — high-level Dart API over libaether_llm.so
/// Inference runs in a separate Isolate so the UI thread never blocks.
/// Tokens stream back via a SendPort/ReceivePort pair.

import 'dart:ffi';
import 'dart:isolate';
import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'llama_ffi.dart';
import 'device_profile.dart';

// ── Messages between main isolate and inference isolate ──────────────────

class _LoadRequest {
  final String modelPath;
  final int nThreads;
  final int nCtx;
  final int nGpuLayers;
  final SendPort replyPort;
  const _LoadRequest(this.modelPath, this.nThreads, this.nCtx,
      this.nGpuLayers, this.replyPort);
}

class _InferRequest {
  final String prompt;
  final int maxTokens;
  final double temperature;
  final double topP;
  final SendPort tokenPort; // receives strings; 'DONE' = finished; 'ERR:…' = error
  const _InferRequest(this.prompt, this.maxTokens, this.temperature,
      this.topP, this.tokenPort);
}

// ── Isolate entry ─────────────────────────────────────────────────────────

void _inferenceIsolate(SendPort mainPort) {
  final lib = AetherLlamaLib.tryLoad();
  if (lib == null) {
    mainPort.send('ERROR: libaether_llm.so not found');
    return;
  }

  final incoming = ReceivePort();
  mainPort.send(incoming.sendPort);

  AetherContextPtr? ctx;

  incoming.listen((msg) {
    if (msg is _LoadRequest) {
      if (ctx != null && ctx!.address != 0) lib.free(ctx!);

      final pathPtr = msg.modelPath.toNativeUtf8();
      ctx = lib.load(pathPtr, msg.nThreads, msg.nCtx, msg.nGpuLayers);
      calloc.free(pathPtr);

      if (ctx == null || ctx!.address == 0) {
        msg.replyPort.send('ERROR: failed to load model');
      } else {
        final name = lib.modelName(ctx!).toDartString();
        msg.replyPort.send('OK:$name');
      }
    } else if (msg is _InferRequest) {
      if (ctx == null || ctx!.address == 0) {
        msg.tokenPort.send('ERR:no model loaded');
        return;
      }

      final promptPtr = msg.prompt.toNativeUtf8();
      final result = lib.infer(
        ctx!, promptPtr,
        msg.maxTokens, msg.temperature, msg.topP, 64,
      );
      calloc.free(promptPtr);

      if (result.address != 0) {
        final text = result.toDartString();
        lib.freeString(result);

        // Stream word by word for natural feel
        final words = text.split(' ');
        for (int i = 0; i < words.length; i++) {
          msg.tokenPort.send(
              i == 0 ? words[i] : ' ${words[i]}');
        }
      }
      msg.tokenPort.send('DONE');

      // Report speed
      if (ctx != null && ctx!.address != 0) {
        final tps = lib.toksPerSec(ctx!);
        msg.tokenPort.send('TPS:$tps');
      }
    } else if (msg == 'SHUTDOWN') {
      if (ctx != null && ctx!.address != 0) lib.free(ctx!);
      incoming.close();
    }
  });
}

// ── LlamaService ─────────────────────────────────────────────────────────

class LlamaService {
  static final LlamaService instance = LlamaService._();
  LlamaService._();

  Isolate? _isolate;
  SendPort? _isolatePort;
  bool _available = false;
  bool _modelLoaded = false;
  String _loadedModelName = '';
  double _lastToksPerSec = 0;

  bool get isAvailable   => _available;
  bool get isModelLoaded => _modelLoaded;
  String get loadedModelName => _loadedModelName;
  double get lastToksPerSec  => _lastToksPerSec;

  /// Spawn the inference isolate. Call once at startup.
  Future<bool> init() async {
    if (AetherLlamaLib.tryLoad() == null) return false;
    if (_isolate != null) return _available;

    final mainPort = ReceivePort();
    try {
      _isolate = await Isolate.spawn(_inferenceIsolate, mainPort.sendPort);
      final first = await mainPort.first;
      if (first is SendPort) {
        _isolatePort = first;
        _available = true;
      } else {
        _available = false;
      }
    } catch (_) {
      _available = false;
    }
    return _available;
  }

  /// Load a model file. Returns true on success.
  Future<bool> loadModel(String modelPath) async {
    if (!_available || _isolatePort == null) return false;

    final profile  = DeviceProfile.detect();
    final replyPort = ReceivePort();
    _isolatePort!.send(_LoadRequest(
        modelPath, profile.nThreads, profile.nCtx, 0, replyPort.sendPort));

    final reply = await replyPort.first as String;
    replyPort.close();

    if (reply.startsWith('OK:')) {
      _modelLoaded = true;
      _loadedModelName = reply.substring(3);
      return true;
    }
    return false;
  }

  /// Stream inference. Yields tokens as they are generated.
  /// Final emit is empty string to signal completion.
  Stream<String> infer(
    String prompt, {
    int maxTokens = 512,
    double temperature = 0.8,
    double topP = 0.9,
  }) async* {
    if (!_available || !_modelLoaded || _isolatePort == null) {
      yield '[AETHER unavailable — no model loaded]';
      return;
    }

    final tokenPort = ReceivePort();
    _isolatePort!.send(_InferRequest(
        prompt, maxTokens, temperature, topP, tokenPort.sendPort));

    await for (final msg in tokenPort) {
      final s = msg as String;
      if (s == 'DONE') {
        tokenPort.close();
        break;
      } else if (s.startsWith('TPS:')) {
        _lastToksPerSec = double.tryParse(s.substring(4)) ?? 0;
      } else if (s.startsWith('ERR:')) {
        yield s;
        tokenPort.close();
        break;
      } else {
        yield s;
      }
    }
  }

  /// Convenience: collect full response string.
  Future<String> inferSync(String prompt,
      {int maxTokens = 512,
      double temperature = 0.8,
      double topP = 0.9}) async {
    final buf = StringBuffer();
    await for (final tok in infer(prompt,
        maxTokens: maxTokens,
        temperature: temperature,
        topP: topP)) {
      buf.write(tok);
    }
    return buf.toString().trim();
  }

  /// Shut down the isolate cleanly.
  void shutdown() {
    _isolatePort?.send('SHUTDOWN');
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _isolatePort = null;
    _modelLoaded = false;
    _available = false;
  }

  // ── Model file management ────────────────────────────────────────────────

  static Future<Directory> modelsDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir  = Directory('${base.path}/models');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<List<File>> listModels() async {
    final dir = await modelsDir();
    return dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.gguf'))
        .toList();
  }

  static Future<String> defaultModelsPath() async {
    // Also check ~/.local/share/pauliens_sky/models
    final home = Platform.environment['HOME'] ?? '';
    final systemPath =
        Directory('$home/.local/share/pauliens_sky/models');
    if (await systemPath.exists()) {
      final ggufs = systemPath
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.gguf'))
          .toList();
      if (ggufs.isNotEmpty) return ggufs.first.path;
    }
    final appModels = await listModels();
    return appModels.isNotEmpty ? appModels.first.path : '';
  }
}
