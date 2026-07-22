import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talklog/features/premium/localized_premium_plan_page.dart';
import 'package:talklog/l10n/app_localizations.dart';

void main() {
  for (final testCase in [
    (const Locale('ja'), 'Premiumで学習を続ける', '月480円で登録'),
    (
      const Locale('en'),
      'Keep learning with Premium',
      'Subscribe for ¥480/month',
    ),
    (
      const Locale('es'),
      'Sigue aprendiendo con Premium',
      'Suscribirse por ¥480 al mes',
    ),
  ]) {
    testWidgets('localizes Premium page in ${testCase.$1.languageCode}', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: testCase.$1,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const LocalizedPremiumPlanPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(testCase.$2), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(find.text(testCase.$3), findsOneWidget);
      expect(find.text('Premium'), findsWidgets);
    });
  }
}
