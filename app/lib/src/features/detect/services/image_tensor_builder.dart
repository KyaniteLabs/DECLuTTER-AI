import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Builds the input tensor for the detector interpreter by resizing and
/// normalizing pixels to the expected data type.
class ImageTensorBuilder {
  const ImageTensorBuilder({
    required this.shape,
    required this.type,
  });

  /// Expected tensor shape `[1, height, width, channels]`.
  final List<int> shape;

  /// Target tensor data type.
  final TensorType type;

  /// Resizes [image] to the tensor dimensions and returns the nested list
  /// structure expected by `Interpreter.run`.
  Object build(img.Image image) {
    if (shape.length != 4 || shape.first != 1) {
      throw FlutterError(
        'Expected input shape [1, height, width, channels] but received $shape.',
      );
    }

    final height = shape[1];
    final width = shape[2];
    final channels = shape[3];

    final resized = img.copyResize(
      image,
      width: width,
      height: height,
      interpolation: img.Interpolation.linear,
    );

    return List.generate(1, (_) {
      return List.generate(height, (y) {
        return List.generate(width, (x) {
          final pixel = resized.getPixel(x, y);
          final values = <num>[];
          if (channels >= 1) {
            values.add(_normalizeValue(pixel.r.toDouble()));
          }
          if (channels >= 2) {
            values.add(_normalizeValue(pixel.g.toDouble()));
          }
          if (channels >= 3) {
            values.add(_normalizeValue(pixel.b.toDouble()));
          }
          if (channels >= 4) {
            values.add(_normalizeValue(pixel.a.toDouble()));
          }
          return values;
        });
      });
    });
  }

  num _normalizeValue(double value) {
    switch (type) {
      case TensorType.float32:
      case TensorType.float16:
        return value / 255.0;
      case TensorType.int8:
      case TensorType.uint8:
      case TensorType.int16:
      case TensorType.int32:
      case TensorType.int64:
        return value.round();
      case TensorType.uint16:
        return value.round();
      case TensorType.boolean:
        return value > 0 ? 1 : 0;
      default:
        return value.round();
    }
  }
}
