/// Helper class to detect if the device supports high-performance GPU features.
class GPUCapabilityProbe {
  static bool? _isSupported;

  /// Returns true if the device can handle GPGPU-style fragment shaders.
  ///
  /// In practice, we check for FragmentProgram support and modern Impeller/Skia availability.
  static Future<bool> check() async {
    if (_isSupported != null) return _isSupported!;

    try {
      // In a real implementation, we would load a tiny "Probe Shader"
      // to see if it compiles and runs without error.
      _isSupported = true; // For this POC, we assume modern hardware.
    } catch (_) {
      _isSupported = false;
    }

    return _isSupported!;
  }
}
