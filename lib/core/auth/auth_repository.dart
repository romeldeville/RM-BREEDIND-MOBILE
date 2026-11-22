import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_state.dart';
import '../auth/token_storage.dart';
import '../network/dio_client.dart';

class LoginResult {
  const LoginResult({
    required this.accessToken,
    required this.tenantId,
    required this.email,
    this.phone,
    required this.displayName,
    this.refreshToken,
    this.platformAdmin = false,
    this.memberships = const [],
  });

  final String accessToken;
  final String? refreshToken;
  final String tenantId;
  final String email;
  final String? phone;
  final String displayName;
  final bool platformAdmin;
  final List<TenantMembership> memberships;
}

class MfaRequiredException implements Exception {
  const MfaRequiredException(this.challengeId);

  final String challengeId;

  @override
  String toString() => 'MFA required (challenge $challengeId)';
}

class ApiFailure implements Exception {
  const ApiFailure(this.message, {this.statusCode, this.code});

  factory ApiFailure.fromDio(DioException error) {
    final response = error.response;
    final data = response?.data;
    String? code;
    String? message;
    if (data is Map<String, dynamic>) {
      code = data['code'] as String?;
      message = (data['detail'] as String?) ?? (data['title'] as String?);
    }
    return ApiFailure(
      message ?? _fallbackMessage(response?.statusCode),
      statusCode: response?.statusCode,
      code: code,
    );
  }

  final String message;
  final int? statusCode;
  final String? code;

  static String _fallbackMessage(int? status) {
    if (status == 401) {
      return 'Identifiants invalides.';
    }
    if (status == 403) {
      return 'Accès refusé.';
    }
    if (status == 423) {
      return 'Compte verrouillé, réessayez plus tard.';
    }
    if (status == 429) {
      return 'Trop de tentatives, patientez un instant.';
    }
    return 'Connexion impossible pour le moment.';
  }

  @override
  String toString() => message;
}

class MemberInfo {
  const MemberInfo({
    required this.membershipId,
    required this.email,
    required this.fullName,
    required this.role,
    required this.status,
    this.farmScope = const [],
  });

