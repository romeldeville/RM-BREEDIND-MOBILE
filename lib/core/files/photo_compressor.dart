import 'dart:typed_data';

import 'package:image/image.dart' as image;

class PhotoCompressionResult {
  const PhotoCompressionResult({
    required this.bytes,
    required this.width,
    required this.height,
    required this.originalBytes,
  });

  final Uint8List bytes;
  final int width;
  final int height;
  final int originalBytes;

  int get compressedBytes => bytes.length;

  double get ratio {
    if (originalBytes == 0) {
      return 1;
    }
    return bytes.length / originalBytes;
  }
}

/// P14-04 - pure Dart compression used before uploading a photo.
///
/// The image is rotated according to its EXIF orientation, resized so that its
/// longest side is at most [maxDimension] pixels, then re-encoded as JPEG.
class PhotoCompressor {
  const PhotoCompressor({this.maxDimension = 1600, this.quality = 82});

  final int maxDimension;
  final int quality;

  Future<PhotoCompressionResult> compress(Uint8List bytes) async {
    final decoded = image.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('Image illisible');
    }
    var output = image.bakeOrientation(decoded);
    if (output.width > maxDimension || output.height > maxDimension) {
      output = output.width >= output.height
          ? image.copyResize(
              output,
              width: maxDimension,
              interpolation: image.Interpolation.linear,
            )
          : image.copyResize(
              output,
              height: maxDimension,
              interpolation: image.Interpolation.linear,
            );
    }
    final encoded = image.encodeJpg(output, quality: quality);
    return PhotoCompressionResult(
      bytes: Uint8List.fromList(encoded),
      width: output.width,
      height: output.height,
      originalBytes: bytes.length,
    );
  }
}
