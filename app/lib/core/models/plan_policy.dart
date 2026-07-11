import 'user_role.dart';

class PlanPolicy {
  const PlanPolicy._();

  static const freeDailyAiCorrections = 5;
  static const freeAudioStorageBytes = 200 * 1024 * 1024;

  static bool hasUnlimitedAiCorrections(UserRole role) {
    return role.canUsePremiumFeature;
  }

  static bool hasUnlimitedStorage(UserRole role) {
    return role.canUsePremiumFeature;
  }

  static int? dailyAiCorrectionLimit(UserRole role) {
    return hasUnlimitedAiCorrections(role) ? null : freeDailyAiCorrections;
  }

  static int? audioStorageLimitBytes(UserRole role) {
    return hasUnlimitedStorage(role) ? null : freeAudioStorageBytes;
  }
}
