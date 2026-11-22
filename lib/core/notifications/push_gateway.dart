import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../config/app_config.dart';

enum PushPermission { granted, denied, notDetermined, unsupported }

/// Thin abstraction over Firebase Messaging so the rest of the application can
/// be tested without a real Firebase project.
abstract class PushGateway {
  bool get supported;

  Future<PushPermission> permissionStatus();

  Future<PushPermission> requestPermission();

  Future<String?> token();

  Stream<String> get tokenRefreshes;

  Future<void> deleteToken();
}

class FirebasePushGateway implements PushGateway {
  FirebasePushGateway({FirebaseMessaging? messaging}) : _injected = messaging;

  final FirebaseMessaging? _injected;
  FirebaseMessaging? _resolved;
  String? _lastToken;

  /// Resolved lazily so no Firebase app is required when push is disabled.
  FirebaseMessaging get _messaging =>
      _resolved ??= (_injected ?? FirebaseMessaging.instance);

  @override
  bool get supported => AppConfig.firebaseConfigured;

  @override
  Future<PushPermission> permissionStatus() async {
    if (!supported) {
      return PushPermission.unsupported;
    }
    final settings = await _messaging.getNotificationSettings();
    return _map(settings.authorizationStatus);
  }

  @override
  Future<PushPermission> requestPermission() async {
    if (!supported) {
      return PushPermission.unsupported;
    }
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return _map(settings.authorizationStatus);
  }

  @override
  Future<String?> token() async {
    if (!supported) {
      return null;
    }
    if (_lastToken != null) {
      return _lastToken;
    }
    final completer = Completer<String?>();
    final subscription = _messaging.onRegistered.listen((token) {
      _lastToken = token;
      if (!completer.isCompleted) {
        completer.complete(token);
      }
    });
    try {
      // Registration is idempotent; it emits onRegistered with the Firebase
      // installation id that the backend uses as the push target.
      await _messaging.register();
      return await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => _lastToken,
      );
    } on Exception {
      return _lastToken;
    } finally {
      await subscription.cancel();
    }
  }

  @override
  Stream<String> get tokenRefreshes =>
      supported ? _messaging.onRegistered : const Stream.empty();

  @override
  Future<void> deleteToken() async {
    if (!supported) {
      return;
    }
    _lastToken = null;
    await _messaging.unregister();
  }

  PushPermission _map(AuthorizationStatus status) {
    return switch (status) {
      AuthorizationStatus.authorized || AuthorizationStatus.provisional =>
        PushPermission.granted,
      AuthorizationStatus.denied => PushPermission.denied,
      AuthorizationStatus.deniedPermanently => PushPermission.denied,
      AuthorizationStatus.notDetermined => PushPermission.notDetermined,
    };
  }
}
