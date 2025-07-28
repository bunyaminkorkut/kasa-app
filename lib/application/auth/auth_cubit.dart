import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasa_app/infrastructure/auth/impl_auth_service.dart';

class AuthState {
  final bool isAuthenticated;
  final String? jwt;

  const AuthState({required this.isAuthenticated, this.jwt});

  AuthState copyWith({bool? isAuthenticated, String? jwt}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      jwt: jwt ?? this.jwt,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  final FlutterSecureStorage secureStorage;
  final AuthService _authService = AuthService();

  AuthCubit({required this.secureStorage})
    : super(const AuthState(isAuthenticated: false));

  /// E-posta/şifre ile giriş
  Future<void> login(String email, String password) async {
    try {
      final jwt = await _authService.login(email: email, password: password);
      await secureStorage.write(key: 'jwt', value: jwt);
      emit(state.copyWith(isAuthenticated: true, jwt: jwt));
    } catch (e) {
      emit(state.copyWith(isAuthenticated: false, jwt: null));
    }
  }

  /// Kayıt
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String iban,
  }) async {
    try {
      final jwt = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        iban: iban,
      );
      await secureStorage.write(key: 'jwt', value: jwt);
      emit(state.copyWith(isAuthenticated: true, jwt: jwt));
    } catch (e) {
      emit(state.copyWith(isAuthenticated: false, jwt: null));
    }
  }

  /// Oturum kontrolü
  Future<void> checkAuthentication() async {
    final jwt = await secureStorage.read(key: 'jwt');
    if (jwt != null && jwt.isNotEmpty) {
      emit(state.copyWith(isAuthenticated: true, jwt: jwt));
    } else {
      emit(state.copyWith(isAuthenticated: false, jwt: null));
    }
  }

  /// Google ile giriş
  Future<void> loginWithGoogle() async {
    try {
      final jwt = await _authService.signInWithGoogle();
      print(jwt);
      await secureStorage.write(key: 'jwt', value: jwt);
      emit(state.copyWith(isAuthenticated: true, jwt: jwt));
    } catch (e) {
      print(e);
      emit(state.copyWith(isAuthenticated: false, jwt: null));
    }
  }

  /// Çıkış
  Future<void> logout() async {
    await secureStorage.delete(key: 'jwt');
    emit(state.copyWith(isAuthenticated: false, jwt: null));
  }
}
