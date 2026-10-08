import 'package:url_launcher/url_launcher.dart';
import 'package:micro_lending_app/utils/formatters/phone_formatter.dart';

class LauncherUtils {
  LauncherUtils._();

  /// Opens the phone's dialer with the customer's number filled in.
  /// The user taps the call button themselves, so no CALL_PHONE
  /// permission is needed. Returns false if the device can't place calls
  /// (tablet without SIM, emulator), so the UI can show a message.
  static Future<bool> call(String phone) async {
    final uri = Uri(scheme: 'tel', path: PhoneFormatter.toE164(phone));
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}