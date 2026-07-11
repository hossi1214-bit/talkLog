import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../../recording/models/record_entry.dart';
import '../models/ai_correction_result.dart';

class EdgeFunctionCorrectionService {
  EdgeFunctionCorrectionService({SupabaseClient? client})
    : _client = client ?? SupabaseService.client;

  final SupabaseClient? _client;

  bool get isAvailable => _client?.auth.currentUser != null;

  Future<AiCorrectionResult> analyze(RecordEntry entry) async {
    final client = _client;
    if (client == null || client.auth.currentUser == null) {
      throw const EdgeCorrectionUnavailableException('Supabaseにログインしていません。');
    }

    final FunctionResponse response;
    try {
      response = await client.functions.invoke(
        'analyze-recording',
        body: {
          'recordingId': entry.id,
          'language': entry.language,
          'audioPath': entry.audioPath,
        },
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

    throw const EdgeCorrectionUnavailableException(
      'Edge Functionのレスポンス形式が不正です。',
    );
  }

  String _errorMessageFor(Object? data, int status) {
    if (data is Map) {
      final error = data['error']?.toString();
      if (error != null && error.isNotEmpty) {
        if (error == 'NO_RECOGNIZABLE_SPEECH') {
          return '音声を認識できませんでした。録音内容を確認して、もう一度録音してください。';
        }
        final remaining = data['remaining'];
        final limit = data['limit'];
        if (status == 429 && limit != null) {
          return '本日の回数上限に達しました。';
        }
        if (remaining != null && limit != null) {
          return '$error ($remaining/$limit)';
        }
        return error;
      }
    }
    return 'Edge Functionがエラーを返しました: $status';
  }

  String _friendlyExceptionMessage(Object error) {
    final message = error.toString();
    if (message.contains('429') ||
        message.contains('Too Many Requests') ||
        message.contains('本日の無料AI添削回数')) {
      return '本日の回数上限に達しました。';
    }
    if (message.contains('NO_RECOGNIZABLE_SPEECH')) {
      return '音声を認識できませんでした。録音内容を確認して、もう一度録音してください。';
    }
    return message;
  }
}

class EdgeCorrectionUnavailableException implements Exception {
  const EdgeCorrectionUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}
