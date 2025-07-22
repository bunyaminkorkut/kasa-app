import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:kasa_app/application/group_bloc/group_bloc.dart';
import 'package:kasa_app/domain/group/group_data.dart';
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

  void _sendRequest(String email) async {
    if (email.isEmpty) return;

    final FlutterSecureStorage secureStorage = FlutterSecureStorage();
    final jwt = await secureStorage.read(key: 'jwt');

    if (jwt == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("JWT bulunamadı")));
      return;
    }

    context.read<GroupBloc>().addSendAddRequest(
      jwtToken: jwt,
      groupId: widget.group.id,
      userEmail: email,
    );

    _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupBloc, GroupState>(
      listenWhen: (prev, curr) {
        print(
          "Prev: ${prev.sendingAddGroupReq}, Curr: ${curr.sendingAddGroupReq}",
        );
        return prev.sendingAddGroupReq != curr.sendingAddGroupReq;
      },

      listener: (context, state) {
        print("asdasd");
        final result = state.sendAddGroupReqFailureOrRequests;
        result.fold(() {}, (success) {
          if (success) {
            state.getGroupsFailureOrGroups.fold(
              () {},
              (either) => either.fold((_) {}, (groups) {
                final updatedGroup = groups.asList().firstWhere(
                  (g) => g.id == widget.group.id,
                  orElse: () => widget.group,
                );
                setState(() {
                  members = updatedGroup.members.toList();
                  requests = updatedGroup.pendingRequests.toList();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Davet başarıyla gönderildi")),
                );
              }),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red, // Kırmızı arka plan
                content: Text(
                  state.sendAddGroupReqErrorMessage ?? "Davet gönderilemedi",
                  style: const TextStyle(color: Colors.white), // Beyaz yazı
                ),
              ),
            );
          }
        });
      },
      child: Scaffold(
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
                      backgroundColor: isCreator
                          ? Colors.blue[100]
                          : Colors.grey[300],
                      child: Icon(
                        isCreator
                            ? Icons.admin_panel_settings
                            : Icons.person_outline,
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
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
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
                  onPressed:
                      context.select<GroupBloc, bool>(
                        (bloc) => bloc.state.sendingAddGroupReq,
                      )
                      ? null
                      : () => _sendRequest(_emailController.text),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    backgroundColor: Colors.blue[700],
                  ),
                  child: BlocBuilder<GroupBloc, GroupState>(
                    builder: (context, state) => state.sendingAddGroupReq
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Gönder",
                            style: TextStyle(color: Colors.white),
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
              final formattedDate = DateFormat(
                'dd MMMM yyyy',
              ).format(request.requestDate);
              return Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orangeAccent,
                      child: Icon(Icons.email_outlined, color: Colors.white),
                    ),
                    title: Text(request.userName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.email),
                        Text(
                          "Gönderildi: $formattedDate",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
