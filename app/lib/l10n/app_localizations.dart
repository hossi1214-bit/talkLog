import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ja'),
  ];

  /// No description provided for @premiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumTitle;

  /// No description provided for @premiumHeadline.
  ///
  /// In en, this message translates to:
  /// **'Keep learning with Premium'**
  String get premiumHeadline;

  /// No description provided for @premiumDescription.
  ///
  /// In en, this message translates to:
  /// **'Build your speaking log at your own pace without worrying about AI correction or audio storage limits.'**
  String get premiumDescription;

  /// No description provided for @premiumSubscribePrice.
  ///
  /// In en, this message translates to:
  /// **'Subscribe for ¥480/month'**
  String get premiumSubscribePrice;

  /// No description provided for @premiumPurchaseUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions will be available after Google Play products are configured.'**
  String get premiumPurchaseUnavailable;

  /// No description provided for @premiumCancellationNote.
  ///
  /// In en, this message translates to:
  /// **'After cancellation, Premium features remain available until the day before your next renewal date.'**
  String get premiumCancellationNote;

  /// No description provided for @premiumItem.
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get premiumItem;

  /// No description provided for @premiumAiCorrection.
  ///
  /// In en, this message translates to:
  /// **'AI correction'**
  String get premiumAiCorrection;

  /// No description provided for @premiumAiTranslation.
  ///
  /// In en, this message translates to:
  /// **'AI translation'**
  String get premiumAiTranslation;

  /// No description provided for @premiumAudioStorage.
  ///
  /// In en, this message translates to:
  /// **'Audio storage'**
  String get premiumAudioStorage;

  /// No description provided for @premiumCorrectionHistory.
  ///
  /// In en, this message translates to:
  /// **'Correction history'**
  String get premiumCorrectionHistory;

  /// No description provided for @premiumWordRanking.
  ///
  /// In en, this message translates to:
  /// **'Word ranking'**
  String get premiumWordRanking;

  /// No description provided for @premiumAds.
  ///
  /// In en, this message translates to:
  /// **'Ads'**
  String get premiumAds;

  /// No description provided for @premiumFivePerDay.
  ///
  /// In en, this message translates to:
  /// **'5/day'**
  String get premiumFivePerDay;

  /// No description provided for @premiumUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get premiumUnlimited;

  /// No description provided for @premiumLimited.
  ///
  /// In en, this message translates to:
  /// **'Limited'**
  String get premiumLimited;

  /// No description provided for @premiumAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get premiumAvailable;

  /// No description provided for @premiumRewardAds.
  ///
  /// In en, this message translates to:
  /// **'Reward ads'**
  String get premiumRewardAds;

  /// No description provided for @premiumNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get premiumNone;

  /// No description provided for @searchVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Search vocabulary'**
  String get searchVocabulary;

  /// No description provided for @recordingSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Recording sync failed: {details}'**
  String recordingSyncFailed(Object details);

  /// No description provided for @lastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced: {time}'**
  String lastSynced(Object time);

  /// No description provided for @settingsSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Settings sync failed: {details}'**
  String settingsSyncFailed(Object details);

  /// No description provided for @accountRole.
  ///
  /// In en, this message translates to:
  /// **'Role: {role}'**
  String accountRole(Object role);

  /// No description provided for @signOutDataNotice.
  ///
  /// In en, this message translates to:
  /// **'Signing out clears the recording history shown on this device. You can retrieve it from cloud sync after signing in again.'**
  String get signOutDataNotice;

  /// No description provided for @passwordResetCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Reset email sent. Check your inbox.'**
  String get passwordResetCheckEmail;

  /// No description provided for @emailRegistrationBenefit.
  ///
  /// In en, this message translates to:
  /// **'Registering with email makes it easier to restore this device\'s learning data later.'**
  String get emailRegistrationBenefit;

  /// No description provided for @emailRegistrationRequiresCloud.
  ///
  /// In en, this message translates to:
  /// **'Email registration is available after Supabase is configured.'**
  String get emailRegistrationRequiresCloud;

  /// No description provided for @connectionDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Connection diagnostics'**
  String get connectionDiagnostics;

  /// No description provided for @checkingConnection.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checkingConnection;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Check connection'**
  String get checkConnection;

  /// No description provided for @supabaseConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Supabase configuration'**
  String get supabaseConfiguration;

  /// No description provided for @supabaseConfigured.
  ///
  /// In en, this message translates to:
  /// **'The URL and anon key are configured.'**
  String get supabaseConfigured;

  /// No description provided for @supabaseNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'SUPABASE_URL / SUPABASE_ANON_KEY are not configured.'**
  String get supabaseNotConfigured;

  /// No description provided for @supabaseInitialization.
  ///
  /// In en, this message translates to:
  /// **'Supabase initialization'**
  String get supabaseInitialization;

  /// No description provided for @supabaseInitialized.
  ///
  /// In en, this message translates to:
  /// **'Initialized.'**
  String get supabaseInitialized;

  /// No description provided for @emailSignInDiagnostic.
  ///
  /// In en, this message translates to:
  /// **'Email sign-in'**
  String get emailSignInDiagnostic;

  /// No description provided for @signedInSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Signed in successfully.'**
  String get signedInSuccessfully;

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in.'**
  String get notSignedIn;

  /// No description provided for @accountAccess.
  ///
  /// In en, this message translates to:
  /// **'Account access'**
  String get accountAccess;

  /// No description provided for @accountAccessAfterSignIn.
  ///
  /// In en, this message translates to:
  /// **'profiles.role is retrieved after signing in.'**
  String get accountAccessAfterSignIn;

  /// No description provided for @databaseTable.
  ///
  /// In en, this message translates to:
  /// **'{table} table'**
  String databaseTable(Object table);

  /// No description provided for @databaseTableAccessible.
  ///
  /// In en, this message translates to:
  /// **'Accessible.'**
  String get databaseTableAccessible;

  /// No description provided for @edgeFunctionResponding.
  ///
  /// In en, this message translates to:
  /// **'The Edge Function is responding.'**
  String get edgeFunctionResponding;

  /// No description provided for @responseStatus.
  ///
  /// In en, this message translates to:
  /// **'Response status: {status}'**
  String responseStatus(Object status);

  /// No description provided for @noRecognizableSpeech.
  ///
  /// In en, this message translates to:
  /// **'No recognizable speech was found. Check the recording and try again.'**
  String get noRecognizableSpeech;

  /// No description provided for @unsupportedCorrectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'This practice language is not supported for AI correction.'**
  String get unsupportedCorrectionLanguage;

  /// No description provided for @analysisFailed.
  ///
  /// In en, this message translates to:
  /// **'AI analysis failed. Please try again later.'**
  String get analysisFailed;

  /// No description provided for @correctionAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to use AI correction.'**
  String get correctionAuthRequired;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect. Check your network and try again.'**
  String get networkError;

  /// No description provided for @invalidServerResponse.
  ///
  /// In en, this message translates to:
  /// **'The server returned an invalid response. Please try again later.'**
  String get invalidServerResponse;

  /// No description provided for @cloudNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Cloud not configured'**
  String get cloudNotConfigured;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get connecting;

  /// No description provided for @signedInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Signed in with email'**
  String get signedInWithEmail;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connectionError;

  /// No description provided for @roleFree.
  ///
  /// In en, this message translates to:
  /// **'Free user'**
  String get roleFree;

  /// No description provided for @rolePremium.
  ///
  /// In en, this message translates to:
  /// **'Premium user'**
  String get rolePremium;

  /// No description provided for @roleTester.
  ///
  /// In en, this message translates to:
  /// **'Beta tester'**
  String get roleTester;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get roleAdmin;

  /// No description provided for @authConfirmationSent.
  ///
  /// In en, this message translates to:
  /// **'Confirmation email sent. Complete registration from the link in the email.'**
  String get authConfirmationSent;

  /// No description provided for @authSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in with your email account.'**
  String get authSignedIn;

  /// No description provided for @authPasswordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Set a new password from the link in the email.'**
  String get authPasswordResetSent;

  /// No description provided for @authPasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated.'**
  String get authPasswordUpdated;

  /// No description provided for @authSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out.'**
  String get authSignedOut;

  /// No description provided for @authEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password.'**
  String get authEnterNewPassword;

  /// No description provided for @authInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authInvalidEmail;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Enter a password with at least 6 characters.'**
  String get authPasswordTooShort;

  /// No description provided for @authNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Email authentication is unavailable because Supabase is not configured.'**
  String get authNotConfigured;

  /// No description provided for @authSignOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed: {details}'**
  String authSignOutFailed(Object details);

  /// No description provided for @authActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed: {details}'**
  String authActionFailed(Object details);

  /// No description provided for @settingsDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Settings downloaded from the cloud.'**
  String get settingsDownloaded;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved to the cloud.'**
  String get settingsSaved;

  /// No description provided for @settingsDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not download settings: {details}'**
  String settingsDownloadFailed(Object details);

  /// No description provided for @settingsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save settings: {details}'**
  String settingsSaveFailed(Object details);

  /// No description provided for @recordingsCloudEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no recordings in the cloud.'**
  String get recordingsCloudEmpty;

  /// No description provided for @recordingsDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded {count} recordings from the cloud.'**
  String recordingsDownloaded(Object count);

  /// No description provided for @recordingsImported.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} recordings from the cloud.'**
  String recordingsImported(Object count);

  /// No description provided for @recordingsSynced.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync completed.'**
  String get recordingsSynced;

  /// No description provided for @draftAuthRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in again to create a practice text.'**
  String get draftAuthRequired;

  /// No description provided for @draftInputTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep your input within 500 characters.'**
  String get draftInputTooLong;

  /// No description provided for @draftApiNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'AI text creation is not configured yet.'**
  String get draftApiNotConfigured;

  /// No description provided for @draftFunctionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Practice text creation is temporarily unavailable. Please try again later.'**
  String get draftFunctionNotFound;

  /// No description provided for @draftApiLimit.
  ///
  /// In en, this message translates to:
  /// **'AI text creation is temporarily unavailable because the service limit was reached.'**
  String get draftApiLimit;

  /// No description provided for @draftFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create a practice text. Please try again later.'**
  String get draftFailed;

  /// No description provided for @chooseNewPracticeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose a new practice language'**
  String get chooseNewPracticeLanguage;

  /// No description provided for @practiceLanguageMustChange.
  ///
  /// In en, this message translates to:
  /// **'That language is currently your practice language. Choose a different practice language before changing the app language.'**
  String get practiceLanguageMustChange;

  /// No description provided for @savedCorrectionLanguageMismatchTitle.
  ///
  /// In en, this message translates to:
  /// **'A correction in another language is saved'**
  String get savedCorrectionLanguageMismatchTitle;

  /// No description provided for @savedCorrectionLanguageMismatchDescription.
  ///
  /// In en, this message translates to:
  /// **'The saved correction was created for another app language or an older analysis version, so it won\'t be reused automatically.'**
  String get savedCorrectionLanguageMismatchDescription;

  /// No description provided for @reanalysisConsumesUsage.
  ///
  /// In en, this message translates to:
  /// **'Creating a new correction uses one AI correction from your allowance.'**
  String get reanalysisConsumesUsage;

  /// No description provided for @reanalyzeInCurrentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Correct in the current language'**
  String get reanalyzeInCurrentLanguage;

  /// No description provided for @correctionAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your recording...'**
  String get correctionAnalyzing;

  /// No description provided for @wordUsageAdviceFallback.
  ///
  /// In en, this message translates to:
  /// **'Try using {word} with one more detail or reason in your next recording.'**
  String wordUsageAdviceFallback(String word);

  /// No description provided for @exampleTranslation.
  ///
  /// In en, this message translates to:
  /// **'Example translation'**
  String get exampleTranslation;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TalkLog'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get navRecord;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get navVocabulary;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Please sign in with your email to use this feature.'**
  String get loginRequired;

  /// No description provided for @languageName.
  ///
  /// In en, this message translates to:
  /// **'{code, select, ja{Japanese} en{English} es{Spanish} fr{French} de{German} it{Italian} ko{Korean} zhHans{Chinese} other{{code}}}'**
  String languageName(String code);

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Let\'s speak a little today!'**
  String get homeGreeting;

  /// No description provided for @currentLearningLanguage.
  ///
  /// In en, this message translates to:
  /// **'Practice language: {language}'**
  String currentLearningLanguage(Object language);

  /// No description provided for @todayStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s step'**
  String get todayStepTitle;

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Start recording'**
  String get startRecording;

  /// No description provided for @todayStartMessage.
  ///
  /// In en, this message translates to:
  /// **'Start with just 30 seconds and create today\'s learning log.'**
  String get todayStartMessage;

  /// No description provided for @todayKeepStreakMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep your streak going. One short recording is enough.'**
  String get todayKeepStreakMessage;

  /// No description provided for @todayOneDoneMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve completed today\'s recording. If you have time, share one more reason or thought.'**
  String get todayOneDoneMessage;

  /// No description provided for @todayManyDoneMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already made {count} recordings today. Great pace!'**
  String todayManyDoneMessage(Object count);

  /// No description provided for @audioStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio storage'**
  String get audioStorageTitle;

  /// No description provided for @storagePremiumUsage.
  ///
  /// In en, this message translates to:
  /// **'{used} used / Premium storage'**
  String storagePremiumUsage(Object used);

  /// No description provided for @storageFreeUsage.
  ///
  /// In en, this message translates to:
  /// **'{used} / {limit} used'**
  String storageFreeUsage(Object limit, Object used);

  /// No description provided for @storagePremiumDescription.
  ///
  /// In en, this message translates to:
  /// **'Your Premium access lets you save recordings without worrying about storage.'**
  String get storagePremiumDescription;

  /// No description provided for @storageLowDescription.
  ///
  /// In en, this message translates to:
  /// **'Only {remaining} remains. Premium lets you save recordings without worrying about storage.'**
  String storageLowDescription(Object remaining);

  /// No description provided for @storageRemainingDescription.
  ///
  /// In en, this message translates to:
  /// **'{remaining} remains. Your audio log grows with every recording.'**
  String storageRemainingDescription(Object remaining);

  /// No description provided for @weeklyPaceTitle.
  ///
  /// In en, this message translates to:
  /// **'This week\'s pace'**
  String get weeklyPaceTitle;

  /// No description provided for @thisWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeekLabel;

  /// No description provided for @versusLastWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'vs. last week'**
  String get versusLastWeekLabel;

  /// No description provided for @recordingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 recordings} =1{1 recording} other{{count} recordings}}'**
  String recordingCount(num count);

  /// No description provided for @recordingDelta.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{±0 recordings} other{{count} recordings}}'**
  String recordingDelta(num count);

  /// No description provided for @trendNoRecordings.
  ///
  /// In en, this message translates to:
  /// **'Make your first recording and start building a learning rhythm.'**
  String get trendNoRecordings;

  /// No description provided for @trendImproving.
  ///
  /// In en, this message translates to:
  /// **'You made {count} more recordings than last week. Keep it up!'**
  String trendImproving(Object count);

  /// No description provided for @trendSteady.
  ///
  /// In en, this message translates to:
  /// **'You\'re keeping the same pace as last week. Consistency is working.'**
  String get trendSteady;

  /// No description provided for @trendNoRecordingsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'No recordings yet this week. Start again with just 30 seconds.'**
  String get trendNoRecordingsThisWeek;

  /// No description provided for @trendSlower.
  ///
  /// In en, this message translates to:
  /// **'You recorded less than last week. Add one short recording today.'**
  String get trendSlower;

  /// No description provided for @currentStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreakTitle;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 days} =1{1 day} other{{count} days}}'**
  String streakDays(num count);

  /// No description provided for @todayRecordingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s recordings'**
  String get todayRecordingsTitle;

  /// No description provided for @totalRecordingTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Total recording time'**
  String get totalRecordingTimeTitle;

  /// No description provided for @durationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =0{0 minutes} =1{1 minute} other{{minutes} minutes}}'**
  String durationMinutes(num minutes);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{1 hour} other{{hours} hours}} {minutes, plural, =0{} =1{1 minute} other{{minutes} minutes}}'**
  String durationHoursMinutes(num hours, num minutes);

  /// No description provided for @todayPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s small topic'**
  String get todayPromptTitle;

  /// No description provided for @todayPromptBody.
  ///
  /// In en, this message translates to:
  /// **'Talk in your practice language about one good thing that happened today.'**
  String get todayPromptBody;

  /// No description provided for @recordTitle.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get recordTitle;

  /// No description provided for @recordStatusBusy.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get recordStatusBusy;

  /// No description provided for @recordStatusRecording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get recordStatusRecording;

  /// No description provided for @recordStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to record'**
  String get recordStatusReady;

  /// No description provided for @recordSaved.
  ///
  /// In en, this message translates to:
  /// **'Recording saved.'**
  String get recordSaved;

  /// No description provided for @recordCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel recording'**
  String get recordCancel;

  /// No description provided for @recordHintBusy.
  ///
  /// In en, this message translates to:
  /// **'Please wait a moment'**
  String get recordHintBusy;

  /// No description provided for @recordHintRecording.
  ///
  /// In en, this message translates to:
  /// **'Speak while viewing your practice text, then stop to save'**
  String get recordHintRecording;

  /// No description provided for @recordHintReady.
  ///
  /// In en, this message translates to:
  /// **'Tap to start recording'**
  String get recordHintReady;

  /// No description provided for @draftTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan what to say'**
  String get draftTitle;

  /// No description provided for @draftResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice text'**
  String get draftResultTitle;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @draftInputLabel.
  ///
  /// In en, this message translates to:
  /// **'What you want to say'**
  String get draftInputLabel;

  /// No description provided for @draftInputHint.
  ///
  /// In en, this message translates to:
  /// **'Example: I was tired after work today, but I want to keep practicing.'**
  String get draftInputHint;

  /// No description provided for @hideKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Hide keyboard'**
  String get hideKeyboard;

  /// No description provided for @draftCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get draftCreating;

  /// No description provided for @draftCreate.
  ///
  /// In en, this message translates to:
  /// **'Create a {language} practice text'**
  String draftCreate(Object language);

  /// No description provided for @draftInputRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter what you want to say.'**
  String get draftInputRequired;

  /// No description provided for @syncFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync failed'**
  String get syncFailedTitle;

  /// No description provided for @syncingTitle.
  ///
  /// In en, this message translates to:
  /// **'Syncing with the cloud'**
  String get syncingTitle;

  /// No description provided for @syncingDescription.
  ///
  /// In en, this message translates to:
  /// **'Syncing your recording history with the cloud.'**
  String get syncingDescription;

  /// No description provided for @syncRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry sync'**
  String get syncRetry;

  /// No description provided for @recordPermissionError.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is required. Allow microphone access in your device settings.'**
  String get recordPermissionError;

  /// No description provided for @recordStorageLimitError.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the free 200 MB audio storage limit. Premium removes the storage limit.'**
  String get recordStorageLimitError;

  /// No description provided for @recordStartError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start recording: {details}'**
  String recordStartError(Object details);

  /// No description provided for @recordSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the recording: {details}'**
  String recordSaveError(Object details);

  /// No description provided for @recordCancelError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t cancel the recording: {details}'**
  String recordCancelError(Object details);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historySelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String historySelected(Object count);

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get clearSelection;

  /// No description provided for @selectAllVisible.
  ///
  /// In en, this message translates to:
  /// **'Select all visible recordings'**
  String get selectAllVisible;

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete selected recordings'**
  String get deleteSelected;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get resetFilters;

  /// No description provided for @refreshCorrectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh correction status'**
  String get refreshCorrectionStatus;

  /// No description provided for @historySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by date or language'**
  String get historySearchHint;

  /// No description provided for @correctedOnly.
  ///
  /// In en, this message translates to:
  /// **'Corrected only'**
  String get correctedOnly;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @dateAll.
  ///
  /// In en, this message translates to:
  /// **'Date: all'**
  String get dateAll;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @withinSevenDays.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get withinSevenDays;

  /// No description provided for @withinThirtyDays.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get withinThirtyDays;

  /// No description provided for @durationAll.
  ///
  /// In en, this message translates to:
  /// **'Length: all'**
  String get durationAll;

  /// No description provided for @underOneMinute.
  ///
  /// In en, this message translates to:
  /// **'Under 1 min'**
  String get underOneMinute;

  /// No description provided for @oneToThreeMinutes.
  ///
  /// In en, this message translates to:
  /// **'1–3 min'**
  String get oneToThreeMinutes;

  /// No description provided for @threeMinutesOrMore.
  ///
  /// In en, this message translates to:
  /// **'3 min or more'**
  String get threeMinutesOrMore;

  /// No description provided for @selectHistoryHelp.
  ///
  /// In en, this message translates to:
  /// **'Select the recordings you want to delete.'**
  String get selectHistoryHelp;

  /// No description provided for @releaseSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get releaseSelection;

  /// No description provided for @noRecordings.
  ///
  /// In en, this message translates to:
  /// **'No recordings yet.'**
  String get noRecordings;

  /// No description provided for @noMatchingHistory.
  ///
  /// In en, this message translates to:
  /// **'No recordings match these filters.'**
  String get noMatchingHistory;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @corrected.
  ///
  /// In en, this message translates to:
  /// **'Corrected'**
  String get corrected;

  /// No description provided for @notCorrected.
  ///
  /// In en, this message translates to:
  /// **'Not corrected'**
  String get notCorrected;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @audioFileMissing.
  ///
  /// In en, this message translates to:
  /// **'Audio file not found.'**
  String get audioFileMissing;

  /// No description provided for @deleteRecordingTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this recording?'**
  String get deleteRecordingTitle;

  /// No description provided for @deleteRecordingDescription.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone. The audio file and cloud recording data will also be deleted.'**
  String get deleteRecordingDescription;

  /// No description provided for @deleteSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} recordings?'**
  String deleteSelectedTitle(Object count);

  /// No description provided for @deleteSelectedDescription.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone. The selected audio files and cloud recording data will also be deleted.'**
  String get deleteSelectedDescription;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @recordingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Recording deleted.'**
  String get recordingDeleted;

  /// No description provided for @recordingsDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count} recordings deleted.'**
  String recordingsDeleted(Object count);

  /// No description provided for @backToHistory.
  ///
  /// In en, this message translates to:
  /// **'Back to history'**
  String get backToHistory;

  /// No description provided for @recordingDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recording details'**
  String get recordingDetailsTitle;

  /// No description provided for @refreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get refreshStatus;

  /// No description provided for @recordingDuration.
  ///
  /// In en, this message translates to:
  /// **'Recording duration'**
  String get recordingDuration;

  /// No description provided for @learningLanguage.
  ///
  /// In en, this message translates to:
  /// **'Practice language'**
  String get learningLanguage;

  /// No description provided for @audioFile.
  ///
  /// In en, this message translates to:
  /// **'Audio file'**
  String get audioFile;

  /// No description provided for @viewAiCorrection.
  ///
  /// In en, this message translates to:
  /// **'View AI correction'**
  String get viewAiCorrection;

  /// No description provided for @deleteRecording.
  ///
  /// In en, this message translates to:
  /// **'Delete recording'**
  String get deleteRecording;

  /// No description provided for @checkingStatus.
  ///
  /// In en, this message translates to:
  /// **'Checking status'**
  String get checkingStatus;

  /// No description provided for @cloudSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced to cloud'**
  String get cloudSynced;

  /// No description provided for @notSynced.
  ///
  /// In en, this message translates to:
  /// **'Not synced'**
  String get notSynced;

  /// No description provided for @correctionSaved.
  ///
  /// In en, this message translates to:
  /// **'Correction saved'**
  String get correctionSaved;

  /// No description provided for @aiAnalysisAvailable.
  ///
  /// In en, this message translates to:
  /// **'AI analysis available'**
  String get aiAnalysisAvailable;

  /// No description provided for @aiAnalysisAfterSync.
  ///
  /// In en, this message translates to:
  /// **'AI analysis available after syncing'**
  String get aiAnalysisAfterSync;

  /// No description provided for @aiCorrectionTitle.
  ///
  /// In en, this message translates to:
  /// **'AI correction'**
  String get aiCorrectionTitle;

  /// No description provided for @backToRecordingDetails.
  ///
  /// In en, this message translates to:
  /// **'Back to recording details'**
  String get backToRecordingDetails;

  /// No description provided for @reanalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze again'**
  String get reanalyze;

  /// No description provided for @savedResultSource.
  ///
  /// In en, this message translates to:
  /// **'Saved result'**
  String get savedResultSource;

  /// No description provided for @edgeFunctionSource.
  ///
  /// In en, this message translates to:
  /// **'Cloud AI'**
  String get edgeFunctionSource;

  /// No description provided for @demoCorrectionSource.
  ///
  /// In en, this message translates to:
  /// **'Demo correction'**
  String get demoCorrectionSource;

  /// No description provided for @savedResultNotice.
  ///
  /// In en, this message translates to:
  /// **'Showing a saved correction result.'**
  String get savedResultNotice;

  /// No description provided for @correctionSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save to the cloud. You can still review this result on this screen. Details: {details}'**
  String correctionSaveFailed(Object details);

  /// No description provided for @vocabularyAdded.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary notes added to your vocabulary list.'**
  String get vocabularyAdded;

  /// No description provided for @vocabularyAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add the notes to your vocabulary list: {details}'**
  String vocabularyAddFailed(Object details);

  /// No description provided for @addVocabularyNotes.
  ///
  /// In en, this message translates to:
  /// **'Add vocabulary notes'**
  String get addVocabularyNotes;

  /// No description provided for @transcript.
  ///
  /// In en, this message translates to:
  /// **'Transcript'**
  String get transcript;

  /// No description provided for @correctedText.
  ///
  /// In en, this message translates to:
  /// **'Corrected text'**
  String get correctedText;

  /// No description provided for @naturalExpression.
  ///
  /// In en, this message translates to:
  /// **'Natural expression'**
  String get naturalExpression;

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// No description provided for @grammarNotes.
  ///
  /// In en, this message translates to:
  /// **'Grammar notes'**
  String get grammarNotes;

  /// No description provided for @vocabularyNotes.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary notes'**
  String get vocabularyNotes;

  /// No description provided for @encouragement.
  ///
  /// In en, this message translates to:
  /// **'Encouragement'**
  String get encouragement;

  /// No description provided for @dailyAiLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached today\'s AI correction limit.'**
  String get dailyAiLimitReached;

  /// No description provided for @correctionLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the AI correction'**
  String get correctionLoadFailed;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @analysisMethod.
  ///
  /// In en, this message translates to:
  /// **'Analysis method: {source}'**
  String analysisMethod(Object source);

  /// No description provided for @runFullAnalysisAgain.
  ///
  /// In en, this message translates to:
  /// **'Run full analysis again'**
  String get runFullAnalysisAgain;

  /// No description provided for @aiScore.
  ///
  /// In en, this message translates to:
  /// **'AI score'**
  String get aiScore;

  /// No description provided for @aiScoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Evaluates clarity, naturalness, and grammar balance.'**
  String get aiScoreDescription;

  /// No description provided for @progressTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressTitle;

  /// No description provided for @syncingLearningData.
  ///
  /// In en, this message translates to:
  /// **'Syncing learning data...'**
  String get syncingLearningData;

  /// No description provided for @learningDataSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sync learning data: {details}'**
  String learningDataSyncFailed(Object details);

  /// No description provided for @learningDataSynced.
  ///
  /// In en, this message translates to:
  /// **'Learning data synced at {time}'**
  String learningDataSynced(Object time);

  /// No description provided for @learningDataAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Learning data is calculated automatically from your recordings.'**
  String get learningDataAutomatic;

  /// No description provided for @totalRecordings.
  ///
  /// In en, this message translates to:
  /// **'Total recordings'**
  String get totalRecordings;

  /// No description provided for @totalRecordingTime.
  ///
  /// In en, this message translates to:
  /// **'Total recording time'**
  String get totalRecordingTime;

  /// No description provided for @averageScore.
  ///
  /// In en, this message translates to:
  /// **'Average score'**
  String get averageScore;

  /// No description provided for @currentAndBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Current: {current} / Best: {best}'**
  String currentAndBestStreak(Object best, Object current);

  /// No description provided for @streakTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning streak'**
  String get streakTitle;

  /// No description provided for @monthlySummary.
  ///
  /// In en, this message translates to:
  /// **'Monthly summary'**
  String get monthlySummary;

  /// No description provided for @monthlyRecordings.
  ///
  /// In en, this message translates to:
  /// **'This month\'s recordings'**
  String get monthlyRecordings;

  /// No description provided for @monthlyTime.
  ///
  /// In en, this message translates to:
  /// **'This month\'s time'**
  String get monthlyTime;

  /// No description provided for @practiceDays.
  ///
  /// In en, this message translates to:
  /// **'Practice days'**
  String get practiceDays;

  /// No description provided for @averageRecordingTime.
  ///
  /// In en, this message translates to:
  /// **'Average recording time'**
  String get averageRecordingTime;

  /// No description provided for @learningTrend.
  ///
  /// In en, this message translates to:
  /// **'Learning trend'**
  String get learningTrend;

  /// No description provided for @thisWeekRecordings.
  ///
  /// In en, this message translates to:
  /// **'This week\'s recordings'**
  String get thisWeekRecordings;

  /// No description provided for @differenceFromLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Difference from last week'**
  String get differenceFromLastWeek;

  /// No description provided for @thisWeekTime.
  ///
  /// In en, this message translates to:
  /// **'This week\'s time'**
  String get thisWeekTime;

  /// No description provided for @mostActiveDay.
  ///
  /// In en, this message translates to:
  /// **'Most active day'**
  String get mostActiveDay;

  /// No description provided for @frequentCorrectionPoints.
  ///
  /// In en, this message translates to:
  /// **'Frequent correction points'**
  String get frequentCorrectionPoints;

  /// No description provided for @correctionPointsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load correction points: {details}'**
  String correctionPointsLoadFailed(Object details);

  /// No description provided for @correctionPointsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your frequent grammar and vocabulary feedback will appear as you complete more AI corrections.'**
  String get correctionPointsEmpty;

  /// No description provided for @lastSevenDays.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get lastSevenDays;

  /// No description provided for @topWords.
  ///
  /// In en, this message translates to:
  /// **'Top 10 most-used words'**
  String get topWords;

  /// No description provided for @wordRankingLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the word ranking: {details}'**
  String wordRankingLoadFailed(Object details);

  /// No description provided for @wordRankingEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your most-used words and alternatives will appear as you transcribe more recordings.'**
  String get wordRankingEmpty;

  /// No description provided for @progressEmpty.
  ///
  /// In en, this message translates to:
  /// **'Record something to see your learning data here.'**
  String get progressEmpty;

  /// No description provided for @feedbackDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Correction point details'**
  String get feedbackDetailTitle;

  /// No description provided for @strategyNotes.
  ///
  /// In en, this message translates to:
  /// **'Strategy notes'**
  String get strategyNotes;

  /// No description provided for @tryNextRecording.
  ///
  /// In en, this message translates to:
  /// **'Try in your next recording'**
  String get tryNextRecording;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to use this'**
  String get howToUse;

  /// No description provided for @feedbackUsageDescription.
  ///
  /// In en, this message translates to:
  /// **'Make a short recording with this point in mind, then check another AI correction to see your improvement.'**
  String get feedbackUsageDescription;

  /// No description provided for @grammarAdvice.
  ///
  /// In en, this message translates to:
  /// **'This grammar point appears often. Focus on just this one point in your next recording.'**
  String get grammarAdvice;

  /// No description provided for @vocabularyAdvice.
  ///
  /// In en, this message translates to:
  /// **'This vocabulary point can broaden your expression. Try an alternative in a similar situation.'**
  String get vocabularyAdvice;

  /// No description provided for @grammarPracticePrompt.
  ///
  /// In en, this message translates to:
  /// **'Make three short sentences using this grammar point, then connect them in one recording.'**
  String get grammarPracticePrompt;

  /// No description provided for @vocabularyPracticePrompt.
  ///
  /// In en, this message translates to:
  /// **'Describe the same event twice using this word and one alternative.'**
  String get vocabularyPracticePrompt;

  /// No description provided for @vocabularyTitle.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get vocabularyTitle;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @vocabularyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your vocabulary list is empty. Add words from AI correction notes.'**
  String get vocabularyEmpty;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @vocabularySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by first letters'**
  String get vocabularySearchHint;

  /// No description provided for @wordsVisible.
  ///
  /// In en, this message translates to:
  /// **'Showing {visible} of {total} words'**
  String wordsVisible(Object total, Object visible);

  /// No description provided for @reviewPending.
  ///
  /// In en, this message translates to:
  /// **'To review'**
  String get reviewPending;

  /// No description provided for @reviewed.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get reviewed;

  /// No description provided for @sortAlphabetical.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get sortAlphabetical;

  /// No description provided for @sortRecentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get sortRecentlyAdded;

  /// No description provided for @sortReviewCount.
  ///
  /// In en, this message translates to:
  /// **'Review count'**
  String get sortReviewCount;

  /// No description provided for @wordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Word updated.'**
  String get wordUpdated;

  /// No description provided for @deleteWordTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this word?'**
  String get deleteWordTitle;

  /// No description provided for @deleteWordDescription.
  ///
  /// In en, this message translates to:
  /// **'Remove “{word}” from your vocabulary list? This can\'t be undone.'**
  String deleteWordDescription(Object word);

  /// No description provided for @wordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Word deleted.'**
  String get wordDeleted;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @wordLabel.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get wordLabel;

  /// No description provided for @tapForExplanation.
  ///
  /// In en, this message translates to:
  /// **'Tap to show the explanation'**
  String get tapForExplanation;

  /// No description provided for @explanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get explanation;

  /// No description provided for @exampleSentence.
  ///
  /// In en, this message translates to:
  /// **'Example sentence'**
  String get exampleSentence;

  /// No description provided for @tapToReturnToWord.
  ///
  /// In en, this message translates to:
  /// **'Tap to return to the word'**
  String get tapToReturnToWord;

  /// No description provided for @pendingWordCount.
  ///
  /// In en, this message translates to:
  /// **'{count} words to review'**
  String pendingWordCount(Object count);

  /// No description provided for @registeredWordCount.
  ///
  /// In en, this message translates to:
  /// **'{count} words saved'**
  String registeredWordCount(Object count);

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @noWordsToReview.
  ///
  /// In en, this message translates to:
  /// **'No words are waiting for review.'**
  String get noWordsToReview;

  /// No description provided for @reviewProgress.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String reviewProgress(Object current, Object total);

  /// No description provided for @meaning.
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get meaning;

  /// No description provided for @showMeaning.
  ///
  /// In en, this message translates to:
  /// **'Show meaning'**
  String get showMeaning;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @remembered.
  ///
  /// In en, this message translates to:
  /// **'Remembered'**
  String get remembered;

  /// No description provided for @reviewCountOnly.
  ///
  /// In en, this message translates to:
  /// **'Reviewed {count} times'**
  String reviewCountOnly(Object count);

  /// No description provided for @reviewCountWithDate.
  ///
  /// In en, this message translates to:
  /// **'Reviewed {count} times / Last: {date}'**
  String reviewCountWithDate(Object count, Object date);

  /// No description provided for @editWordTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit word'**
  String get editWordTitle;

  /// No description provided for @meaningExplanation.
  ///
  /// In en, this message translates to:
  /// **'Meaning / explanation'**
  String get meaningExplanation;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @wordAndMeaningRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter both the word and its meaning.'**
  String get wordAndMeaningRequired;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languageSettings;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @practiceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Practice language'**
  String get practiceLanguage;

  /// No description provided for @currentValue.
  ///
  /// In en, this message translates to:
  /// **'Current: {value}'**
  String currentValue(Object value);

  /// No description provided for @selectAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select app language'**
  String get selectAppLanguage;

  /// No description provided for @selectPracticeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select practice language'**
  String get selectPracticeLanguage;

  /// No description provided for @sameLanguageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This is your app language, so it can\'t be selected as a practice language.'**
  String get sameLanguageUnavailable;

  /// No description provided for @practiceLanguageConflict.
  ///
  /// In en, this message translates to:
  /// **'This language is currently selected as your practice language. Choose another practice language first.'**
  String get practiceLanguageConflict;

  /// No description provided for @cloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync'**
  String get cloudSync;

  /// No description provided for @reconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get reconnect;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @syncRecordingHistory.
  ///
  /// In en, this message translates to:
  /// **'Sync recording history'**
  String get syncRecordingHistory;

  /// No description provided for @downloadSettings.
  ///
  /// In en, this message translates to:
  /// **'Download settings'**
  String get downloadSettings;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save settings'**
  String get saveSettings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @registerPremium.
  ///
  /// In en, this message translates to:
  /// **'Get Premium'**
  String get registerPremium;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @registerWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Register with email'**
  String get registerWithEmail;

  /// No description provided for @registerCurrentData.
  ///
  /// In en, this message translates to:
  /// **'Register this data with email'**
  String get registerCurrentData;

  /// No description provided for @signInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with email'**
  String get signInWithEmail;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPassword;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @newPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Set a new password.'**
  String get newPasswordPrompt;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePassword;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent.'**
  String get passwordResetSent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
