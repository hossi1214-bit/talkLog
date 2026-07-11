import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/plan_policy.dart';
import '../models/user_role.dart';
import 'supabase_service.dart';

class AuthSessionService extends ChangeNotifier {
  AuthSessionService._();

  static final AuthSessionService instance = AuthSessionService._();
  static const emailRedirectTo = 'talklog://login-callback';

  bool _isLoading = false;
  String? _errorMessage;
  String? _message;
  UserRole _role = UserRole.free;
  bool _isPasswordRecovery = false;
  StreamSubscription<AuthState>? _authStateSubscription;

  bool get isConfigured => SupabaseService.isConfigured;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get message => _message;
  UserRole get role => _role;
  String get roleValue => _role.value;
  String get roleLabel => _role.label;
  bool get canUsePremiumFeature => _role.canUsePremiumFeature;
  int? get dailyAiCorrectionLimit => PlanPolicy.dailyAiCorrectionLimit(_role);
  int? get audioStorageLimitBytes => PlanPolicy.audioStorageLimitBytes(_role);
  bool get isAdmin => _role.isAdmin;
  bool get isPasswordRecovery => _isPasswordRecovery;

  SupabaseClient? get _client => SupabaseService.client;
  User? get currentUser => _client?.auth.currentUser;
  String? get userId => currentUser?.id;
  String? get email => currentUser?.email;
  bool get isSignedIn => currentUser != null;
  bool get isAnonymous => currentUser?.isAnonymous ?? false;
  bool get isEmailSignedIn => isSignedIn && !isAnonymous;

  String get providerLabel {
    final user = currentUser;
    if (user == null || user.isAnonymous) {
      return '未ログイン';
    }
    final provider = user.appMetadata['provider'] as String?;
    return switch (provider) {
      'email' => 'メール',
      'google' => 'Google',
      'apple' => 'Apple',
      _ => provider ?? 'メール',
    };
  }

  String get statusLabel {
    if (!isConfigured) {
      return 'Supabase未設定';
    }
    if (_isLoading) {
      return '接続中';
    }
    if (isEmailSignedIn) {
      return '$providerLabelでログイン中';
    }
    if (_errorMessage != null) {
      return '接続エラー';
    }
    return '未ログイン';
  }

  Future<void> initializeSession() async {
    if (!SupabaseService.isConfigured) {
      _errorMessage = null;
      _message = null;
      _role = UserRole.free;
      notifyListeners();
      return;
    }

    await SupabaseService.initializeIfConfigured();
    final client = _client;
    if (client == null) {
      return;
    }
    _ensureAuthListener(client);

    _errorMessage = null;
    if (client.auth.currentUser?.isAnonymous ?? false) {
      await client.auth.signOut();
      _role = UserRole.free;
    }
    notifyListeners();

    if (isEmailSignedIn) {
      await _tryEnsureProfile(client);
    } else {
      _role = UserRole.free;
      notifyListeners();
    }
  }

  Future<void> refreshUserRole() async {
    final client = _client;
    if (client == null || !isEmailSignedIn) {
      _role = UserRole.free;
      notifyListeners();
      return;
    }
    await _loadProfileRole(client);
    notifyListeners();
  }

  Future<void> registerEmailAccount({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    final validationError = _validateEmailPassword(normalizedEmail, password);
    if (validationError != null) {
      _errorMessage = validationError;
      _message = null;
      notifyListeners();
      return;
    }

    await _withAuthClient((client) async {
      await client.auth.signUp(
        email: normalizedEmail,
        password: password,
        emailRedirectTo: emailRedirectTo,
      );
      _message = '確認メールを送信しました。メール内のリンクから登録を完了してください。';
      await _tryEnsureProfile(client);
    }, actionLabel: 'メール登録');
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim();
    final validationError = _validateEmailPassword(normalizedEmail, password);
    if (validationError != null) {
      _errorMessage = validationError;
      _message = null;
      notifyListeners();
      return;
    }

    await _withAuthClient((client) async {
      await client.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );
      _message = 'メールアカウントでログインしました。';
      await _tryEnsureProfile(client);
    }, actionLabel: 'メールログイン');
  }

