// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumHeadline => 'Premiumで学習を続ける';

  @override
  String get premiumDescription => 'AI添削と音声保存の制限を気にせず、自分のペースで発話の成長ログを積み上げられます。';

  @override
  String get premiumSubscribePrice => '月480円で登録';

  @override
  String get premiumPurchaseUnavailable => 'サブスク登録はGoogle Playの商品設定後に有効化します。';

  @override
  String get premiumCancellationNote => '解約後も、現在の更新日前日まではPremium機能を利用できます。';

  @override
  String get premiumItem => '項目';

  @override
  String get premiumAiCorrection => 'AI添削';

  @override
  String get premiumAiTranslation => 'AI翻訳';

  @override
  String get premiumAudioStorage => '音声保存';

  @override
  String get premiumCorrectionHistory => '添削履歴';

  @override
  String get premiumWordRanking => '単語ランキング';

  @override
  String get premiumAds => '広告';

  @override
  String get premiumFivePerDay => '1日5回';

  @override
  String get premiumUnlimited => '無制限';

  @override
  String get premiumLimited => '制限あり';

  @override
  String get premiumAvailable => '利用可';

  @override
  String get premiumRewardAds => 'リワード広告あり';

  @override
  String get premiumNone => 'なし';

  @override
  String get searchVocabulary => '単語帳を検索';

  @override
  String recordingSyncFailed(Object details) {
    return '録音同期に失敗しました: $details';
  }

  @override
  String lastSynced(Object time) {
    return '最終同期: $time';
  }

  @override
  String settingsSyncFailed(Object details) {
    return '設定同期に失敗しました: $details';
  }

  @override
  String accountRole(Object role) {
    return '権限: $role';
  }

  @override
  String get signOutDataNotice =>
      'ログアウトすると、この端末に表示していた録音履歴はクリアされます。再ログイン後はクラウド同期で取得できます。';

  @override
  String get passwordResetCheckEmail => '再設定メールを送信しました。メールを確認してください。';

  @override
  String get emailRegistrationBenefit => 'メール登録すると、この端末の学習データを後から復元しやすくなります。';

  @override
  String get emailRegistrationRequiresCloud => 'Supabase設定後にメール登録を利用できます。';

  @override
  String get connectionDiagnostics => '接続診断';

  @override
  String get checkingConnection => '確認中...';

  @override
  String get checkConnection => '接続状態を確認';

  @override
  String get supabaseConfiguration => 'Supabase設定';

  @override
  String get supabaseConfigured => 'URLとanon keyが設定されています。';

  @override
  String get supabaseNotConfigured =>
      'SUPABASE_URL / SUPABASE_ANON_KEY が未設定です。';

  @override
  String get supabaseInitialization => 'Supabase初期化';

  @override
  String get supabaseInitialized => '初期化済みです。';

  @override
  String get emailSignInDiagnostic => 'メールログイン';

  @override
  String get signedInSuccessfully => 'ログインできています。';

  @override
  String get notSignedIn => '未ログインです。';

  @override
  String get accountAccess => 'アカウント権限';

  @override
  String get accountAccessAfterSignIn => 'ログイン後にprofiles.roleを取得します。';

  @override
  String databaseTable(Object table) {
    return '$table テーブル';
  }

  @override
  String get databaseTableAccessible => '参照できます。';

  @override
  String get edgeFunctionResponding => 'Edge Functionは応答しています。';

  @override
  String responseStatus(Object status) {
    return '応答ステータス: $status';
  }

  @override
  String get noRecognizableSpeech => '音声を認識できませんでした。録音内容を確認して、もう一度録音してください。';

  @override
  String get unsupportedCorrectionLanguage => 'この学習言語はAI添削に対応していません。';

  @override
  String get analysisFailed => 'AI解析に失敗しました。時間をおいてもう一度お試しください。';

  @override
  String get correctionAuthRequired => 'AI添削を利用するには、もう一度ログインしてください。';

  @override
  String get networkError => '通信できませんでした。ネットワーク接続を確認して、もう一度お試しください。';

  @override
  String get invalidServerResponse =>
      'サーバーから正しい応答を取得できませんでした。時間をおいてもう一度お試しください。';

  @override
  String get cloudNotConfigured => 'クラウド未設定';

  @override
  String get connecting => '接続中';

  @override
  String get signedInWithEmail => 'メールでログイン中';

  @override
  String get connectionError => '接続エラー';

  @override
  String get roleFree => '無料ユーザー';

  @override
  String get rolePremium => '有料ユーザー';

  @override
  String get roleTester => 'βテスター';

  @override
  String get roleAdmin => '管理者';

  @override
  String get authConfirmationSent => '確認メールを送信しました。メール内のリンクから登録を完了してください。';

  @override
  String get authSignedIn => 'メールアカウントでログインしました。';

  @override
  String get authPasswordResetSent =>
      'パスワード再設定メールを送信しました。メール内のリンクから新しいパスワードを設定してください。';

  @override
  String get authPasswordUpdated => 'パスワードを更新しました。';

  @override
  String get authSignedOut => 'ログアウトしました。';

  @override
  String get authEnterNewPassword => '新しいパスワードを入力してください。';

  @override
  String get authInvalidEmail => '正しいメールアドレスを入力してください。';

  @override
  String get authPasswordTooShort => 'パスワードは6文字以上で入力してください。';

  @override
  String get authNotConfigured => 'Supabaseが未設定のため、メール認証を利用できません。';

  @override
  String authSignOutFailed(Object details) {
    return 'ログアウトに失敗しました: $details';
  }

  @override
  String authActionFailed(Object details) {
    return '認証処理に失敗しました: $details';
  }

  @override
  String get settingsDownloaded => '設定をクラウドから読み込みました。';

  @override
  String get settingsSaved => '設定をクラウドに保存しました。';

  @override
  String settingsDownloadFailed(Object details) {
    return '設定を読み込めませんでした: $details';
  }

  @override
  String settingsSaveFailed(Object details) {
    return '設定を保存できませんでした: $details';
  }

  @override
  String get recordingsCloudEmpty => 'クラウドに録音履歴はありません。';

  @override
  String recordingsDownloaded(Object count) {
    return 'クラウドから$count件読み込みました。';
  }

  @override
  String recordingsImported(Object count) {
    return 'クラウドから$count件取り込みました。';
  }

  @override
  String get recordingsSynced => 'クラウド同期が完了しました。';

  @override
  String get draftAuthRequired => '練習文を作成するには、もう一度ログインしてください。';

  @override
  String get draftInputTooLong => '入力は500文字以内にしてください。';

  @override
  String get draftApiNotConfigured => 'AIによる練習文作成の設定が完了していません。';

  @override
  String get draftFunctionNotFound => '練習文作成機能を一時的に利用できません。時間をおいてもう一度お試しください。';

  @override
  String get draftApiLimit => 'サービスの利用上限により、AI練習文作成を一時的に利用できません。';

  @override
  String get draftFailed => '練習文を作成できませんでした。時間をおいてもう一度お試しください。';

  @override
  String get chooseNewPracticeLanguage => '新しい学習言語を選択';

  @override
  String get practiceLanguageMustChange =>
      '現在の学習言語を使用言語に変更するため、先に別の学習言語を選択してください。';

  @override
  String get savedCorrectionLanguageMismatchTitle => '別の言語の添削が保存されています';

  @override
  String get savedCorrectionLanguageMismatchDescription =>
      '保存済みの添削は別の使用言語または古い解析バージョンで作成されているため、自動では再利用しません。';

  @override
  String get reanalysisConsumesUsage => '新しい添削を作成すると、AI添削の利用回数を1回消費します。';

  @override
  String get reanalyzeInCurrentLanguage => '現在の言語で再添削';

  @override
  String get exampleTranslation => '例文の翻訳';

  @override
  String get appTitle => 'TalkLog';

  @override
  String get navHome => 'ホーム';

  @override
  String get navRecord => '録音';

  @override
  String get navHistory => '履歴';

  @override
  String get navVocabulary => '単語帳';

  @override
  String get navProgress => '進捗';

  @override
  String get navSettings => '設定';

  @override
  String get loginRequired => '利用するにはメールでログインしてください。';

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ja': '日本語',
      'en': '英語',
      'es': 'スペイン語',
      'fr': 'フランス語',
      'de': 'ドイツ語',
      'it': 'イタリア語',
      'ko': '韓国語',
      'zhHans': '中国語',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String get homeGreeting => '今日も少し話してみましょう！';

  @override
  String currentLearningLanguage(Object language) {
    return '現在の学習言語: $language';
  }

  @override
  String get todayStepTitle => '今日の一歩';

  @override
  String get startRecording => '録音を始める';

  @override
  String get todayStartMessage => 'まずは30秒だけ録音して、今日の学習記録を作りましょう。';

  @override
  String get todayKeepStreakMessage => '連続記録を続けるチャンスです。短い録音を1本だけ足しましょう。';

  @override
  String get todayOneDoneMessage =>
      '今日の録音は完了しています。余裕があれば、理由や感想を足してもう1本話してみましょう。';

  @override
  String todayManyDoneMessage(Object count) {
    return '今日はすでに$count本録音できています。よいペースです！';
  }

  @override
  String get audioStorageTitle => '音声ストレージ';

  @override
  String storagePremiumUsage(Object used) {
    return '$used 使用中 / Premium容量';
  }

  @override
  String storageFreeUsage(Object limit, Object used) {
    return '$used / $limit 使用中';
  }

  @override
  String get storagePremiumDescription => 'Premium権限のため、容量を気にせず保存できます。';

  @override
  String storageLowDescription(Object remaining) {
    return '残り$remainingです。Premiumなら容量を気にせず保存できます。';
  }

  @override
  String storageRemainingDescription(Object remaining) {
    return '残り$remainingです。録音を続けるほど音声ログが積み上がります。';
  }

  @override
  String get weeklyPaceTitle => '今週のペース';

  @override
  String get thisWeekLabel => '今週';

  @override
  String get versusLastWeekLabel => '先週比';

  @override
  String recordingCount(num count) {
    return '$count回';
  }

  @override
  String recordingDelta(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count回',
      zero: '±0回',
    );
    return '$_temp0';
  }

  @override
  String get trendNoRecordings => 'まずは1回録音して、学習リズムを作りましょう。';

  @override
  String trendImproving(Object count) {
    return '先週より$count回多く録音できています。この調子です！';
  }

  @override
  String get trendSteady => '先週と同じペースで続けられています。少なくても継続できています。';

  @override
  String get trendNoRecordingsThisWeek => '今週はまだ録音がありません。30秒だけ話すところから戻しましょう。';

  @override
  String get trendSlower => '先週より録音回数が少なめです。今日は短い録音を1本だけ足してみましょう。';

  @override
  String get currentStreakTitle => '現在のストリーク';

  @override
  String streakDays(num count) {
    return '$count日';
  }

  @override
  String get todayRecordingsTitle => '今日の録音';

  @override
  String get totalRecordingTimeTitle => '累計録音時間';

  @override
  String durationMinutes(num minutes) {
    return '$minutes分';
  }

  @override
  String durationHoursMinutes(num hours, num minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String get todayPromptTitle => '今日の小さなお題';

  @override
  String get todayPromptBody => '今日よかったことを1つ、学習中の言語で話してみましょう。';

  @override
  String get recordTitle => '録音';

  @override
  String get recordStatusBusy => '処理中です';

  @override
  String get recordStatusRecording => '録音中';

  @override
  String get recordStatusReady => '録音できます';

  @override
  String get recordSaved => '録音を保存しました。';

  @override
  String get recordCancel => '録音をキャンセル';

  @override
  String get recordHintBusy => '少しお待ちください';

  @override
  String get recordHintRecording => '練習文を見ながら話して、停止で保存します';

  @override
  String get recordHintReady => 'タップして録音開始';

  @override
  String get draftTitle => '何を言うか考える';

  @override
  String get draftResultTitle => '見ながら話す文';

  @override
  String get clear => 'クリア';

  @override
  String get draftInputLabel => '言いたいこと';

  @override
  String get draftInputHint => '例: 今日は仕事で疲れたけど、学習を続けたい';

  @override
  String get hideKeyboard => 'キーボードを閉じる';

  @override
  String get draftCreating => '作成中...';

  @override
  String draftCreate(Object language) {
    return '$languageの練習文を作る';
  }

  @override
  String get draftInputRequired => '言いたいことを入力してください。';

  @override
  String get syncFailedTitle => 'クラウド同期に失敗しました';

  @override
  String get syncingTitle => 'クラウド同期中です';

  @override
  String get syncingDescription => '録音履歴をクラウドと同期しています。';

  @override
  String get syncRetry => '再同期';

  @override
  String get recordPermissionError => '録音にはマイクの許可が必要です。端末のアプリ設定からマイクを許可してください。';

  @override
  String get recordStorageLimitError =>
      '無料プランの音声保存容量200MBに達しています。Premiumなら容量を気にせず保存できます。';

  @override
  String recordStartError(Object details) {
    return '録音を開始できませんでした: $details';
  }

  @override
  String recordSaveError(Object details) {
    return '録音を保存できませんでした: $details';
  }

  @override
  String recordCancelError(Object details) {
    return '録音をキャンセルできませんでした: $details';
  }

  @override
  String get historyTitle => '履歴';

  @override
  String historySelected(Object count) {
    return '$count件選択中';
  }

  @override
  String get clearSelection => '選択を解除';

  @override
  String get selectAllVisible => '表示中の履歴をすべて選択';

  @override
  String get deleteSelected => '選択した履歴を削除';

  @override
  String get resetFilters => '絞り込みをリセット';

  @override
  String get refreshCorrectionStatus => '添削状態を再取得';

  @override
  String get historySearchHint => '日付・言語で検索';

  @override
  String get correctedOnly => '添削済みのみ';

  @override
  String get all => 'すべて';

  @override
  String get dateAll => '期間: すべて';

  @override
  String get today => '今日';

  @override
  String get withinSevenDays => '7日以内';

  @override
  String get withinThirtyDays => '30日以内';

  @override
  String get durationAll => '長さ: すべて';

  @override
  String get underOneMinute => '1分未満';

  @override
  String get oneToThreeMinutes => '1〜3分';

  @override
  String get threeMinutesOrMore => '3分以上';

  @override
  String get selectHistoryHelp => '削除したい履歴を選択してください。';

  @override
  String get releaseSelection => '解除';

  @override
  String get noRecordings => '録音はまだありません。';

  @override
  String get noMatchingHistory => '条件に合う履歴はありません。';

  @override
  String get pause => '一時停止';

  @override
  String get play => '再生';

  @override
  String get corrected => '添削済み';

  @override
  String get notCorrected => '未添削';

  @override
  String get more => 'その他';

  @override
  String get details => '詳細';

  @override
  String get select => '選択';

  @override
  String get delete => '削除';

  @override
  String get audioFileMissing => '音声ファイルが見つかりません。';

  @override
  String get deleteRecordingTitle => '録音を削除しますか？';

  @override
  String get deleteRecordingDescription =>
      'この操作は取り消せません。音声ファイルとクラウド上の録音データも削除されます。';

  @override
  String deleteSelectedTitle(Object count) {
    return '$count件の録音を削除しますか？';
  }

  @override
  String get deleteSelectedDescription =>
      'この操作は取り消せません。選択した音声ファイルとクラウド上の録音データも削除されます。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get recordingDeleted => '録音を削除しました。';

  @override
  String recordingsDeleted(Object count) {
    return '$count件の録音を削除しました。';
  }

  @override
  String get backToHistory => '履歴へ戻る';

  @override
  String get recordingDetailsTitle => '録音の詳細';

  @override
  String get refreshStatus => '状態を更新';

  @override
  String get recordingDuration => '録音時間';

  @override
  String get learningLanguage => '学習言語';

  @override
  String get audioFile => '音声ファイル';

  @override
  String get viewAiCorrection => 'AI添削を見る';

  @override
  String get deleteRecording => '録音を削除';

  @override
  String get checkingStatus => '状態確認中';

  @override
  String get cloudSynced => 'クラウド同期済み';

  @override
  String get notSynced => '未同期';

  @override
  String get correctionSaved => '添削保存済み';

  @override
  String get aiAnalysisAvailable => 'AI解析可能';

  @override
  String get aiAnalysisAfterSync => '同期後にAI解析可能';

  @override
  String get aiCorrectionTitle => 'AI添削';

  @override
  String get backToRecordingDetails => '録音詳細へ戻る';

  @override
  String get reanalyze => '再解析';

  @override
  String get savedResultSource => '保存済み';

  @override
  String get edgeFunctionSource => 'クラウドAI';

  @override
  String get demoCorrectionSource => 'デモ添削';

  @override
  String get savedResultNotice => '保存済みの添削結果を表示しています。';

  @override
  String correctionSaveFailed(Object details) {
    return 'クラウド保存に失敗しました。表示中の添削結果はこの画面で確認できます。原因: $details';
  }

  @override
  String get vocabularyAdded => '語彙メモを単語帳に追加しました。';

  @override
  String vocabularyAddFailed(Object details) {
    return '単語帳への追加に失敗しました: $details';
  }

  @override
  String get addVocabularyNotes => '語彙メモを単語帳に追加';

  @override
  String get transcript => '文字起こし';

  @override
  String get correctedText => '添削後の文';

  @override
  String get naturalExpression => '自然な表現';

  @override
  String get translation => '翻訳';

  @override
  String get grammarNotes => '文法メモ';

  @override
  String get vocabularyNotes => '語彙メモ';

  @override
  String get encouragement => '励ましコメント';

  @override
  String get dailyAiLimitReached => '本日の回数上限に達しました。';

  @override
  String get correctionLoadFailed => 'AI添削を読み込めませんでした';

  @override
  String get close => '閉じる';

  @override
  String analysisMethod(Object source) {
    return '解析方法: $source';
  }

  @override
  String get runFullAnalysisAgain => 'もう一度本番解析';

  @override
  String get aiScore => 'AIスコア';

  @override
  String get aiScoreDescription => '発話の伝わりやすさ、自然さ、文法のバランスを評価します。';

  @override
  String get progressTitle => '進捗';

  @override
  String get syncingLearningData => '学習データを同期中...';

  @override
  String learningDataSyncFailed(Object details) {
    return '学習データの同期に失敗しました: $details';
  }

  @override
  String learningDataSynced(Object time) {
    return '学習データ同期済み $time';
  }

  @override
  String get learningDataAutomatic => '学習データは録音履歴から自動集計されます。';

  @override
  String get totalRecordings => '総録音回数';

  @override
  String get totalRecordingTime => '総録音時間';

  @override
  String get averageScore => '平均スコア';

  @override
  String currentAndBestStreak(Object best, Object current) {
    return '現在 $current / 最高 $best';
  }

  @override
  String get streakTitle => '連続学習日数';

  @override
  String get monthlySummary => '今月のサマリー';

  @override
  String get monthlyRecordings => '今月の録音';

  @override
  String get monthlyTime => '今月の時間';

  @override
  String get practiceDays => '練習した日';

  @override
  String get averageRecordingTime => '平均録音時間';

  @override
  String get learningTrend => '学習傾向';

  @override
  String get thisWeekRecordings => '今週の録音';

  @override
  String get differenceFromLastWeek => '先週との差';

  @override
  String get thisWeekTime => '今週の時間';

  @override
  String get mostActiveDay => 'よく話す曜日';

  @override
  String get frequentCorrectionPoints => 'よく出る添削ポイント';

  @override
  String correctionPointsLoadFailed(Object details) {
    return '添削ポイントを読み込めませんでした: $details';
  }

  @override
  String get correctionPointsEmpty => 'AI添削済みの録音が増えると、よく出る文法・語彙の指摘が表示されます。';

  @override
  String get lastSevenDays => '過去7日間';

  @override
  String get topWords => 'よく使う単語トップ10';

  @override
  String wordRankingLoadFailed(Object details) {
    return '単語ランキングを読み込めませんでした: $details';
  }

  @override
  String get wordRankingEmpty => '文字起こし済みの録音が増えると、よく使う単語と言い換え候補が表示されます。';

  @override
  String get progressEmpty => '録音すると学習データがここに表示されます。';

  @override
  String get feedbackDetailTitle => '添削ポイント詳細';

  @override
  String get strategyNotes => '対策メモ';

  @override
  String get tryNextRecording => '次の録音で試すこと';

  @override
  String get howToUse => '使い方';

  @override
  String get feedbackUsageDescription =>
      'このポイントを意識して短く録音し、AI添削でもう一度確認すると改善の変化が見えやすくなります。';

  @override
  String get grammarAdvice => '同じ指摘が出やすい文法です。次の録音では、このポイントを1つだけ意識して話してみましょう。';

  @override
  String get vocabularyAdvice => '表現の幅を広げやすい語彙ポイントです。似た場面で別の言い方も試してみましょう。';

  @override
  String get grammarPracticePrompt => 'この文法を使う短い文を3つ作り、1回の録音でつなげて話してみましょう。';

  @override
  String get vocabularyPracticePrompt => '同じ出来事を、この単語と別の候補を使って2通りで説明してみましょう。';

  @override
  String get vocabularyTitle => '単語帳';

  @override
  String get reload => '再読み込み';

  @override
  String get vocabularyEmpty => '単語帳はまだ空です。添削結果の語彙メモから追加できます。';

  @override
  String get clearSearch => '検索をクリア';

  @override
  String get vocabularySearchHint => '先頭の文字で検索';

  @override
  String wordsVisible(Object total, Object visible) {
    return '$total語中$visible語を表示';
  }

  @override
  String get reviewPending => '復習待ち';

  @override
  String get reviewed => '復習済み';

  @override
  String get sortAlphabetical => 'アルファベット順';

  @override
  String get sortRecentlyAdded => '最近追加';

  @override
  String get sortReviewCount => '復習回数';

  @override
  String get wordUpdated => '単語を更新しました。';

  @override
  String get deleteWordTitle => '単語を削除しますか？';

  @override
  String deleteWordDescription(Object word) {
    return '「$word」を単語帳から削除します。この操作は取り消せません。';
  }

  @override
  String get wordDeleted => '単語を削除しました。';

  @override
  String get edit => '編集';

  @override
  String get wordLabel => '単語';

  @override
  String get tapForExplanation => 'タップで解説を表示';

  @override
  String get explanation => '解説';

  @override
  String get exampleSentence => '例文';

  @override
  String get tapToReturnToWord => 'タップで単語に戻る';

  @override
  String pendingWordCount(Object count) {
    return '復習待ち $count語';
  }

  @override
  String registeredWordCount(Object count) {
    return '登録済み $count語';
  }

  @override
  String get review => '復習';

  @override
  String get back => '戻る';

  @override
  String get noWordsToReview => '復習待ちの単語はありません。';

  @override
  String reviewProgress(Object current, Object total) {
    return '$current / $total';
  }

  @override
  String get meaning => '意味';

  @override
  String get showMeaning => '意味を見る';

  @override
  String get next => '次へ';

  @override
  String get remembered => '覚えた';

  @override
  String reviewCountOnly(Object count) {
    return '復習 $count回';
  }

  @override
  String reviewCountWithDate(Object count, Object date) {
    return '復習 $count回 / 最終 $date';
  }

  @override
  String get editWordTitle => '単語を編集';

  @override
  String get meaningExplanation => '意味・解説';

  @override
  String get save => '保存';

  @override
  String get wordAndMeaningRequired => '単語と意味を入力してください。';

  @override
  String get settingsTitle => '設定';

  @override
  String get languageSettings => '言語';

  @override
  String get appLanguage => '使用言語';

  @override
  String get practiceLanguage => '学習言語';

  @override
  String currentValue(Object value) {
    return '現在: $value';
  }

  @override
  String get selectAppLanguage => '使用言語を選択';

  @override
  String get selectPracticeLanguage => '学習言語を選択';

  @override
  String get sameLanguageUnavailable => '使用言語と同じため、学習言語には選択できません。';

  @override
  String get practiceLanguageConflict => '現在の学習言語と同じです。先に別の学習言語を選択してください。';

  @override
  String get cloudSync => 'クラウド同期';

  @override
  String get reconnect => '再接続';

  @override
  String get syncing => '同期中...';

  @override
  String get syncRecordingHistory => '録音履歴をクラウドと同期';

  @override
  String get downloadSettings => '設定を取得';

  @override
  String get saveSettings => '設定を保存';

  @override
  String get account => 'アカウント';

  @override
  String get registerPremium => 'Premiumに登録';

  @override
  String get emailAddress => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get registerWithEmail => 'メールで登録';

  @override
  String get registerCurrentData => 'このデータをメール登録';

  @override
  String get signInWithEmail => 'メールでログイン';

  @override
  String get forgotPassword => 'パスワードを忘れた場合';

  @override
  String get signOut => 'ログアウト';

  @override
  String get newPasswordPrompt => '新しいパスワードを設定してください。';

  @override
  String get newPassword => '新しいパスワード';

  @override
  String get updatePassword => 'パスワードを更新';

  @override
  String get show => '表示';

  @override
  String get hide => '非表示';

  @override
  String get passwordResetSent => 'パスワード再設定メールを送信しました。';
}
