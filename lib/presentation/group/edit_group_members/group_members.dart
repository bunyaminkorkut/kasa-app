import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasa_app/domain/group/group_data.dart';
import 'package:kasa_app/domain/group/request_data.dart';
import 'package:kasa_app/domain/group/sended_request_data.dart';
import 'package:kasa_app/domain/group/user_data.dart';

class EditGroupMembersPage extends StatefulWidget {
  final GroupData group;

  const EditGroupMembersPage({super.key, required this.group});

  @override
  State<EditGroupMembersPage> createState() => _EditGroupMembersPageState();
}

class _EditGroupMembersPageState extends State<EditGroupMembersPage> {
  late List<UserData> members;
  late List<GroupSendedRequestData> requests;
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    members = List.from(widget.group.members);
    requests = List.from(widget.group.pendingRequests);
  }

  void _removeMember(int index) {
    setState(() {
      members.removeAt(index);
    });
  }

  void _sendRequest(String email) {
    if (email.isEmpty) return;

  

  }

  void _saveChanges() {
    // TODO: Backend'e save işlemi yapılabilir
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Üyeleri Düzenle"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Üyeler",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...members.asMap().entries.map((entry) {
            final index = entry.key;
            final member = entry.value;
            final isCreator = member.id == widget.group.creator.id;

            return Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isCreator ? Colors.blue[100] : Colors.grey[300],
                    child: Icon(
                      isCreator ? Icons.admin_panel_settings : Icons.person_outline,
                      color: isCreator ? Colors.blue : Colors.black54,
                    ),
                  ),
                  title: Text(
                    member.fullname,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(member.email),
                  trailing: isCreator
                      ? const Text(
                          "Kurucu",
                          style: TextStyle(color: Colors.blue),
                        )
                      : IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeMember(index),
                        ),
                ),
                const Divider(),
              ],
            );
          }),
          const SizedBox(height: 24),

          // Yeni kullanıcı ekleme
          const Text(
            "Kullanıcı Davet Et",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: "Email adresi girin",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _sendRequest(_emailController.text),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  backgroundColor: Colors.blue[700],
                ),
                child: const Text("Gönder",
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pending Requests
          const Text(
            "Gönderilen Davetler",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...requests.map((request) {
            final formattedDate = "${request.requestDate}";
            return Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    child: Icon(Icons.email_outlined, color: Colors.white),
                  ),
                  title: Text(request.userName),
                  subtitle: Text("Gönderildi: ${DateFormat('dd MMMM yyyy').format(request.requestDate)}"),
                ),
                const Divider(),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
