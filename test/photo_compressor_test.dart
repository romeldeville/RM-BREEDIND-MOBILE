import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:rm_breeding_mobile/core/files/photo_compressor.dart';

Uint8List _landscapeJpeg() {
  final source = image.Image(width: 800, height: 400);
  image.fill(source, color: image.ColorRgb8(22, 96, 52));
  return Uint8List.fromList(image.encodeJpg(source, quality: 95));
}

Uint8List _portraitJpeg() {
  final source = image.Image(width: 400, height: 800);
  image.fill(source, color: image.ColorRgb8(96, 22, 52));
  return Uint8List.fromList(image.encodeJpg(source, quality: 95));
}

void main() {
  test('downscales a landscape photo to the maximum dimension', () async {
    const compressor = PhotoCompressor(maxDimension: 200, quality: 80);
    final original = _landscapeJpeg();

    final result = await compressor.compress(original);

    expect(result.width, 200);
    expect(result.height, 100);
    expect(result.originalBytes, original.length);
    expect(result.compressedBytes, greaterThan(0));
    expect(result.bytes[0], 0xFF);
    expect(result.bytes[1], 0xD8);
    expect(result.ratio, lessThan(1));
  });

  test('downscales a portrait photo using its height', () async {
    const compressor = PhotoCompressor(maxDimension: 200, quality: 80);

    final result = await compressor.compress(_portraitJpeg());

    expect(result.width, 100);
    expect(result.height, 200);
  });

  test('keeps small photos at their original size', () async {
    const compressor = PhotoCompressor(maxDimension: 1600, quality: 82);
    final original = _landscapeJpeg();

    final result = await compressor.compress(original);

    expect(result.width, 800);
    expect(result.height, 400);
  });

  test('rejects bytes that are not an image', () async {
    const compressor = PhotoCompressor();

    expect(
      () => compressor.compress(Uint8List.fromList([1, 2, 3, 4])),
      throwsA(isA<FormatException>()),
    );
  });
}
