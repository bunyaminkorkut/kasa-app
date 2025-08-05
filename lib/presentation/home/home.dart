import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kasa_app/application/group_bloc/group_bloc.dart';
import 'package:kasa_app/presentation/group/group_list.dart';
import 'package:kasa_app/presentation/notifications/notifications.dart';
import 'package:kasa_app/presentation/settings/settings.dart';
import 'package:kt_dart/collection.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: currentIndex);
  }

  void _onBottomNavigationBarTap(int index) {
    setState(() {
      currentIndex = index;
    });
    pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        children: const [
          GroupListPage(),
          NotificationsPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: BlocBuilder<GroupBloc, GroupState>(
        builder: (context, state) {
          int unreadRequestCount = 0;

          state.getGroupRequestsFailureOrRequests.fold(() {}, (either) {
            either.fold(
              (_) {},
              (requests) {
                unreadRequestCount = requests.filter((r) => r.status == "pending").size;
              },
            );
          });

          return BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: _onBottomNavigationBarTap,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.group),
                label: 'Gruplar',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications),
                    if (unreadRequestCount > 0)
                      Positioned(
                        right: -6,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadRequestCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Bildirimler',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Ayarlar',
              ),
            ],
          );
        },
      ),
    );
  }
}
