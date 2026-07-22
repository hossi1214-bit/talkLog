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
      throw const SpeakingDraftException('DRAFT_AUTH_REQUIRED');
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

    throw const SpeakingDraftException('DRAFT_FAILED');
  }

  String _errorMessageFor(Object? data) {
    final rawMessage = _rawErrorMessage(data);
    if (rawMessage == null || rawMessage.isEmpty) {
      return 'DRAFT_FAILED';
    }

    final lower = rawMessage.toLowerCase();
    if (rawMessage.contains('japaneseText is required')) {
      return 'DRAFT_INPUT_REQUIRED';
    }
    if (rawMessage.contains('japaneseText is too long')) {
      return 'DRAFT_INPUT_TOO_LONG';
    }
    if (rawMessage.contains('OPENAI_API_KEY')) {
      return 'DRAFT_API_NOT_CONFIGURED';
    }
    if (rawMessage.contains('Invalid user session') ||
        rawMessage.contains('Authorization') ||
        lower.contains('jwt')) {
      return 'DRAFT_AUTH_REQUIRED';
    }
    if (lower.contains('function not found') ||
        lower.contains('404') ||
        lower.contains('not found')) {
      return 'DRAFT_FUNCTION_NOT_FOUND';
    }
    if (lower.contains('quota') ||
        lower.contains('billing') ||
        lower.contains('insufficient_quota')) {
      return 'DRAFT_API_LIMIT';
    }
    if (lower.contains('network') || lower.contains('socket')) {
      return 'DRAFT_NETWORK_ERROR';
    }

    return 'DRAFT_FAILED';
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
