import 'package:url_launcher/url_launcher.dart';

class WhatsAppLauncher {
  /// Opens WhatsApp with the given phone number and message across Android, iOS, and Web.
  static Future<void> openWhatsApp({
    String phone = '252611112886',
    String message = 'Asc EMARA Support',
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final encodedMsg = Uri.encodeComponent(message);

    // Primary: https://wa.me link
    final Uri waMeUri = Uri.parse("https://wa.me/$cleanPhone?text=$encodedMsg");
    // Direct App scheme: whatsapp://send
    final Uri appUri = Uri.parse("whatsapp://send?phone=$cleanPhone&text=$encodedMsg");
    // Fallback: api.whatsapp.com link
    final Uri apiUri = Uri.parse("https://api.whatsapp.com/send?phone=$cleanPhone&text=$encodedMsg");

    try {
      if (await canLaunchUrl(waMeUri)) {
        await launchUrl(waMeUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    try {
      await launchUrl(waMeUri, mode: LaunchMode.externalApplication);
      return;
    } catch (_) {}

    try {
      await launchUrl(apiUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(apiUri);
      } catch (e) {
        // Ignore if unlaunchable
      }
    }
  }
}
