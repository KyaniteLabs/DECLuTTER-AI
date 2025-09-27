import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:declutter_ai/src/features/detect/services/detector_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('detector service falls back to mock detections when model is missing', () async {
    final service = DetectorService();

    final tempDir = await Directory.systemTemp.createTemp('detector_test');
    final imageFile = File('${tempDir.path}/sample.jpg');
    final generated = img.Image(width: 640, height: 480);
    await imageFile.writeAsBytes(img.encodeJpg(generated));

    final result = await service.detectOnImage(imageFile.path);

    expect(result.isMocked, isTrue);
    expect(result.detections, isNotEmpty);
    expect(result.originalSize.width, greaterThan(0));
    expect(result.originalSize.height, greaterThan(0));
  });
}
