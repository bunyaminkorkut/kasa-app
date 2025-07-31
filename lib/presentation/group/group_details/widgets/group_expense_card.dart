import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasa_app/domain/group/group_data.dart';
import 'package:kasa_app/presentation/group/expense_detail/expense_detail_page.dart';

class GroupExpensesCard extends StatelessWidget {
  final GroupData group;

  const GroupExpensesCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    if (group.expenses.isEmpty) {
      return Card(
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "Henüz gider yok",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),
      );
    }

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
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                color: Colors.orange[600],
                size: 24,
              ),
            ),
            title: Text(
              "Giderler (${group.expenses.length})",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            childrenPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            children: group.expenses.asMap().entries.map((entry) {
              final index = entry.key;
              final expense = entry.value;
              final formattedDate = DateFormat('dd MMM yyyy').format(
                DateTime.fromMillisecondsSinceEpoch(expense.paymentDate * 1000),
              );

              return Column(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ExpenseDetailPage(expense: expense),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              expense.paymentTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: expense.descriptionNote.isNotEmpty
                                ? Text(expense.descriptionNote)
                                : null,
                            trailing: Text(
                              "${expense.amount.toStringAsFixed(2)} ₺",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              top: 4,
                              right: 16,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 14,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Ödeyen: ${expense.payerName}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (expense.billImageUrl.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 16, top: 12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  expense.billImageUrl,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // 🔹 Araya boşluk eklendi, sonuncuda eklenmesin diye koşul koyduk
                  if (index != group.expenses.length - 1)
                    const SizedBox(height: 6),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
