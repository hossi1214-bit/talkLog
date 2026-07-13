import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talklog/app/app.dart';

void main() {
  testWidgets('requires email login before using non-settings tabs', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const TalkLogApp());
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    expect(find.text('ホーム'), findsOneWidget);
    expect(find.text('録音'), findsOneWidget);
    expect(find.text('履歴'), findsOneWidget);
    expect(find.text('進捗'), findsOneWidget);
    expect(find.text('設定'), findsWidgets);
    expect(find.text('メールアドレス'), findsOneWidget);

    await tester.tap(find.text('録音'));
    await tester.pump();

    expect(find.text('利用するにはメールログインしてください。'), findsWidgets);
    expect(find.text('メールアドレス'), findsOneWidget);
    expect(find.text('録音できます'), findsNothing);
    expect(find.byIcon(Icons.mic), findsNothing);
  });
}
