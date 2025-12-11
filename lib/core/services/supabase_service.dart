import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/api_response.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late final SupabaseClient _client;

  Future<void> init() async {
    await Supabase.initialize(
      url: 'https://nmwixlmkyraxlhmkakoj.supabase.co',
      anonKey: 'sb_publishable__QzvQutc3m-HPSrl8NGy-w_UrxwiiOl',
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _client = Supabase.instance.client;
  }

  Session? get currentSession => _client.auth.currentSession;

  User? get currentUser => _client.auth.currentUser;

  bool get isLoggedIn => currentSession != null;

  Future<ApiResponse<User>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return ApiResponse.success(
          data: response.user!,
          message: 'Account created successfully',
        );
      } else {
        return ApiResponse.error(
          message: 'Failed to create account',
        );
      }
    } on AuthException catch (e) {
      return ApiResponse.error(
        message: e.message,
        statusCode: int.tryParse(e.statusCode ?? ''),
      );
    } catch (e) {
      return ApiResponse.error(
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return ApiResponse.success(
          data: response.user!,
          message: 'Logged in successfully',
        );
      } else {
        return ApiResponse.error(
          message: 'Failed to log in',
        );
      }
    } on AuthException catch (e) {
      return ApiResponse.error(
        message: e.message,
        statusCode: int.tryParse(e.statusCode ?? ''),
      );
    } catch (e) {
      return ApiResponse.error(
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<void>> signOut() async {
    try {
      await _client.auth.signOut();
      return ApiResponse.success(
        message: 'Logged out successfully',
      );
    } catch (e) {
      return ApiResponse.error(
        message: e.toString(),
      );
    }
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  SupabaseClient get client => _client;
}
