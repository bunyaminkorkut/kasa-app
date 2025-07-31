import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kasa_app/domain/group/group_data.dart';
import 'package:kasa_app/presentation/group/add_expense_page/add_expense_page.dart';
import 'package:kasa_app/presentation/group/edit_group_members/group_members.dart';
import 'package:kasa_app/application/group_bloc/group_bloc.dart';
import 'package:kasa_app/presentation/group/group_details/widgets/group_checkout_card.dart';
import 'package:kasa_app/presentation/group/group_details/widgets/group_expense_card.dart';
import 'package:kasa_app/presentation/group/group_details/widgets/group_members_card.dart';

class GroupDetailsPage extends StatelessWidget {
  final int groupId;

  const GroupDetailsPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        return state.getGroupsFailureOrGroups.fold(
          () => const Center(child: CircularProgressIndicator()),
          (either) => either.fold(
            (failure) => Center(child: Text('Grup yüklenirken hata oluştu')),
            (groups) {
              final group = groups.asList().firstWhere((g) => g.id == groupId);

              if (group == null) {
                return const Center(child: Text('Grup bulunamadı'));
              }

              return Scaffold(
                backgroundColor: Colors.grey[50],
                appBar: AppBar(
                  title: Text(
                    group.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shadowColor: Colors.black12,
                  surfaceTintColor: Colors.transparent,
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGroupInfoCard(group),
                      const SizedBox(height: 20),
                      GroupMembersCard(group: group),
                      const SizedBox(height: 20),
                      GroupExpensesCard(group: group),
                      const SizedBox(height: 20),
                      GroupCheckoutCard(group: group),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateExpensePage(group: group),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Gider Oluştur",
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.blue[600],
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endFloat,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGroupInfoCard(GroupData group) {
    final formattedDate = DateFormat('dd MMMM yyyy').format(group.createdDate);
    final totalExpense = group.expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  "Grup Bilgileri",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildInfoRow(
              Icons.person_outline,
              "Kurucu",
              group.creator.fullname,
              group.creator.email,
            ),
            const SizedBox(height: 16),

            _buildInfoRow(
              Icons.calendar_today_outlined,
              "Oluşturulma",
              formattedDate,
            ),
            const SizedBox(height: 16),

            _buildInfoRow(
              Icons.receipt_long_outlined,
              "Toplam Harcama",
              "${totalExpense.toStringAsFixed(2)} ₺",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, [
    String? subtitle,
  ]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Icon(icon, size: 20, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
