// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get premiumTitle => 'Premium';

  @override
  String get premiumHeadline => 'Sigue aprendiendo con Premium';

  @override
  String get premiumDescription =>
      'Crea tu registro de progreso oral a tu ritmo, sin preocuparte por los límites de correcciones con IA o almacenamiento de audio.';

  @override
  String get premiumSubscribePrice => 'Suscribirse por ¥480 al mes';

  @override
  String get premiumPurchaseUnavailable =>
      'Las suscripciones estarán disponibles después de configurar los productos de Google Play.';

  @override
  String get premiumCancellationNote =>
      'Después de cancelar, podrás usar las funciones Premium hasta el día anterior a la próxima renovación.';

  @override
  String get premiumItem => 'Función';

  @override
  String get premiumAiCorrection => 'Corrección con IA';

  @override
  String get premiumAiTranslation => 'Traducción con IA';

  @override
  String get premiumAudioStorage => 'Almacenamiento de audio';

  @override
  String get premiumCorrectionHistory => 'Historial de correcciones';

  @override
  String get premiumWordRanking => 'Clasificación de palabras';

  @override
  String get premiumAds => 'Anuncios';

  @override
  String get premiumFivePerDay => '5 al día';

  @override
  String get premiumUnlimited => 'Ilimitado';

  @override
  String get premiumLimited => 'Limitado';

  @override
  String get premiumAvailable => 'Disponible';

  @override
  String get premiumRewardAds => 'Anuncios con recompensa';

  @override
  String get premiumNone => 'Ninguno';

  @override
  String get searchVocabulary => 'Buscar en el vocabulario';

  @override
  String recordingSyncFailed(Object details) {
    return 'Error al sincronizar grabaciones: $details';
  }

  @override
  String lastSynced(Object time) {
    return 'Última sincronización: $time';
  }

  @override
  String settingsSyncFailed(Object details) {
    return 'Error al sincronizar los ajustes: $details';
  }

  @override
  String accountRole(Object role) {
    return 'Rol: $role';
  }

  @override
  String get signOutDataNotice =>
      'Al cerrar sesión se borra el historial mostrado en este dispositivo. Puedes recuperarlo de la nube después de iniciar sesión de nuevo.';

  @override
  String get passwordResetCheckEmail =>
      'Correo de restablecimiento enviado. Revisa tu bandeja de entrada.';

  @override
  String get emailRegistrationBenefit =>
      'Registrarte con correo facilita restaurar más adelante los datos de aprendizaje de este dispositivo.';

  @override
  String get emailRegistrationRequiresCloud =>
      'El registro por correo estará disponible después de configurar Supabase.';

  @override
  String get connectionDiagnostics => 'Diagnóstico de conexión';

  @override
  String get checkingConnection => 'Comprobando...';

  @override
  String get checkConnection => 'Comprobar conexión';

  @override
  String get supabaseConfiguration => 'Configuración de Supabase';

  @override
  String get supabaseConfigured =>
      'La URL y la clave anónima están configuradas.';

  @override
  String get supabaseNotConfigured =>
      'SUPABASE_URL / SUPABASE_ANON_KEY no están configuradas.';

  @override
  String get supabaseInitialization => 'Inicialización de Supabase';

  @override
  String get supabaseInitialized => 'Inicializado.';

  @override
  String get emailSignInDiagnostic => 'Inicio de sesión por correo';

  @override
  String get signedInSuccessfully => 'Sesión iniciada correctamente.';

  @override
  String get notSignedIn => 'No has iniciado sesión.';

  @override
  String get accountAccess => 'Acceso de la cuenta';

  @override
  String get accountAccessAfterSignIn =>
      'profiles.role se obtiene después de iniciar sesión.';

  @override
  String databaseTable(Object table) {
    return 'Tabla $table';
  }

  @override
  String get databaseTableAccessible => 'Accesible.';

  @override
  String get edgeFunctionResponding => 'La función Edge está respondiendo.';

  @override
  String responseStatus(Object status) {
    return 'Estado de respuesta: $status';
  }

  @override
  String get noRecognizableSpeech =>
      'No se pudo reconocer la voz. Revisa la grabación e inténtalo de nuevo.';

  @override
  String get unsupportedCorrectionLanguage =>
      'Este idioma de práctica no es compatible con la corrección mediante IA.';

  @override
  String get analysisFailed =>
      'El análisis con IA falló. Inténtalo de nuevo más tarde.';

  @override
  String get correctionAuthRequired =>
      'Vuelve a iniciar sesión para usar la corrección mediante IA.';

  @override
  String get networkError =>
      'No se pudo conectar. Revisa la red e inténtalo de nuevo.';

  @override
  String get invalidServerResponse =>
      'El servidor devolvió una respuesta no válida. Inténtalo de nuevo más tarde.';

  @override
  String get cloudNotConfigured => 'Nube no configurada';

  @override
  String get connecting => 'Conectando';

  @override
  String get signedInWithEmail => 'Sesión iniciada por correo';

  @override
  String get connectionError => 'Error de conexión';

  @override
  String get roleFree => 'Usuario gratuito';

  @override
  String get rolePremium => 'Usuario Premium';

  @override
  String get roleTester => 'Probador beta';

  @override
  String get roleAdmin => 'Administrador';

  @override
  String get authConfirmationSent =>
      'Correo de confirmación enviado. Completa el registro desde el enlace del correo.';

  @override
  String get authSignedIn => 'Sesión iniciada con tu cuenta de correo.';

  @override
  String get authPasswordResetSent =>
      'Correo de restablecimiento enviado. Define una nueva contraseña desde el enlace del correo.';

  @override
  String get authPasswordUpdated => 'Contraseña actualizada.';

  @override
  String get authSignedOut => 'Sesión cerrada.';

  @override
  String get authEnterNewPassword => 'Introduce una nueva contraseña.';

  @override
  String get authInvalidEmail => 'Introduce una dirección de correo válida.';

  @override
  String get authPasswordTooShort =>
      'Introduce una contraseña de al menos 6 caracteres.';

  @override
  String get authNotConfigured =>
      'La autenticación por correo no está disponible porque Supabase no está configurado.';

  @override
  String authSignOutFailed(Object details) {
    return 'No se pudo cerrar la sesión: $details';
  }

  @override
  String authActionFailed(Object details) {
    return 'La autenticación falló: $details';
  }

  @override
  String get settingsDownloaded => 'Ajustes descargados de la nube.';

  @override
  String get settingsSaved => 'Ajustes guardados en la nube.';

  @override
  String settingsDownloadFailed(Object details) {
    return 'No se pudieron descargar los ajustes: $details';
  }

  @override
  String settingsSaveFailed(Object details) {
    return 'No se pudieron guardar los ajustes: $details';
  }

  @override
  String get recordingsCloudEmpty => 'No hay grabaciones en la nube.';

  @override
  String recordingsDownloaded(Object count) {
    return 'Se descargaron $count grabaciones de la nube.';
  }

  @override
  String recordingsImported(Object count) {
    return 'Se importaron $count grabaciones de la nube.';
  }

  @override
  String get recordingsSynced => 'Sincronización con la nube completada.';

  @override
  String get draftAuthRequired =>
      'Vuelve a iniciar sesión para crear un texto de práctica.';

  @override
  String get draftInputTooLong => 'Limita el texto a 500 caracteres.';

  @override
  String get draftApiNotConfigured =>
      'La creación de textos con IA todavía no está configurada.';

  @override
  String get draftFunctionNotFound =>
      'La creación de textos de práctica no está disponible temporalmente. Inténtalo más tarde.';

  @override
  String get draftApiLimit =>
      'La creación de textos con IA no está disponible temporalmente porque se alcanzó el límite del servicio.';

  @override
  String get draftFailed =>
      'No se pudo crear el texto de práctica. Inténtalo de nuevo más tarde.';

  @override
  String get chooseNewPracticeLanguage => 'Elige un nuevo idioma de práctica';

  @override
  String get practiceLanguageMustChange =>
      'Ese idioma es actualmente tu idioma de práctica. Elige otro antes de cambiar el idioma de la aplicación.';

  @override
  String get savedCorrectionLanguageMismatchTitle =>
      'Hay una corrección guardada en otro idioma';

  @override
  String get savedCorrectionLanguageMismatchDescription =>
      'La corrección guardada se creó para otro idioma de la aplicación o una versión anterior del análisis, por lo que no se reutilizará automáticamente.';

  @override
  String get reanalysisConsumesUsage =>
      'Crear una nueva corrección consume un uso de tu límite de correcciones con IA.';

  @override
  String get reanalyzeInCurrentLanguage => 'Corregir en el idioma actual';

  @override
  String get exampleTranslation => 'Traducción del ejemplo';

  @override
  String get appTitle => 'TalkLog';

  @override
  String get navHome => 'Inicio';

  @override
  String get navRecord => 'Grabar';

  @override
  String get navHistory => 'Historial';

  @override
  String get navVocabulary => 'Vocabulario';

  @override
  String get navProgress => 'Progreso';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get loginRequired =>
      'Inicia sesión con tu correo electrónico para usar esta función.';

  @override
  String languageName(String code) {
    String _temp0 = intl.Intl.selectLogic(code, {
      'ja': 'japonés',
      'en': 'inglés',
      'es': 'español',
      'fr': 'francés',
      'de': 'alemán',
      'it': 'italiano',
      'ko': 'coreano',
      'zhHans': 'chino',
      'other': '$code',
    });
    return '$_temp0';
  }

  @override
  String get homeGreeting => '¡Hablemos un poco hoy!';

  @override
  String currentLearningLanguage(Object language) {
    return 'Idioma de práctica: $language';
  }

  @override
  String get todayStepTitle => 'El paso de hoy';

  @override
  String get startRecording => 'Empezar a grabar';

  @override
  String get todayStartMessage =>
      'Empieza con solo 30 segundos y crea el registro de aprendizaje de hoy.';

  @override
  String get todayKeepStreakMessage =>
      'Mantén tu racha. Una grabación corta es suficiente.';

  @override
  String get todayOneDoneMessage =>
      'Ya completaste la grabación de hoy. Si tienes tiempo, añade otra razón o idea.';

  @override
  String todayManyDoneMessage(Object count) {
    return 'Ya hiciste $count grabaciones hoy. ¡Muy buen ritmo!';
  }

  @override
  String get audioStorageTitle => 'Almacenamiento de audio';

  @override
  String storagePremiumUsage(Object used) {
    return '$used usados / almacenamiento Premium';
  }

  @override
  String storageFreeUsage(Object limit, Object used) {
    return '$used / $limit usados';
  }

  @override
  String get storagePremiumDescription =>
      'Con Premium puedes guardar grabaciones sin preocuparte por el espacio.';

  @override
  String storageLowDescription(Object remaining) {
    return 'Solo quedan $remaining. Con Premium puedes guardar grabaciones sin preocuparte por el espacio.';
  }

  @override
  String storageRemainingDescription(Object remaining) {
    return 'Quedan $remaining. Tu registro de audio crece con cada grabación.';
  }

  @override
  String get weeklyPaceTitle => 'Ritmo de esta semana';

  @override
  String get thisWeekLabel => 'Esta semana';

  @override
  String get versusLastWeekLabel => 'vs. semana pasada';

  @override
  String recordingCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grabaciones',
      one: '1 grabación',
      zero: '0 grabaciones',
    );
    return '$_temp0';
  }

  @override
  String recordingDelta(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grabaciones',
      one: '+1 grabación',
      zero: '±0 grabaciones',
    );
    return '$_temp0';
  }

  @override
  String get trendNoRecordings =>
      'Haz tu primera grabación y empieza a crear un ritmo de aprendizaje.';

  @override
  String trendImproving(Object count) {
    return 'Hiciste $count grabaciones más que la semana pasada. ¡Sigue así!';
  }

  @override
  String get trendSteady =>
      'Mantienes el mismo ritmo que la semana pasada. La constancia funciona.';

  @override
  String get trendNoRecordingsThisWeek =>
      'Todavía no hay grabaciones esta semana. Vuelve a empezar con solo 30 segundos.';

  @override
  String get trendSlower =>
      'Grabaste menos que la semana pasada. Añade una grabación corta hoy.';

  @override
  String get currentStreakTitle => 'Racha actual';

  @override
  String streakDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
      zero: '0 días',
    );
    return '$_temp0';
  }

  @override
  String get todayRecordingsTitle => 'Grabaciones de hoy';

  @override
  String get totalRecordingTimeTitle => 'Tiempo total de grabación';

  @override
  String durationMinutes(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos',
      one: '1 minuto',
      zero: '0 minutos',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(num hours, num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours horas',
      one: '1 hora',
    );
    String _temp1 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos',
      one: '1 minuto',
      zero: '',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String get todayPromptTitle => 'Pequeño tema de hoy';

  @override
  String get todayPromptBody =>
      'Habla en tu idioma de práctica sobre algo bueno que te haya pasado hoy.';

  @override
  String get recordTitle => 'Grabar';

  @override
  String get recordStatusBusy => 'Procesando';

  @override
  String get recordStatusRecording => 'Grabando';

  @override
  String get recordStatusReady => 'Listo para grabar';

  @override
  String get recordSaved => 'Grabación guardada.';

  @override
  String get recordCancel => 'Cancelar grabación';

  @override
  String get recordHintBusy => 'Espera un momento';

  @override
  String get recordHintRecording =>
      'Habla mientras miras el texto de práctica y detén la grabación para guardarla';

  @override
  String get recordHintReady => 'Toca para empezar a grabar';

  @override
  String get draftTitle => 'Piensa qué decir';

  @override
  String get draftResultTitle => 'Texto para practicar';

  @override
  String get clear => 'Borrar';

  @override
  String get draftInputLabel => 'Lo que quieres decir';

  @override
  String get draftInputHint =>
      'Ejemplo: Hoy terminé cansado del trabajo, pero quiero seguir practicando.';

  @override
  String get hideKeyboard => 'Ocultar teclado';

  @override
  String get draftCreating => 'Creando...';

  @override
  String draftCreate(Object language) {
    return 'Crear un texto de práctica en $language';
  }

  @override
  String get draftInputRequired => 'Escribe lo que quieres decir.';

  @override
  String get syncFailedTitle => 'Falló la sincronización con la nube';

  @override
  String get syncingTitle => 'Sincronizando con la nube';

  @override
  String get syncingDescription =>
      'Sincronizando el historial de grabaciones con la nube.';

  @override
  String get syncRetry => 'Reintentar sincronización';

  @override
  String get recordPermissionError =>
      'Se necesita acceso al micrófono. Permítelo en los ajustes del dispositivo.';

  @override
  String get recordStorageLimitError =>
      'Alcanzaste el límite gratuito de 200 MB de audio. Premium elimina el límite de almacenamiento.';

  @override
  String recordStartError(Object details) {
    return 'No se pudo iniciar la grabación: $details';
  }

  @override
  String recordSaveError(Object details) {
    return 'No se pudo guardar la grabación: $details';
  }

  @override
  String recordCancelError(Object details) {
    return 'No se pudo cancelar la grabación: $details';
  }

  @override
  String get historyTitle => 'Historial';

  @override
  String historySelected(Object count) {
    return '$count seleccionadas';
  }

  @override
  String get clearSelection => 'Quitar selección';

  @override
  String get selectAllVisible => 'Seleccionar todas las grabaciones visibles';

  @override
  String get deleteSelected => 'Eliminar grabaciones seleccionadas';

  @override
  String get resetFilters => 'Restablecer filtros';

  @override
  String get refreshCorrectionStatus => 'Actualizar estado de corrección';

  @override
  String get historySearchHint => 'Buscar por fecha o idioma';

  @override
  String get correctedOnly => 'Solo corregidas';

  @override
  String get all => 'Todos';

  @override
  String get dateAll => 'Fecha: todas';

  @override
  String get today => 'Hoy';

  @override
  String get withinSevenDays => 'Últimos 7 días';

  @override
  String get withinThirtyDays => 'Últimos 30 días';

  @override
  String get durationAll => 'Duración: todas';

  @override
  String get underOneMinute => 'Menos de 1 min';

  @override
  String get oneToThreeMinutes => '1–3 min';

  @override
  String get threeMinutesOrMore => '3 min o más';

  @override
  String get selectHistoryHelp =>
      'Selecciona las grabaciones que quieres eliminar.';

  @override
  String get releaseSelection => 'Quitar';

  @override
  String get noRecordings => 'Todavía no hay grabaciones.';

  @override
  String get noMatchingHistory => 'Ninguna grabación coincide con los filtros.';

  @override
  String get pause => 'Pausar';

  @override
  String get play => 'Reproducir';

  @override
  String get corrected => 'Corregida';

  @override
  String get notCorrected => 'Sin corregir';

  @override
  String get more => 'Más';

  @override
  String get details => 'Detalles';

  @override
  String get select => 'Seleccionar';

  @override
  String get delete => 'Eliminar';

  @override
  String get audioFileMissing => 'No se encontró el archivo de audio.';

  @override
  String get deleteRecordingTitle => '¿Eliminar esta grabación?';

  @override
  String get deleteRecordingDescription =>
      'Esta acción no se puede deshacer. También se eliminarán el audio y los datos de la nube.';

  @override
  String deleteSelectedTitle(Object count) {
    return '¿Eliminar $count grabaciones?';
  }

  @override
  String get deleteSelectedDescription =>
      'Esta acción no se puede deshacer. También se eliminarán los audios seleccionados y sus datos de la nube.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get recordingDeleted => 'Grabación eliminada.';

  @override
  String recordingsDeleted(Object count) {
    return 'Se eliminaron $count grabaciones.';
  }

  @override
  String get backToHistory => 'Volver al historial';

  @override
  String get recordingDetailsTitle => 'Detalles de la grabación';

  @override
  String get refreshStatus => 'Actualizar estado';

  @override
  String get recordingDuration => 'Duración de la grabación';

  @override
  String get learningLanguage => 'Idioma de práctica';

  @override
  String get audioFile => 'Archivo de audio';

  @override
  String get viewAiCorrection => 'Ver corrección de IA';

  @override
  String get deleteRecording => 'Eliminar grabación';

  @override
  String get checkingStatus => 'Comprobando estado';

  @override
  String get cloudSynced => 'Sincronizada con la nube';

  @override
  String get notSynced => 'Sin sincronizar';

  @override
  String get correctionSaved => 'Corrección guardada';

  @override
  String get aiAnalysisAvailable => 'Análisis de IA disponible';

  @override
  String get aiAnalysisAfterSync =>
      'Análisis de IA disponible después de sincronizar';

  @override
  String get aiCorrectionTitle => 'Corrección de IA';

  @override
  String get backToRecordingDetails => 'Volver a los detalles de la grabación';

  @override
  String get reanalyze => 'Analizar de nuevo';

  @override
  String get savedResultSource => 'Resultado guardado';

  @override
  String get edgeFunctionSource => 'IA en la nube';

  @override
  String get demoCorrectionSource => 'Corrección de demostración';

  @override
  String get savedResultNotice => 'Mostrando una corrección guardada.';

  @override
  String correctionSaveFailed(Object details) {
    return 'No se pudo guardar en la nube. Puedes revisar el resultado en esta pantalla. Detalles: $details';
  }

  @override
  String get vocabularyAdded =>
      'Las notas de vocabulario se añadieron a tu lista.';

  @override
  String vocabularyAddFailed(Object details) {
    return 'No se pudieron añadir las notas al vocabulario: $details';
  }

  @override
  String get addVocabularyNotes => 'Añadir notas de vocabulario';

  @override
  String get transcript => 'Transcripción';

  @override
  String get correctedText => 'Texto corregido';

  @override
  String get naturalExpression => 'Expresión natural';

  @override
  String get translation => 'Traducción';

  @override
  String get grammarNotes => 'Notas de gramática';

  @override
  String get vocabularyNotes => 'Notas de vocabulario';

  @override
  String get encouragement => 'Mensaje de ánimo';

  @override
  String get dailyAiLimitReached =>
      'Alcanzaste el límite de correcciones de IA de hoy.';

  @override
  String get correctionLoadFailed => 'No se pudo cargar la corrección de IA';

  @override
  String get close => 'Cerrar';

  @override
  String analysisMethod(Object source) {
    return 'Método de análisis: $source';
  }

  @override
  String get runFullAnalysisAgain => 'Volver a ejecutar el análisis completo';

  @override
  String get aiScore => 'Puntuación de IA';

  @override
  String get aiScoreDescription =>
      'Evalúa la claridad, la naturalidad y el equilibrio gramatical.';

  @override
  String get progressTitle => 'Progreso';

  @override
  String get syncingLearningData => 'Sincronizando datos de aprendizaje...';

  @override
  String learningDataSyncFailed(Object details) {
    return 'No se pudieron sincronizar los datos: $details';
  }

  @override
  String learningDataSynced(Object time) {
    return 'Datos sincronizados a las $time';
  }

  @override
  String get learningDataAutomatic =>
      'Los datos se calculan automáticamente a partir de tus grabaciones.';

  @override
  String get totalRecordings => 'Grabaciones totales';

  @override
  String get totalRecordingTime => 'Tiempo total de grabación';

  @override
  String get averageScore => 'Puntuación media';

  @override
  String currentAndBestStreak(Object best, Object current) {
    return 'Actual: $current / Máxima: $best';
  }

  @override
  String get streakTitle => 'Racha de aprendizaje';

  @override
  String get monthlySummary => 'Resumen mensual';

  @override
  String get monthlyRecordings => 'Grabaciones del mes';

  @override
  String get monthlyTime => 'Tiempo del mes';

  @override
  String get practiceDays => 'Días de práctica';

  @override
  String get averageRecordingTime => 'Tiempo medio de grabación';

  @override
  String get learningTrend => 'Tendencia de aprendizaje';

  @override
  String get thisWeekRecordings => 'Grabaciones de esta semana';

  @override
  String get differenceFromLastWeek => 'Diferencia con la semana pasada';

  @override
  String get thisWeekTime => 'Tiempo de esta semana';

  @override
  String get mostActiveDay => 'Día más activo';

  @override
  String get frequentCorrectionPoints => 'Correcciones frecuentes';

  @override
  String correctionPointsLoadFailed(Object details) {
    return 'No se pudieron cargar las correcciones: $details';
  }

  @override
  String get correctionPointsEmpty =>
      'Las observaciones frecuentes de gramática y vocabulario aparecerán cuando completes más correcciones de IA.';

  @override
  String get lastSevenDays => 'Últimos 7 días';

  @override
  String get topWords => 'Las 10 palabras más usadas';

  @override
  String wordRankingLoadFailed(Object details) {
    return 'No se pudo cargar la clasificación de palabras: $details';
  }

  @override
  String get wordRankingEmpty =>
      'Tus palabras más usadas y sus alternativas aparecerán cuando transcribas más grabaciones.';

  @override
  String get progressEmpty =>
      'Graba algo para ver aquí tus datos de aprendizaje.';

  @override
  String get feedbackDetailTitle => 'Detalles del punto de corrección';

  @override
  String get strategyNotes => 'Notas de mejora';

  @override
  String get tryNextRecording => 'Prueba en la próxima grabación';

  @override
  String get howToUse => 'Cómo usarlo';

  @override
  String get feedbackUsageDescription =>
      'Haz una grabación corta teniendo en cuenta este punto y vuelve a comprobar la corrección de IA para ver tu mejora.';

  @override
  String get grammarAdvice =>
      'Este punto gramatical aparece a menudo. Concéntrate solo en él en tu próxima grabación.';

  @override
  String get vocabularyAdvice =>
      'Este punto de vocabulario puede ampliar tu expresión. Prueba una alternativa en una situación similar.';

  @override
  String get grammarPracticePrompt =>
      'Crea tres frases cortas con este punto gramatical y únelas en una grabación.';

  @override
  String get vocabularyPracticePrompt =>
      'Describe el mismo hecho dos veces usando esta palabra y una alternativa.';

  @override
  String get vocabularyTitle => 'Vocabulario';

  @override
  String get reload => 'Recargar';

  @override
  String get vocabularyEmpty =>
      'Tu lista está vacía. Añade palabras desde las notas de corrección de IA.';

  @override
  String get clearSearch => 'Borrar búsqueda';

  @override
  String get vocabularySearchHint => 'Buscar por las primeras letras';

  @override
  String wordsVisible(Object total, Object visible) {
    return 'Mostrando $visible de $total palabras';
  }

  @override
  String get reviewPending => 'Por repasar';

  @override
  String get reviewed => 'Repasadas';

  @override
  String get sortAlphabetical => 'Orden alfabético';

  @override
  String get sortRecentlyAdded => 'Añadidas recientemente';

  @override
  String get sortReviewCount => 'Número de repasos';

  @override
  String get wordUpdated => 'Palabra actualizada.';

  @override
  String get deleteWordTitle => '¿Eliminar esta palabra?';

  @override
  String deleteWordDescription(Object word) {
    return '¿Quitar «$word» de tu lista? Esta acción no se puede deshacer.';
  }

  @override
  String get wordDeleted => 'Palabra eliminada.';

  @override
  String get edit => 'Editar';

  @override
  String get wordLabel => 'Palabra';

  @override
  String get tapForExplanation => 'Toca para ver la explicación';

  @override
  String get explanation => 'Explicación';

  @override
  String get exampleSentence => 'Frase de ejemplo';

  @override
  String get tapToReturnToWord => 'Toca para volver a la palabra';

  @override
  String pendingWordCount(Object count) {
    return '$count palabras por repasar';
  }

  @override
  String registeredWordCount(Object count) {
    return '$count palabras guardadas';
  }

  @override
  String get review => 'Repasar';

  @override
  String get back => 'Volver';

  @override
  String get noWordsToReview => 'No hay palabras pendientes de repaso.';

  @override
  String reviewProgress(Object current, Object total) {
    return '$current de $total';
  }

  @override
  String get meaning => 'Significado';

  @override
  String get showMeaning => 'Ver significado';

  @override
  String get next => 'Siguiente';

  @override
  String get remembered => 'Aprendida';

  @override
  String reviewCountOnly(Object count) {
    return 'Repasada $count veces';
  }

  @override
  String reviewCountWithDate(Object count, Object date) {
    return 'Repasada $count veces / Última: $date';
  }

  @override
  String get editWordTitle => 'Editar palabra';

  @override
  String get meaningExplanation => 'Significado / explicación';

  @override
  String get save => 'Guardar';

  @override
  String get wordAndMeaningRequired => 'Introduce la palabra y su significado.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get languageSettings => 'Idiomas';

  @override
  String get appLanguage => 'Idioma de la aplicación';

  @override
  String get practiceLanguage => 'Idioma de práctica';

  @override
  String currentValue(Object value) {
    return 'Actual: $value';
  }

  @override
  String get selectAppLanguage => 'Seleccionar idioma de la aplicación';

  @override
  String get selectPracticeLanguage => 'Seleccionar idioma de práctica';

  @override
  String get sameLanguageUnavailable =>
      'Es el idioma de la aplicación y no se puede seleccionar como idioma de práctica.';

  @override
  String get practiceLanguageConflict =>
      'Este idioma está seleccionado como idioma de práctica. Elige primero otro idioma de práctica.';

  @override
  String get cloudSync => 'Sincronización en la nube';

  @override
  String get reconnect => 'Volver a conectar';

  @override
  String get syncing => 'Sincronizando...';

  @override
  String get syncRecordingHistory => 'Sincronizar historial de grabaciones';

  @override
  String get downloadSettings => 'Descargar ajustes';

  @override
  String get saveSettings => 'Guardar ajustes';

  @override
  String get account => 'Cuenta';

  @override
  String get registerPremium => 'Obtener Premium';

  @override
  String get emailAddress => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get registerWithEmail => 'Registrarse con correo';

  @override
  String get registerCurrentData => 'Registrar estos datos con correo';

  @override
  String get signInWithEmail => 'Iniciar sesión con correo';

  @override
  String get forgotPassword => 'Olvidé mi contraseña';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get newPasswordPrompt => 'Establece una nueva contraseña.';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get updatePassword => 'Actualizar contraseña';

  @override
  String get show => 'Mostrar';

  @override
  String get hide => 'Ocultar';

  @override
  String get passwordResetSent => 'Correo de restablecimiento enviado.';
}
