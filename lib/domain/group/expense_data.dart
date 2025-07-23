import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  const Expense({
    required this.expenseId,
    required this.payerId,
    required this.payerName,
    required this.groupId,
    required this.amount,
    required this.descriptionNote,
    required this.paymentTitle,
    required this.paymentDate,
    required this.billImageUrl,
    required this.participants,
  });

  final int expenseId;
  final int groupId;
  final String payerId;
  final String payerName;
  final double amount;
  final String descriptionNote;
  final String paymentTitle;
  final int paymentDate; // Unix timestamp
  final String billImageUrl;
  final List<ExpenseParticipant> participants;

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      expenseId: map['expense_id'] as int,
      groupId: map['group_id'] as int,
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
      payerName: map['payer_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'expense_id': expenseId,
      'payer_id': payerId,
      'amount': amount,
      'group_id': groupId,
      'payer_name':payerName,
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
        groupId,
        payerName
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
