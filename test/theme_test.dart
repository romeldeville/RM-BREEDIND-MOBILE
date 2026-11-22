import 'package:flutter_test/flutter_test.dart';

import 'package:rm_breeding_mobile/core/theme/app_theme.dart';
import 'package:rm_breeding_mobile/core/theme/app_tokens.dart';

void main() {
  test('theme uses design tokens', () {
    final theme = buildAppTheme();
    expect(theme.colorScheme.primary, AppTokens.primary);
    expect(theme.scaffoldBackgroundColor, AppTokens.background);
    expect(theme.useMaterial3, isTrue);
  });

  test('touch target token is at least 48px', () {
    expect(AppTokens.touchTarget, greaterThanOrEqualTo(48));
  });
}
