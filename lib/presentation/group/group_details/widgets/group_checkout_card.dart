import 'package:flutter/material.dart';
import 'package:kasa_app/domain/group/checkout_data.dart';
import 'package:kasa_app/domain/group/group_data.dart';

class GroupCheckoutCard extends StatelessWidget {
  final GroupData group;

  const GroupCheckoutCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final checkoutEntries = CheckoutData(
      debts: group.debts,
      credits: group.credits,
    ).mergeDebtsAndCredits();

    if (checkoutEntries.isEmpty) {
      return Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Henüz borç/alacak kaydı yok",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      );
    }

    // Toplam borç ve alacakları hesapla
    double totalDebt = 0;
    double totalCredit = 0;
    for (var entry in checkoutEntries) {
      totalDebt += entry.debtAmount;
      totalCredit += entry.creditAmount;
    }

    // Net tutar
    final netAmount = totalCredit - totalDebt;

    // Ödeme butonunda gösterilecek tutar (yalnızca net borç varsa)
    final double payAmount = netAmount < 0 ? netAmount.abs() : 0;

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            expansionTileTheme: const ExpansionTileThemeData(
              shape: RoundedRectangleBorder(),
              collapsedShape: RoundedRectangleBorder(),
            ),
          ),
          child: ExpansionTile(
            initiallyExpanded: false,
            tilePadding: const EdgeInsets.all(12),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.swap_horiz, color: Colors.green[600], size: 24),
            ),
            title: const Text(
              "Checkout (Borç/Alacak)",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            childrenPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            children: [
              ...checkoutEntries.map((entry) {
                final bool hasDebt = entry.debtAmount > 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          entry.fullname,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: entry.iban.isNotEmpty
                            ? Text(
                                "IBAN: ${entry.iban}",
                                style: const TextStyle(fontSize: 13),
                              )
                            : null,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (entry.creditAmount > 0)
                              Text(
                                "+${entry.creditAmount.toStringAsFixed(2)} ₺",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            if (entry.debtAmount > 0)
                              Text(
                                "-${entry.debtAmount.toStringAsFixed(2)} ₺",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Eğer net borç varsa ödeme butonu göster
                      if (netAmount < 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              print('${entry.fullname} için toplam borç ödemesi başlatıldı: $payAmount ₺');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: Text("Öde ${payAmount.toStringAsFixed(2)} ₺"),
                          ),
                        ),

                      // Eğer net alacak varsa buton yerine toplam alacak yazısı
                      if (netAmount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Toplam Alacak: +${netAmount.toStringAsFixed(2)} ₺",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
