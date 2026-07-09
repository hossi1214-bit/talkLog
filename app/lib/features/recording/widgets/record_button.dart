import 'package:flutter/material.dart';

class RecordButton extends StatelessWidget {
  const RecordButton({
    required this.isRecording,
    required this.onPressed,
    this.isBusy = false,
    super.key,
  });

  final bool isRecording;
  final bool isBusy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox.square(
      dimension: 112,
      child: FilledButton(
        onPressed: isBusy ? null : onPressed,
        style: FilledButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: isRecording
              ? colorScheme.error
              : colorScheme.primary,
          foregroundColor: isRecording
              ? colorScheme.onError
              : colorScheme.onPrimary,
        ),
        child: isBusy
            ? const SizedBox.square(
                dimension: 32,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            : Icon(isRecording ? Icons.stop : Icons.mic, size: 42),
      ),
    );
  }
}
