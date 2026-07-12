import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';

class SpeakingDraftService {
  SpeakingDraftService({SupabaseClient? client})
    : _client = client ?? SupabaseService.client;

  final SupabaseClient? _client;

  Future<String> createDraft({
    required String japaneseText,
    required String language,
  }) async {
    final client = _client;
    if (client == null || client.auth.currentUser == null) {
      throw const SpeakingDraftException('ログインが必要です。');
    }

    try {
      final response = await client.functions.invoke(
        'create-speaking-draft',
        body: {'japaneseText': japaneseText, 'language': language},
      );

      if (response.status >= 400) {
        throw SpeakingDraftException(_errorMessageFor(response.data));
      }

      final data = response.data;
      if (data is Map) {
        final draft = data['draft']?.toString().trim();
        if (draft != null && draft.isNotEmpty) {
          return draft;
        }
      }
    } on SpeakingDraftException {
      rethrow;
    } catch (error) {
      throw SpeakingDraftException(_errorMessageFor(error));
    }

    throw const SpeakingDraftException('練習文を作成できませんでした。');
  }

  String _errorMessageFor(Object? data) {
    final rawMessage = _rawErrorMessage(data);
    if (rawMessage != null && rawMessage.isNotEmpty) {
      if (rawMessage.contains('japaneseText is required')) {
        return '日本語で言いたいことを入力してください。';
      }
      if (rawMessage.contains('japaneseText is too long')) {
        return '入力は500文字以内にしてください。';
      }
      if (rawMessage.contains('OPENAI_API_KEY')) {
        return 'AI変換の設定が未完了です。';
      }
      if (rawMessage.contains('Invalid user session') ||
          rawMessage.contains('Authorization')) {
        return 'ログインが必要です。';
      }
    }
    return '練習文を作成できませんでした。';
  }

  String? _rawErrorMessage(Object? data) {
    if (data is Map) {
      final error = data['error'];
      if (error is Map) {
        return error['message']?.toString();
      }
      return error?.toString();
    }
    return data?.toString();
  }
}

class SpeakingDraftException implements Exception {
  const SpeakingDraftException(this.message);

  final String message;

  @override
  String toString() => message;
}
