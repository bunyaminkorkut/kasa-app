import 'package:equatable/equatable.dart';

class GroupSendedRequestData extends Equatable {
  const GroupSendedRequestData({
    required this.groupId,
    required this.requestId,
    required this.groupName,
    required this.userName,
    required this.status,
    required this.email,
    required this.requestDate,
  });

  final int groupId;
  final int requestId;
  final String groupName;
  final String status;
  final String userName;
  final String email;
  final DateTime requestDate;

  GroupSendedRequestData copyWith({
    String? groupName,
    int? groupId,
    int? requestId,
    String? status,
    DateTime? requestDate,
    String? userName,
    String? email
  }) {
    return GroupSendedRequestData(
      groupName: groupName ?? this.groupName,
      groupId: groupId ?? this.groupId,
      requestId: requestId ?? this.requestId,
      status: status ?? this.status,
      requestDate: requestDate ?? this.requestDate,
      userName: userName?? this.userName,
      email: email ?? this.email
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'group_name': groupName,
      'group_id': groupId,
      'request_id': requestId,
      'status': status,
      'created_at': requestDate.millisecondsSinceEpoch ~/ 1000,
      'user_name': userName,
      'email': email
    };
  }

  factory GroupSendedRequestData.fromMap(Map<String, dynamic> map) {
    return GroupSendedRequestData(
      groupName: map['group_name'] as String,
      groupId: map['group_id'] as int,
      requestId: map['request_id'] as int,
      userName: map['fullname'] as String,
      status: map['request_status'] as String,
      requestDate: DateTime.fromMillisecondsSinceEpoch(
        (map['requested_at'] as int) * 1000,
      ),
      email: map['email'] as String,
    );
  }
  

  @override
  List<Object?> get props => [
    groupName,
    groupId,
    requestId,
    userName,
    status,
    requestDate,
    email,
  ];
}
