
import 'package:equatable/equatable.dart';

class AuthData extends Equatable {
  final String email;
  final String password;
  final String fullName;
  final String iban;

  const AuthData({
    required this.email,
    required this.password,
    required this.fullName,
    required this.iban,
  });

  @override
  List<Object> get props => [email, password, fullName, iban];

  @override
  String toString() {
    return 'AuthData(email: $email, password: $password, fullName: $fullName, iban: $iban)';
  }
}