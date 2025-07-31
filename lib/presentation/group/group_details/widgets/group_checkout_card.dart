import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasa_app/application/group_bloc/group_bloc.dart';
import 'package:kasa_app/domain/group/checkout_data.dart';
import 'package:kasa_app/domain/group/group_data.dart';

class GroupCheckoutCard extends StatelessWidget {
  final GroupData group;

  const GroupCheckoutCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        final checkoutEntries = CheckoutData(
          debts: group.debts,
          credits: group.credits,
        ).mergeDebtsAndCredits();

        if (checkoutEntries.isEmpty) {
          return _buildEmptyCard();
        }

        final double totalDebt = checkoutEntries.fold(
          0,
          (sum, e) => sum + e.debtAmount,
        );
        final double totalCredit = checkoutEntries.fold(
          0,
          (sum, e) => sum + e.creditAmount,
        );
        final double netAmount = totalCredit - totalDebt;

        return Card(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                leading: _buildIcon(),
                title: const Text(
                  "Checkout (Borç/Alacak)",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                childrenPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                children: [
                  ...checkoutEntries.map((entry) {
                    final bool hasDebt = entry.debtAmount > 0;
                    final double payAmount = hasDebt ? entry.debtAmount : 0;

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

                          // ✅ Ödeme Butonu
                          if (entry.creditAmount - entry.debtAmount < 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: ElevatedButton(
                                onPressed: state.isPayingExpense
                                    ? null
                                    : () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            title: const Text("Ödeme Bilgisi"),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildCopyableText(
                                                  ctx,
                                                  "Alıcı",
                                                  entry.fullname,
                                                ),
                                                const SizedBox(height: 12),
                                                entry.iban.isNotEmpty
                                                    ? _buildCopyableText(
                                                        ctx,
                                                        "IBAN",
                                                        entry.iban,
                                                      )
                                                    : const Text(
                                                        "IBAN bilgisi mevcut değil.",
                                                      ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text("İptal"),
                                              ),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  Navigator.pop(ctx, true);
                                                },
                                                child: const Text(
                                                  "Ödemeyi Onayla",
                                                ),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed == true &&
                                            context.mounted) {
                                          // İkinci emin misiniz popupı
                                          final reallyConfirmed =
                                              await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                  title: const Text(
                                                    "Emin misiniz?",
                                                  ),
                                                  content: const Text(
                                                    "Bu ödemeyi kaydetmek istediğinize emin misiniz?",
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        "Vazgeç",
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            true,
                                                          ),
                                                      child: const Text(
                                                        "Evet, eminim",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );

                                          if (reallyConfirmed == true &&
                                              context.mounted) {
                                            final jwt =
                                                await const FlutterSecureStorage()
                                                    .read(key: "jwt");
                                            if (jwt != null &&
                                                context.mounted) {
                                              context
                                                  .read<GroupBloc>()
                                                  .addPayExpense(
                                                    jwtToken: jwt,
                                                    sendedUserId: entry.userId,
                                                    groupId: group.id,
                                                  );

                                              // Bloc güncellenince snackbar göstermek için kısa gecikme
                                              await Future.delayed(
                                                const Duration(
                                                  milliseconds: 800,
                                                ),
                                              );

                                              final success = context
                                                  .read<GroupBloc>()
                                                  .state
                                                  .payExpenseFailOrSuccess
                                                  .getOrElse(() => false);

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    success
                                                        ? "Ödeme başarıyla kaydedildi."
                                                        : "Bir hata oluştu.",
                                                  ),
                                                  backgroundColor: success
                                                      ? Colors.green
                                                      : Colors.redAccent,
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: state.isPayingExpense
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        "Öde ${(entry.creditAmount - entry.debtAmount).toStringAsFixed(2)} ₺",
                                      ),
                              ),
                            ),

                          if ((entry.creditAmount - entry.debtAmount) > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "Toplam Alacak: +${(entry.creditAmount - entry.debtAmount).toStringAsFixed(2)} ₺",
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
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyCard() {
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

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.swap_horiz, color: Colors.green[600], size: 24),
    );
  }

  Widget _buildCopyableText(BuildContext context, String label, String value) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$label kopyalandı")));
      },
      child: Row(
        children: [
          Text("$label: "),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.copy, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}
