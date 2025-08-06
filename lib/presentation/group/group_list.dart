import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kasa_app/application/group_bloc/group_bloc.dart';
import 'package:kasa_app/domain/ad/ad.dart';
import 'package:kasa_app/presentation/group/widgets/create_group_popup.dart';
import 'package:kasa_app/presentation/group/widgets/group_card.dart';
import 'package:kt_dart/collection.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<void> _refreshGroups(BuildContext context) async {
    final jwt = await secureStorage.read(key: 'jwt');
    if (jwt != null && jwt.isNotEmpty) {
      context.read<GroupBloc>().addFetchGroups(jwtToken: jwt);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No JWT found')));
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _showCreateGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CreateGroupDialog(
          onCreate: (groupName) async {
            final jwt = await secureStorage.read(key: 'jwt');
            if (jwt != null && jwt.isNotEmpty) {
              context.read<GroupBloc>().addCreateGroup(
                jwtToken: jwt,
                groupName: groupName,
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupBloc, GroupState>(
      listenWhen: (previous, current) =>
          previous.createGroupFailOrSuccess != current.createGroupFailOrSuccess,
      listener: (context, state) async {
        state.createGroupFailOrSuccess?.fold(() {}, (success) async {
          if (success) {
            Container(
              alignment: Alignment.center,
              width: KasaBannerAd().bannerAd.size.width.toDouble(),
              height: KasaBannerAd().bannerAd.size.height.toDouble(),
              child: AdWidget(ad: KasaBannerAd().bannerAd),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Grup başarıyla oluşturuldu')),
            );
          } else {
            Container(
              alignment: Alignment.center,
              width: KasaBannerAd().bannerAd.size.width.toDouble(),
              height: KasaBannerAd().bannerAd.size.height.toDouble(),
              child: AdWidget(ad: KasaBannerAd().bannerAd),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Grup oluşturulamadı')),
            );
          }
        });
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Gruplarım')),
        body: RefreshIndicator(
          onRefresh: () => _refreshGroups(context),
          child: BlocBuilder<GroupBloc, GroupState>(
            builder: (context, state) {
              if (state.isFetchingData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.getGroupsFailureOrGroups.isSome()) {
                return state.getGroupsFailureOrGroups.fold(
                  () => const SizedBox.shrink(),
                  (either) => either.fold(
                    (failure) =>
                        Center(child: Text('Error: ${failure.toString()}')),
                    (groups) {
                      if (groups.isEmpty()) {
                        return const Center(child: Text('Grup bulunamadı'));
                      }

                      return Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            width: KasaBannerAd().bannerAd.size.width.toDouble(),
                            height: KasaBannerAd().bannerAd.size.height.toDouble(),
                            child: AdWidget(ad: KasaBannerAd().bannerAd),
                          ),
                          Expanded(
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: groups.size,
                              itemBuilder: (context, index) {
                                final group = groups[index];
                                return GroupCard(group: group);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              }

              return const Center(child: Text('No data'));
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateGroupDialog(context),
          backgroundColor: Colors.blue[600],
          child: const Icon(Icons.add, color: Colors.white),
          tooltip: 'Grup Oluştur',
        ),
      ),
    );
  }
}
