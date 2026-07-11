import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class RecordService {
  RecordService({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  String? _currentPath;

  Future<void> start() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw const RecordPermissionException();
    }

    final encoder = await _selectEncoder();
    final directory = await _recordingsDirectory();
    final path =
        '${directory.path}${Platform.pathSeparator}talklog_${DateTime.now().millisecondsSinceEpoch}.${_extensionFor(encoder)}';

    try {
      await _recorder.start(
        RecordConfig(
          encoder: encoder,
          numChannels: 1,
          sampleRate: _sampleRateFor(encoder),
        ),
        path: path,
      );
      _currentPath = path;
    } catch (error) {
      throw RecordStartException(error.toString());
    }
  }

  Future<String> stop() async {
    try {
      final path = await _recorder.stop() ?? _currentPath;
      _currentPath = null;
      if (path == null) {
        throw const RecordSaveException('録音ファイルが作成されませんでした。');
      }
      return path;
    } catch (error) {
      if (error is RecordSaveException) {
        rethrow;
      }
      throw RecordSaveException(error.toString());
    }
  }

  Future<void> cancel() async {
    try {
      final path = await _recorder.stop() ?? _currentPath;
      _currentPath = null;
      if (path == null) {
        return;
      }
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (error) {
      throw RecordSaveException(error.toString());
    }
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }

  Future<AudioEncoder> _selectEncoder() async {
    for (final encoder in const [AudioEncoder.aacLc, AudioEncoder.wav]) {
      if (await _recorder.isEncoderSupported(encoder)) {
        return encoder;
      }
    }
    throw const RecordStartException('この端末で利用できる録音形式が見つかりませんでした。');
  }

  int _sampleRateFor(AudioEncoder encoder) {
    return switch (encoder) {
      AudioEncoder.amrNb => 8000,
      AudioEncoder.amrWb => 16000,
      _ => 44100,
    };
  }

  String _extensionFor(AudioEncoder encoder) {
    return switch (encoder) {
      AudioEncoder.wav => 'wav',
      AudioEncoder.flac => 'flac',
      AudioEncoder.opus => 'opus',
      AudioEncoder.pcm16bits => 'pcm',
      AudioEncoder.amrNb || AudioEncoder.amrWb => '3gp',
      _ => 'm4a',
    };
  }

  Future<Directory> _recordingsDirectory() async {
    final baseDirectory = await getApplicationDocumentsDirectory();
    final directory = Directory(
      '${baseDirectory.path}${Platform.pathSeparator}recordings',
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }
}

class RecordPermissionException implements Exception {
  const RecordPermissionException();
}

class RecordStartException implements Exception {
  const RecordStartException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RecordSaveException implements Exception {
  const RecordSaveException(this.message);

  final String message;

  @override
  String toString() => message;
}
