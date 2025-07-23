import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kasa_app/domain/group/group_data.dart';
import 'package:kasa_app/presentation/group/add_expense_page/add_expense_page.dart';
import 'package:kasa_app/presentation/group/edit_group_members/group_members.dart';
import 'package:kasa_app/application/group_bloc/group_bloc.dart';

class GroupDetailsPage extends StatelessWidget {
  final int groupId;

  const GroupDetailsPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        // Grup listesi başarıyla yüklendi mi?
        return state.getGroupsFailureOrGroups.fold(
          // Veri yoksa yükleniyor ya da hata varsa mesaj göster
          () => const Center(child: CircularProgressIndicator()),
          (either) => either.fold(
            (failure) => Center(child: Text('Grup yüklenirken hata oluştu')),
            (groups) {
              // groupId'ye göre grup bulunuyor
              final group = groups.asList().firstWhere((g) => g.id == groupId);

              if (group == null) {
                return const Center(child: Text('Grup bulunamadı'));
              }

              // Grup bulunduysa detay sayfasını göster
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
                      _buildMembersCard(context, group),
                      const SizedBox(height: 20),
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
                  icon: const Icon(Icons.add),
                  label: const Text("Gider Oluştur"),
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
              null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    String? subtitle,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
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

  Widget _buildMembersCard(BuildContext context, GroupData group) {
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
            tilePadding: const EdgeInsets.all(12.0),
            childrenPadding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 20,
            ),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.people_outline,
                color: Colors.green[600],
                size: 24,
              ),
            ),
            title: Row(
              children: [
                Text(
                  "Üyeler (${group.members.length})",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                if (group.isAdmin)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditGroupMembersPage(group: group),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.settings,
                                size: 16,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Düzenle",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            children: [
              ...group.members.asMap().entries.map((entry) {
                final index = entry.key;
                final member = entry.value;
                final isCreator = member.id == group.creator.id;
                final isLast = index == group.members.length - 1;

                return Column(
                  children: [
                    _buildMemberTile(member, isCreator),
                    if (!isLast) const Divider(height: 8, thickness: 0.5),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemberTile(dynamic member, bool isCreator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isCreator ? Colors.blue[100] : Colors.grey[200],
            child: Icon(
              isCreator ? Icons.admin_panel_settings : Icons.person,
              color: isCreator ? Colors.blue[700] : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      member.fullname,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (isCreator) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Admin",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  member.email,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
