
import 'package:flutter/material.dart';
import 'package:kasa_app/presentation/group/group_list.dart';

class GroupUniLink extends StatefulWidget {
  final String groupToken;

  const GroupUniLink({Key? key, required this.groupToken}) : super(key: key);

  @override
  _GroupUniLinkState createState() => _GroupUniLinkState();
}

class _GroupUniLinkState extends State<GroupUniLink> {
  @override
  void initState() {
    super.initState();
    print('Group Token: ${widget.groupToken}');
  }

  @override
  Widget build(BuildContext context) {
    return GroupListPage(
    );
  }
}
