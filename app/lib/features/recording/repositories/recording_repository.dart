import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../models/record_entry.dart';

abstract class RecordingRepository {
  Future<void> syncRecording(RecordEntry entry);
  Future<List<RecordEntry>> fetchRecordings();
  Future<bool> hasRemoteRecording(RecordEntry entry);
  Future<void> deleteRecording(RecordEntry entry);
}

class SupabaseRecordingRepository implements RecordingRepository {
  SupabaseRecordingRepository({SupabaseClient? client})
    : _client = client ?? SupabaseService.client;

  final SupabaseClient? _client;

  bool get isAvailable => _client != null;

  @override
  Future<void> syncRecording(RecordEntry entry) async {
    final client = _client;
    final userId = client?.auth.currentUser?.id;
    if (client == null || userId == null || !_isUuid(entry.id)) {
      return;
    }

    await _ensureProfile(client, userId);

    final remoteAudioPath = _remoteAudioPath(userId: userId, entry: entry);
    final audioFile = File(entry.audioPath);

    if (await audioFile.exists()) {
      await client.storage
          .from('recordings')
          .upload(
            remoteAudioPath,
            audioFile,
            fileOptions: FileOptions(
              upsert: true,
              contentType: _contentTypeFor(entry.audioPath),
            ),
          );
    }

    await client.from('recordings').upsert({
      'id': entry.id,
      'user_id': userId,
      'language': entry.language,
      'audio_path': remoteAudioPath,
      'local_audio_path': entry.audioPath,
      'duration_seconds': entry.duration.inSeconds,
      'created_at': entry.createdAt.toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<List<RecordEntry>> fetchRecordings() async {
    final client = _client;
    final userId = client?.auth.currentUser?.id;
    if (client == null || userId == null) {
      return const [];
    }

    await _ensureProfile(client, userId);

    final rows = await client
        .from('recordings')
        .select(
          'id, language, audio_path, local_audio_path, duration_seconds, created_at',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final entries = <RecordEntry>[];
    for (final row in rows) {
      final data = Map<String, dynamic>.from(row as Map);
      final id = data['id'] as String?;
      final createdAtRaw = data['created_at'] as String?;
      if (id == null || createdAtRaw == null || !_isUuid(id)) {
        continue;
      }

      final audioPath = data['audio_path'] as String?;
      final localAudioPath = data['local_audio_path'] as String?;
      final resolvedAudioPath = await _resolveAudioPath(
        client: client,
        recordingId: id,
        remoteAudioPath: audioPath,
        localAudioPath: localAudioPath,
      );
      if (resolvedAudioPath == null) {
        continue;
      }

      entries.add(
        RecordEntry(
          id: id,
          createdAt: RecordEntry.parseStoredDateTime(createdAtRaw),
          duration: Duration(seconds: data['duration_seconds'] as int? ?? 0),
          audioPath: resolvedAudioPath,
          language: data['language'] as String? ?? 'スペイン語',
        ),
      );
    }

    return entries;
  }

  @override
  Future<bool> hasRemoteRecording(RecordEntry entry) async {
    final client = _client;
    final userId = client?.auth.currentUser?.id;
    if (client == null || userId == null || !_isUuid(entry.id)) {
      return false;
    }

    final row = await client
        .from('recordings')
        .select('id')
        .eq('id', entry.id)
        .eq('user_id', userId)
        .maybeSingle();
    return row != null;
  }

  @override
  Future<void> deleteRecording(RecordEntry entry) async {
    final client = _client;
    final userId = client?.auth.currentUser?.id;
    if (client == null || userId == null || !_isUuid(entry.id)) {
      return;
    }

    final remoteAudioPath = _remoteAudioPath(userId: userId, entry: entry);
    await client.storage.from('recordings').remove([remoteAudioPath]);
    await client
        .from('recordings')
        .delete()
        .eq('id', entry.id)
        .eq('user_id', userId);
  }

  Future<void> _ensureProfile(SupabaseClient client, String userId) async {
    final user = client.auth.currentUser;
    await client.from('profiles').upsert({
      'id': userId,
      'email': user?.email,
      'display_name': user?.email ?? '匿名ユーザー',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });

    await client.from('settings').upsert({
      'user_id': userId,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }

  Future<String?> _resolveAudioPath({
    required SupabaseClient client,
    required String recordingId,
    required String? remoteAudioPath,
    required String? localAudioPath,
  }) async {
    if (localAudioPath != null && await File(localAudioPath).exists()) {
      return localAudioPath;
    }
    if (remoteAudioPath == null || remoteAudioPath.isEmpty) {
      return null;
    }

    final directory = await getApplicationDocumentsDirectory();
    final cloudDirectory = Directory(
      '${directory.path}${Platform.pathSeparator}cloud_recordings',
    );
    if (!await cloudDirectory.exists()) {
      await cloudDirectory.create(recursive: true);
    }

    final extension = _extensionFor(remoteAudioPath);
    final localFile = File(
      '${cloudDirectory.path}${Platform.pathSeparator}$recordingId.$extension',
    );
    if (await localFile.exists()) {
      return localFile.path;
    }

    final bytes = await client.storage
        .from('recordings')
        .download(remoteAudioPath);
    await localFile.writeAsBytes(bytes, flush: true);
    return localFile.path;
  }

  String _remoteAudioPath({
    required String userId,
    required RecordEntry entry,
  }) {
    final createdAt = entry.createdAt.toUtc();
    final year = createdAt.year.toString().padLeft(4, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    final extension = _extensionFor(entry.audioPath);
    return '$userId/$year/$month/${entry.id}.$extension';
  }

  String _extensionFor(String path) {
    final filename = path.split(RegExp(r'[\\/]')).last;
    final dotIndex = filename.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == filename.length - 1) {
      return 'm4a';
    }
    return filename.substring(dotIndex + 1).toLowerCase();
  }

  String _contentTypeFor(String path) {
    return switch (_extensionFor(path)) {
      'wav' => 'audio/wav',
      'flac' => 'audio/flac',
      'opus' => 'audio/ogg',
      'pcm' => 'audio/L16',
      '3gp' => 'audio/3gpp',
      _ => 'audio/mp4',
    };
  }

  bool _isUuid(String value) {
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(value);
  }
}
