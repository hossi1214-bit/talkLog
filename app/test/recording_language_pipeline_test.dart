import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talklog/features/correction/services/edge_function_correction_service.dart';
import 'package:talklog/features/recording/controllers/record_controller.dart';
import 'package:talklog/features/recording/data/recording_store.dart';
import 'package:talklog/features/recording/services/record_service.dart';
import 'package:talklog/features/settings/data/app_settings_store.dart';
import 'package:talklog/features/settings/models/app_language.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'carries every selected learning language through the AI pipeline',
    () async {
      SharedPreferences.setMockInitialValues({
        'base_locale': 'en',
        'learning_language': 'es',
      });
      final recordingStore = RecordingStore.instance;
      await recordingStore.clearLocal();

      for (final learningLanguage in supportedLearningLanguages) {
        final baseLocale = learningLanguage == AppLanguage.english
            ? 'ja'
            : 'en';
        final settingsStore = AppSettingsStore.forTesting();
        await settingsStore.load();
        expect(
          await settingsStore.setLanguages(
            baseLocale: baseLocale,
            learningLanguage: learningLanguage.code,
          ),
          isTrue,
        );
        final controller = RecordController(
          recordService: _FakeRecordService(learningLanguage.code),
          store: recordingStore,
          settingsStore: settingsStore,
        );

        await controller.startRecording();
        final entry = await controller.stopRecording();

        expect(entry, isNotNull);
        expect(entry!.language, learningLanguage.code);
        final request = EdgeFunctionCorrectionService.requestBodyFor(
          entry,
          baseLocale: baseLocale,
        );
        expect(request['language'], learningLanguage.code);
        expect(request['learningLanguage'], learningLanguage.code);
        expect(request['baseLocale'], baseLocale);
        controller.dispose();
      }
    },
  );
}

class _FakeRecordService extends RecordService {
  _FakeRecordService(this.languageCode);

  final String languageCode;

  @override
  Future<void> start() async {}

  @override
  Future<String> stop() async => 'recording-$languageCode.m4a';

  @override
  Future<void> dispose() async {}
}
