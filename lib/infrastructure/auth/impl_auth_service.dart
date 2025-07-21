import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:kasa_app/app_config.dart';
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
}
