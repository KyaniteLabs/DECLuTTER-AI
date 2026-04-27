import 'detection_interpreter.dart';
import 'onnx_detection_interpreter.dart';

Future<DetectionInterpreter?> createOnnxInterpreter(String assetPath) async {
  return await OnnxDetectionInterpreter.fromAsset(assetPath);
}
