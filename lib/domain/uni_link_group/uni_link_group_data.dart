

import 'package:equatable/equatable.dart';
import 'package:kasa_app/domain/group/group_data.dart';
import 'package:kt_dart/collection.dart';

class UniLinkGroupData extends Equatable {
  final int newGroupId;
  final KtList<GroupData> groups;

  const UniLinkGroupData({
    required this.newGroupId,
    required this.groups,
  });

  factory UniLinkGroupData.fromMap(Map<String, dynamic> map) {
    return UniLinkGroupData(
      newGroupId: map['new_group_id'],
      groups: KtList.from(
        (map['groups'] as List<dynamic>).map((group) => GroupData.fromMap(group)),
      ),
    );
  }

  @override
  List<Object> get props => [newGroupId, groups];

  @override
  String toString() {
    return 'UniLinkGroupData(newGroupId: $newGroupId, groups: $groups)';
  }
}
