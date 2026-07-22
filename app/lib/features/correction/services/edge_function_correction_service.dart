import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../recording/models/record_entry.dart';
import '../../settings/data/app_settings_store.dart';
import '../../settings/models/app_language.dart';
import '../models/ai_correction_result.dart';

class EdgeFunctionCorrectionService {
  EdgeFunctionCorrectionService({SupabaseClient? client})
    : _client = client ?? SupabaseService.client;

  final SupabaseClient? _client;

  bool get isAvailable => _client?.auth.currentUser != null;

  static Map<String, dynamic> requestBodyFor(
    RecordEntry entry, {
    required String baseLocale,
  }) {
    final parsedBaseLocale = AppLanguage.parse(baseLocale);
    final parsedLearningLanguage = AppLanguage.parse(entry.languageCode);
    if (parsedBaseLocale == null ||
        parsedLearningLanguage == null ||
        !isValidLanguageSelection(
          baseLocale: parsedBaseLocale,
          learningLanguage: parsedLearningLanguage,
        )) {
      throw ArgumentError('Unsupported language selection');
    }
    return {
      'recordingId': entry.id,
      'language': parsedLearningLanguage.code,
      'learningLanguage': parsedLearningLanguage.code,
      'baseLocale': baseLocale,
      'audioPath': entry.audioPath,
    };
  }

  Future<AiCorrectionResult> analyze(RecordEntry entry) async {
    final client = _client;
    if (client == null || client.auth.currentUser == null) {
      throw const EdgeCorrectionUnavailableException('AUTH_REQUIRED');
    }

    final FunctionResponse response;
    try {
      response = await client.functions.invoke(
        'analyze-recording',
        body: requestBodyFor(
          entry,
          baseLocale: AppSettingsStore.instance.baseLocaleCode,
        ),
      );
    } catch (error) {
      throw EdgeCorrectionUnavailableException(
        _friendlyExceptionMessage(error),
      );
    }

    if (response.status >= 400) {
      throw EdgeCorrectionUnavailableException(
        _errorMessageFor(response.data, response.status),
      );
    }
    final data = response.data;
    if (data is Map) {
      final result = data['result'];
      if (result is Map) {
        return AiCorrectionResult.fromJson(Map<String, dynamic>.from(result));
      }
      return AiCorrectionResult.fromJson(Map<String, dynamic>.from(data));
    }

    throw const EdgeCorrectionUnavailableException('INVALID_RESPONSE');
  }

  String _errorMessageFor(Object? data, int status) {
    if (data is Map) {
      final error = data['error']?.toString();
      if (error != null && error.isNotEmpty) {
        if (error == 'NO_RECOGNIZABLE_SPEECH') {
          return error;
        }
        final remaining = data['remaining'];
        final limit = data['limit'];
        if (status == 429 && limit != null) {
          return 'DAILY_LIMIT_REACHED';
        }
        if (error == 'UNSUPPORTED_LANGUAGE' || error == 'ANALYSIS_FAILED') {
          return error;
        }
        if (remaining != null && limit != null) {
          return '$error ($remaining/$limit)';
        }
        return error;
      }
    }
    return 'ANALYSIS_FAILED';
  }

  String _friendlyExceptionMessage(Object error) {
    final message = error.toString();
    if (message.contains('429') ||
        message.contains('Too Many Requests') ||
        message.contains('本日の無料AI添削回数')) {
      return 'DAILY_LIMIT_REACHED';
    }
    if (message.contains('NO_RECOGNIZABLE_SPEECH')) {
      return 'NO_RECOGNIZABLE_SPEECH';
    }
    if (message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('socket')) {
      return 'NETWORK_ERROR';
    }
    return 'ANALYSIS_FAILED';
  }
}

class EdgeCorrectionUnavailableException implements Exception {
  const EdgeCorrectionUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}