  Future<bool> sendPasswordResetEmail({required String email}) async {
    final normalizedEmail = email.trim();
    final validationError = _validateEmail(normalizedEmail);
    if (validationError != null) {
      _errorMessage = validationError;
      _message = null;
      notifyListeners();
      return false;
    }

    var didSend = false;
    await _withAuthClient((client) async {
      await client.auth.resetPasswordForEmail(
        normalizedEmail,
        redirectTo: emailRedirectTo,
      );
      didSend = true;
      _message = 'パスワード再設定メールを送信しました。メール内のリンクから新しいパスワードを設定してください。';
    }, actionLabel: 'パスワード再設定メール送信');
    return didSend && _errorMessage == null;
  }

  Future<void> updatePassword({required String password}) async {
    final validationError = _validatePassword(password);
    if (validationError != null) {
      _errorMessage = validationError;
      _message = null;
      notifyListeners();
      return;
    }

    await _withAuthClient((client) async {
      await client.auth.updateUser(UserAttributes(password: password));
      _isPasswordRecovery = false;
      _message = 'パスワードを更新しました。';
      await _tryEnsureProfile(client);
    }, actionLabel: 'パスワード更新');
  }

  Future<void> signOut() async {
    final client = _client;
    if (client == null || _isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _message = null;
    notifyListeners();

    try {
      await client.auth.signOut();
      _role = UserRole.free;
      _message = 'ログアウトしました。';
    } catch (error) {
      _errorMessage = 'ログアウトに失敗しました: ${_friendlyError(error)}';
      _message = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    await initializeSession();
  }

  Future<void> _withAuthClient(
    Future<void> Function(SupabaseClient client) action, {
    required String actionLabel,
  }) async {
    if (!SupabaseService.isConfigured) {
      _errorMessage = 'Supabaseが未設定のため、$actionLabelを利用できません。';
      _message = null;
      notifyListeners();
      return;
    }

    await SupabaseService.initializeIfConfigured();
    final client = _client;
    if (client == null || _isLoading) {
      return;
    }
    _ensureAuthListener(client);

    _isLoading = true;
    _errorMessage = null;
    _message = null;
    notifyListeners();

    try {
      await action(client);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = '$actionLabelに失敗しました: ${_friendlyError(error)}';
      _message = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _ensureAuthListener(SupabaseClient client) {
    _authStateSubscription ??= client.auth.onAuthStateChange.listen((event) {
      _errorMessage = null;
      if (event.event == AuthChangeEvent.passwordRecovery) {
        _isPasswordRecovery = true;
        _message = '新しいパスワードを入力してください。';
      } else if (event.session != null &&
          event.session!.user.isAnonymous == false) {
        _message = '$providerLabelでログインしました。';
      } else {
        _role = UserRole.free;
        _isPasswordRecovery = false;
      }
      notifyListeners();
      unawaited(_tryEnsureProfile(client));
    });
  }

  Future<void> _tryEnsureProfile(SupabaseClient client) async {
    try {
      await _ensureProfile(client);
      await _loadProfileRole(client);
    } catch (_) {
      // ログイン自体は成功しているため、プロフィール初期同期の失敗は同期時に表示する。
    } finally {
      notifyListeners();
    }
  }

  Future<void> _ensureProfile(SupabaseClient client) async {
    final user = client.auth.currentUser;
    if (user == null || user.isAnonymous) {
      _role = UserRole.free;
      return;
    }

    await client.from('profiles').upsert({
      'id': user.id,
      'email': user.email,
      'display_name': user.email ?? 'メールユーザー',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });

    await client.from('settings').upsert({
      'user_id': user.id,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }

  Future<void> _loadProfileRole(SupabaseClient client) async {
    final user = client.auth.currentUser;
    if (user == null || user.isAnonymous) {
      _role = UserRole.free;
      return;
    }

    final row = await client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();
    _role = UserRole.fromDbValue(row?['role']);
  }

  String? _validateEmailPassword(String email, String password) {
    return _validateEmail(email) ?? _validatePassword(password);
  }

  String? _validateEmail(String email) {
    if (email.isEmpty || !email.contains('@')) {
      return 'メールアドレスを入力してください。';
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.length < 6) {
      return 'パスワードは6文字以上で入力してください。';
    }
    return null;
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.length <= 160) {
      return message;
    }
    return '${message.substring(0, 160)}...';
  }
}
