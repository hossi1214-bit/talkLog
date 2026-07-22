import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talklog/features/premium/localized_premium_plan_page.dart';
import 'package:talklog/l10n/app_localizations.dart';

void main() {
  for (final locale in const [Locale('en'), Locale('es')]) {
    testWidgets('long ${locale.languageCode} copy fits a narrow screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: const LocalizedPremiumPlanPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      await tester.dragUntilVisible(
        find.byType(FilledButton),
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FilledButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
