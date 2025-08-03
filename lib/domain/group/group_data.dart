import 'package:equatable/equatable.dart';
import 'package:kasa_app/domain/group/checkout_data.dart';
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
    required this.debts,
    required this.credits,
    this.groupToken
  });

  final String name;
  final int id;
  final DateTime createdDate;
  final UserData creator;
  final List<UserData> members;
  final bool isAdmin;
  final List<GroupSendedRequestData> pendingRequests;
  final List<Expense> expenses;
  final List<DebtData> debts;
  final List<CreditData> credits;
  final String? groupToken;

  GroupData copyWith({
    String? name,
    int? id,
    DateTime? createdDate,
    UserData? creator,
    List<UserData>? members,
    bool? isAdmin,
    List<GroupSendedRequestData>? pendingRequests,
    List<Expense>? expenses,
    List<DebtData>? debts,
    List<CreditData>? credits,
    String? groupToken,
  }) {
    return GroupData(
      name: name ?? this.name,
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      creator: creator ?? this.creator,
      members: members ?? this.members,
      isAdmin: isAdmin ?? this.isAdmin,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      expenses: expenses ?? this.expenses,
      debts: debts ?? this.debts,
      credits: credits ?? this.credits,
      groupToken: groupToken ?? this.groupToken,
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
      'debts': debts.map((e) => e.toJson()).toList(),
      'credits': credits.map((e) => e.toJson()).toList(),
      'group_token': groupToken, // Optional field
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
              ?.map((e) => GroupSendedRequestData.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      isAdmin: map['is_admin'] as bool? ?? false,
      expenses: (map['expenses'] as List?)
              ?.map((e) => Expense.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      debts: (map['debts'] as List?)
              ?.where((e) => (e as Map<String, dynamic>)['status'] != 'paid')
              .map((e) => DebtData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      credits: (map['credits'] as List?)
              ?.where((e) => (e as Map<String, dynamic>)['status'] != 'paid')
              .map((e) => CreditData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      groupToken: map['group_token'] as String?, // Optional field
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
        debts,
        credits,
        isAdmin,
        groupToken
      ];
}
