import 'package:firebase_auth/firebase_auth.dart';
import 'package:kasa_app/domain/auth/auth_data.dart';

abstract class IUserRepository {
  Future<String> login({required String email, required String password});

  Future<String> register({
    required String email,
    required String password,
    required String fullName,
    required String iban,
  });
  Future<String> signInWithGoogle(); // değiştirildi
  Future<String> signInWithApple(); // değiştirildi

  Future<AuthData> getMe({required String jwt});

  Future<AuthData> updateIban({required String newIban, required String jwt});
  
  Future<AuthData> updateFullName({
    required String newFullName,
    required String jwt,
  });
  Future<void> sendFCMToken({
    required String fcmToken,
    required String jwt,
  });

}
