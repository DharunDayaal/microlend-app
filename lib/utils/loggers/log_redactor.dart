import 'package:micro_lending_app/utils/formatters/phone_formatter.dart';

class LogRedactor {
  LogRedactor._();

  static const _secretKeys = {
    'password',
    'password_hash',
    'token',
    'access_token',
    'refresh_token',
    'authorization',
    'otp',
  };

  static const _phoneKeys = {'phone', 'phone_number'};

  /// Returns a copy of the map that is safe to log.
  /// Secrets become "***", phone numbers are masked, nested maps and lists
  /// are cleaned recursively.
  static dynamic clean(dynamic value) {
    if (value is Map) {
      return value.map((k, v) {
        final key = k.toString().toLowerCase();
        if (_secretKeys.contains(key)) return MapEntry(k, '***');
        if (_phoneKeys.contains(key) && v is String) {
          return MapEntry(k, PhoneFormatter.masked(v));
        }
        return MapEntry(k, clean(v));
      });
    }
    if (value is List) return value.map(clean).toList();
    return value;
  }
}
