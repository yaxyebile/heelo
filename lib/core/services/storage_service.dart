import 'package:hive_flutter/hive_flutter.dart';

/// Local session storage only (current user id). All data lives in Supabase.
class StorageService {
  static const String settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(settingsBox);
  }

  static String? getCurrentUserId() {
    final settings = Hive.box(settingsBox);
    return settings.get('current_user_id') as String?;
  }

  static Future<void> setCurrentUserId(String? userId) async {
    final settings = Hive.box(settingsBox);
    if (userId == null) {
      await settings.delete('current_user_id');
    } else {
      await settings.put('current_user_id', userId);
    }
  }

  /// Skip heavy seed checks after first successful DB detection.
  static bool isSeedVerified() {
    final settings = Hive.box(settingsBox);
    return settings.get('seed_verified', defaultValue: false) as bool;
  }

  static Future<void> setSeedVerified() async {
    await Hive.box(settingsBox).put('seed_verified', true);
  }
}
