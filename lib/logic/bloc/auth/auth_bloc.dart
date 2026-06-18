import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import 'package:snailywhim/data/repositories/auth_repository.dart';
import 'package:snailywhim/logic/bloc/auth/auth_event.dart';
import 'package:snailywhim/logic/bloc/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  AuthBloc({required this.repository}) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
  }
  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      final user = await repository.getCurrentUser();
      developer.log('Current User: ${user?.email}', name: 'AuthBloc');
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await repository.login(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user));
      developer.log('Login Success: ${user.email}', name: 'AuthBloc');
    } catch (e) {
      emit(AuthError(e.toString()));
      developer.log('Login Error: $e', name: 'AuthBloc');
    }
  }

  Future<void> _onRegister(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await repository.register(
        email: event.email,
        password: event.password,
        nama: event.nama,
      );
      emit(Unauthenticated());
      developer.log('Register Success', name: 'AuthBloc');
    }
    catch (e) {
      developer.log('Register Error: $e', name: 'AuthBloc');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    try {
      await repository.logout();
      emit(Unauthenticated());
      developer.log('Logout Success', name: 'AuthBloc');
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
