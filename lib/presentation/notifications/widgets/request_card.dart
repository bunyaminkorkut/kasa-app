import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:kasa_app/application/group_bloc/group_bloc.dart';
import 'package:kasa_app/domain/group/request_data.dart';

class GroupRequestCard extends StatefulWidget {
  final GroupRequestData request;
  final bool isLoading;

  const GroupRequestCard({
    super.key,
    required this.request,
    this.isLoading = false,
  });

  @override
  State<GroupRequestCard> createState() => _GroupRequestCardState();
}

class _GroupRequestCardState extends State<GroupRequestCard> {
  late String _status;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _status = widget.request.status;
  }

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

  void handleAccept() async {
    final jwt = await secureStorage.read(key: 'jwt') ?? '';
    context.read<GroupBloc>().addSendAnswerRequest(
      jwtToken: jwt,
      requestId: widget.request.requestId, // veya uygun default
      isAccepting: true,
    );
  }

  void handleReject() async {
    final jwt = await secureStorage.read(key: 'jwt') ?? '';
    context.read<GroupBloc>().addSendAnswerRequest(
      jwtToken: jwt,
      requestId: widget.request.requestId, // veya uygun default
      isAccepting: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat(
      'dd.MM.yyyy',
    ).format(widget.request.requestDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _statusColor(_status),
              child: Icon(
                _status == 'accepted'
                    ? Icons.check
                    : _status == 'rejected'
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
                    widget.request.groupName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Talep Durumu: ${_status[0].toUpperCase()}${_status.substring(1)}\n'
                    'Talep Tarihi: $dateFormatted',
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            if (_status.toLowerCase() == 'pending')
              widget.isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: handleAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size(80, 36),
                          ),
                          child: const Text(
                            'Accept',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: handleReject,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(80, 36),
                          ),
                          child: const Text(
                            'Reject',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
          ],
        ),
      ),
    );
  }
}
