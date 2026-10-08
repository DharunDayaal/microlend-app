class PasswordStrength {
  PasswordStrength._();

  /// 0 = empty, 1 = weak, 2 = fair, 3 = good, 4 = strong.
  /// One point each for: 8+ characters, upper and lower case, a digit, a symbol.
  /// Passwords under 6 characters never score above 1.
  static int score(String password) {
    if (password.isEmpty) return 0;
    if (password.length < 6) return 1;

    var points = 0;
    if (password.length >= 8) points++;
    if (RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[A-Z]').hasMatch(password)) {
      points++;
    }
    if (RegExp(r'\d').hasMatch(password)) points++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) points++;

    return points.clamp(1, 4);
  }
}
