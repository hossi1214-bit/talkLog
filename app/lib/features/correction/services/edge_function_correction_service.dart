import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/auth_session_service.dart';
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
    if (!AuthSessionService.instance.canUsePremiumFeature) {
      throw const EdgeCorrectionUnavailableException(
        'AI添削は有料機能です。PREMIUM、TESTER、ADMINアカウントで利用できます。',
      );
    }

    final response = await client.functions.invoke(
      'analyze-recording',
      body: {
        'recordingId': entry.id,
        'language': entry.language,
        'audioPath': entry.audioPath,
      },
    );

    if (response.status >= 400) {
      throw EdgeCorrectionUnavailableException(
        'Edge Functionがエラーを返しました: ${response.status}',
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
}

class EdgeCorrectionUnavailableException implements Exception {
  const EdgeCorrectionUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}
