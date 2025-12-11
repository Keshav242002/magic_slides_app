import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<SignUpEvent>(_onSignUp);
    on<SignInEvent>(_onSignIn);
    on<SignOutEvent>(_onSignOut);
    on<CheckLoginStatusEvent>(_onCheckLoginStatus);
  }

  Future<void> _onSignUp(
    SignUpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final response = await _authRepository.signUp(
      email: event.email,
      password: event.password,
    );

    if (response.isSuccess && response.data != null) {
      emit(AuthAuthenticated(user: response.data!));
    } else {
      emit(AuthError(message: response.message ?? 'Sign up failed'));
    }
  }

  Future<void> _onSignIn(
    SignInEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final response = await _authRepository.signIn(
      email: event.email,
      password: event.password,
    );

    if (response.isSuccess && response.data != null) {
      emit(AuthAuthenticated(user: response.data!));
    } else {
      emit(AuthError(message: response.message ?? 'Sign in failed'));
    }
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final response = await _authRepository.signOut();

    if (response.isSuccess) {
      emit(const AuthUnauthenticated());
    } else {
      emit(AuthError(message: response.message ?? 'Sign out failed'));
    }
  }

  Future<void> _onCheckLoginStatus(
    CheckLoginStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = _authRepository.isLoggedIn();
    
    if (isLoggedIn) {
      final user = _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } else {
      emit(const AuthUnauthenticated());
    }
  }
}
