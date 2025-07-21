import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasa_app/application/group_bloc/group_bloc.dart';
import 'package:kasa_app/presentation/notifications/widgets/request_card.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadNotifications() async {
    final jwt = await secureStorage.read(key: 'jwt');
    if (jwt != null && jwt.isNotEmpty) {
      context.read<GroupBloc>().addFetchGroupRequests(jwtToken: jwt);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No JWT found')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  Future<void> _refreshNotifications() async {
    await _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        child: BlocBuilder<GroupBloc, GroupState>(
          builder: (context, state) {
            if (state.isFetchingData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.getGroupRequestsFailureOrRequests.isSome()) {
              return state.getGroupRequestsFailureOrRequests.fold(
                () => const SizedBox.shrink(),
                (either) => either.fold(
                  (failure) =>
                      Center(child: Text('Error: ${failure.toString()}')),
                  (requests) {
                    if (requests.isEmpty()) {
                      return const Center(child: Text('No group requests found'));
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: requests.size,
                      itemBuilder: (context, index) {
                        final req = requests[index];
                        return GroupRequestCard(request: req);
                      },
                    );
                  },
                ),
              );
            }

            return const Center(child: Text('No data'));
          },
        ),
      ),
    );
  }
}
