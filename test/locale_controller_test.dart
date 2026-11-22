import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rm_breeding_mobile/core/i18n/locale_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('locale defaults to French and toggles to English', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(localeControllerProvider), const Locale('fr'));
    container.read(localeControllerProvider.notifier).toggle();
    expect(container.read(localeControllerProvider), const Locale('en'));
  });

  test('setLocale persists the choice', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(localeControllerProvider.notifier).setLocale(const Locale('en'));
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('rmb.locale'), 'en');
  });
}
