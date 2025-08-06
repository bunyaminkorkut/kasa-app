
import 'package:equatable/equatable.dart';

class AuthData extends Equatable {
  final String id;
  final String email;
  final String password;
  final String fullName;
  final String iban;

  const AuthData({
    required this.id,
    required this.email,
    required this.password,
    required this.fullName,
    required this.iban,
  });

  factory AuthData.fromMap(Map<String, dynamic> map) {
    return AuthData(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      fullName: map['fullName'] ?? '',
      iban: map['iban'] ?? '',
    );
  }

  @override
  List<Object> get props => [email, password, fullName, iban, id];

  @override
  String toString() {
    return 'AuthData(email: $email, password: $password, fullName: $fullName, iban: $iban, id: $id)';
  }
}
