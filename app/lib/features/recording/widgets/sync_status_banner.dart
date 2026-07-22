import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../data/recording_store.dart';

class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({required this.store, super.key});

  final RecordingStore store;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                        isError ? l10n.syncFailedTitle : l10n.syncingTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: isError ? colorScheme.onErrorContainer : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isError ? error : l10n.syncingDescription,
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
                  label: Text(l10n.syncRetry),
                  onPressed: store.syncAll,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
