import 'package:flutter/material.dart';
import 'auth_wrapper.dart';

/// Root navigator — login/logout resets the whole stack here.
class AppNavigator {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  /// Rebuilds the app shell (fixes stale Profile/Messages after login).
  static void resetToHome({int tab = 0}) {
    key.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => AuthWrapper(initialTab: tab)),
      (_) => false,
    );
  }
}
