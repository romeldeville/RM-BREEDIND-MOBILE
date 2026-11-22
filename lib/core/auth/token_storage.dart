import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'rmb.accessToken';
  static const _refreshTokenKey = 'rmb.refreshToken';
  static const _tenantIdKey = 'rmb.tenantId';
  static const _emailKey = 'rmb.email';
  static const _displayNameKey = 'rmb.displayName';
  static const _membershipsKey = 'rmb.memberships';
  static const _platformAdminKey = 'rmb.platformAdmin';

  final FlutterSecureStorage _storage;

  Future<void> save({
    String? accessToken,
    String? refreshToken,
    String? tenantId,
    String? email,
    String? displayName,
    String? membershipsJson,
    bool? platformAdmin,
  }) async {
    if (accessToken != null) {
      await _storage.write(key: _accessTokenKey, value: accessToken);
    }
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
    if (tenantId != null) {
      await _storage.write(key: _tenantIdKey, value: tenantId);
    }
    if (email != null) {
      await _storage.write(key: _emailKey, value: email);
    }
    if (displayName != null) {
      await _storage.write(key: _displayNameKey, value: displayName);
    }
    if (membershipsJson != null) {
      await _storage.write(key: _membershipsKey, value: membershipsJson);
    }
    if (platformAdmin != null) {
      await _storage.write(key: _platformAdminKey, value: platformAdmin.toString());
    }
  }

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<String?> readTenantId() => _storage.read(key: _tenantIdKey);

  Future<String?> readEmail() => _storage.read(key: _emailKey);

  Future<String?> readDisplayName() => _storage.read(key: _displayNameKey);

  Future<String?> readMembershipsJson() => _storage.read(key: _membershipsKey);

  Future<bool> readPlatformAdmin() async =>
      (await _storage.read(key: _platformAdminKey)) == 'true';

  Future<Map<String, dynamic>?> readSession() async {
    final token = await readAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }
    final rawMemberships = await readMembershipsJson();
    final memberships = rawMemberships == null
        ? const <Map<String, dynamic>>[]
        : (jsonDecode(rawMemberships) as List<dynamic>)
            .map((value) => value as Map<String, dynamic>)
            .toList(growable: false);
    return {
      'accessToken': token,
      'refreshToken': await readRefreshToken(),
      'tenantId': await readTenantId(),
      'email': await readEmail(),
      'displayName': await readDisplayName(),
      'platformAdmin': await readPlatformAdmin(),
      'memberships': memberships,
    };
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tenantIdKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _displayNameKey);
    await _storage.delete(key: _membershipsKey);
    await _storage.delete(key: _platformAdminKey);
  }
}
