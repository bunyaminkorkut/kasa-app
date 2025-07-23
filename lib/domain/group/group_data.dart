import 'package:equatable/equatable.dart';
import 'package:kasa_app/domain/group/expense_data.dart';
import 'package:kasa_app/domain/group/sended_request_data.dart';
import 'user_data.dart';

class GroupData extends Equatable {
  const GroupData({
    required this.name,
    required this.id,
    required this.createdDate,
    required this.creator,
    required this.members,
    required this.isAdmin,
    required this.pendingRequests,
    required this.expenses,
  });

  final String name;
  final int id;
  final DateTime createdDate;
  final UserData creator;
  final List<UserData> members;
  final bool isAdmin;
  final List<GroupSendedRequestData> pendingRequests;
  final List<Expense> expenses;

  GroupData copyWith({
    String? name,
    int? id,
    DateTime? createdDate,
    UserData? creator,
    List<UserData>? members,
    List<GroupSendedRequestData>? pendingRequests,
    bool? isAdmin,
    List<Expense>? expenses,
  }) {
    return GroupData(
      name: name ?? this.name,
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      creator: creator ?? this.creator,
      members: members ?? this.members,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      isAdmin: isAdmin ?? this.isAdmin,
      expenses: expenses ?? this.expenses,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdDate.millisecondsSinceEpoch ~/ 1000,
      'creator': creator.toMap(),
      'members': members.map((e) => e.toMap()).toList(),
      'pending_requests': pendingRequests.map((e) => e.toMap()).toList(),
      'is_admin': isAdmin,
      'expenses': expenses.map((e) => e.toMap()).toList(),
    };
  }

  factory GroupData.fromMap(Map<String, dynamic> map) {
    return GroupData(
      name: map['name'] as String? ?? '',
      id: map['id'] as int? ?? 0,
      createdDate: DateTime.fromMillisecondsSinceEpoch(
        (map['created_at'] as int) * 1000,
      ),
      creator: UserData.fromMap(map['creator'] as Map<String, dynamic>),
      members: (map['members'] as List?)
              ?.map((e) => UserData.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      pendingRequests: (map['pending_requests'] as List?)
              ?.map(
                (e) => GroupSendedRequestData.fromMap(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      isAdmin: map['is_admin'] as bool? ?? false,
      expenses: (map['expenses'] as List?)
              ?.map((e) => Expense.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        createdDate,
        creator,
        members,
        pendingRequests,
        expenses,
      ];
}

