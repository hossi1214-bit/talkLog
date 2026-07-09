import 'package:flutter/material.dart';

import '../data/recording_store.dart';

class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({required this.store, super.key});

  final RecordingStore store;

  @override
  Widget build(BuildContext context) {
    final error = store.lastSyncError;
    if (!store.isSyncing && error == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isError = error != null;

    return Card(
      color: isError ? colorScheme.errorContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isError
                      ? Icons.cloud_off_outlined
                      : Icons.cloud_sync_outlined,
                  color: isError
                      ? colorScheme.onErrorContainer
                      : colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isError ? 'クラウド同期に失敗しました' : 'クラウド同期中です',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: isError ? colorScheme.onErrorContainer : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isError ? error : '録音履歴をクラウドと同期しています。',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isError ? colorScheme.onErrorContainer : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (store.isSyncing)
              const LinearProgressIndicator()
            else
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('再同期'),
                  onPressed: store.syncAll,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
