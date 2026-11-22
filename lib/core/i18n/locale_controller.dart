import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends Notifier<Locale> {
  static const _storageKey = 'rmb.locale';

  @override
  Locale build() {
    _restore();
    return const Locale('fr');
  }

  void setLocale(Locale locale) {
    if (locale == state) {
      return;
    }
    state = locale;
    _persist(locale);
  }

  void toggle() {
    setLocale(state.languageCode == 'fr' ? const Locale('en') : const Locale('fr'));
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_storageKey);
      if (stored == 'fr' || stored == 'en') {
        state = Locale(stored!);
      }
    } catch (_) {
      // Storage unavailable: keep default locale.
    }
  }

  Future<void> _persist(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, locale.languageCode);
    } catch (_) {
      // Ignore persistence errors.
    }
  }
}

final localeControllerProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);
