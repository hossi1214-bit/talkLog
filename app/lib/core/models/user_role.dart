enum UserRole {
  free('FREE', '無料ユーザー'),
  premium('PREMIUM', '有料ユーザー'),
  tester('TESTER', 'βテスター'),
  admin('ADMIN', '管理者');

  const UserRole(this.value, this.label);

  final String value;
  final String label;

  bool get canUsePremiumFeature => switch (this) {
    UserRole.premium || UserRole.tester || UserRole.admin => true,
    UserRole.free => false,
  };

  bool get isAdmin => this == UserRole.admin;

  static UserRole fromDbValue(Object? value) {
    final normalized = value?.toString().trim().toUpperCase();
    return UserRole.values.firstWhere(
      (role) => role.value == normalized,
      orElse: () => UserRole.free,
    );
  }
}

bool canUsePremiumFeature(String role) {
  return UserRole.fromDbValue(role).canUsePremiumFeature;
}

bool isAdmin(String role) {
  return UserRole.fromDbValue(role).isAdmin;
}
