import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ConnectivityService extends ChangeNotifier {
  bool _isConnected = true;
  bool _isChecking = false;
  Timer? _timer;

  bool get isConnected => _isConnected;
  bool get isChecking => _isChecking;

  ConnectivityService() {
    _startPeriodicCheck();
  }

  void _startPeriodicCheck() {
    checkConnection();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) {
      checkConnection();
    });
  }

  Future<bool> checkConnection() async {
    if (_isChecking) return _isConnected;
    _isChecking = true;
    notifyListeners();

    bool hasNet = false;
    try {
      if (kIsWeb) {
        // Web check using small HTTP HEAD request
        final res = await http.get(Uri.parse('https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=10')).timeout(const Duration(seconds: 4));
        hasNet = res.statusCode >= 200 && res.statusCode < 500;
      } else {
        // Native check using Socket lookup
        final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 4));
        hasNet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      }
    } catch (_) {
      hasNet = false;
    }

    if (_isConnected != hasNet) {
      _isConnected = hasNet;
    }

    _isChecking = false;
    notifyListeners();
    return _isConnected;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
