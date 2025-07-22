import 'package:flutter/material.dart';
import 'package:kasa_app/domain/group/group_data.dart';
import 'package:intl/intl.dart';
import 'package:kasa_app/presentation/group/edit_group_members/group_members.dart';
import 'package:kasa_app/presentation/group/group_details/group_details_page.dart';

class GroupCard extends StatelessWidget {
  final GroupData group;

  const GroupCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd.MM.yyyy').format(group.createdDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          group.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Oluşturulma tarihi: $formattedDate',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        leading: const Icon(Icons.group, size: 32, color: Colors.blue),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupDetailsPage(groupId: group.id),
            ),
          );
        },
      ),
    );
  }
}
