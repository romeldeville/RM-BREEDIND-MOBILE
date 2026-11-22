import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  PinService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const int _iterations = 60000;
  static const int _keyLength = 32;
  static const _hashKey = 'rmb.pin.hash';
  static const _saltKey = 'rmb.pin.salt';
  static const _iterationsKey = 'rmb.pin.iterations';

  final FlutterSecureStorage _storage;

  Future<bool> hasPin() async {
    final hash = await _storage.read(key: _hashKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final hash = _pbkdf2(pin, salt, _iterations, _keyLength);
    await _storage.write(key: _saltKey, value: base64Encode(salt));
    await _storage.write(key: _iterationsKey, value: _iterations.toString());
    await _storage.write(key: _hashKey, value: base64Encode(hash));
  }

  Future<bool> verifyPin(String pin) async {
    final storedHash = await _storage.read(key: _hashKey);
    final storedSalt = await _storage.read(key: _saltKey);
    final storedIterations = int.tryParse(
          await _storage.read(key: _iterationsKey) ?? '',
        ) ??
        _iterations;
    if (storedHash == null || storedSalt == null) {
      return false;
    }
    final salt = base64Decode(storedSalt);
    final candidate = _pbkdf2(pin, salt, storedIterations, _keyLength);
    return _constantTimeEquals(base64Encode(candidate), storedHash);
  }

  Future<void> clear() async {
    await _storage.delete(key: _hashKey);
    await _storage.delete(key: _saltKey);
    await _storage.delete(key: _iterationsKey);
  }

  List<int> _pbkdf2(String pin, List<int> salt, int iterations, int length) {
    final hmac = Hmac(sha256, utf8.encode(pin));
    final output = <int>[];
    var block = 1;
    while (output.length < length) {
      final blockIndex = [
        (block >> 24) & 0xff,
        (block >> 16) & 0xff,
        (block >> 8) & 0xff,
        block & 0xff,
      ];
      var u = hmac.convert([...salt, ...blockIndex]).bytes;
      final t = List<int>.from(u);
      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < t.length; j++) {
          t[j] ^= u[j];
        }
      }
      output.addAll(t);
      block++;
    }
    return output.sublist(0, length);
  }

  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) {
      return false;
    }
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}

final pinServiceProvider = Provider<PinService>((ref) => PinService());
