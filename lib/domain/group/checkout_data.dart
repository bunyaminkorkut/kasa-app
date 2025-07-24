class CheckoutEntry {
  final String userId;
  final String fullname;
  final double debtAmount;
  final double creditAmount;
  final String iban;

  CheckoutEntry({
    required this.userId,
    required this.fullname,
    required this.debtAmount,
    required this.creditAmount,
    required this.iban,
  });
}

class CheckoutData {
  final List<DebtData> debts;
  final List<CreditData> credits;

  CheckoutData({
    required this.debts,
    required this.credits,
  });

  List<CheckoutEntry> mergeDebtsAndCredits() {
  final Map<String, CheckoutEntry> result = {};

  // Borçları birikimli ekle
  for (final debt in debts) {
    if (result.containsKey(debt.userId)) {
      final existing = result[debt.userId]!;
      result[debt.userId] = CheckoutEntry(
        userId: existing.userId,
        fullname: existing.fullname,
        debtAmount: existing.debtAmount + debt.amount,
        creditAmount: existing.creditAmount,
        iban: debt.iban.isNotEmpty ? debt.iban : existing.iban,
      );
    } else {
      result[debt.userId] = CheckoutEntry(
        userId: debt.userId,
        fullname: debt.userName,
        debtAmount: debt.amount,
        creditAmount: 0.0,
        iban: debt.iban,
      );
    }
  }

  // Alacakları birikimli ekle/güncelle
  for (final credit in credits) {
    if (result.containsKey(credit.userId)) {
      final existing = result[credit.userId]!;
      result[credit.userId] = CheckoutEntry(
        userId: existing.userId,
        fullname: existing.fullname,
        debtAmount: existing.debtAmount,
        creditAmount: existing.creditAmount + credit.amount,
        iban: credit.iban.isNotEmpty ? credit.iban : existing.iban,
      );
    } else {
      result[credit.userId] = CheckoutEntry(
        userId: credit.userId,
        fullname: credit.userName,
        debtAmount: 0.0,
        creditAmount: credit.amount,
        iban: credit.iban,
      );
    }
  }

  return result.values.toList();
}

}

class DebtData {
  final String userId;
  final String userName;
  final double amount;
  final String iban;

  DebtData({
    required this.userId,
    required this.userName,
    required this.amount,
    required this.iban,
  });

  factory DebtData.fromJson(Map<String, dynamic> json) {
    return DebtData(
      userId: json['user_id'],
      userName: json['username'] ?? json['user_name'],
      amount: (json['amount'] as num).toDouble(),
      iban: json['iban'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'user_name': userName,
        'amount': amount,
        'iban': iban,
      };
}

class CreditData {
  final String userId;
  final String userName;
  final double amount;
  final String iban;

  CreditData({
    required this.userId,
    required this.userName,
    required this.amount,
    required this.iban,
  });

  factory CreditData.fromJson(Map<String, dynamic> json) {
    return CreditData(
      userId: json['user_id'],
      userName: json['username'] ?? json['user_name'],
      amount: (json['amount'] as num).toDouble(),
      iban: json['iban'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'user_name': userName,
        'amount': amount,
        'iban': iban,
      };
}