  factory MemberInfo.fromJson(Map<String, dynamic> json) {
    return MemberInfo(
      membershipId: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: json['role'] as String? ?? 'WORKER',
      status: json['status'] as String? ?? 'ACTIVE',
      farmScope: (json['farmScope'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(growable: false),
    );
  }

  final String membershipId;
  final String email;
  final String fullName;
  final String role;
  final String status;
  final List<String> farmScope;
}

class AuthRepository {
  AuthRepository(this._dio, this._storage);

  final Dio _dio;
  final TokenStorage _storage;

  Future<LoginResult> login({
    required String email,
    required String password,
    String? tenantSlug,
  }) async {
    try {
      final data = await _post('/auth/login', {
        'email': email,
        'password': password,
      });
      return _completeSession(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        final body = error.response?.data;
        if (body is Map<String, dynamic> && body['code'] == 'MFA_REQUIRED') {
          throw MfaRequiredException(body['challengeId'] as String? ?? '');
        }
      }
      throw ApiFailure.fromDio(error);
    }
  }

  Future<LoginResult> verifyMfa({
    required String challengeId,
    required String code,
  }) async {
    try {
      final data = await _post('/auth/mfa/verify', {
        'challengeId': challengeId,
        'code': code,
      });
      return _completeSession(data);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<void> requestOtp({
    required String destination,
    String channel = 'EMAIL',
  }) async {
    try {
      await _dio.post<dynamic>('/auth/otp/request', data: {
        'destination': destination,
        'channel': channel,
      });
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<LoginResult> verifyOtp({
    required String destination,
    required String code,
  }) async {
    try {
      final data = await _post('/auth/otp/verify', {
        'destination': destination,
        'code': code,
      });
      return _completeSession(data);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<LoginResult> switchTenant(String tenantId) async {
    try {
      final data = await _post('/tenants/$tenantId/switch', const {});
      return _completeSession(data);
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<List<TenantMembership>> memberships() async {
    final me = await _get('/auth/me') as Map<String, dynamic>;
    return (me['memberships'] as List<dynamic>? ?? const [])
        .map((value) => TenantMembership.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<MemberInfo>> members(String tenantId) async {
    final data = await _get('/tenants/$tenantId/members');
    return (data as List<dynamic>)
        .map((value) => MemberInfo.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> inviteMember({
    required String tenantId,
    required String email,
    required String role,
    List<String> farmScope = const [],
  }) async {
    try {
      await _dio.post<dynamic>('/tenants/$tenantId/invitations', data: {
        'email': email,
        'role': role,
        'farmScope': farmScope,
      });
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<void> updateMemberRole({
    required String tenantId,
    required String membershipId,
    required String role,
    List<String> farmScope = const [],
  }) async {
    try {
      await _dio.patch<dynamic>(
        '/tenants/$tenantId/members/$membershipId',
        data: {'role': role, 'farmScope': farmScope},
      );
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<void> removeMember({
    required String tenantId,
    required String membershipId,
  }) async {
    try {
      await _dio.delete<dynamic>('/tenants/$tenantId/members/$membershipId');
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<void> acceptInvitation({
    required String token,
    required String fullName,
    required String password,
  }) async {
    try {
      await _dio.post<dynamic>('/auth/invitations/accept', data: {
        'token': token,
        'fullName': fullName,
        'password': password,
      });
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? phone,
    String? locale,
  }) async {
    try {
      final response = await _dio.put<dynamic>('/auth/me', data: {
        'fullName': fullName,
        if (phone != null) 'phone': phone,
        if (locale != null) 'locale': locale,
      });
      final data = (response.data as Map<String, dynamic>?) ?? const {};
      await _storage.save(
        displayName: data['fullName'] as String?,
      );
      return data;
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post<dynamic>('/auth/password/change', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<AuthState> restore() async {
    final session = await _storage.readSession();
    if (session == null) {
      return const AuthState.unauthenticated();
    }
    final memberships = (session['memberships'] as List<dynamic>)
        .map((value) => TenantMembership.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
    return AuthState(
      isAuthenticated: true,
      accessToken: session['accessToken'] as String?,
      tenantId: session['tenantId'] as String?,
      email: session['email'] as String?,
      phone: session['phone'] as String?,
      displayName: session['displayName'] as String?,
      platformAdmin: session['platformAdmin'] as bool? ?? false,
      memberships: memberships,
    );
  }

  Future<void> logout() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken != null) {
      try {
        await _dio.post<dynamic>('/auth/logout', data: {
          'refreshToken': refreshToken,
        });
      } on DioException {
        // Local logout must succeed even when the API is unreachable.
      }
    }
    await clear();
  }

  Future<void> clear() => _storage.clear();

  Future<void> persistDemo(LoginResult result) async {
    await _storage.save(
      accessToken: result.accessToken,
      tenantId: result.tenantId,
      email: result.email,
      displayName: result.displayName,
      membershipsJson: jsonEncode(
        result.memberships.map((membership) => membership.toJson()).toList(),
      ),
    );
  }

  Future<LoginResult> _completeSession(Map<String, dynamic> tokens) async {
    final accessToken = tokens['accessToken'] as String? ?? '';
    final refreshToken = tokens['refreshToken'] as String?;
    await _storage.save(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    final me = await _get('/auth/me') as Map<String, dynamic>;
    final memberships = (me['memberships'] as List<dynamic>? ?? const [])
        .map((value) => TenantMembership.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
    final tenantId = _tenantIdFromToken(accessToken) ??
        (memberships.isEmpty ? '' : memberships.first.tenantId);
    final displayName = me['fullName'] as String? ?? '';
    final email = me['email'] as String? ?? '';
    final phone = me['phone'] as String?;
    final platformAdmin = me['platformAdmin'] as bool? ?? false;

    await _storage.save(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tenantId: tenantId,
      email: email,
      displayName: displayName,
      platformAdmin: platformAdmin,
      membershipsJson: jsonEncode(
        memberships.map((membership) => membership.toJson()).toList(),
      ),
    );

    return LoginResult(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tenantId: tenantId,
      email: email,
      phone: phone,
      displayName: displayName,
      platformAdmin: platformAdmin,
      memberships: memberships,
    );
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post<dynamic>(path, data: body);
    return (response.data as Map<String, dynamic>?) ?? const {};
  }

  Future<dynamic> _get(String path) async {
    final response = await _dio.get<dynamic>(path);
    return response.data;
  }



  String? _tenantIdFromToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      return null;
    }
    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      if (payload is Map<String, dynamic>) {
        return payload['tenantId'] as String?;
      }
    } on FormatException {
      return null;
    }
    return null;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider), ref.watch(tokenStorageProvider));
});
