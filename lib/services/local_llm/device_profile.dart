import 'dart:io';

enum DeviceClass { ultraLow, low, mid, high, desktop }

class DeviceProfile {
  final DeviceClass deviceClass;
  final int nThreads;
  final int nCtx;
  final int nBatch;
  final String recommendedModel;
  final int estimatedRamMb;

  const DeviceProfile({
    required this.deviceClass,
    required this.nThreads,
    required this.nCtx,
    required this.nBatch,
    required this.recommendedModel,
    required this.estimatedRamMb,
  });

  double get estimatedToksPerSec => switch (deviceClass) {
    DeviceClass.ultraLow => 1.5,
    DeviceClass.low      => 3.0,
    DeviceClass.mid      => 5.0,
    DeviceClass.high     => 9.0,
    DeviceClass.desktop  => 5.0,
  };

  String get deviceLabel => switch (deviceClass) {
    DeviceClass.ultraLow => 'Ultra-low (≤2GB RAM)',
    DeviceClass.low      => 'Low-end phone (3GB RAM)',
    DeviceClass.mid      => 'Mid-range phone (4–6GB)',
    DeviceClass.high     => 'High-end phone / Apple Silicon',
    DeviceClass.desktop  => 'Linux / Mac desktop',
  };

  static DeviceProfile detect() {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      return _desktop();
    }
    // Android / iOS — estimate from platform
    return _mobileMid();
  }

  static DeviceProfile _desktop() {
    final cores = Platform.numberOfProcessors;
    final threads = (cores / 2).ceil().clamp(2, 8);
    return DeviceProfile(
      deviceClass: DeviceClass.desktop,
      nThreads: threads,
      nCtx: 4096,
      nBatch: 256,
      recommendedModel: 'mistral-7b-instruct-v0.3.Q4_K_M.gguf',
      estimatedRamMb: 5000,
    );
  }

  static DeviceProfile _mobileMid() => const DeviceProfile(
    deviceClass: DeviceClass.mid,
    nThreads: 4,
    nCtx: 2048,
    nBatch: 128,
    recommendedModel: 'phi-3-mini-4k-instruct.Q4_K_M.gguf',
    estimatedRamMb: 2300,
  );

  static DeviceProfile _mobileLow() => const DeviceProfile(
    deviceClass: DeviceClass.low,
    nThreads: 2,
    nCtx: 1024,
    nBatch: 64,
    recommendedModel: 'gemma-2-2b-it-Q4_K_M.gguf',
    estimatedRamMb: 1600,
  );
}
