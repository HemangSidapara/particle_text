import 'package:flutter_test/flutter_test.dart';
import 'package:particle_gpu_core/particle_gpu_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GPUCapabilityProbe', () {
    test('check() returns a boolean', () async {
      // Note: In test environment, this will likely return false 
      // as shaders can't be compiled in headless tests easily,
      // but we verify the API contract.
      final result = await GPUCapabilityProbe.check();
      expect(result, isA<bool>());
    });
  });
}
