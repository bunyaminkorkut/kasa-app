import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kasa_app/application/group_bloc/group_bloc.dart';
import 'package:kasa_app/presentation/group/widgets/group_card.dart';
import 'package:kasa_app/presentation/notifications/widgets/request_card.dart';
import 'package:kt_dart/collection.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<void> _refreshNotifications(BuildContext context) async {
    final jwt = await secureStorage.read(key: 'jwt');
    if (jwt != null && jwt.isNotEmpty) {
      context.read<GroupBloc>().addFetchGroupRequests(jwtToken: jwt);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No JWT found')));
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: RefreshIndicator(
        onRefresh: () => _refreshNotifications(context),
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
                      return const Center(child: Text('No groups found'));
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(), // zorunlu
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
