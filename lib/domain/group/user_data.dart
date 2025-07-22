import 'package:equatable/equatable.dart';

class UserData extends Equatable {
  const UserData({
    required this.id,
    required this.fullname,
    required this.email,
  });

  final String id;
  final String fullname;
  final String email;

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'] as String,
      fullname: map['fullname'] as String,
      email: map['email'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullname': fullname,
      'email': email,
    };
  }

  @override
  List<Object?> get props => [id, fullname, email];
}
