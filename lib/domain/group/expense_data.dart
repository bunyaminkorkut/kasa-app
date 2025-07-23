import 'package:equatable/equatable.dart';
import 'package:kasa_app/domain/group/sended_request_data.dart';
import 'user_data.dart';
import 'request_data.dart';

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

class Expense extends Equatable {
  const Expense({
    required this.expenseId,
    required this.payerId,
    required this.amount,
    required this.descriptionNote,
    required this.paymentTitle,
    required this.paymentDate,
    required this.billImageUrl,
    required this.participants,
  });

  final int expenseId;
  final String payerId;
  final double amount;
  final String descriptionNote;
  final String paymentTitle;
  final int paymentDate; // Unix timestamp
  final String billImageUrl;
  final List<ExpenseParticipant> participants;

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      expenseId: map['expense_id'] as int,
      payerId: map['payer_id'] as String,
      amount: (map['amount'] as num).toDouble(),
      descriptionNote: map['description_note'] as String? ?? '',
      paymentTitle: map['payment_title'] as String? ?? '',
      paymentDate: map['payment_date'] as int? ?? 0,
      billImageUrl: map['bill_image_url'] as String? ?? '',
      participants: (map['participants'] as List?)
              ?.map((e) => ExpenseParticipant.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'expense_id': expenseId,
      'payer_id': payerId,
      'amount': amount,
      'description_note': descriptionNote,
      'payment_title': paymentTitle,
      'payment_date': paymentDate,
      'bill_image_url': billImageUrl,
      'participants': participants.map((e) => e.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        expenseId,
        payerId,
        amount,
        descriptionNote,
        paymentTitle,
        paymentDate,
        billImageUrl,
        participants,
      ];
}

class ExpenseParticipant extends Equatable {
  const ExpenseParticipant({
    required this.userId,
    required this.amountShare,
    required this.paymentStatus,
  });

  final String userId;
  final double amountShare;
  final String paymentStatus;

  factory ExpenseParticipant.fromMap(Map<String, dynamic> map) {
    return ExpenseParticipant(
      userId: map['user_id'] as String,
      amountShare: (map['amount_share'] as num).toDouble(),
      paymentStatus: map['payment_status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'amount_share': amountShare,
      'payment_status': paymentStatus,
    };
  }

  @override
  List<Object?> get props => [
        userId,
        amountShare,
        paymentStatus,
      ];
}
