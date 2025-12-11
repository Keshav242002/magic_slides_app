import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/api_response.dart';
import '../../core/services/supabase_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/constants/app_constants.dart';

class AuthRepository {
  final SupabaseService _supabaseService = SupabaseService();
  final StorageService _storageService = StorageService();

  Future<ApiResponse<User>> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _supabaseService.signUp(
      email: email,
      password: password,
    );

    if (response.isSuccess && response.data != null) {
      await _storageService.saveBool(AppConstants.keyIsLoggedIn, true);
      await _storageService.saveString(AppConstants.keyUserEmail, email);
    }

    return response;
  }

  Future<ApiResponse<User>> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabaseService.signIn(
      email: email,
      password: password,
    );

    if (response.isSuccess && response.data != null) {
      await _storageService.saveBool(AppConstants.keyIsLoggedIn, true);
      await _storageService.saveString(AppConstants.keyUserEmail, email);
    }

    return response;
  }

  Future<ApiResponse<void>> signOut() async {
    final response = await _supabaseService.signOut();

    if (response.isSuccess) {
      await _storageService.remove(AppConstants.keyIsLoggedIn);
      await _storageService.remove(AppConstants.keyUserEmail);
    }

    return response;
  }

  bool isLoggedIn() {
    final hasSession = _supabaseService.isLoggedIn;
    final isStoredLoggedIn =
        _storageService.getBool(AppConstants.keyIsLoggedIn) ?? false;
    return hasSession && isStoredLoggedIn;
  }

  String? getCurrentUserEmail() {
    return _supabaseService.currentUser?.email ??
        _storageService.getString(AppConstants.keyUserEmail);
  }

  User? getCurrentUser() {
    return _supabaseService.currentUser;
  }

  Stream<AuthState> get authStateChanges =>
      _supabaseService.authStateChanges;
}
