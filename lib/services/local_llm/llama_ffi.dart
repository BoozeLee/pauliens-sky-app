/// Raw dart:ffi bindings to libaether_llm.so
/// Do not call these directly — use LlamaService instead.
// ignore_for_file: library_private_types_in_public_api
library llama_ffi;

import 'dart:ffi';
import 'dart:io';

// ── Native types ─────────────────────────────────────────────────────────

final class AetherContextOpaque extends Opaque {}
typedef AetherContextPtr = Pointer<AetherContextOpaque>;

// C function signatures
typedef _AetherLoadC = AetherContextPtr Function(
    Pointer<Uint8> path, Int32 nThreads, Int32 nCtx, Int32 nGpuLayers);
typedef _AetherLoadDart = AetherContextPtr Function(
    Pointer<Uint8> path, int nThreads, int nCtx, int nGpuLayers);

typedef _AetherFreeC    = Void Function(AetherContextPtr);
typedef _AetherFreeDart = void Function(AetherContextPtr);

typedef _AetherInferC = Pointer<Uint8> Function(
    AetherContextPtr, Pointer<Uint8> prompt,
    Int32 maxTokens, Float temperature, Float topP, Int32 repeatPenaltyN);
typedef _AetherInferDart = Pointer<Uint8> Function(
    AetherContextPtr, Pointer<Uint8> prompt,
    int maxTokens, double temperature, double topP, int repeatPenaltyN);

typedef _AetherFreeStringC    = Void Function(Pointer<Uint8>);
typedef _AetherFreeStringDart = void Function(Pointer<Uint8>);

typedef _AetherModelNameC    = Pointer<Uint8> Function(AetherContextPtr);
typedef _AetherModelNameDart = Pointer<Uint8> Function(AetherContextPtr);

typedef _AetherToksPerSecC    = Float Function(AetherContextPtr);
typedef _AetherToksPerSecDart = double Function(AetherContextPtr);

// ── Library loader ───────────────────────────────────────────────────────

class AetherLlamaLib {
  late final _AetherLoadDart      load;
  late final _AetherFreeDart      free;
  late final _AetherInferDart     infer;
  late final _AetherFreeStringDart freeString;
  late final _AetherModelNameDart  modelName;
  late final _AetherToksPerSecDart toksPerSec;

  static AetherLlamaLib? _instance;

  static AetherLlamaLib? tryLoad() {
    if (_instance != null) return _instance;
    try {
      _instance = AetherLlamaLib._open();
      return _instance;
    } catch (_) {
      return null;
    }
  }

  AetherLlamaLib._open() {
    final lib = _openLib();
    load       = lib.lookupFunction<_AetherLoadC, _AetherLoadDart>('aether_load');
    free       = lib.lookupFunction<_AetherFreeC, _AetherFreeDart>('aether_free');
    infer      = lib.lookupFunction<_AetherInferC, _AetherInferDart>('aether_infer');
    freeString = lib.lookupFunction<_AetherFreeStringC, _AetherFreeStringDart>(
        'aether_free_string');
    modelName  = lib.lookupFunction<_AetherModelNameC, _AetherModelNameDart>(
        'aether_model_name');
    toksPerSec = lib.lookupFunction<_AetherToksPerSecC, _AetherToksPerSecDart>(
        'aether_last_toks_per_sec');
  }

  static DynamicLibrary _openLib() {
    if (Platform.isLinux) {
      // Try bundled lib first, then system path
      for (final path in [
        '${_exeDir()}/lib/libaether_llm.so',
        '${_exeDir()}/libaether_llm.so',
        'libaether_llm.so',
      ]) {
        if (File(path).existsSync()) {
          return DynamicLibrary.open(path);
        }
      }
      return DynamicLibrary.open('libaether_llm.so');
    }
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libaether_llm.so');
    }
    if (Platform.isMacOS || Platform.isIOS) {
      return DynamicLibrary.open('libaether_llm.dylib');
    }
    throw UnsupportedError('libaether_llm not available on ${Platform.operatingSystem}');
  }

  static String _exeDir() {
    return File(Platform.resolvedExecutable).parent.path;
  }
}

// ── Uint8 helpers (inline, no package needed) ────────────────────────────

extension StringToNative on String {
  Pointer<Uint8> toNativeUint8() {
    final units = codeUnits;
    final ptr = calloc<Uint8>(units.length + 1);
    for (int i = 0; i < units.length; i++) {
      ptr[i] = units[i] & 0xFF;
    }
    ptr[units.length] = 0;
    return ptr.cast<Uint8>();
  }
}

extension NativeToString on Pointer<Uint8> {
  String toDartString() {
    if (address == 0) return '';
    final bytes = <int>[];
    int i = 0;
    while (cast<Uint8>()[i] != 0) {
      bytes.add(cast<Uint8>()[i]);
      i++;
    }
    return String.fromCharCodes(bytes);
  }
}

// ── calloc ───────────────────────────────────────────────────────────────

final Allocator calloc = _CallocAllocator();

class _CallocAllocator implements Allocator {
  static final _lib = DynamicLibrary.process();
  static final _calloc = _lib
      .lookupFunction<Pointer<NativeType> Function(Size, Size),
          Pointer<NativeType> Function(int, int)>('calloc');
  static final _free = _lib
      .lookupFunction<Void Function(Pointer<NativeType>),
          void Function(Pointer<NativeType>)>('free');

  @override
  Pointer<T> allocate<T extends NativeType>(int byteCount, {int? alignment}) {
    return _calloc(1, byteCount).cast<T>();
  }

  @override
  void free(Pointer<NativeType> pointer) => _free(pointer);
}
