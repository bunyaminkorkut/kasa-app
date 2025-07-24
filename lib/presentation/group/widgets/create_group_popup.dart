import 'package:flutter/material.dart';

class CreateGroupDialog extends StatefulWidget {
  final void Function(String groupName) onCreate;

  const CreateGroupDialog({super.key, required this.onCreate});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Grup Oluştur'),
      content: SizedBox(
        child: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            labelText: 'Grup Adı',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            final groupName = _controller.text.trim();
            if (groupName.isNotEmpty) {
              widget.onCreate(groupName);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Oluştur'),
        ),
      ],
    );
  }
}
