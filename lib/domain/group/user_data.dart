import 'package:equatable/equatable.dart';

class UserData extends Equatable {
  const UserData({
    required this.id,
    required this.fullname,
    required this.email,
    this.totalShare = 0.0,
  });

  final String id;
  final String fullname;
  final String email;
  final double totalShare;

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'] as String,
      fullname: map['fullname'] as String,
      email: map['email'] as String,
      totalShare: map['total_share'] == 0
          ? 0.0
          : map['total_share'] as double? ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullname': fullname,
      'email': email,
      'total_share': totalShare,
    };
  }

  @override
  List<Object?> get props => [id, fullname, email, totalShare];
}
