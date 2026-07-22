// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumHeadline => 'Keep learning with Premium';

  @override
  String get premiumDescription =>
      'Build your speaking log at your own pace without worrying about AI correction or audio storage limits.';

  @override
  String get premiumSubscribePrice => 'Subscribe for ¥480/month';

  @override
  String get premiumPurchaseUnavailable =>
      'Subscriptions will be available after Google Play products are configured.';

  @override
  String get premiumCancellationNote =>
      'After cancellation, Premium features remain available until the day before your next renewal date.';

  @override
  String get premiumItem => 'Feature';

  @override
  String get premiumAiCorrection => 'AI correction';

  @override
  String get premiumAiTranslation => 'AI translation';

  @override
  String get premiumAudioStorage => 'Audio storage';

  @override
  String get premiumCorrectionHistory => 'Correction history';

  @override
  String get premiumWordRanking => 'Word ranking';

  @override
  String get premiumAds => 'Ads';

  @override
  String get premiumFivePerDay => '5/day';

  @override
  String get premiumUnlimited => 'Unlimited';

  @override
  String get premiumLimited => 'Limited';

  @override
  String get premiumAvailable => 'Available';

  @override
  String get premiumRewardAds => 'Reward ads';

  @override
  String get premiumNone => 'None';

  @override
  String get searchVocabulary => 'Search vocabulary';

  @override
  String recordingSyncFailed(Object details) {
    return 'Recording sync failed: $details';
  }

  @override
  String lastSynced(Object time) {
    return 'Last synced: $time';
  }

  @override
  String settingsSyncFailed(Object details) {
    return 'Settings sync failed: $details';
  }

  @override
  String accountRole(Object role) {
    return 'Role: $role';
  }

  @override
  String get signOutDataNotice =>
      'Signing out clears the recording history shown on this device. You can retrieve it from cloud sync after signing in again.';

  @override
  String get passwordResetCheckEmail => 'Reset email sent. Check your inbox.';

  @override
  String get emailRegistrationBenefit =>
      'Registering with email makes it easier to restore this device\'s learning data later.';

  @override
  String get emailRegistrationRequiresCloud =>
      'Email registration is available after Supabase is configured.';

  @override
  String get connectionDiagnostics => 'Connection diagnostics';

  @override
  String get checkingConnection => 'Checking...';

  @override
  String get checkConnection => 'Check connection';

  @override
  String get supabaseConfiguration => 'Supabase configuration';

  @override
  String get supabaseConfigured => 'The URL and anon key are configured.';

  @override
  String get supabaseNotConfigured =>
      'SUPABASE_URL / SUPABASE_ANON_KEY are not configured.';

  @override
  String get supabaseInitialization => 'Supabase initialization';

  @override
  String get supabaseInitialized => 'Initialized.';

  @override
  String get emailSignInDiagnostic => 'Email sign-in';

  @override
  String get signedInSuccessfully => 'Signed in successfully.';

  @override
  String get notSignedIn => 'Not signed in.';

  @override
  String get accountAccess => 'Account access';

  @override
  String get accountAccessAfterSignIn =>
      'profiles.role is retrieved after signing in.';

  @override
  String databaseTable(Object table) {
    return '$table table';
  }

  @override
  String get databaseTableAccessible => 'Accessible.';

  @override
  String get edgeFunctionResponding => 'The Edge Function is responding.';

  @override
  String responseStatus(Object status) {
    return 'Response status: $status';
  }

  @override
  String get noRecognizableSpeech =>
      'No recognizable speech was found. Check the recording and try again.';

  @override
  String get unsupportedCorrectionLanguage =>
      'This practice language is not supported for AI correction.';

  @override
  String get analysisFailed => 'AI analysis failed. Please try again later.';

  @override
  String get correctionAuthRequired => 'Sign in again to use AI correction.';

  @override
  String get networkError =>
      'Could not connect. Check your network and try again.';

  @override
  String get invalidServerResponse =>
      'The server returned an invalid response. Please try again later.';

  @override
  String get cloudNotConfigured => 'Cloud not configured';

  @override
  String get connecting => 'Connecting';

  @override
  String get signedInWithEmail => 'Signed in with email';

  @override
  String get connectionError => 'Connection error';

  @override
  String get roleFree => 'Free user';

  @override
  String get rolePremium => 'Premium user';

  @override
  String get roleTester => 'Beta tester';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get authConfirmationSent =>
      'Confirmation email sent. Complete registration from the link in the email.';

  @override
  String get authSignedIn => 'Signed in with your email account.';

  @override
  String get authPasswordResetSent =>
      'Password reset email sent. Set a new password from the link in the email.';

  @override
  String get authPasswordUpdated => 'Password updated.';

  @override
  String get authSignedOut => 'Signed out.';

  @override
  String get authEnterNewPassword => 'Enter a new password.';

  @override
  String get authInvalidEmail => 'Enter a valid email address.';

  @override
  String get authPasswordTooShort =>
      'Enter a password with at least 6 characters.';

  @override
  String get authNotConfigured =>
      'Email authentication is unavailable because Supabase is not configured.';

  @override
  String authSignOutFailed(Object details) {
    return 'Sign out failed: $details';
  }

  @override
  String authActionFailed(Object details) {
    return 'Authentication failed: $details';
  }

  @override
  String get settingsDownloaded => 'Settings downloaded from the cloud.';

  @override
  String get settingsSaved => 'Settings saved to the cloud.';

  @override
  String settingsDownloadFailed(Object details) {
    return 'Could not download settings: $details';
  }

  @override
  String settingsSaveFailed(Object details) {
    return 'Could not save settings: $details';
  }

  @override
  String get recordingsCloudEmpty => 'There are no recordings in the cloud.';

  @override
  String recordingsDownloaded(Object count) {
    return 'Downloaded $count recordings from the cloud.';
  }

  @override
  String recordingsImported(Object count) {
    return 'Imported $count recordings from the cloud.';
  }

  @override
  String get recordingsSynced => 'Cloud sync completed.';

  @override
  String get draftAuthRequired => 'Sign in again to create a practice text.';

  @override
  String get draftInputTooLong => 'Keep your input within 500 characters.';

  @override
  String get draftApiNotConfigured => 'AI text creation is not configured yet.';

  @override
  String get draftFunctionNotFound =>
      'Practice text creation is temporarily unavailable. Please try again later.';

  @override
  String get draftApiLimit =>
      'AI text creation is temporarily unavailable because the service limit was reached.';

  @override
  String get draftFailed =>
      'Could not create a practice text. Please try again later.';

  @override
  String get chooseNewPracticeLanguage => 'Choose a new practice language';

  @override
  String get practiceLanguageMustChange =>
      'That language is currently your practice language. Choose a different practice language before changing the app language.';

  @override
  String get savedCorrectionLanguageMismatchTitle =>
      'A correction in another language is saved';

  @override
  String get savedCorrectionLanguageMismatchDescription =>
      'The saved correction was created for another app language or an older analysis version, so it won\'t be reused automatically.';

  @override
  String get reanalysisConsumesUsage =>
      'Creating a new correction uses one AI correction from your allowance.';

  @override
  String get reanalyzeInCurrentLanguage => 'Correct in the current language';

  @override
  String get correctionAnalyzing => 'Analyzing your recording...';

  @override
  String wordUsageAdviceFallback(String word) {
    return 'Try using $word with one more detail or reason in your next recording.';
  }

  @override
  String get exampleTranslation => 'Example translation';

  @override
  String get appTitle => 'TalkLog';

  @override
  String get navHome => 'Home';

  @override
  String get navRecord => 'Record';

  @override
  String get navHistory => 'History';

  @override
  String get navVocabulary => 'Vocabulary';

  @override
  String get navProgress => 'Progress';

  @override
  String get navSettings => 'Settings';

  @override
  String get loginRequired =>
      'Please sign in with your email to use this feature.';

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ja': 'Japanese',
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'ko': 'Korean',
      'zhHans': 'Chinese',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String get homeGreeting => 'Let\'s speak a little today!';

  @override
  String currentLearningLanguage(Object language) {
    return 'Practice language: $language';
  }

  @override
  String get todayStepTitle => 'Today\'s step';

  @override
  String get startRecording => 'Start recording';

  @override
  String get todayStartMessage =>
      'Start with just 30 seconds and create today\'s learning log.';

  @override
  String get todayKeepStreakMessage =>
      'Keep your streak going. One short recording is enough.';

  @override
  String get todayOneDoneMessage =>
      'You\'ve completed today\'s recording. If you have time, share one more reason or thought.';

  @override
  String todayManyDoneMessage(Object count) {
    return 'You\'ve already made $count recordings today. Great pace!';
  }

  @override
  String get audioStorageTitle => 'Audio storage';

  @override
  String storagePremiumUsage(Object used) {
    return '$used used / Premium storage';
  }

  @override
  String storageFreeUsage(Object limit, Object used) {
    return '$used / $limit used';
  }

  @override
  String get storagePremiumDescription =>
      'Your Premium access lets you save recordings without worrying about storage.';

  @override
  String storageLowDescription(Object remaining) {
    return 'Only $remaining remains. Premium lets you save recordings without worrying about storage.';
  }

  @override
  String storageRemainingDescription(Object remaining) {
    return '$remaining remains. Your audio log grows with every recording.';
  }

  @override
  String get weeklyPaceTitle => 'This week\'s pace';

  @override
  String get thisWeekLabel => 'This week';

  @override
  String get versusLastWeekLabel => 'vs. last week';

  @override
  String recordingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordings',
      one: '1 recording',
      zero: '0 recordings',
    );
    return '$_temp0';
  }

  @override
  String recordingDelta(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordings',
      zero: '±0 recordings',
    );
    return '$_temp0';
  }

  @override
  String get trendNoRecordings =>
      'Make your first recording and start building a learning rhythm.';

  @override
  String trendImproving(Object count) {
    return 'You made $count more recordings than last week. Keep it up!';
  }

  @override
  String get trendSteady =>
      'You\'re keeping the same pace as last week. Consistency is working.';

  @override
  String get trendNoRecordingsThisWeek =>
      'No recordings yet this week. Start again with just 30 seconds.';

  @override
  String get trendSlower =>
      'You recorded less than last week. Add one short recording today.';

  @override
  String get currentStreakTitle => 'Current streak';

  @override
  String streakDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: '0 days',
    );
    return '$_temp0';
  }

  @override
  String get todayRecordingsTitle => 'Today\'s recordings';

  @override
  String get totalRecordingTimeTitle => 'Total recording time';

  @override
  String durationMinutes(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
      zero: '0 minutes',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(num hours, num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours',
      one: '1 hour',
    );
    String _temp1 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
      zero: '',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String get todayPromptTitle => 'Today\'s small topic';

  @override
  String get todayPromptBody =>
      'Talk in your practice language about one good thing that happened today.';

  @override
  String get recordTitle => 'Record';

  @override
  String get recordStatusBusy => 'Processing';

  @override
  String get recordStatusRecording => 'Recording';

  @override
  String get recordStatusReady => 'Ready to record';

  @override
  String get recordSaved => 'Recording saved.';

  @override
  String get recordCancel => 'Cancel recording';

  @override
  String get recordHintBusy => 'Please wait a moment';

  @override
  String get recordHintRecording =>
      'Speak while viewing your practice text, then stop to save';

  @override
  String get recordHintReady => 'Tap to start recording';

  @override
  String get draftTitle => 'Plan what to say';

  @override
  String get draftResultTitle => 'Practice text';

  @override
  String get clear => 'Clear';

  @override
  String get draftInputLabel => 'What you want to say';

  @override
  String get draftInputHint =>
      'Example: I was tired after work today, but I want to keep practicing.';

  @override
  String get hideKeyboard => 'Hide keyboard';

  @override
  String get draftCreating => 'Creating...';

  @override
  String draftCreate(Object language) {
    return 'Create a $language practice text';
  }

  @override
  String get draftInputRequired => 'Enter what you want to say.';

  @override
  String get syncFailedTitle => 'Cloud sync failed';

  @override
  String get syncingTitle => 'Syncing with the cloud';

  @override
  String get syncingDescription =>
      'Syncing your recording history with the cloud.';

  @override
  String get syncRetry => 'Retry sync';

  @override
  String get recordPermissionError =>
      'Microphone access is required. Allow microphone access in your device settings.';

  @override
  String get recordStorageLimitError =>
      'You\'ve reached the free 200 MB audio storage limit. Premium removes the storage limit.';

  @override
  String recordStartError(Object details) {
    return 'Couldn\'t start recording: $details';
  }

  @override
  String recordSaveError(Object details) {
    return 'Couldn\'t save the recording: $details';
  }

  @override
  String recordCancelError(Object details) {
    return 'Couldn\'t cancel the recording: $details';
  }

  @override
  String get historyTitle => 'History';

  @override
  String historySelected(Object count) {
    return '$count selected';
  }

  @override
  String get clearSelection => 'Clear selection';

  @override
  String get selectAllVisible => 'Select all visible recordings';

  @override
  String get deleteSelected => 'Delete selected recordings';

  @override
  String get resetFilters => 'Reset filters';

  @override
  String get refreshCorrectionStatus => 'Refresh correction status';

  @override
  String get historySearchHint => 'Search by date or language';

  @override
  String get correctedOnly => 'Corrected only';

  @override
  String get all => 'All';

  @override
  String get dateAll => 'Date: all';

  @override
  String get today => 'Today';

  @override
  String get withinSevenDays => 'Last 7 days';

  @override
  String get withinThirtyDays => 'Last 30 days';

  @override
  String get durationAll => 'Length: all';

  @override
  String get underOneMinute => 'Under 1 min';

  @override
  String get oneToThreeMinutes => '1–3 min';

  @override
  String get threeMinutesOrMore => '3 min or more';

  @override
  String get selectHistoryHelp => 'Select the recordings you want to delete.';

  @override
  String get releaseSelection => 'Clear';

  @override
  String get noRecordings => 'No recordings yet.';

  @override
  String get noMatchingHistory => 'No recordings match these filters.';

  @override
  String get pause => 'Pause';

  @override
  String get play => 'Play';

  @override
  String get corrected => 'Corrected';

  @override
  String get notCorrected => 'Not corrected';

  @override
  String get more => 'More';

  @override
  String get details => 'Details';

  @override
  String get select => 'Select';

  @override
  String get delete => 'Delete';

  @override
  String get audioFileMissing => 'Audio file not found.';

  @override
  String get deleteRecordingTitle => 'Delete this recording?';

  @override
  String get deleteRecordingDescription =>
      'This can\'t be undone. The audio file and cloud recording data will also be deleted.';

  @override
  String deleteSelectedTitle(Object count) {
    return 'Delete $count recordings?';
  }

  @override
  String get deleteSelectedDescription =>
      'This can\'t be undone. The selected audio files and cloud recording data will also be deleted.';

  @override
  String get cancel => 'Cancel';

  @override
  String get recordingDeleted => 'Recording deleted.';

  @override
  String recordingsDeleted(Object count) {
    return '$count recordings deleted.';
  }

  @override
  String get backToHistory => 'Back to history';

  @override
  String get recordingDetailsTitle => 'Recording details';

  @override
  String get refreshStatus => 'Refresh status';

  @override
  String get recordingDuration => 'Recording duration';

  @override
  String get learningLanguage => 'Practice language';

  @override
  String get audioFile => 'Audio file';

  @override
  String get viewAiCorrection => 'View AI correction';

  @override
  String get deleteRecording => 'Delete recording';

  @override
  String get checkingStatus => 'Checking status';

  @override
  String get cloudSynced => 'Synced to cloud';

  @override
  String get notSynced => 'Not synced';

  @override
  String get correctionSaved => 'Correction saved';

  @override
  String get aiAnalysisAvailable => 'AI analysis available';

  @override
  String get aiAnalysisAfterSync => 'AI analysis available after syncing';

  @override
  String get aiCorrectionTitle => 'AI correction';

  @override
  String get backToRecordingDetails => 'Back to recording details';

  @override
  String get reanalyze => 'Analyze again';

  @override
  String get savedResultSource => 'Saved result';

  @override
  String get edgeFunctionSource => 'Cloud AI';

  @override
  String get demoCorrectionSource => 'Demo correction';

  @override
  String get savedResultNotice => 'Showing a saved correction result.';

  @override
  String correctionSaveFailed(Object details) {
    return 'Couldn\'t save to the cloud. You can still review this result on this screen. Details: $details';
  }

  @override
  String get vocabularyAdded =>
      'Vocabulary notes added to your vocabulary list.';

  @override
  String vocabularyAddFailed(Object details) {
    return 'Couldn\'t add the notes to your vocabulary list: $details';
  }

  @override
  String get addVocabularyNotes => 'Add vocabulary notes';

  @override
  String get transcript => 'Transcript';

  @override
  String get correctedText => 'Corrected text';

  @override
  String get naturalExpression => 'Natural expression';

  @override
  String get translation => 'Translation';

  @override
  String get grammarNotes => 'Grammar notes';

  @override
  String get vocabularyNotes => 'Vocabulary notes';

  @override
  String get encouragement => 'Encouragement';

  @override
  String get dailyAiLimitReached =>
      'You\'ve reached today\'s AI correction limit.';

  @override
  String get correctionLoadFailed => 'Couldn\'t load the AI correction';

  @override
  String get close => 'Close';

  @override
  String analysisMethod(Object source) {
    return 'Analysis method: $source';
  }

  @override
  String get runFullAnalysisAgain => 'Run full analysis again';

  @override
  String get aiScore => 'AI score';

  @override
  String get aiScoreDescription =>
      'Evaluates clarity, naturalness, and grammar balance.';

  @override
  String get progressTitle => 'Progress';

  @override
  String get syncingLearningData => 'Syncing learning data...';

  @override
  String learningDataSyncFailed(Object details) {
    return 'Couldn\'t sync learning data: $details';
  }

  @override
  String learningDataSynced(Object time) {
    return 'Learning data synced at $time';
  }

  @override
  String get learningDataAutomatic =>
      'Learning data is calculated automatically from your recordings.';

  @override
  String get totalRecordings => 'Total recordings';

  @override
  String get totalRecordingTime => 'Total recording time';

  @override
  String get averageScore => 'Average score';

  @override
  String currentAndBestStreak(Object best, Object current) {
    return 'Current: $current / Best: $best';
  }

  @override
  String get streakTitle => 'Learning streak';

  @override
  String get monthlySummary => 'Monthly summary';

  @override
  String get monthlyRecordings => 'This month\'s recordings';

  @override
  String get monthlyTime => 'This month\'s time';

  @override
  String get practiceDays => 'Practice days';

  @override
  String get averageRecordingTime => 'Average recording time';

  @override
  String get learningTrend => 'Learning trend';

  @override
  String get thisWeekRecordings => 'This week\'s recordings';

  @override
  String get differenceFromLastWeek => 'Difference from last week';

  @override
  String get thisWeekTime => 'This week\'s time';

  @override
  String get mostActiveDay => 'Most active day';

  @override
  String get frequentCorrectionPoints => 'Frequent correction points';

  @override
  String correctionPointsLoadFailed(Object details) {
    return 'Couldn\'t load correction points: $details';
  }

  @override
  String get correctionPointsEmpty =>
      'Your frequent grammar and vocabulary feedback will appear as you complete more AI corrections.';

  @override
  String get lastSevenDays => 'Last 7 days';

  @override
  String get topWords => 'Top 10 most-used words';

  @override
  String wordRankingLoadFailed(Object details) {
    return 'Couldn\'t load the word ranking: $details';
  }

  @override
  String get wordRankingEmpty =>
      'Your most-used words and alternatives will appear as you transcribe more recordings.';

  @override
  String get progressEmpty =>
      'Record something to see your learning data here.';

  @override
  String get feedbackDetailTitle => 'Correction point details';

  @override
  String get strategyNotes => 'Strategy notes';

  @override
  String get tryNextRecording => 'Try in your next recording';

  @override
  String get howToUse => 'How to use this';

  @override
  String get feedbackUsageDescription =>
      'Make a short recording with this point in mind, then check another AI correction to see your improvement.';

  @override
  String get grammarAdvice =>
      'This grammar point appears often. Focus on just this one point in your next recording.';

  @override
  String get vocabularyAdvice =>
      'This vocabulary point can broaden your expression. Try an alternative in a similar situation.';

  @override
  String get grammarPracticePrompt =>
      'Make three short sentences using this grammar point, then connect them in one recording.';

  @override
  String get vocabularyPracticePrompt =>
      'Describe the same event twice using this word and one alternative.';

  @override
  String get vocabularyTitle => 'Vocabulary';

  @override
  String get reload => 'Reload';

  @override
  String get vocabularyEmpty =>
      'Your vocabulary list is empty. Add words from AI correction notes.';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get vocabularySearchHint => 'Search by first letters';

  @override
  String wordsVisible(Object total, Object visible) {
    return 'Showing $visible of $total words';
  }

  @override
  String get reviewPending => 'To review';

  @override
  String get reviewed => 'Reviewed';

  @override
  String get sortAlphabetical => 'Alphabetical';

  @override
  String get sortRecentlyAdded => 'Recently added';

  @override
  String get sortReviewCount => 'Review count';

  @override
  String get wordUpdated => 'Word updated.';

  @override
  String get deleteWordTitle => 'Delete this word?';

  @override
  String deleteWordDescription(Object word) {
    return 'Remove “$word” from your vocabulary list? This can\'t be undone.';
  }

  @override
  String get wordDeleted => 'Word deleted.';

  @override
  String get edit => 'Edit';

  @override
  String get wordLabel => 'Word';

  @override
  String get tapForExplanation => 'Tap to show the explanation';

  @override
  String get explanation => 'Explanation';

  @override
  String get exampleSentence => 'Example sentence';

  @override
  String get tapToReturnToWord => 'Tap to return to the word';

  @override
  String pendingWordCount(Object count) {
    return '$count words to review';
  }

  @override
  String registeredWordCount(Object count) {
    return '$count words saved';
  }

  @override
  String get review => 'Review';

  @override
  String get back => 'Back';

  @override
  String get noWordsToReview => 'No words are waiting for review.';

  @override
  String reviewProgress(Object current, Object total) {
    return '$current of $total';
  }

  @override
  String get meaning => 'Meaning';

  @override
  String get showMeaning => 'Show meaning';

  @override
  String get next => 'Next';

  @override
  String get remembered => 'Remembered';

  @override
  String reviewCountOnly(Object count) {
    return 'Reviewed $count times';
  }

  @override
  String reviewCountWithDate(Object count, Object date) {
    return 'Reviewed $count times / Last: $date';
  }

  @override
  String get editWordTitle => 'Edit word';

  @override
  String get meaningExplanation => 'Meaning / explanation';

  @override
  String get save => 'Save';

  @override
  String get wordAndMeaningRequired => 'Enter both the word and its meaning.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageSettings => 'Languages';

  @override
  String get appLanguage => 'App language';

  @override
  String get practiceLanguage => 'Practice language';

  @override
  String currentValue(Object value) {
    return 'Current: $value';
  }

  @override
  String get selectAppLanguage => 'Select app language';

  @override
  String get selectPracticeLanguage => 'Select practice language';

  @override
  String get sameLanguageUnavailable =>
      'This is your app language, so it can\'t be selected as a practice language.';

  @override
  String get practiceLanguageConflict =>
      'This language is currently selected as your practice language. Choose another practice language first.';

  @override
  String get cloudSync => 'Cloud sync';

  @override
  String get reconnect => 'Reconnect';

  @override
  String get syncing => 'Syncing...';

  @override
  String get syncRecordingHistory => 'Sync recording history';

  @override
  String get downloadSettings => 'Download settings';

  @override
  String get saveSettings => 'Save settings';

  @override
  String get account => 'Account';

  @override
  String get registerPremium => 'Get Premium';

  @override
  String get emailAddress => 'Email address';

  @override
  String get password => 'Password';

  @override
  String get registerWithEmail => 'Register with email';

  @override
  String get registerCurrentData => 'Register this data with email';

  @override
  String get signInWithEmail => 'Sign in with email';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get signOut => 'Sign out';

  @override
  String get newPasswordPrompt => 'Set a new password.';

  @override
  String get newPassword => 'New password';

  @override
  String get updatePassword => 'Update password';

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get passwordResetSent => 'Password reset email sent.';
}
