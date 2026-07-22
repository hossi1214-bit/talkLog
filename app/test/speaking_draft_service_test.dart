import 'package:flutter_test/flutter_test.dart';
import 'package:talklog/features/recording/services/speaking_draft_service.dart';

void main() {
  test(
    'returns a stable error code when authentication is unavailable',
    () async {
      final service = SpeakingDraftService();

      await expectLater(
        service.createDraft(japaneseText: '話したいこと', language: 'en'),
        throwsA(
          isA<SpeakingDraftException>().having(
            (error) => error.message,
            'message',
            'DRAFT_AUTH_REQUIRED',
          ),
        ),
      );
    },
  );
}
