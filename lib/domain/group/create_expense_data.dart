import 'package:equatable/equatable.dart';

class ExpenseUserData extends Equatable {
  final String userId;
  final double? amount; // Opsiyonel, null ise eşit bölüşüm varsayılır

  const ExpenseUserData({
    required this.userId,
    this.amount,
  });

  factory ExpenseUserData.fromJson(Map<String, dynamic> json) {
    return ExpenseUserData(
      userId: json['user_id'] as String,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        if (amount != null) 'amount': amount,
      };

  @override
  List<Object?> get props => [userId, amount];
}

class CreateExpenseData extends Equatable {
  final int groupId;
  final double totalAmount;
  final String note;
  final String paymentTitle;
  final List<ExpenseUserData> users;
  final String? billImageUrl; // Opsiyonel

  const CreateExpenseData({
    required this.groupId,
    required this.totalAmount,
    required this.note,
    required this.paymentTitle,
    required this.users,
    this.billImageUrl,
  });

  factory CreateExpenseData.fromJson(Map<String, dynamic> json) {
    final usersJson = json['users'] as List<dynamic>;
    return CreateExpenseData(
      groupId: json['group_id'] as int,
      totalAmount: (json['total_amount'] as num).toDouble(),
      note: json['note'] as String,
      paymentTitle: json['payment_title'] as String,
      billImageUrl: json['bill_image_url'] as String?,
      users: usersJson
          .map((e) => ExpenseUserData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'group_id': groupId,
        'total_amount': totalAmount,
        'note': note,
        'payment_title': paymentTitle,
        if (billImageUrl != null) 'bill_image_url': billImageUrl,
        'users': users.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props =>
      [groupId, totalAmount, note, paymentTitle, users, billImageUrl];
}
