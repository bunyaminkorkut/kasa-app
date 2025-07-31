import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasa_app/domain/group/expense_data.dart';

class ExpenseDetailPage extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailPage({Key? key, required this.expense}) : super(key: key);

  String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat.yMMMMd().add_Hm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Katılımcıları kopyala ve ödeme yapan en üstte olacak şekilde sırala
    final sortedParticipants = expense.participants.toList()
      ..sort((a, b) {
        if (a.userId == expense.payerId) return -1;
        if (b.userId == expense.payerId) return 1;
        return 0;
      });

    return Scaffold(
      appBar: AppBar(title: const Text('Harcamalar Detayı'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve tutar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    expense.paymentTitle.isNotEmpty
                        ? expense.paymentTitle
                        : 'Başlıksız Harcama',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${expense.amount.toStringAsFixed(2)} ₺',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Ödeme tarihi
            Text(
              'Ödeme Tarihi: ${formatDate(expense.paymentDate)}',
              style: TextStyle(color: Colors.grey[700]),
            ),

            const SizedBox(height: 12),

            // Ödeyen kişi
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade300,
                child: Text(
                  expense.payerName.isNotEmpty
                      ? expense.payerName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                expense.payerName.isNotEmpty
                    ? expense.payerName
                    : 'Bilinmeyen Ödeyen',
              ),
              subtitle: const Text('Ödeyen kişi'),
            ),

            const SizedBox(height: 16),

            // Açıklama notu
            if (expense.descriptionNote.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Açıklama',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(expense.descriptionNote),
                  const SizedBox(height: 16),
                ],
              ),

            // Fatura görseli (varsa)
            if (expense.billImageUrl.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fatura',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      expense.billImageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 100),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Katılımcılar listesi başlığı
            const Text(
              'Katılımcılar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),

            // Katılımcılar kartları, ödeme yapan kişi en üstte ve farklı renkte
            ...sortedParticipants.map((p) {
              final bool isPayer = p.userId == expense.payerId;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                color: isPayer ? Colors.green[100] : null,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isPayer
                        ? Colors.green
                        : p.paymentStatus == 'paid'
                        ? Colors.green[300]
                        : Colors.red[300],
                    child: Text(
                      p.userName.isNotEmpty ? p.userName[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    p.userName,
                    style: TextStyle(
                      fontWeight: isPayer ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: isPayer
                      ? const Text("Ödeme yapan")
                      : Text(
                          p.paymentStatus == 'paid' ? '✅ Ödendi' : '❌ Ödenmedi',
                          style: TextStyle(
                            color: p.paymentStatus == 'paid'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                  trailing: Text(
                    '${p.amountShare.toStringAsFixed(2)} ₺',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
