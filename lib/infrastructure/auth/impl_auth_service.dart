import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:kasa_app/app_config.dart';
import 'package:kasa_app/domain/auth/auth_data.dart';
import 'package:kasa_app/domain/auth/user.dart';

class AuthService implements IUserRepository {
  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final hostUri = Uri.parse(KasaAppConfig().apiHost);
    final uri = hostUri.resolveUri(
      Uri(path: '/login'), // API endpoint for login
    );
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['jwtToken'] as String;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  @override
  Future<String> register({
    required String email,
    required String fullName,
    required String iban,
    required String password,
  }) async {
    final hostUri = Uri.parse(KasaAppConfig().apiHost);
    final uri = hostUri.resolveUri(Uri(path: '/register'));
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'fullname': fullName,
        'iban': iban,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['jwtToken'] as String;
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  @override
  Future<String> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
    );

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) return "";

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(credential);

    final hostUri = Uri.parse(KasaAppConfig().apiHost);
    final uri = hostUri.resolveUri(Uri(path: '/login-google'));
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': userCredential.user?.email,
        'fullname': userCredential.user?.displayName,
        'userId': userCredential.user?.uid,
        'idToken': await userCredential.user?.getIdToken(),
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['token'] as String;
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  @override
  Future<AuthData> getMe({required String jwt}) async {
    final hostUri = Uri.parse(KasaAppConfig().apiHost);
    final uri = hostUri.resolveUri(Uri(path: '/get-me'));

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return AuthData.fromMap(decoded);
    } else {
      throw Exception(
        'Kullanıcı bilgisi alınamadı: ${response.statusCode} - ${response.body}',
      );
    }
  }

  @override
  Future<AuthData> updateIban({
    required String newIban,
    required String jwt,
  }) async {
    final hostUri = Uri.parse(KasaAppConfig().apiHost);
    final uri = hostUri.resolve('/update-user');

    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({'iban': newIban}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return AuthData.fromMap(json);
    } else {
      throw Exception('IBAN güncelleme başarısız: ${response.body}');
    }
  }

  @override
  Future<AuthData> updateFullName({
    required String newFullName,
    required String jwt,
  }) async {
    final hostUri = Uri.parse(KasaAppConfig().apiHost);
    final uri = hostUri.resolve('/update-user');

    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({'fullName': newFullName}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return AuthData.fromMap(json);
    } else {
      throw Exception('Ad Soyad güncelleme başarısız: ${response.body}');
    }
  }

  @override
  Future<bool> sendFCMToken({
    required String fcmToken,
    required String jwt,
  }) async {
    final hostUri = Uri.parse(KasaAppConfig().apiHost);
    final uri = hostUri.resolve('/save-fcm-token');
    print(fcmToken);
    print(jwt);
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({'token': fcmToken}),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return true;
    } else {
      throw Exception('FCM token gönderme başarısız: ${response.body}');
    }
  }
}
