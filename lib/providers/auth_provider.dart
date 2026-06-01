import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/navigation/app_navigator.dart';
import '../core/services/storage_service.dart';
import '../core/services/supabase_service.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _initError;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get initError => _initError;

  AuthProvider() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userId = StorageService.getCurrentUserId();
      if (userId != null) {
        _currentUser = await SupabaseService.fetchProfileById(userId);
      }
    } catch (e) {
      _initError = e.toString();
      debugPrint('AuthProvider load: $e');
    }
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await SupabaseService.loginProfile(email, password);
      if (user != null) {
        if (user.isBanned) {
          _isLoading = false;
          notifyListeners();
          return 'Akoonkaaga waa la xayiray. La xiriir admin.';
        }
        _currentUser = user;
        await StorageService.setCurrentUserId(user.id);
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Server khalad: $e';
    }

    _isLoading = false;
    notifyListeners();
    return 'Email ama password waa khalad';
  }

  Future<String?> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (await SupabaseService.emailExists(email)) {
        _isLoading = false;
        notifyListeners();
        return 'Email hormar lagu diwaan-geliyay';
      }

      final newUser = AppUser(
        id: const Uuid().v4(),
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: UserRole.user,
      );
      await SupabaseService.upsertProfile(newUser);
      _currentUser = newUser;
      await StorageService.setCurrentUserId(newUser.id);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Server khalad: $e';
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<String?> adminRegisterUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? storeId,
  }) async {
    try {
      if (await SupabaseService.emailExists(email)) {
        return 'Email horay u jira';
      }

      final newUser = AppUser(
        id: const Uuid().v4(),
        name: name,
        email: email,
        password: password,
        role: role,
        storeId: storeId,
      );
      await SupabaseService.upsertProfile(newUser);
      notifyListeners();
      return null;
    } catch (e) {
      return 'Server khalad: $e';
    }
  }

  Future<void> assignStoreToUser(String userId, String storeId) async {
    try {
      await SupabaseService.updateProfileStore(userId, storeId);
      if (_currentUser?.id == userId) {
        _currentUser = await SupabaseService.fetchProfileById(userId);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('assignStoreToUser: $e');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await StorageService.setCurrentUserId(null);
    notifyListeners();
    AppNavigator.resetToHome();
  }
}
