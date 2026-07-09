import 'package:flutter/material.dart';

import '../../core/services/auth_session_service.dart';
import '../../core/services/supabase_service.dart';
import '../recording/data/recording_store.dart';
import 'data/app_settings_store.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _settingsStore = AppSettingsStore.instance;
  final _authSessionService = AuthSessionService.instance;
  final _recordingStore = RecordingStore.instance;

  bool _isCheckingConnection = false;
  List<_DiagnosticItem> _diagnostics = const [];

  @override
  void initState() {
    super.initState();
    _settingsStore.addListener(_handleStateChanged);
    _authSessionService.addListener(_handleStateChanged);
    _recordingStore.addListener(_handleStateChanged);
    _settingsStore.load();
  }

  @override
  void dispose() {
    _settingsStore.removeListener(_handleStateChanged);
    _authSessionService.removeListener(_handleStateChanged);
    _recordingStore.removeListener(_handleStateChanged);
    super.dispose();
  }

  void _handleStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncError = _recordingStore.lastSyncError;
    final syncMessage = _recordingStore.lastSyncMessage;
    final settingsError = _settingsStore.cloudError;
    final settingsMessage = _settingsStore.cloudMessage;

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('学習言語'),
            subtitle: Text('現在: ${_settingsStore.learningLanguage}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showLanguagePicker,
          ),
          const ListTile(
            leading: Icon(Icons.notifications_none),
            title: Text('通知'),
            subtitle: Text('今後の学習リマインダー用の設定項目です。'),
          ),
          const Divider(height: 32),
          _AccountAuthCard(
            statusText: _cloudStatusText,
            email: _authSessionService.email,
            roleLabel: _authSessionService.roleLabel,
            canUsePremiumFeature: _authSessionService.canUsePremiumFeature,
            isConfigured: _authSessionService.isConfigured,
            isLoading: _authSessionService.isLoading,
            isAnonymous: _authSessionService.isAnonymous,
            message: _authSessionService.message,
            errorMessage: _authSessionService.errorMessage,
            onRegisterEmail: _authSessionService.registerEmailAccount,
            onSignInEmail: _signInEmailAndLoadData,
            onSignOut: _signOutAndClearLocal,
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: const Text('クラウド同期'),
            subtitle: Text(_cloudStatusText),
            trailing: _authSessionService.isLoading
                ? const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : IconButton(
                    tooltip: '再接続',
                    icon: const Icon(Icons.refresh),
                    onPressed: _authSessionService.isConfigured
                        ? _authSessionService.retry
                        : null,
                  ),
          ),
          if (_authSessionService.isEmailSignedIn)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlinedButton.icon(
                    icon: _recordingStore.isSyncing
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_sync_outlined),
                    label: Text(
                      _recordingStore.isSyncing ? '同期中...' : '録音履歴をクラウドと同期',
                    ),
                    onPressed: _recordingStore.isSyncing
                        ? null
                        : _recordingStore.syncAll,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('設定を取得'),
                          onPressed: _settingsStore.isCloudSyncing
                              ? null
                              : _settingsStore.syncFromCloud,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.upload_outlined),
                          label: const Text('設定を保存'),
                          onPressed: _settingsStore.isCloudSyncing
                              ? null
                              : _settingsStore.syncToCloud,
                        ),
                      ),
                    ],
                  ),
                  if (_settingsStore.isCloudSyncing) ...[
                    const SizedBox(height: 8),
                    const LinearProgressIndicator(),
                  ],
                  if (syncError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '録音同期に失敗しました: $syncError',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ] else if (syncMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      syncMessage,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ] else if (_recordingStore.lastSyncedAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '最終同期: ${_formatTime(_recordingStore.lastSyncedAt!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (settingsError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '設定同期に失敗しました: $settingsError',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ] else if (settingsMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      settingsMessage,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 20),
          _ConnectionDiagnosticsCard(
            isChecking: _isCheckingConnection,
            diagnostics: _diagnostics,
            onCheck: _runConnectionDiagnostics,
          ),
        ],
      ),
    );
  }

  String get _cloudStatusText {
    final userId = _authSessionService.userId;
    if (userId == null) {
      return _authSessionService.statusLabel;
    }
    return '${_authSessionService.statusLabel} / ID: ${_shortUserId(userId)}';
  }

  String _shortUserId(String userId) {
    if (userId.length <= 8) {
      return userId;
    }
    return userId.substring(0, 8);
  }

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _signInEmailAndLoadData({
    required String email,
    required String password,
  }) async {
    await _authSessionService.signInWithEmail(email: email, password: password);
    if (_authSessionService.isEmailSignedIn) {
      await _recordingStore.clearLocal();
      await _recordingStore.loadFromCloud();
      await _settingsStore.syncFromCloud();
    }
  }

  Future<void> _signOutAndClearLocal() async {
    await _authSessionService.signOut();
    await _recordingStore.clearLocal();
  }

  Future<void> _showLanguagePicker() async {
    final selectedLanguage = await showDialog<String>(
      context: context,
      builder: (context) {
        final currentLanguage = _settingsStore.learningLanguage;
        return SimpleDialog(
          title: const Text('学習言語を選択'),
          children: [
            for (final language in AppSettingsStore.supportedLanguages)
              SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(language),
                child: Row(
                  children: [
                    Expanded(child: Text(language)),
                    if (language == currentLanguage)
                      Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );

    if (selectedLanguage != null) {
      await _settingsStore.setLearningLanguage(selectedLanguage);
    }
  }

  Future<void> _runConnectionDiagnostics() async {
    setState(() {
      _isCheckingConnection = true;
      _diagnostics = const [];
    });

    final items = <_DiagnosticItem>[];
    items.add(
      _DiagnosticItem(
        label: 'Supabase設定',
        isOk: SupabaseService.isConfigured,
        message: SupabaseService.isConfigured
            ? 'URLとanon keyが設定されています。'
            : 'SUPABASE_URL / SUPABASE_ANON_KEY が未設定です。',
      ),
    );

    if (SupabaseService.isConfigured) {
      try {
        await SupabaseService.initializeIfConfigured();
        items.add(
          const _DiagnosticItem(
            label: 'Supabase初期化',
            isOk: true,
            message: '初期化済みです。',
          ),
        );
      } catch (error) {
        items.add(
          _DiagnosticItem(
            label: 'Supabase初期化',
            isOk: false,
            message: _friendlyError(error),
          ),
        );
      }
    }

    await _authSessionService.initializeSession();
    items.add(
      _DiagnosticItem(
        label: 'メールログイン',
        isOk: _authSessionService.isEmailSignedIn,
        message: _authSessionService.isEmailSignedIn
            ? 'ログインできています。'
            : _authSessionService.errorMessage ?? '未ログインです。',
      ),
    );
    items.add(
      _DiagnosticItem(
        label: 'アカウント権限',
        isOk: _authSessionService.isEmailSignedIn,
        message: _authSessionService.isEmailSignedIn
            ? ' / '
            : 'ログイン後にprofiles.roleを取得します。',
      ),
    );

    final client = SupabaseService.client;
    if (client != null && _authSessionService.isEmailSignedIn) {
      await _checkTable(items, 'profiles');
      await _checkTable(items, 'recordings');
      await _checkTable(items, 'transcripts');
      await _checkTable(items, 'feedbacks');
      await _checkTable(items, 'vocabulary');
      await _checkTable(items, 'word_usage');
      await _checkEdgeFunction(items);
    }

    if (mounted) {
      setState(() {
        _diagnostics = items;
        _isCheckingConnection = false;
      });
    }
  }

  Future<void> _checkTable(
    List<_DiagnosticItem> items,
    String tableName,
  ) async {
    final client = SupabaseService.client;
    if (client == null) {
      return;
    }
    try {
      await client.from(tableName).select('id').limit(1);
      items.add(
        _DiagnosticItem(
          label: '$tableName テーブル',
          isOk: true,
          message: '参照できます。',
        ),
      );
    } catch (error) {
      items.add(
        _DiagnosticItem(
          label: '$tableName テーブル',
          isOk: false,
          message: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> _checkEdgeFunction(List<_DiagnosticItem> items) async {
    final client = SupabaseService.client;
    if (client == null) {
      return;
    }
    try {
      final response = await client.functions.invoke(
        'analyze-recording',
        body: const {},
      );
      final isExpectedResponse =
          response.status == 400 ||
          response.status == 401 ||
          response.status == 404;
      items.add(
        _DiagnosticItem(
          label: 'analyze-recording',
          isOk: isExpectedResponse || response.status < 500,
          message: isExpectedResponse
              ? 'Edge Functionは応答しています。'
              : '応答ステータス: ${response.status}',
        ),
      );
    } catch (error) {
      items.add(
        _DiagnosticItem(
          label: 'analyze-recording',
          isOk: false,
          message: _friendlyError(error),
        ),
      );
    }
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.length <= 160) {
      return message;
    }
    return '${message.substring(0, 160)}...';
  }
}

class _AccountAuthCard extends StatefulWidget {
  const _AccountAuthCard({
    required this.statusText,
    required this.email,
    required this.roleLabel,
    required this.canUsePremiumFeature,
    required this.isConfigured,
    required this.isLoading,
    required this.isAnonymous,
    required this.message,
    required this.errorMessage,
    required this.onRegisterEmail,
    required this.onSignInEmail,
    required this.onSignOut,
  });

  final String statusText;
  final String? email;
  final String roleLabel;
  final bool canUsePremiumFeature;
  final bool isConfigured;
  final bool isLoading;
  final bool isAnonymous;
  final String? message;
  final String? errorMessage;
  final Future<void> Function({required String email, required String password})
  onRegisterEmail;
  final Future<void> Function({required String email, required String password})
  onSignInEmail;
  final VoidCallback onSignOut;

  @override
  State<_AccountAuthCard> createState() => _AccountAuthCardState();
}

class _AccountAuthCardState extends State<_AccountAuthCard> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canUseAuthButtons = widget.isConfigured && !widget.isLoading;
    final isEmailLoggedIn = !widget.isAnonymous && widget.email != null;
    final registerLabel = widget.isAnonymous ? 'このデータをメール登録' : 'メールで登録';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text('アカウント', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 10),
            Text(widget.statusText, style: theme.textTheme.bodyMedium),
            if (widget.email != null) ...[
              const SizedBox(height: 4),
              Text(widget.email!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.canUsePremiumFeature
                          ? Icons.workspace_premium_outlined
                          : Icons.lock_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '権限: ${widget.roleLabel}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (isEmailLoggedIn) ...[
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.45,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.mail_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.email!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: widget.isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                label: const Text('ログアウト'),
                onPressed: canUseAuthButtons ? widget.onSignOut : null,
              ),
              const SizedBox(height: 10),
              Text(
                'ログアウトすると、この端末に表示していた録音履歴はクリアされます。再ログイン後はクラウド同期で取得できます。',
                style: theme.textTheme.bodySmall,
              ),
            ] else ...[
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'メールアドレス',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
                enabled: canUseAuthButtons,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'パスワード',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword ? '表示' : '非表示',
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                enabled: canUseAuthButtons,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    icon: widget.isLoading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.person_add_alt_1_outlined),
                    label: Text(registerLabel),
                    onPressed: canUseAuthButtons ? _registerEmail : null,
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text('メールでログイン'),
                    onPressed: canUseAuthButtons ? _signInEmail : null,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'メール登録すると、この端末の学習データを後から復元しやすくなります。',
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (!widget.isConfigured) ...[
              const SizedBox(height: 10),
              Text(
                'Supabase設定後にメール登録を利用できます。',
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (widget.message != null) ...[
              const SizedBox(height: 10),
              Text(widget.message!, style: theme.textTheme.bodySmall),
            ],
            if (widget.errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                widget.errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _registerEmail() async {
    await widget.onRegisterEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  Future<void> _signInEmail() async {
    await widget.onSignInEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }
}

class _ConnectionDiagnosticsCard extends StatelessWidget {
  const _ConnectionDiagnosticsCard({
    required this.isChecking,
    required this.diagnostics,
    required this.onCheck,
  });

  final bool isChecking;
  final List<_DiagnosticItem> diagnostics;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.health_and_safety_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text('接続診断', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: isChecking
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(isChecking ? '確認中...' : '接続状態を確認'),
              onPressed: isChecking ? null : onCheck,
            ),
            if (diagnostics.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final item in diagnostics) _DiagnosticRow(item: item),
            ],
          ],
        ),
      ),
    );
  }
}

class _DiagnosticRow extends StatelessWidget {
  const _DiagnosticRow({required this.item});

  final _DiagnosticItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            item.isOk ? Icons.check_circle_outline : Icons.error_outline,
            size: 18,
            color: item.isOk ? colorScheme.primary : colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: Theme.of(context).textTheme.labelLarge),
                Text(
                  item.message,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagnosticItem {
  const _DiagnosticItem({
    required this.label,
    required this.isOk,
    required this.message,
  });

  final String label;
  final bool isOk;
  final String message;
}
