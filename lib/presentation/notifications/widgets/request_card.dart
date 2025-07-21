import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasa_app/domain/group/request_data.dart';

class GroupRequestCard extends StatelessWidget {
  final GroupRequestData request;
  final void Function()? onAccept;
  final void Function()? onReject;

  const GroupRequestCard({
    super.key,
    required this.request,
    this.onAccept,
    this.onReject,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('dd.MM.yyyy').format(request.requestDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _statusColor(request.status),
              child: Icon(
                request.status.toLowerCase() == 'accepted'
                    ? Icons.check
                    : request.status.toLowerCase() == 'rejected'
                        ? Icons.close
                        : Icons.hourglass_top,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.groupName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Talep Durumu: ${request.status[0].toUpperCase()}${request.status.substring(1)}\n'
                    'Talep Tarihi: $dateFormatted',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            if (request.status.toLowerCase() == 'pending')
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(80, 36),
                    ),
                    child: const Text('Accept'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: onReject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(80, 36),
                    ),
                    child: const Text('Reject'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
