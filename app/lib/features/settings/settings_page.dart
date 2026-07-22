import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/services/auth_session_service.dart';
import '../../core/services/supabase_service.dart';
import '../../l10n/app_localizations.dart';
import '../premium/localized_premium_plan_page.dart';
import '../recording/data/recording_store.dart';
import 'data/app_settings_store.dart';
import 'models/app_language.dart';

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
    final l10n = AppLocalizations.of(context);
    final syncError = _recordingStore.lastSyncError;
    final syncMessage = _recordingStore.lastSyncMessage;
    final settingsError = _settingsStore.cloudError;
    final settingsMessage = _settingsStore.cloudMessage;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.languageSettings,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.translate),
            title: Text(l10n.appLanguage),
            subtitle: Text(
              l10n.currentValue(
                _languageName(l10n, _settingsStore.baseLocaleCode),
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showBaseLocalePicker,
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: Text(l10n.practiceLanguage),
            subtitle: Text(
              l10n.currentValue(
                _languageName(l10n, _settingsStore.learningLanguageCode),
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showLearningLanguagePicker,
          ),
          const Divider(height: 32),
          _AccountAuthCard(
            statusText: _cloudStatusText(l10n),
            email: _authSessionService.email,
            roleLabel: _localizedRole(l10n, _authSessionService.roleValue),
            canUsePremiumFeature: _authSessionService.canUsePremiumFeature,
            isConfigured: _authSessionService.isConfigured,
            isLoading: _authSessionService.isLoading,
            isAnonymous: _authSessionService.isAnonymous,
            isPasswordRecovery: _authSessionService.isPasswordRecovery,
            message: _authSessionService.message == null
                ? null
                : _localizedServiceMessage(l10n, _authSessionService.message!),
            errorMessage: _authSessionService.errorMessage == null
                ? null
                : _localizedServiceMessage(
                    l10n,
                    _authSessionService.errorMessage!,
                  ),
            onRegisterEmail: _authSessionService.registerEmailAccount,
            onSignInEmail: _signInEmailAndLoadData,
            onSendPasswordResetEmail:
                _authSessionService.sendPasswordResetEmail,
            onUpdatePassword: _authSessionService.updatePassword,
            onSignOut: _signOutAndClearLocal,
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.cloud_outlined),
            title: Text(l10n.cloudSync),
            subtitle: Text(_cloudStatusText(l10n)),
            trailing: _authSessionService.isLoading
                ? const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : IconButton(
                    tooltip: l10n.reconnect,
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
                      _recordingStore.isSyncing
                          ? l10n.syncing
                          : l10n.syncRecordingHistory,
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
                          label: Text(l10n.downloadSettings),
                          onPressed: _settingsStore.isCloudSyncing
                              ? null
                              : _settingsStore.syncFromCloud,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.upload_outlined),
                          label: Text(l10n.saveSettings),
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
                      l10n.recordingSyncFailed(syncError),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ] else if (syncMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _localizedServiceMessage(l10n, syncMessage),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ] else if (_recordingStore.lastSyncedAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.lastSynced(
                        _formatTime(context, _recordingStore.lastSyncedAt!),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (settingsError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _localizedServiceMessage(l10n, settingsError),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ] else if (settingsMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _localizedServiceMessage(l10n, settingsMessage),
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

  String _cloudStatusText(AppLocalizations l10n) {
    final userId = _authSessionService.userId;
    final status = !_authSessionService.isConfigured
        ? l10n.cloudNotConfigured
        : _authSessionService.isLoading
        ? l10n.connecting
        : _authSessionService.isEmailSignedIn
        ? l10n.signedInWithEmail
        : _authSessionService.errorMessage != null
        ? l10n.connectionError
        : l10n.notSignedIn;
    if (userId == null) {
      return status;
    }
    return '$status / ID: ${_shortUserId(userId)}';
  }

  String _localizedRole(AppLocalizations l10n, String role) => switch (role) {
    'PREMIUM' => l10n.rolePremium,
    'TESTER' => l10n.roleTester,
    'ADMIN' => l10n.roleAdmin,
    _ => l10n.roleFree,
  };

  String _localizedServiceMessage(AppLocalizations l10n, String message) {
    final parts = message.split('|');
    final details = parts.length > 1 ? parts.sublist(1).join('|') : '';
    return switch (parts.first) {
      'AUTH_CONFIRMATION_SENT' => l10n.authConfirmationSent,
      'AUTH_SIGNED_IN' => l10n.authSignedIn,
      'AUTH_PASSWORD_RESET_SENT' => l10n.authPasswordResetSent,
      'AUTH_PASSWORD_UPDATED' => l10n.authPasswordUpdated,
      'AUTH_SIGNED_OUT' => l10n.authSignedOut,
      'AUTH_ENTER_NEW_PASSWORD' => l10n.authEnterNewPassword,
      'AUTH_INVALID_EMAIL' => l10n.authInvalidEmail,
      'AUTH_PASSWORD_TOO_SHORT' => l10n.authPasswordTooShort,
      'AUTH_NOT_CONFIGURED' => l10n.authNotConfigured,
      'AUTH_SIGN_OUT_FAILED' => l10n.authSignOutFailed(details),
      'AUTH_ACTION_FAILED' => l10n.authActionFailed(details),
      'SETTINGS_DOWNLOADED' => l10n.settingsDownloaded,
      'SETTINGS_SAVED' => l10n.settingsSaved,
      'SETTINGS_DOWNLOAD_FAILED' => l10n.settingsDownloadFailed(details),
      'SETTINGS_SAVE_FAILED' => l10n.settingsSaveFailed(details),
      'RECORDINGS_CLOUD_EMPTY' => l10n.recordingsCloudEmpty,
      'RECORDINGS_DOWNLOADED' => l10n.recordingsDownloaded(
        int.tryParse(details) ?? 0,
      ),
      'RECORDINGS_IMPORTED' => l10n.recordingsImported(
        int.tryParse(details) ?? 0,
      ),
      'RECORDINGS_SYNCED' => l10n.recordingsSynced,
      _ => message,
    };
  }

  String _shortUserId(String userId) {
    if (userId.length <= 8) {
      return userId;
    }
    return userId.substring(0, 8);
  }

  String _formatTime(BuildContext context, DateTime dateTime) {
    return DateFormat.Hm(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(dateTime.toLocal());
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

  Future<void> _showBaseLocalePicker() async {
    final l10n = AppLocalizations.of(context);
    final selectedLocale = await showDialog<AppLanguage>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.selectAppLanguage),
        children: [
          for (final language in supportedBaseLocales)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(language),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(_languageName(l10n, language.code))],
                    ),
                  ),
                  if (language == _settingsStore.baseLocale)
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
    if (selectedLocale != null) {
      if (selectedLocale == _settingsStore.learningLanguageValue) {
        if (!mounted) return;
        final replacement = await _showConflictResolutionPicker(selectedLocale);
        if (replacement == null) return;
        await _settingsStore.setLanguages(
          baseLocale: selectedLocale.code,
          learningLanguage: replacement.code,
        );
      } else {
        await _settingsStore.setBaseLocale(selectedLocale.code);
      }
    }
  }

  Future<AppLanguage?> _showConflictResolutionPicker(
    AppLanguage nextBaseLocale,
  ) async {
    final l10n = AppLocalizations.of(context);
    return showDialog<AppLanguage>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.chooseNewPracticeLanguage),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Text(l10n.practiceLanguageMustChange),
          ),
          for (final language in supportedLearningLanguages)
            if (language != nextBaseLocale)
              SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(language),
                child: Text(_languageName(l10n, language.code)),
              ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLearningLanguagePicker() async {
    final l10n = AppLocalizations.of(context);
    final selectedLanguage = await showDialog<String>(
      context: context,
      builder: (context) {
        final currentLanguage = _settingsStore.learningLanguageCode;
        return SimpleDialog(
          title: Text(l10n.selectPracticeLanguage),
          children: [
            for (final language in _settingsStore.availableLearningLanguages)
              SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(language.code),
                child: Row(
                  children: [
                    Expanded(child: Text(_languageName(l10n, language.code))),
                    if (language.code == currentLanguage)
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

  String _languageName(AppLocalizations l10n, String code) {
    return l10n.languageName(code == 'zh-Hans' ? 'zhHans' : code);
  }

  Future<void> _runConnectionDiagnostics() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _isCheckingConnection = true;
      _diagnostics = const [];
    });

    final items = <_DiagnosticItem>[];
    items.add(
      _DiagnosticItem(
        label: l10n.supabaseConfiguration,
        isOk: SupabaseService.isConfigured,
        message: SupabaseService.isConfigured
            ? l10n.supabaseConfigured
            : l10n.supabaseNotConfigured,
      ),
    );

    if (SupabaseService.isConfigured) {
      try {
        await SupabaseService.initializeIfConfigured();
        items.add(
          _DiagnosticItem(
            label: l10n.supabaseInitialization,
            isOk: true,
            message: l10n.supabaseInitialized,
          ),
        );
      } catch (error) {
        items.add(
          _DiagnosticItem(
            label: l10n.supabaseInitialization,
            isOk: false,
            message: _friendlyError(error),
          ),
        );
      }
    }

    await _authSessionService.initializeSession();
    items.add(
      _DiagnosticItem(
        label: l10n.emailSignInDiagnostic,
        isOk: _authSessionService.isEmailSignedIn,
        message: _authSessionService.isEmailSignedIn
            ? l10n.signedInSuccessfully
            : _authSessionService.errorMessage == null
            ? l10n.notSignedIn
            : _localizedServiceMessage(l10n, _authSessionService.errorMessage!),
      ),
    );
    items.add(
      _DiagnosticItem(
        label: l10n.accountAccess,
        isOk: _authSessionService.isEmailSignedIn,
        message: _authSessionService.isEmailSignedIn
            ? ' / '
            : l10n.accountAccessAfterSignIn,
      ),
    );

    final client = SupabaseService.client;
    if (client != null && _authSessionService.isEmailSignedIn) {
      await _checkTable(items, 'profiles', l10n);
      await _checkTable(items, 'recordings', l10n);
      await _checkTable(items, 'transcripts', l10n);
      await _checkTable(items, 'feedbacks', l10n);
      await _checkTable(items, 'vocabulary', l10n);
      await _checkTable(items, 'word_usage', l10n);
      await _checkEdgeFunction(items, l10n);
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
    AppLocalizations l10n,
  ) async {
    final client = SupabaseService.client;
    if (client == null) {
      return;
    }
    try {
      await client.from(tableName).select('id').limit(1);
      items.add(
        _DiagnosticItem(
          label: l10n.databaseTable(tableName),
          isOk: true,
          message: l10n.databaseTableAccessible,
        ),
      );
    } catch (error) {
      items.add(
        _DiagnosticItem(
          label: l10n.databaseTable(tableName),
          isOk: false,
          message: _friendlyError(error),
        ),
      );
    }
  }

  Future<void> _checkEdgeFunction(
    List<_DiagnosticItem> items,
    AppLocalizations l10n,
  ) async {
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
              ? l10n.edgeFunctionResponding
              : l10n.responseStatus(response.status),
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
    required this.isPasswordRecovery,
    required this.message,
    required this.errorMessage,
    required this.onRegisterEmail,
    required this.onSignInEmail,
    required this.onSendPasswordResetEmail,
    required this.onUpdatePassword,
    required this.onSignOut,
  });

  final String statusText;
  final String? email;
  final String roleLabel;
  final bool canUsePremiumFeature;
  final bool isConfigured;
  final bool isLoading;
  final bool isAnonymous;
  final bool isPasswordRecovery;
  final String? message;
  final String? errorMessage;
  final Future<void> Function({required String email, required String password})
  onRegisterEmail;
  final Future<void> Function({required String email, required String password})
  onSignInEmail;
  final Future<bool> Function({required String email}) onSendPasswordResetEmail;
  final Future<void> Function({required String password}) onUpdatePassword;
  final VoidCallback onSignOut;

  @override
  State<_AccountAuthCard> createState() => _AccountAuthCardState();
}

class _AccountAuthCardState extends State<_AccountAuthCard> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureNewPassword = true;
  bool _passwordResetEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final canUseAuthButtons = widget.isConfigured && !widget.isLoading;
    final isEmailLoggedIn = !widget.isAnonymous && widget.email != null;
    final registerLabel = widget.isAnonymous
        ? l10n.registerCurrentData
        : l10n.registerWithEmail;

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
                Text(l10n.account, style: theme.textTheme.titleMedium),
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
                        l10n.accountRole(widget.roleLabel),
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
            if (!widget.canUsePremiumFeature) ...[
              FilledButton.icon(
                icon: const Icon(Icons.workspace_premium_outlined),
                label: Text(l10n.registerPremium),
                onPressed: () => _openPremiumPlan(context),
              ),
              const SizedBox(height: 12),
            ],
            if (widget.isPasswordRecovery) ...[
              Text(l10n.newPasswordPrompt, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 10),
              TextField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                autofillHints: const [AutofillHints.newPassword],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.newPassword,
                  prefixIcon: const Icon(Icons.lock_reset_outlined),
                  suffixIcon: IconButton(
                    tooltip: _obscureNewPassword ? l10n.show : l10n.hide,
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                ),
                enabled: canUseAuthButtons,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: widget.isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(l10n.updatePassword),
                onPressed: canUseAuthButtons ? _updatePassword : null,
              ),
            ] else if (isEmailLoggedIn) ...[
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
                label: Text(l10n.signOut),
                onPressed: canUseAuthButtons ? widget.onSignOut : null,
              ),
              const SizedBox(height: 10),
              Text(l10n.signOutDataNotice, style: theme.textTheme.bodySmall),
            ] else ...[
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: l10n.emailAddress,
                  prefixIcon: const Icon(Icons.mail_outline),
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
                  labelText: l10n.password,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword ? l10n.show : l10n.hide,
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
                    label: Text(l10n.signInWithEmail),
                    onPressed: canUseAuthButtons ? _signInEmail : null,
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.help_outline),
                    label: Text(l10n.forgotPassword),
                    onPressed: canUseAuthButtons
                        ? _sendPasswordResetEmail
                        : null,
                  ),
                ],
              ),
              if (_passwordResetEmailSent) ...[
                const SizedBox(height: 10),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.55,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.mark_email_read_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.passwordResetCheckEmail,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                l10n.emailRegistrationBenefit,
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (!widget.isConfigured) ...[
              const SizedBox(height: 10),
              Text(
                l10n.emailRegistrationRequiresCloud,
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

  void _openPremiumPlan(BuildContext context) {
    Navigator.of(context).push(LocalizedPremiumPlanPage.route());
  }

  Future<void> _registerEmail() async {
    setState(() {
      _passwordResetEmailSent = false;
    });
    await widget.onRegisterEmail(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  Future<void> _sendPasswordResetEmail() async {
    final wasSent = await widget.onSendPasswordResetEmail(
      email: _emailController.text,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _passwordResetEmailSent = wasSent;
    });
    if (wasSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).passwordResetSent)),
      );
    }
  }

  Future<void> _updatePassword() async {
    await widget.onUpdatePassword(password: _newPasswordController.text);
    if (mounted) {
      _newPasswordController.clear();
    }
  }

  Future<void> _signInEmail() async {
    setState(() {
      _passwordResetEmailSent = false;
    });
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
    final l10n = AppLocalizations.of(context);
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
                Text(
                  l10n.connectionDiagnostics,
                  style: theme.textTheme.titleMedium,
                ),
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
              label: Text(
                isChecking ? l10n.checkingConnection : l10n.checkConnection,
              ),
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
