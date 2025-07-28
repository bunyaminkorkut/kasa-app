import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kasa_app/domain/auth/auth_data.dart';
import 'package:kasa_app/infrastructure/auth/impl_auth_service.dart';

class AuthState {
  final bool isAuthenticated;
  final String? jwt;
  final AuthData? user;

  const AuthState({required this.isAuthenticated, this.jwt, this.user});

  AuthState copyWith({bool? isAuthenticated, String? jwt, AuthData? user}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      jwt: jwt ?? this.jwt,
      user: user,
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

  Future<void> logout() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Google hesabını sıfırla (disconnect daha etkili)
      final isSignedIn = await googleSignIn.isSignedIn();
      if (isSignedIn) {
        await googleSignIn.disconnect();
      }

      // Firebase çıkışı
      await FirebaseAuth.instance.signOut();

      // JWT'yi temizle
      await secureStorage.delete(key: 'jwt');

      emit(state.copyWith(isAuthenticated: false, jwt: null));
    } catch (e) {
      print('Çıkış hatası: $e');
      throw Exception('Çıkış yapılamadı');
    }
  }

  Future<void> getUser(String jwt) async {
    try {
      final AuthData user = await _authService.getMe(jwt: jwt);
      emit(state.copyWith(isAuthenticated: true, jwt: jwt, user: user));
    } catch (e) {
      print(e);
      emit(state.copyWith(isAuthenticated: false, jwt: null, user: null));
      throw Exception('Kullanıcı bilgisi alınamadı');
    }
  }

  Future<void> updateIban(String newIban) async {
    try {
      final updatedUser = await _authService.updateIban(
        newIban: newIban,
        jwt: state.jwt!,
      );
      emit(state.copyWith(user: updatedUser));
    } catch (e) {
      print('IBAN güncellenemedi: $e');
    }
  }

  Future<void> updateFullName(String newName) async {
    try {
      final updatedUser = await _authService.updateFullName(
        newFullName: newName,
        jwt: state.jwt!,
      );
      emit(state.copyWith(user: updatedUser));
    } catch (e) {
      print('Ad soyad güncellenemedi: $e');
    }
  }
}
